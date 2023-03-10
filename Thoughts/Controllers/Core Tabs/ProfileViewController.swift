//
//  ProfileViewController.swift
//  Thoughts
//
//  Created by ENMANUEL TORRES on 13/02/23.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
 
    
    //Profile Photo
    
    // Full Name
    
    // Email
    
    // List of posts
    
    private var user : User?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PostPreviewTableViewCell.self,
                           forCellReuseIdentifier: PostPreviewTableViewCell.indertifier)
        return tableView
    }()
    
    let currentEmail : String
    
    init(currentEmail : String){
        self.currentEmail = currentEmail
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
   

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        SetUpSignOutButton()
        SetUpTable()
        title = "Profile"
        fetchPosts()
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    private func SetUpTable(){
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        setUpTableHeader()
        fetchProfileData()
        
    }
    
   
    
    private func setUpTableHeader(profilePhotoRef : String? = nil, name : String? = nil){
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.width/1.5))
        headerView.backgroundColor = .systemBlue
        headerView.isUserInteractionEnabled = true
        headerView.clipsToBounds = true
        tableView.tableHeaderView = headerView
        
        // Profile picture
        let profilePhoto = UIImageView(image: UIImage(systemName: "person.circle"))
        profilePhoto.tintColor = .white
        profilePhoto.contentMode = .scaleAspectFit
        profilePhoto.frame = CGRect(x: (view.width - (view.width/4))/2,
                                    y: (headerView.height-(view.width/4))/2.5,
                                    width: view.width/4,
                                    height: view.width/4)
        profilePhoto.layer.masksToBounds = true
        profilePhoto.layer.cornerRadius = profilePhoto.width/2
        profilePhoto.isUserInteractionEnabled = true
        headerView.addSubview(profilePhoto)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapProfilePhoto))
        profilePhoto.addGestureRecognizer(tap)
        
        
        // Email
        let emailLabel = UILabel(frame: CGRect(x: 20, y: profilePhoto.bottom+10, width: view.width - 40, height: 100))
        headerView.addSubview(emailLabel)
        emailLabel.text = currentEmail
        emailLabel.textAlignment = .center
        emailLabel.textColor = .white
        emailLabel.font = .systemFont(ofSize: 25, weight: .bold)
        
        
        if let name = name {
            title = name
        }
        
        if let ref = profilePhotoRef {
            // Fetch image
            StorageManager.shared.downloadURLForProfilePicture(path: ref) { url in
                guard let url = url else {
                    return
                }
                let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                    guard let data = data else {
                        return
                    }
                    DispatchQueue.main.async{
                        profilePhoto.image = UIImage(data: data)
                    }
                }
                task.resume()
            }
        }
    }
    
    @objc private func didTapProfilePhoto(){
        guard let myEmail = UserDefaults.standard.string(forKey: "email"),
              myEmail == currentEmail else {
            return
        }
        
        
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    private func fetchProfileData(){
        DatabaseManager.shared.getUser(email: currentEmail) {[weak self] user in
            guard let user = user else {
                return
            }
            self?.user = user
            
            DispatchQueue.main.async{
                self?.setUpTableHeader(profilePhotoRef: user.profilePictureRef, name: user.name)
            }
        }
    }
        
    private func SetUpSignOutButton(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign out",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didtapSignOut))
    }
 
    /// Sign Out
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
    
    // TableView
    
    private var posts: [BlogPost] = []
    
    private func fetchPosts(){
       
        print("Fetching post...")
        DatabaseManager.shared.getPosts(email: currentEmail) {[weak self] posts in
            self?.posts = posts
            print("Found \(posts.count) posts")
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostPreviewTableViewCell.indertifier, for: indexPath) as? PostPreviewTableViewCell else {
            fatalError()
        }
        cell.congifure(with: PostPreviewTableViewCellViewModel.init(title: post.title, imageUrl: post.headerImageUrl))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath : IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ViewPostViewController(post: posts[indexPath.row])
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.title = "Post"
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker : UIImagePickerController){
        picker.dismiss(animated: true)
    }
    
    func imagePickerController (_ picker : UIImagePickerController, didFinishPickingMediaWithInfo info : [UIImagePickerController.InfoKey :Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        
        StorageManager.shared.uploadUserProfilePicture(email: currentEmail, image: image) {[weak self] success in
            guard let StrongSelf = self else {
                return
            }
            if success {
                //Update database
                DatabaseManager.shared.updateProfilePhoto(email: StrongSelf.currentEmail) { updated in
                    guard updated else {
                        return
                    }
                    DispatchQueue.main.async {
                        StrongSelf.fetchProfileData()
                    }
                }
            }
        }
    }
}
