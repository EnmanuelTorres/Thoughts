//
//  AuthManager.swift
//  Thoughts
//
//  Created by ENMANUEL TORRES on 13/02/23.
//

import Foundation
import FirebaseAuth

final class AuthManager {
    static let share = AuthManager()
    
    private let auth = Auth.auth()
    
    private init(){}
    
    
    public var isSignIn: Bool {
        return auth.currentUser != nil
    }
    
    public func singUp(email: String, password: String, completion: @escaping (Bool)-> Void) {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              password.count >= 6 else {
            return
        }
        
        auth.createUser(withEmail: email, password: password) {result, error in
            guard result != nil, error == nil else {
                completion(false)
                return
            }
            
            //Account Created
            completion(true)        }
        
    }
    
    public func singIn(email: String, password: String, completion: @escaping (Bool)-> Void) {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              password.count >= 6 else {
            return
        }
        
        auth.signIn(withEmail: email, password: password) { result, error in
            guard result != nil, error == nil else {
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    
    public func singOut( completion: (Bool)-> Void) {
        do {
            try auth.signOut()
            completion(true)
        }catch {
            print(error)
            completion(false)
        }
    }
}
