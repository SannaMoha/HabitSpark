import SwiftUI
import CoreData

struct AccountCreationView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var showMainApp = false

    var body: some View {
        if showMainApp {
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
                    Text("Create Account")
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

                    Button("Create Account") {
                        createAccount()
                    }
                    .padding()
                    .background(Color(hex: "#D5F0C1"))
                    .cornerRadius(10)
                }
                .padding()
            }
        }
    }

    private func createAccount() {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "username == %@", username)

        do {
            let result = try viewContext.fetch(fetchRequest)
            if !result.isEmpty {
                errorMessage = "Username already exists"
                return
            }

            let newUser = User(context: viewContext)
            newUser.username = username
            newUser.password = password
            try viewContext.save()

            AccountManager.shared.currentUser = newUser
            showMainApp = true
        } catch {
            errorMessage = "Account creation failed"
        }
    }
}
