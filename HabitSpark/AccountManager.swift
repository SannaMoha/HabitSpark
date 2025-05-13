//
import Foundation

class AccountManager: ObservableObject {
    @Published var currentUser: User? = nil

    static let shared = AccountManager()
    private init() {}
}
