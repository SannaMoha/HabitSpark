import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @State private var name: String = ""
    @State private var category: String = "Wellness"
    @State private var stackAfter: String = ""

    let categories = ["Wellness", "Focus", "Creativity", "Self-Care", "Productivity"]
    let exampleHabits = [
        "Wellness": ["Stretch for 5 minutes", "Drink a full glass of water", "Go for a short walk"],
        "Focus": ["Review to-do list", "Write in planner", "Brain dump for 5 min"],
        "Creativity": ["Sketch something small", "Free write 3 lines", "Doodle while listening to music"],
        "Self-Care": ["Take 3 deep breaths", "Moisturize face", "Put phone down for 10 minutes"],
        "Productivity": ["Clear your desk", "Write one task", "Start a 25-min Pomodoro"]
    ]

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#FFD6E8"), Color(hex: "#FFFFC2"), Color(hex: "#D5F0C1")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                Form {
                    Section(header: Text("Habit Name")) {
                        TextField("e.g. Drink water", text: $name)
                    }

                    Section(header: Text("Category")) {
                        Picker("Category", selection: $category) {
                            ForEach(categories, id: \.self) { cat in
                                Text(cat)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }

                    Section(header: Text("Stack After (Optional)")) {
                        TextField("e.g. After brushing teeth", text: $stackAfter)
                    }
                }
            }
            .navigationTitle("New Habit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let user = AccountManager.shared.currentUser {
                            let newHabit = Item(context: viewContext)
                            newHabit.name = name
                            newHabit.timestamp = Date()
                            newHabit.category = category
                            newHabit.stackAfter = stackAfter
                            newHabit.user = user  // 💡 this is the fix
                            saveContext()
                        }
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
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
