//
//  StorageManager.swift
//  Thoughts
//
//  Created by ENMANUEL TORRES on 13/02/23.
//

import Foundation
import Firebase

final class StorageManager {
    static let shared = StorageManager()
    
    private let container = Storage.storage()
    
    private init(){}
    
    public func uploadUserProfilePicture(email: String, image : UIImage?, completion: @escaping (Bool)-> Void){
        let path = email.replacingOccurrences(of: "@", with: "-").replacingOccurrences(of: ".", with: "-")
        guard let pngData = image?.pngData() else {
            return
        }
        container.reference(withPath: "profile_pictures/\(path)/photo.png")
            .putData(pngData, metadata: nil) { metadata, error in
                guard metadata != nil, error == nil else {
                    completion(false)
                    return
                }
                completion(true)
            }
    }
    
    public func downloadURLForProfileicture(path: String, completion: @escaping (URL?) -> Void){
        container.reference(withPath: path).downloadURL { url, _ in
            completion(url)
        }
    }
    
    public func uploadBlogHeaderImage(blogPost: BlogPost,image : UIImage?, completion: @escaping (Bool)-> Void){
        
    }
    public func downloadURLForPostHeader(blogPost: BlogPost, completion: @escaping (URL?) -> Void){
        
    }
}
