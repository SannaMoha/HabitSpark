import SwiftUI
import CoreData

struct PetCompanionView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: HabitCompletion.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \HabitCompletion.date, ascending: false)]
    ) private var completions: FetchedResults<HabitCompletion>

    @State private var showStageInfo = false
    @State private var showEarnedHabits = false

    var body: some View {
        VStack(spacing: 8) {
            Text("Your Habit Buddy")
                .font(.headline)
                .padding(.top)

            Button(action: {
                showStageInfo = true
            }) {
                Text("Stage: \(petStage.label)")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .underline()
            }

            Button(action: {
                showEarnedHabits = true
            }) {
                Text("Habits Earned: \(completions.count)")
                    .font(.caption)
                    .foregroundColor(.teal)
                    .underline()
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.7))
        .cornerRadius(15)
        .padding(.horizontal)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        .sheet(isPresented: $showStageInfo) {
            StageInfoSheet()
        }
        .sheet(isPresented: $showEarnedHabits) {
            EarnedHabitsSheet(completions: completions)
        }
    }

    private var petStage: PetStage {
        switch completions.count {
        case 0...2: return .egg
        case 3...6: return .baby
        case 7...13: return .teen
        default: return .grown
        }
    }
}

struct EarnedHabitsSheet: View {
    let completions: FetchedResults<HabitCompletion>

    var grouped: [String: [HabitCompletion]] {
        Dictionary(grouping: completions) {
            $0.habit?.category ?? "Uncategorized"
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(grouped.keys.sorted(), id: \.self) { category in
                    Section(header: Text(category)) {
                        ForEach(grouped[category] ?? [], id: \.self) { completion in
                            VStack(alignment: .leading) {
                                Text(completion.habit?.name ?? "Unknown Habit")
                                    .font(.body)
                                if let date = completion.date {
                                    Text(date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Habits Earned")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true)
                    }
                }
            }
        }
    }
}

struct StageInfoSheet: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Habit Buddy Stages")
                    .font(.title2)
                    .padding(.top)

                VStack(alignment: .leading, spacing: 12) {
                    Text("🥚 **Egg** — 0–2 tasks earned\nJust getting started!")
                    Text("🌱 **Baby** — 3–6 tasks earned\nYour habit is sprouting!")
                    Text("🌼 **Teen** — 7–13 tasks earned\nIt’s growing strong!")
                    Text("✨ **Grown** — 14+ tasks earned\nYou’ve built a strong streak!")
                }
                .padding()
                .foregroundColor(.primary)

                Spacer()
            }
            .padding()
            .navigationTitle("Buddy Evolution Guide")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true)
                    }
                }
            }
        }
    }
}

enum PetStage {
    case egg, baby, teen, grown

    var label: String {
        switch self {
        case .egg: return "Egg 🥚"
        case .baby: return "Baby 🌱"
        case .teen: return "Teen 🌼"
        case .grown: return "Grown ✨"
        }
    }

    var color: Color {
        switch self {
        case .egg: return .gray
        case .baby: return .mint
        case .teen: return .purple
        case .grown: return .pink
        }
    }
}
