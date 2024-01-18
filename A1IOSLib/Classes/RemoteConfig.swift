//
//  FirebaseHandler.swift
//  A1Apps
//
//  Created by Navnidhi on 01/01/24.
//  Copyright © 2024 A1Apps. All rights reserved.
//
import Foundation
import FirebaseRemoteConfig
import SwiftyJSON
/** Enum FirebaseHandlerErrors with following cases
 * **failed**
 * **NoInternetConnection**
 */
public enum FirebaseHandlerErrors:Error {
    case failed
    case NoInternetConnection
}

/** Enum FirebaseHandlerResult  with following cases
 * **success** : Generic type case
 * **failure** : FirebaseHandlerErrors type erro case
 */
public enum FirebaseHandlerResult<T>{
    case success(result: T)
    case failure(error:FirebaseHandlerErrors)
}

/**
 This Class provides handler for Firebase remote config.
 */
public class FirebaseHandler {
    /// Typealias for FirebaseHandlerResult
    public typealias remoteConfigCompletion = (_ result: FirebaseHandlerResult<FirebaseConfig>) -> Void
    /**
     This function fetchs remote config from Firebase and transfers the scope to completion handler.
     
     - Parameter block: It is a remoteConfigCompletion type completion handler.
     */
    public class func getRemoteConfig(block : @escaping remoteConfigCompletion){
        RemoteConfig.remoteConfig().fetch(withExpirationDuration: TimeInterval(0)) { (status, error) -> Void in
            if status == .success {
                RemoteConfig.remoteConfig().activate { (success, error) in
                }
                let config = self.getUpdatedvalue()
                block(.success(result:config))
            } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
                block(.failure(error:FirebaseHandlerErrors.failed))
            }
        }
    }
    
    public class func getUpdatedvalue() -> FirebaseConfig {
        let config = FirebaseConfig()
        config.adConfig = getModelForAdConfig(key: firebaseKeys.AD_CONFIG, defaultvalue: config.adConfig)
        config.subsConfig = getModelForSubsConfig(key: firebaseKeys.SUBS_CONFIG, defaultvalue: config.subsConfig)
        config.versionConfig = getModelForVersionConfig(key: firebaseKeys.VERSION_CONFIG, defaultvalue: config.versionConfig)
        return config
    }
    
    public class func getModelForAdConfig(key : String?, defaultvalue : AdConfig) -> AdConfig {
        let item = JSON.init(RemoteConfig.remoteConfig().configValue(forKey : key).jsonValue)
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(item)
            return try JSONDecoder().decode(AdConfig.self, from: jsonData)
        } catch {
            print("\(error)")
            return defaultvalue
        }
    }
    
    public class func getModelForSubsConfig(key : String?, defaultvalue : SubsConfig) -> SubsConfig {
        let item = JSON.init(RemoteConfig.remoteConfig().configValue(forKey : key).jsonValue)
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(item)
            return try JSONDecoder().decode(SubsConfig.self, from: jsonData)
        } catch {
            print("\(error)")
            return defaultvalue
        }
    }
    
    public class func getModelForVersionConfig(key : String?, defaultvalue : VersionConfig) -> VersionConfig {
        let item = JSON.init(RemoteConfig.remoteConfig().configValue(forKey : key).jsonValue)
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(item)
            return try JSONDecoder().decode(VersionConfig.self, from: jsonData)
        } catch {
            print("\(error)")
            return defaultvalue
        }
    }
}

/**
 This Class provides codable Model.
 
 It has following remote config properties
 * ad_config
 * subs_config
 */
public class FirebaseConfig: Codable {
    public var adConfig: AdConfig = AdConfig(interInterval: 30, adsEnabled: true, interEnabled: true, interID: "", appOpenEnabled: true, appOpenID: "", bannerEnabled: true, bannerID: "", appOpenInterval: 10, appOpenInterInterval: 10)
    public var subsConfig: SubsConfig = SubsConfig(doublePaywallEnabled: false)
    public var versionConfig: VersionConfig = VersionConfig(forceUpdateRequired: false, forceUpdateVersion: "")

    init(){}
    enum CodingKeys: String, CodingKey {
        case adConfig = "ad_config"
        case subsConfig = "subs_config"
        case versionConfig = "version_config"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        adConfig = try! values.decode(AdConfig.self, forKey: .adConfig)
        subsConfig = try! values.decode(SubsConfig.self, forKey: .subsConfig) 
        versionConfig = try! values.decode(VersionConfig.self, forKey: .versionConfig)
    }
}

fileprivate struct firebaseKeys{
    static let AD_CONFIG = "ad_config"
    static let SUBS_CONFIG = "subs_config"
    static let VERSION_CONFIG = "version_config"
}

// MARK: - AdConfig
public struct AdConfig: Codable {
    public let interInterval: Int
    public let adsEnabled, interEnabled: Bool
    public let interID: String
    public let appOpenEnabled: Bool
    public let appOpenID: String
    public let bannerEnabled: Bool
    public let bannerID: String
    public let appOpenInterval, appOpenInterInterval: Int

    enum CodingKeys: String, CodingKey {
        case interInterval = "inter_interval"
        case adsEnabled = "ads_enabled"
        case interEnabled = "inter_enabled"
        case interID = "inter_id"
        case appOpenEnabled = "app_open_enabled"
        case appOpenID = "app_open_id"
        case bannerEnabled = "banner_enabled"
        case bannerID = "banner_id"
        case appOpenInterval = "app_open_interval"
        case appOpenInterInterval = "app_open_inter_interval"
    }
}

// MARK: - SubsConfig
public struct SubsConfig: Codable {
    public let doublePaywallEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case doublePaywallEnabled = "double_paywall_enabled"
    }
}

// MARK: - VersionConfig
public struct VersionConfig: Codable {
    public let forceUpdateRequired: Bool
    public let forceUpdateVersion: String

    enum CodingKeys: String, CodingKey {
        case forceUpdateRequired = "force_update_required"
        case forceUpdateVersion = "force_update_version"
    }
}
