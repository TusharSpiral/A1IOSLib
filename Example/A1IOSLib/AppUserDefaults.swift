//
//  AppUserDefaults.swift
//  PDFScanner
//
//  Created by Tushar Goyal on 22/12/22.
//

import Foundation

@propertyWrapper
struct UserDefault<T> {
    let key : String
    let defaultValue : T
    init(_ key : String , defaultValue : T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue : T {
        get{
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }set{
           UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

struct AppUserDefaults {
    @UserDefault(UserDefaults.key.isPro, defaultValue: false)
    static var isPro : Bool // this value is set inside AdsHandler.setPro() func
    @UserDefault(UserDefaults.key.interInterval, defaultValue: 10)
    static var interInterval : Int
    @UserDefault(UserDefaults.key.appOpenInterval, defaultValue: 10)
    static var appOpenInterval : Int
    @UserDefault(UserDefaults.key.appOpenInterInterval, defaultValue: 10)
    static var appOpenInterInterval : Int
    @UserDefault(UserDefaults.key.interClickInterval, defaultValue: 2)
    static var interClickInterval : Int
    @UserDefault(UserDefaults.key.adsEnabled, defaultValue: true)
    static var adsEnabled : Bool
    @UserDefault(UserDefaults.key.interEnabled, defaultValue: true)
    static var interEnabled : Bool
    @UserDefault(UserDefaults.key.appOpenEnabled, defaultValue: true)
    static var appOpenEnabled : Bool
    @UserDefault(UserDefaults.key.bannerEnabled, defaultValue: true)
    static var bannerEnabled : Bool
    @UserDefault(UserDefaults.key.rewardedEnabled, defaultValue: true)
    static var rewardedEnabled : Bool
    @UserDefault(UserDefaults.key.appOpenID, defaultValue: "")
    static var appOpenID : String
    @UserDefault(UserDefaults.key.interID, defaultValue: "")
    static var interID : String
    @UserDefault(UserDefaults.key.bannerID, defaultValue: "")
    static var bannerID : String
    @UserDefault(UserDefaults.key.rewardedID, defaultValue: "")
    static var rewardedID : String
}

extension UserDefaults {
    public enum key {
        static let isPro = "isPro"
        static let interInterval = "interInterval"
        static let appOpenInterval = "appOpenInterval"
        static let appOpenInterInterval = "appOpenInterInterval"
        static let interClickInterval = "interClickInterval"
        static let adsEnabled = "adsEnabled"
        static let interEnabled = "interEnabled"
        static let appOpenEnabled = "appOpenEnabled"
        static let bannerEnabled = "bannerEnabled"
        static let rewardedEnabled = "rewardedEnabled"
        static let appOpenID = "appOpenID"
        static let interID = "interID"
        static let bannerID = "bannerID"
        static let rewardedID = "rewardedID"
    }
}
