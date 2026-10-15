import Foundation

// The property names are the same as the keys in the Firebase JSON response
struct User: Codable {
    let localId: String
    let email: String
    let displayName: String
    let idToken: String
    let registered: Bool
    let refreshToken: String
}
