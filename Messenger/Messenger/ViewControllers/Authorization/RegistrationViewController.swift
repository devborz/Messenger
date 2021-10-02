//
//  RegistrationViewController.swift
//  Messenger
//
//  Created by Усман Туркаев on 20.08.2021.
//

import UIKit
import Firebase

class RegistrationViewController: UIViewController {
    
    let usernameTextField = UITextField()

    let emailTextField = UITextField()
    
    let passwordTextField = UITextField()
    
    let password2TextField = UITextField()
    
    let registerButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Register"
        navigationItem.largeTitleDisplayMode = .always
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(usernameTextField)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(password2TextField)
        view.addSubview(registerButton)
        
        usernameTextField.frame = CGRect(x: 20, y: view.frame.height / 2 - 150, width: view.frame.width - 40, height: 40)
        emailTextField.frame = CGRect(x: 20, y: usernameTextField.bottom + 20, width: view.frame.width - 40, height: 40)
        passwordTextField.frame = CGRect(x: 20, y: emailTextField.bottom + 20, width: view.frame.width - 40, height: 40)
        password2TextField.frame = CGRect(x: 20, y: passwordTextField.bottom + 20, width: view.frame.width - 40, height: 40)
        registerButton.frame = CGRect(x: 20, y: password2TextField.bottom + 20, width: view.frame.width - 40, height: 50)
        
        
        usernameTextField.backgroundColor = .secondarySystemBackground
        usernameTextField.placeholder = "Username"
        usernameTextField.borderStyle = .roundedRect
        usernameTextField.keyboardType = .asciiCapable
        usernameTextField.autocorrectionType = .no
        usernameTextField.autocapitalizationType = .none
        
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
        
        password2TextField.backgroundColor = .secondarySystemBackground
        password2TextField.placeholder = "Password"
        password2TextField.borderStyle = .roundedRect
        password2TextField.isSecureTextEntry = true
        password2TextField.autocorrectionType = .no
        password2TextField.autocapitalizationType = .none
        
        registerButton.backgroundColor = .systemBlue
        registerButton.setTitle("Create account", for: .normal)
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        registerButton.setTitleColor(.lightGray, for: .highlighted)
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        registerButton.layer.cornerRadius = 10
        registerButton.clipsToBounds = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(gesture)
    }
    
    @objc
    func viewTapped() {
        usernameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        password2TextField.resignFirstResponder()
    }
    
    @objc
    func registerButtonTapped() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let password2 = password2TextField.text,
              let username = usernameTextField.text else { return }
        
        guard !email.isEmpty && !password.isEmpty
                && !password2.isEmpty && !username.isEmpty else { return }
        
        guard password == password2 else { return }
    
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            guard error == nil else { return }
            
            guard let id = DatabaseManager.shared.currentUserID else { return }
            
            DatabaseManager.shared.createUser(username, id: id) { error in
                guard error == nil else { return }
                
                let vc = ChatsListController()
                let navigationController = UINavigationController(rootViewController: vc)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: true, completion: nil)
            }
        }
    }
}
