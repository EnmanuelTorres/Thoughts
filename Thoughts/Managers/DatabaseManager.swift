//
//  DatabaseManager.swift
//  Thoughts
//
//  Created by ENMANUEL TORRES on 13/02/23.
//

import Foundation
import FirebaseFirestore

final class DatabaseManager{
    static let shared = DatabaseManager()
    
    private let database = Firestore.firestore()
    
    private init(){}
    
    public func insert(blogPost: BlogPost, email: String, completion: @escaping (Bool)->Void){
        let userEmail = email.replacingOccurrences(of: ".", with: "-").replacingOccurrences(of: "@", with: "-")
        
        let data: [String : Any] = [
            "id": blogPost.identifier,
            "title": blogPost.title,
            "body": blogPost.text,
            "created":blogPost.timestamp,
            "headerImageUrl" :blogPost.headerImageUrl?.absoluteString ?? ""
        ]
        
        database.collection("users").document(userEmail).collection("post").document(blogPost.identifier).setData(data) { error in
            completion(error == nil)
        }
    }
    
    public func getAllPosts(completion: @escaping ([BlogPost])->Void){
       
        database.collection("users")
            .getDocuments{ [weak self] snapshot, error in
                guard let documents = snapshot?.documents.compactMap({$0.data()}),
                      error == nil else {
                    return
                }
                let emails: [String] = documents.compactMap({ $0["email"] as? String})
                print(emails)
                guard !emails.isEmpty else {
                    completion([])
                   return
                }
                let group = DispatchGroup()
                var results : [BlogPost] = []
                
                for email in emails {
                    group.enter()
                    self?.getPosts(email: email) { userPosts in
                        defer {
                            group.leave()
                        }
                        results.append(contentsOf: userPosts)
                    }
                }
                group.notify(queue: .global()) {
                    print("Feed posts: \(results.count)")
                    completion(results)
                }
            }
    }
    

    
    public func getPosts(email: String, completion: @escaping ([BlogPost])->Void){
        let userEmail = email.replacingOccurrences(of: ".", with: "-").replacingOccurrences(of: "@", with: "-")
        
        database.collection("users")
            .document(userEmail)
            .collection("post")
            .getDocuments { snapshot, error in
            guard let documents = snapshot?.documents.compactMap({ $0.data() }),
                  error == nil else {
                return
            }
            let posts : [BlogPost] = documents.compactMap { dictionary in
                guard let id = dictionary["id"] as? String,
                      let title = dictionary["title"] as? String,
                      let body = dictionary["body"] as? String,
                      let created = dictionary["created"] as? TimeInterval,
                      let headerImageUrl = dictionary["headerImageUrl"] as? String else {
                    print("Invalid post fetch conversation")
                    return nil
                }
               
                let post = BlogPost(identifier: id,
                                    title: title,
                                    timestamp: created,
                                    headerImageUrl: URL(string: headerImageUrl),
                                    text: body)
                return post
            }
                completion(posts)
        }
        
    }
    
    public func insert(user: User, completion: @escaping (Bool)->Void){
        let documentId = user.email.replacingOccurrences(of: ".", with: "-").replacingOccurrences(of: "@", with: "-")
        
        let data = [
            "email": user.email,
            "name": user.name
        ]
        
        database.collection("users").document(documentId).setData(data) {error in
            completion(error == nil)
        }
    }
    
    public func getUser(email: String, completion: @escaping (User?) -> Void) {
        let documentId = email.replacingOccurrences(of: ".", with: "-").replacingOccurrences(of: "@", with: "-")
        
        database.collection("users").document(documentId).getDocument { snapshot, error in
            guard let data = snapshot?.data() as? [String : String],
                  let name = data["name"],
                  error == nil else {
                return
            }
            
            let ref = data["profile_photo"]  
            let user = User(name: name, email: email, profilePictureRef: ref)
            completion(user)
            
        }
    }
    func updateProfilePhoto(email: String, completion: @escaping (Bool) -> Void){
        let path = email.replacingOccurrences(of: "@", with: "-").replacingOccurrences(of: ".", with: "-")
        
        let photoReference = "profile_pictures/\(path)/photo.png"
        
        let dbRef = database.collection("users").document(path)
        
        dbRef.getDocument { snapshot, error in
            guard var data = snapshot?.data(), error == nil else {
                return
            }
            data["profile_photo"] = photoReference
            
            dbRef.setData(data) { error in
                completion(error == nil)
                
            }
        }
    }
}
