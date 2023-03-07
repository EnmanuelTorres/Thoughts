//
//  IAPManager.swift
//  Thoughts
//
//  Created by ENMANUEL TORRES on 13/02/23.
//

import Foundation
import Purchases
import StoreKit


final class APIManager {
    static let shared = APIManager()
    
    
    private init(){}
    
    func isPremium() -> Bool{
        return UserDefaults.standard.bool(forKey: "premium")
    }
    
    public func getSubscriptionStatus(completion: ((Bool) -> Void)?){
        Purchases.shared.purchaserInfo { info, error in
            guard let entitlements = info?.entitlements, error == nil else {
                return
            }
            if entitlements.all["Premium"]?.isActive == true {
                print("God updated status of subscribed")
                UserDefaults.standard.setValue(true, forKey: "premium")
                completion?(true)
            } else {
                print("God uptated status of Not subscribed")
                UserDefaults.standard.setValue(false, forKey: "premium")
                completion?(false)
            }
            
        }
    }
    
    public func fetchPackages(Completion: @escaping (Purchases.Package?) -> Void) {
        Purchases.shared.offerings { offerings, error in
            guard let package = offerings?.offering(identifier: "default")?.availablePackages.first, error == nil else {
                Completion(nil)
                return
            }
            Completion(package)
        }
    }
    
    public func subscribe(package : Purchases.Package, completion: @escaping (Bool) -> Void){
        
        guard !isPremium() else {
            completion(true)
            print("User already subscribed")
            return
        }
        
        Purchases.shared.purchasePackage(package) { transaction, info, error, userCancelled in
            guard let transaction = transaction, let entiltlements = info?.entitlements, error == nil, !userCancelled else {
                return
            }
            
            switch transaction.transactionState {
                
            case .purchasing:
                print("purchasing")
            case .purchased:
                if entiltlements.all["Premium"]?.isActive == true {
                    print("Purshased!")
                    UserDefaults.standard.setValue(true, forKey: "premium")
                    completion(true)
                } else {
                    print("Purchase failed")
                    UserDefaults.standard.setValue(false, forKey: "premium")
                    completion(false)
                }
            case .failed:
                print("failed")
            case .restored:
                print("restored")
            case .deferred:
                print("deferred")
            @unknown default:
                print("default case")
            }
        }
    }
    
    public func restorePurchases(completion: @escaping (Bool) -> Void){
        Purchases.shared.restoreTransactions { info, error in
            guard let entiltlements = info?.entitlements, error == nil else {
                return
            }
            if entiltlements.all["Premium"]?.isActive == true {
                print("Restore successed")
                UserDefaults.standard.setValue(true, forKey: "premium")
                completion(true)
            } else {
                print("Restored failed")
                UserDefaults.standard.setValue(false, forKey: "premium")
                completion(false)
            }
        }
    }
}
