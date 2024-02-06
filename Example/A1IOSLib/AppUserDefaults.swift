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
    
    @UserDefault(UserDefaults.key.showPurchaslyScreen, defaultValue: false)
    static var showPurchaslyScreen : Bool
    
    @UserDefault(UserDefaults.key.hideTabBarBanner, defaultValue: true)
    static var hideTabBarBanner : Bool
    
    @UserDefault(UserDefaults.key.ratingCount, defaultValue: 0)
    static var ratingCount : Int
    
    @UserDefault(UserDefaults.key.isUserLogin, defaultValue: false)
    static var isUserLogin : Bool
    
    @UserDefault(UserDefaults.key.isUserLoginToDropBox, defaultValue: false)
    static var isUserLoginToDropBox : Bool
    
    @UserDefault(UserDefaults.key.isUserLoginToGoogleDrive, defaultValue: false)
    static var isUserLoginToGoogleDrive : Bool
    
    @UserDefault(UserDefaults.key.isFreshLaunching, defaultValue: true)
    static var isFreshLaunching : Bool

}

extension UserDefaults {
    public enum key {
        static let isPro = "isPro"
        static let showPurchaslyScreen = "showPurchaslyScreen"
        static let hideTabBarBanner = "ErrorBannerLoad"
        static let ratingCount = "RatingCount"
        static let isUserLogin = "isUserLogin"
        static let isUserLoginToDropBox = "isUserLoginToDropBox"
        static let isUserLoginToGoogleDrive = "isUserLoginToGoogleDrive"
        static let isFreshLaunching = "isFreshLaunching"

    }
}
