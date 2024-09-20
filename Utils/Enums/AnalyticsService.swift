//
//  AnalyticsService.swift
//  UnTaxi
//
//  Created by Done Santana on 9/9/24.
//  Copyright © 2024 Done Santana. All rights reserved.
//

import Foundation
import FirebaseAnalytics

final class AnalyticsHelper {
    private class func event(with type: AnalyticsEvent, parameters: [String: Any]? = nil) {
        if GlobalConstants.analyticsTrackingIsEnable {
            Analytics.logEvent(type.name, parameters: parameters)
        }
    }
}

extension AnalyticsHelper {
    class func loginEvent() {
        event(with: .login, parameters: nil)
    }
    
    class func solicitudEvent(type: AnalyticsEvent) {
        event(with: type, parameters: nil)
    }
    
    class func otraPersonaSelectedEvent() {
        event(with: .otraPersonaSelected, parameters: nil)
    }    
    
    class func otraPersonaFilledEvent() {
        event(with: .otraPersonaFilled, parameters: nil)
    }
    
    class func useYapaEvent() {
        event(with: .pagoYapa, parameters: nil)
    }  
    
    class func showMenuEvent() {
        event(with: .showMenu, parameters: nil)
    }
    
    class func showCallCenterEvent() {
        event(with: .callCenter, parameters: nil)
    }    
    
    class func showCallCenterUsedEvent() {
        event(with: .callCenterUsed, parameters: nil)
    }
}
