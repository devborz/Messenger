//
//  LoginViewController.swift
//  Messenger
//
//  Created by Усман Туркаев on 20.08.2021.
//

import UIKit
import FirebaseAuth

extension UIView {
    
    var bottom: CGFloat {
        return frame.maxY
    }
}

class LoginViewController: UIViewController {
    
    let emailTextField = UITextField()
    
    let passwordTextField = UITextField()
    
    let loginButton = UIButton()
    
    var registerItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Login"
        navigationItem.largeTitleDisplayMode = .always
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        
        emailTextField.frame = CGRect(x: 20, y: view.frame.height / 2 - 50, width: view.frame.width - 40, height: 40)
        passwordTextField.frame = CGRect(x: 20, y: emailTextField.bottom + 20, width: view.frame.width - 40, height: 40)
        loginButton.frame = CGRect(x: 20, y: passwordTextField.bottom + 20, width: view.frame.width - 40, height: 50)
        
        emailTextField.backgroundColor = .secondarySystemBackground
        emailTextField.placeholder = "Email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocorrectionType = .no
        emailTextField.autocapitalizationType = .none
    
        passwordTextField.backgroundColor = .secondarySystemBackground
        passwordTextField.placeholder = "Password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocorrectionType = .no
        passwordTextField.autocapitalizationType = .none
        
        
        loginButton.backgroundColor = .systemBlue
        loginButton.setTitle("Login", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        loginButton.setTitleColor(.lightGray, for: .highlighted)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        loginButton.layer.cornerRadius = 10
        loginButton.clipsToBounds = true
        
        registerItem = .init(title: "Register", style: .plain, target: self, action: #selector(registerButtonTapped))
        navigationItem.rightBarButtonItem = registerItem
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(gesture)
    }
    
    @objc
    func viewTapped() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @objc
    func registerButtonTapped() {
        let vc = RegistrationViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    func loginButtonTapped() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else { return }
        
        guard !email.isEmpty && !password.isEmpty else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            guard error == nil else { return }
            
            let vc = ChatsListController()
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true, completion: nil)
        }
    }

}
