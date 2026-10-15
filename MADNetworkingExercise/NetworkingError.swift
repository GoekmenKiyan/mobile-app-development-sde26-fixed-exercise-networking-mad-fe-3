import Foundation

enum NetworkingError: Error {
    case serializationError(String)
    case invalidEmail
    case wrongEmail
    case wrongPassword
    case networkOffline(String)
    case invalidResponseData
    case unsuccessfulResponse(Int)
    case unexpectedError(String)
}

// Firebase wraps its error information in an object called "error"
struct ResponseError: Codable {
    let details: ResponseErrorDetails

    enum CodingKeys: String, CodingKey {
        case details = "error"
    }
}

struct ResponseErrorDetails: Codable {
    let code: Int
    let message: String
    let errors: [ResponseErrorItem]?
}

struct ResponseErrorItem: Codable {
    let message: String
    let domain: String
    let reason: String
}
