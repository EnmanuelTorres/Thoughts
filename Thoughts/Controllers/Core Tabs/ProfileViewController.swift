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
        
    }
}
