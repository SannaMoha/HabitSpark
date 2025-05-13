import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default
    ) private var items: FetchedResults<Item>

    @FetchRequest(
        entity: HabitCompletion.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \HabitCompletion.date, ascending: false)]
    )
    private var completions: FetchedResults<HabitCompletion>

    @State private var showingAddHabit = false
    @State private var showingDashboard = false
    @State private var showingAccount = false
    @State private var selectedHabit: Item?
    @State private var showingMoodPrompt = false
    @State private var moodResponse: String = ""

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#FFD6E8"),
                        Color(hex: "#FFFFC2"),
                        Color(hex: "#D5F0C1")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    PetCompanionView()

                    List {
                        ForEach(groupedItems.keys.sorted(), id: \.self) { category in
                            Section(header: Text(category.uppercased())
                                .font(.headline)
                                .foregroundColor(Color(hex: "#FFABAB"))) {
                                ForEach(groupedItems[category] ?? []) { item in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.name ?? "Untitled")
                                                .font(.headline)
                                                .foregroundColor(.black)

                                            if let completions = item.completions as? Set<HabitCompletion>,
                                               let latestMood = completions.sorted(by: { $0.date ?? Date() > $1.date ?? Date() }).first?.mood,
                                               !latestMood.isEmpty {
                                                Text("Last mood: \(latestMood)")
                                                    .font(.caption2)
                                                    .foregroundColor(.teal)
                                            }

                                            if let timestamp = item.timestamp {
                                                Text("Added: \(timestamp.formatted(date: .abbreviated, time: .shortened))")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                        }

                                        Spacer()

                                        Button(action: {
                                            markHabitCompletedToday(for: item)
                                            selectedHabit = item
                                            showingMoodPrompt = true
                                        }) {
                                            Image(systemName: hasCompletedToday(item) ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(hasCompletedToday(item) ? .green : .gray)
                                                .font(.title2)
                                        }
                                    }
                                    .padding()
                                    .background(Color(hex: "#D5F0C1").opacity(0.2))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(hex: "#D5F0C1"), lineWidth: 2)
                                    )
                                    .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
                                }
                                .onDelete(perform: deleteItems)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("HabitSpark")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { showingDashboard = true }) {
                        Image(systemName: "list.bullet.rectangle.fill")
                    }
                    Button(action: { showingAddHabit = true }) {
                        Image(systemName: "plus.circle.fill")
                    }
                    Button(action: { showingAccount = true }) {
                        Image(systemName: "person.crop.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView().environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $showingDashboard) {
                ProgressDashboardView().environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $showingAccount) {
                AccountInfoView()
            }
            .alert("How did you feel after completing this habit?", isPresented: $showingMoodPrompt, actions: {
                TextField("Happy, tired, focused…", text: $moodResponse)
                Button("Save", role: .cancel) {
                    if let selected = selectedHabit {
                        saveMood(for: selected)
                    }
                    moodResponse = ""
                }
            })
        }
    }

    private var groupedItems: [String: [Item]] {
        let currentUser = AccountManager.shared.currentUser
        return Dictionary(grouping: items.filter { $0.user == currentUser }) {
            $0.category ?? "Uncategorized"
        }
    }

    private func hasCompletedToday(_ item: Item) -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return item.completions?.contains(where: {
            guard let completion = $0 as? HabitCompletion else { return false }
            return Calendar.current.isDate(completion.date ?? Date(), inSameDayAs: today)
        }) ?? false
    }

    private func markHabitCompletedToday(for item: Item) {
        guard !hasCompletedToday(item) else { return }

        let completion = HabitCompletion(context: viewContext)
        completion.date = Date()
        completion.habit = item
        saveContext()
    }

    private func saveMood(for item: Item) {
        let today = Calendar.current.startOfDay(for: Date())
        if let completions = item.completions as? Set<HabitCompletion>,
           let todayCompletion = completions.first(where: {
               guard let date = $0.date else { return false }
               return Calendar.current.isDate(date, inSameDayAs: today)
           }) {
            todayCompletion.mood = moodResponse.trimmingCharacters(in: .whitespaces)
            saveContext()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            saveContext()
        }
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 1)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}
