import SwiftUI

struct AccountInfoView: View {
    @Environment(\.dismiss) var dismiss

    var user: User? {
        AccountManager.shared.currentUser
    }

    var body: some View {
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

            VStack(spacing: 30) {
                Text("My Account")
                    .font(.title2)
                    .foregroundColor(.purple)

                VStack(spacing: 10) {
                    Text("👤 Username:")
                        .font(.headline)

                    Text(user?.username ?? "N/A")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "#D5F0C1"), lineWidth: 2)
                )

                Button("Log Out") {
                    AccountManager.shared.currentUser = nil
                    dismiss()
                }
                .foregroundColor(.red)

                Spacer()
            }
            .padding()
            .navigationTitle("Account")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}
