//
//  SignInViewController.swift
//  Thoughts
//
//  Created by ENMANUEL TORRES on 13/02/23.
//

import UIKit

class SignInViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sign In"
        view.backgroundColor = .systemBackground
        
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            if !IAPManager.shared.isPremium() {
                let vc = PayWallViewController()
                let navVC = UINavigationController(rootViewController: vc)
                self.present(navVC, animated: true)
            }
        }
        
    }
}
