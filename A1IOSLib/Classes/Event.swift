//
//  Event.swift
//  A1OfficeSDK
//
//  Created by Tushar Goyal on 05/09/23.
//

import Foundation
import UIKit
import YandexMobileMetrica
import FBSDKCoreKit
import FirebaseAnalytics
import Mixpanel
import FirebaseCore

public enum PurchaselyKey: String {
    
    // MARK: - First Time Application Event
    case event_app_first_open
    
    // MARK: - Purchasely
    case event_subs_purchasely_load_started
    case event_subs_purchasely_show_requested
    case event_subs_purchasely_screen_shown
    case event_subs_purchasely_payment_failed
    case event_subs_purchase_acknowledged // with params
    
}

public class EventManager: NSObject {
    let proOpenFromKey = "pro_opened_from"
    public static var shared = EventManager()
    private var mixPanelKey = ""
    private var appMetricaKey = ""
    private var firebase = true
    private var facebook = true
    
    public func configureEventManager(appMetricaKey: String = "", mixPanelKey: String = "", firebase: Bool = true, facebook: Bool = true) {
        self.appMetricaKey = appMetricaKey
        self.mixPanelKey = mixPanelKey
        self.firebase = firebase
        self.facebook = facebook
        if firebase {
            FirebaseApp.configure()
        }
        if !appMetricaKey.isEmpty {
            let configuration = YMMYandexMetricaConfiguration.init(apiKey: appMetricaKey)
            YMMYandexMetrica.activate(with: configuration!)
        }
        if !mixPanelKey.isEmpty {
            Mixpanel.initialize(token: mixPanelKey, trackAutomaticEvents: true)
        }
        logEvent(title: PurchaselyKey.event_app_first_open.rawValue)
    }

    public func logEvent(title: String, key: String, value: String) {
        if !appMetricaKey.isEmpty {
            YMMYandexMetrica.reportEvent(title, parameters: [key : value])
        }
        if !mixPanelKey.isEmpty {
            Mixpanel.mainInstance().track(event: title, properties: [key : value])
        }
        if firebase {
            Analytics.logEvent(title, parameters: [key: value])
        }
        if facebook {
            AppEvents.shared.logEvent(AppEvents.Name(title), parameters: [AppEvents.ParameterName(key): value])
        }
    }

    public func logEvent(title: String, params: [String: String]? = nil) {
        if !appMetricaKey.isEmpty {
            YMMYandexMetrica.reportEvent(title, parameters: params)
        }
        if !mixPanelKey.isEmpty {
            Mixpanel.mainInstance().track(event: title, properties: params)
        }
        if firebase {
            Analytics.logEvent(title, parameters: params)
        }
        if facebook {
            if let myparams = params {
                let appEventsParams = myparams.map { key, value in
                    (AppEvents.ParameterName(key), value)
                }
                let parameters = Dictionary(uniqueKeysWithValues: appEventsParams)
                AppEvents.shared.logEvent(AppEvents.Name(title), parameters: parameters)
            } else {
                AppEvents.shared.logEvent(AppEvents.Name(title), parameters: nil)
            }
        }
    }
    
    public func logProOpenedEvent(title: String, from: String) {
        if !appMetricaKey.isEmpty {
            YMMYandexMetrica.reportEvent(title, parameters: [proOpenFromKey: from])
        }
        if !mixPanelKey.isEmpty {
            Mixpanel.mainInstance().track(event: title, properties: [proOpenFromKey: from])
        }
        if firebase {
            Analytics.logEvent(title, parameters: [proOpenFromKey: from])
        }
        if facebook {
            AppEvents.shared.logEvent(AppEvents.Name(title), parameters: [AppEvents.ParameterName(proOpenFromKey): from])
        }
    }

    public func logFacebookEvent(name: String, params: [String: String]) {
        if facebook {
            let appEventsParams = params.map { key, value in
                (AppEvents.ParameterName(key), value)
            }
            let parameters = Dictionary(uniqueKeysWithValues: appEventsParams)
            AppEvents.shared.logEvent(AppEvents.Name(name), parameters: parameters)
        }
        //Add same events for google as well
        if firebase {
            Analytics.logEvent(name, parameters: params)
        }
    }

    public func logEvent(title: String, keys: [String] = [], values: [String] = []) {
        var params = setParam(keys: keys, values: values)
        logEvent(title: title, params: params)
    }
    
    private func setParam(keys: [String], values: [String]) -> [String: String] {
        var params: [String: String] = [:]
        for (index, key) in keys.enumerated() {
            params.updateValue(values[index], forKey: key)
        }
        return params
    }

    
}
