import SwiftUI

struct RootView: View {
    @ObservedObject var accountManager = AccountManager.shared

    var body: some View {
        if accountManager.currentUser != nil {
            ContentView()
        } else {
            NavigationView {
                AccountLoginView()
            }
        }
    }
}
