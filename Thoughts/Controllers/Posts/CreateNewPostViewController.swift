//
//  CreateNewPostViewController.swift
//  Thoughts
//
//  Created by ENMANUEL TORRES on 13/02/23.
//

import UIKit
import JGProgressHUD

class CreateNewPostViewController: UITabBarController {
    
    private let spiner = JGProgressHUD(style: .dark)
    
    // Title field
    private let titleField: UITextField = {
       let field = UITextField()
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.placeholder = "Enter Title"
        field.autocapitalizationType = .words
        field.autocorrectionType = .yes
        field.backgroundColor = .secondarySystemBackground
        field.layer.masksToBounds = true
        return field
    }()
    
    // Image Header
    private let headerImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(systemName: "photo")
        imageView.backgroundColor = .tertiarySystemBackground
        return imageView
    }()
    
    //TextView for post
    private let textView : UITextView = {
        let textView = UITextView()
        textView.isEditable = true
        textView.font = .systemFont(ofSize: 28)
        textView.backgroundColor = .secondarySystemBackground
        return textView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(titleField)
        view.addSubview(headerImageView)
        view.addSubview(textView)
        configureButtons()
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapHeader))
        headerImageView.addGestureRecognizer(tap)
    }
    private  var seletedHeaderImage : UIImage?
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        titleField.frame = CGRect(x: 10,
                                  y: view.safeAreaInsets.top,
                                  width: view.width - 20,
                                  height: 50)
        
        headerImageView.frame = CGRect(x: 0,
                                       y: titleField.bottom + 5,
                                       width: view.width,
                                       height: 160)
        
        textView.frame = CGRect(x: 10,
                                y: headerImageView.bottom + 10,
                                width: view.width - 20,
                                height: view.height - 210 - view.safeAreaInsets.top)
        
    }
    
    private func configureButtons(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                           style: .done,
                                                           target: self,
                                                           action: #selector(didTapCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post",
                                                           style: .done,
                                                           target: self,
                                                           action: #selector(didTapPost))
    }
    
    @objc private func didTapHeader(){
       let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func didTapCancel(){
        dismiss(animated: true)
        
    }
    
    @objc private func didTapPost(){
        //Check data and post
          spiner.show(in: view)
        print("pase por aqui 3")
        guard let title = titleField.text, let body = textView.text,let headerImage = seletedHeaderImage,
              let email = UserDefaults.standard.string(forKey: "email"),
              !title.trimmingCharacters(in: .whitespaces).isEmpty,
              !body.trimmingCharacters(in: .whitespaces).isEmpty else {
            
            let alert = UIAlertController(title: "Enter Post Details",
                                          message: "Please enter a title, body and select an image to continue.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
            present(alert, animated: true)
            print("pase por aqui 4")
            return
        }
        
        let newPostId = UUID().uuidString
        
        //Upload header Image
        
        StorageManager.shared.uploadBlogHeaderImage(email: email,
                                                    image: headerImage,
                                                    postId: newPostId) { success in
            guard success else {
                print("pase por aqui 5")
                return
            }
            StorageManager.shared.downloadURLForPostHeader(email: email, postId: newPostId) {[weak self] url in
                guard let headerUrl = url else {
                    print("Failed to upload url for header")
                    DispatchQueue.main.async {
                        HapticsManager.shared.vibrate(for: .error)
                    }
                    return
                }
                //Insert of post info DB
                
                let post = BlogPost(identifier: newPostId,
                                    title: title,
                                    timestamp: Date().timeIntervalSince1970,
                                    headerImageUrl: headerUrl,
                                    text: body)
               
                self?.spiner.dismiss()
                
                DatabaseManager.shared.insert(blogPost: post, email: email) {[weak self] posted in
                    guard posted else {
                        print("Failed to post new Blog Article")
                        DispatchQueue.main.async {
                            HapticsManager.shared.vibrate(for: .error)
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        HapticsManager.shared.vibrateForSelection()
                        self?.didTapCancel()
                    }
                }
            }
        }
    }
    
}

extension CreateNewPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        seletedHeaderImage = image
        headerImageView.image = image
    }
}
