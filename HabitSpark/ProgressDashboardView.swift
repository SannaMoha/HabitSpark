import SwiftUI
import CoreData

struct ProgressDashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(entity: HabitCompletion.entity(), sortDescriptors: [
        NSSortDescriptor(keyPath: \HabitCompletion.date, ascending: false)
    ])
    private var completions: FetchedResults<HabitCompletion>

    var grouped: [String: [HabitCompletion]] {
        Dictionary(grouping: completions) {
            $0.habit?.category ?? "Uncategorized"
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(grouped.keys.sorted(), id: \.self) { category in
                    Section(header: Text(category.uppercased())
                        .font(.headline)
                        .foregroundColor(Color("PastelRed"))) {
                        ForEach(grouped[category] ?? [], id: \.self) { completion in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(completion.habit?.name ?? "Unknown Habit")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                if let date = completion.date {
                                    Text(date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(8)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color("PastelGreen"), lineWidth: 1)
                            )
                        }
                    }
                }

                if !completions.isEmpty {
                    Button("🗑️ Clear All History") {
                        for c in completions {
                            viewContext.delete(c)
                        }
                        saveContext()
                    }
                    .foregroundColor(.red)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Completed Habits")
            .background(
                LinearGradient(colors: [
                    Color("PastelPink").opacity(0.1),
                    Color("PastelYellow").opacity(0.1)
                ], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true)
                    }
                }
            }
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
