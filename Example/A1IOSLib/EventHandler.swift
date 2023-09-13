//
//  EventHandler.swift
//  PDFScanner
//
//  Created by Navnidhi Sharma on 08/11/22.
//  Copyright © 2022 PDFScanner. All rights reserved.
//

import UIKit
import A1IOSLib

enum EventTitle: String {
    case testing
}

enum Content: String {
    case empty = ""
}

class EventHandler: NSObject {
    static var shared = EventHandler()
    
    func configureEventHandler() {
        EventManager.shared.configureEventManager(appMetricaKey: "Key") // appMetrica and mixpanel is optional now
    }
    
    func logEvent(title: EventTitle, key: String, value: String) {
        EventManager.shared.logEvent(title: title.rawValue, key: key, value: value)
    }

    func logEvent(title: EventTitle, params: [String: String]? = nil) {
        EventManager.shared.logEvent(title: title.rawValue, params: params)
    }
    
    func logProOpenedEvent(title: EventTitle, from: Content) {
        EventManager.shared.logProOpenedEvent(title: title.rawValue, from: from.rawValue)
    }

    func logFacebookEvent(name: String, params: [String: String]) {
        EventManager.shared.logFacebookEvent(name: name, params: params)
    }

}
