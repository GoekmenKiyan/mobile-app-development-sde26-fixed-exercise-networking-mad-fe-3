import UIKit

final class ViewController: UIViewController {
    private let networking = Networking()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Firebase Login"
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.textAlignment = .center
        return label
    }()

    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.text = "mad-fe@mad.at"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.textContentType = .username
        return textField
    }()

    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.text = "madmad"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.textContentType = .password
        return textField
    }()

    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.title = "Login"
        button.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
        return button
    }()

    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
    }

    private func setupLayout() {
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            emailTextField,
            passwordTextField,
            loginButton,
            activityIndicator
        ])

        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            loginButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func loginButtonPressed() {
        view.endEditing(true)

        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        setLoading(true)

        networking.login(email: email, password: password) { [weak self] user, error in
            guard let self = self else { return }

            self.setLoading(false)

            if let user = user {
                self.showAlert(
                    title: "Login successful",
                    message: "Welcome, \(user.email)!"
                )
                return
            }

            if let error = error {
                self.showAlert(
                    title: "Login failed",
                    message: self.message(for: error)
                )
            }
        }
    }

    private func setLoading(_ isLoading: Bool) {
        loginButton.isEnabled = !isLoading
        emailTextField.isEnabled = !isLoading
        passwordTextField.isEnabled = !isLoading

        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    private func message(for error: NetworkingError) -> String {
        switch error {
        case .serializationError(let message):
            return "The login data could not be prepared. \(message)"
        case .invalidEmail:
            return "Please enter a valid email address."
        case .wrongEmail:
            return "No account exists for this email address."
        case .wrongPassword:
            return "The password is incorrect."
        case .networkOffline(let message):
            return "The network is offline. \(message)"
        case .invalidResponseData:
            return "The server returned data in an unexpected format."
        case .unsuccessfulResponse(let statusCode):
            return "The server returned an error (HTTP \(statusCode))."
        case .unexpectedError(let message):
            return "An unexpected error occurred. \(message)"
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
