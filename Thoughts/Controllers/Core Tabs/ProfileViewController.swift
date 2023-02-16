//
//  ProfileViewController.swift
//  Thoughts
//
//  Created by ENMANUEL TORRES on 13/02/23.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign out",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didtapSignOut))
    }
 
    @objc private func didtapSignOut(){
        let sheet = UIAlertController(title: "Sign Out", message: "Are you sure you'd like to Sign Out?", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Sign Out ", style: .destructive, handler: { _ in
            
            AuthManager.share.singOut{ [weak self]success in
                
                if success {
                    DispatchQueue.main.async{
                        UserDefaults.standard.set(nil, forKey: "name")
                        UserDefaults.standard.set(nil, forKey: "email")
                        
                        let signInVc = SignInViewController()
                        signInVc.navigationItem.largeTitleDisplayMode = .always
                        
                        let navVC = UINavigationController(rootViewController: signInVc)
                        navVC.navigationBar.prefersLargeTitles = true
                        navVC.modalPresentationStyle = .fullScreen
                        self?.present(navVC, animated: true)
                    }
                }
            }
        }))
        present(sheet, animated: true)
    }
}
