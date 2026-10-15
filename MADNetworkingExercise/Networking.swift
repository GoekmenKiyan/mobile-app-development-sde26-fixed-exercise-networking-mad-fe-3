import Foundation

final class Networking {
    private let apiKey = "AIzaSyDeLs8S6Hpy642JUPC3Pft-xVx8Ocs-uXY"
    private let session = URLSession(configuration: .default)

    func login(
        email: String,
        password: String,
        completionHandler: @escaping (User?, NetworkingError?) -> Void
    ) {
        // Helper func
        func finish(user: User?, error: NetworkingError?) {
            DispatchQueue.main.async {
                completionHandler(user, error)
            }
        }

        let endpoint = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=\(apiKey)"

        guard let url = URL(string: endpoint) else {
            finish(user: nil, error: .unexpectedError("The login URL is invalid."))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let dictionary: [String: Any] = [
            "email": email,
            "password": password,
            "returnSecureToken": true
        ]

        do {
            request.httpBody = try JSONSerialization.data(
                withJSONObject: dictionary,
                options: []
            )
        } catch {
            finish(user: nil, error: .serializationError(error.localizedDescription))
            return
        }

        let task = session.dataTask(with: request) { data, response, error in
            if let error = error as NSError? {
                let offlineCodes = [
                    NSURLErrorNotConnectedToInternet,
                    NSURLErrorNetworkConnectionLost,
                    NSURLErrorDataNotAllowed
                ]

                if offlineCodes.contains(error.code) {
                    finish(user: nil, error: .networkOffline(error.localizedDescription))
                } else {
                    finish(user: nil, error: .unexpectedError(error.localizedDescription))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                finish(user: nil, error: .invalidResponseData)
                return
            }

            let decoder = JSONDecoder()

            if (200...299).contains(httpResponse.statusCode) {
                guard let data = data else {
                    finish(user: nil, error: .invalidResponseData)
                    return
                }

                do {
                    let user = try decoder.decode(User.self, from: data)
                    print(user)
                    finish(user: user, error: nil)
                } catch {
                    print("Could not decode user:", error)
                    finish(user: nil, error: .invalidResponseData)
                }
                return
            }

            guard let data = data else {
                finish(
                    user: nil,
                    error: .unsuccessfulResponse(httpResponse.statusCode)
                )
                return
            }

            // Failed Firebase request has different JSON structure
            do {
                let responseError = try decoder.decode(ResponseError.self, from: data)
                let message = responseError.details.message

                switch message {
                case "INVALID_EMAIL":
                    finish(user: nil, error: .invalidEmail)
                case "EMAIL_NOT_FOUND":
                    finish(user: nil, error: .wrongEmail)
                case "INVALID_PASSWORD", "INVALID_LOGIN_CREDENTIALS":
                    finish(user: nil, error: .wrongPassword)
                default:
                    finish(
                        user: nil,
                        error: .unsuccessfulResponse(httpResponse.statusCode)
                    )
                }
            } catch {
                print("Could not decode Firebase error:", error)
                finish(
                    user: nil,
                    error: .unsuccessfulResponse(httpResponse.statusCode)
                )
            }
        }

        task.resume()
    }
}
