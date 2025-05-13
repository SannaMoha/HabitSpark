import SwiftUI
import CoreData

struct AccountLoginView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var showMainApp = false

    var body: some View {
        if showMainApp, let _ = AccountManager.shared.currentUser {
            ContentView()
                .environment(\.managedObjectContext, viewContext)
        } else {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#FFD6E8"), Color(hex: "#FFFFC2"), Color(hex: "#D5F0C1")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("HabitSpark Login")
                        .font(.largeTitle)
                        .foregroundColor(.purple)

                    TextField("Username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)

                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    Button("Login") {
                        login()
                    }
                    .padding()
                    .background(Color(hex: "#D5F0C1"))
                    .cornerRadius(10)

                    NavigationLink("Create Account", destination: AccountCreationView())
                }
                .padding()
            }
        }
    }

    private func login() {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "username == %@ AND password == %@", username, password)

        do {
            let result = try viewContext.fetch(fetchRequest)
            if let user = result.first {
                AccountManager.shared.currentUser = user
                showMainApp = true
            } else {
                errorMessage = "Invalid credentials"
            }
        } catch {
            errorMessage = "Login failed"
        }
    }
}
