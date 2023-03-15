//
//  HapticsManager.swift
//  Thoughts
//
//  Created by ENMANUEL TORRES on 10/03/23.
//

import Foundation
import UIKit

class HapticsManager {
 static let shared = HapticsManager()
    
    private init() {}
    
    
    func vibrateForSelection(){
        let generetaror = UISelectionFeedbackGenerator()
        generetaror.prepare()
        generetaror.selectionChanged()
    }
    
    func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType){
        let generetaror = UINotificationFeedbackGenerator()
        generetaror.prepare()
        generetaror.notificationOccurred(type)
    }
    
}
