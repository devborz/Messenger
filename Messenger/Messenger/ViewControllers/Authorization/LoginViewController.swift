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
    
    var constraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Login"
        navigationItem.largeTitleDisplayMode = .always
        
        view.backgroundColor = .systemBackground
        
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        
        emailTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        emailTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20).isActive = true
        passwordTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        passwordTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        
        loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20).isActive = true
        loginButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        loginButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        constraint = loginButton.bottomAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height / 2 + 150)
        constraint.isActive = true
        
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
        loginButton.layer.cornerRadius = 15
        loginButton.clipsToBounds = true
        
        registerItem = .init(title: "Register", style: .plain, target: self, action: #selector(registerButtonTapped))
        navigationItem.rightBarButtonItem = registerItem
        
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
            
            let vc = TabBarController()
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }

}
