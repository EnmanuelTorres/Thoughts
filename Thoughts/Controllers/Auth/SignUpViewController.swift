//
//  SignUpViewController.swift
//  Thoughts
//
//  Created by ENMANUEL TORRES on 13/02/23.
//

import UIKit

class SignUpViewController: UITabBarController {

    // Header View
    private let headerView = SignInHeaderView()
    
    // Name field
    private let nameField: UITextField = {
       let field = UITextField()
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.placeholder = "Full Name"
        field.backgroundColor = .secondarySystemBackground
        field.layer.cornerRadius = 8
        field.layer.masksToBounds = true
        return field
    }()

    // Email field
    private let emailField: UITextField = {
       let field = UITextField()
        field.keyboardType = .emailAddress
        field.autocapitalizationType = . none
        field.autocorrectionType = .no
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.placeholder = "Emailm Addres"
        field.backgroundColor = .secondarySystemBackground
        field.layer.cornerRadius = 8
        field.layer.masksToBounds = true
        return field
    }()
    
    // Password field
    private let passwordField: UITextField = {
       let field = UITextField()
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.placeholder = "Password"
        field.autocapitalizationType = . none
        field.autocorrectionType = .no
        field.isSecureTextEntry = true
        field.backgroundColor = .secondarySystemBackground
        field.layer.cornerRadius = 8
        field.layer.masksToBounds = true
        return field
    }()
    
    //Sign Up button
    private let signUpButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGreen
        button.setTitle("Create Account", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Account"
        view.backgroundColor = .systemBackground
        view .addSubview(headerView)
        view .addSubview(nameField)
        view .addSubview(emailField)
        view .addSubview(passwordField)
        view .addSubview(signUpButton)
       
        
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
      
        
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            if !APIManager.shared.isPremium() {
                let vc = PayWallViewController()
                let navVC = UINavigationController(rootViewController: vc)
                self.present(navVC, animated: true)
            }
        }
        
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        headerView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.height/5)
        
        nameField.frame = CGRect(x: 20, y: headerView.bottom, width: view.width - 40, height: 50)
        emailField.frame = CGRect(x: 20, y: nameField.bottom+10, width: view.width - 40, height: 50)
        passwordField.frame = CGRect(x: 20, y: emailField.bottom+10, width: view.width-40, height: 50)
        signUpButton.frame = CGRect(x: 20, y: passwordField.bottom+10, width: view.width-40, height: 50)
        
    }
    
    @objc func didTapSignUp(){
        
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty,
              let name = nameField.text, !name.isEmpty else {
            return
        }
        // Create User
        AuthManager.share.singUp(email: email, password: password) { [weak self] success in
            if success {
                //Update database
                let newUser = User(name: name, email: email, profilePictureRef: nil)
                DatabaseManager.shared.insert(user: newUser) { inserted in
                    guard inserted else {
                        return
                    }
                    
                    UserDefaults.standard.set(name, forKey: "name")
                    UserDefaults.standard.set(email, forKey: "email")
                    
                    
                    DispatchQueue.main.async {
                        let vc = TabBarViewController()
                        vc.modalPresentationStyle = .fullScreen
                        self?.present(vc, animated: true)
                    }
                }
            }else {
                print("Failed to create account")
            }
        }
        
        
    }
   
}

