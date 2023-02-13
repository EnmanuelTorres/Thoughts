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
    
    private let container = Storage.storage().reference()
    
    private init(){}
    
    public func uploadUserProfilePicture(email: String, image : UIImage?, completion: @escaping (Bool)-> Void){
        
    }
    
    public func downloadURLForProfileicture(user: User, completion: @escaping (URL?) -> Void){
        
    }
    
    public func uploadBlogHeaderImage(blogPost: BlogPost,image : UIImage?, completion: @escaping (Bool)-> Void){
        
    }
    public func downloadURLForPostHeader(blogPost: BlogPost, completion: @escaping (URL?) -> Void){
        
    }
}
