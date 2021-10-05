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
    
    let vStackView = UIStackView()
    
    var constraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Register"
        navigationItem.largeTitleDisplayMode = .always
        
        view.backgroundColor = .systemBackground
        
        vStackView.translatesAutoresizingMaskIntoConstraints = false
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(vStackView)
        view.addSubview(registerButton)
        
        vStackView.alignment = .fill
        vStackView.spacing = 20
        vStackView.distribution = .fillEqually
        vStackView.axis = .vertical
        
        vStackView.addArrangedSubview(usernameTextField)
        vStackView.addArrangedSubview(emailTextField)
        vStackView.addArrangedSubview(passwordTextField)
        vStackView.addArrangedSubview(password2TextField)
        
        vStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        vStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        vStackView.heightAnchor.constraint(equalToConstant: 220).isActive = true
    
        registerButton.topAnchor.constraint(equalTo: vStackView.bottomAnchor, constant: 20).isActive = true
        registerButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        registerButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        constraint = registerButton.bottomAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height / 2 + 150)
        constraint.isActive = true
        
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
        registerButton.layer.cornerRadius = 15
        registerButton.clipsToBounds = true
        registerButton.frame.size.height = 60
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(gesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addKeyboardObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
    }
    
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChanged(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    func keyboardChanged(_ notification: NSNotification) {
        guard let info = notification.userInfo,
              let endFrame = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        constraint.constant = min(endFrame.minY - 10, view.frame.height / 2 + 150)
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut) { [weak self] in
            self?.view.layoutIfNeeded()
        } completion: { completed in
            
        }

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
