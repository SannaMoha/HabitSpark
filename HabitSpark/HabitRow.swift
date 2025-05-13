//
//  HabitRow.swift
//  HabitSpark
import SwiftUI
import CoreData

struct HabitRow: View {
    let item: Item
    let markCompleted: () -> Void
    let latestMood: String?
    let streak: Int
    let isComplete: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name ?? "Untitled")
                    .font(.headline)
                    .foregroundColor(.purple)

                Text("Streak: \(streak) days")
                    .font(.caption)
                    .foregroundColor(.gray)

                if let mood = latestMood, !mood.isEmpty {
                    Text("Last mood: \(mood)")
                        .font(.caption2)
                        .foregroundColor(.teal)
                }
            }

            Spacer()

            Button(action: markCompleted) {
                Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isComplete ? .green : .gray)
                    .font(.title2)
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(15)
        .shadow(color: .purple.opacity(0.15), radius: 4, x: 0, y: 2)
    }
}

