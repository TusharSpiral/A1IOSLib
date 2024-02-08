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
import A1IOSLib

/** Enum FirebaseHandlerErrors with following cases
 * **failed**
 * **NoInternetConnection**
 */
enum FirebaseHandlerErrors:Error {
    case failed
    case NoInternetConnection
}

/** Enum FirebaseHandlerResult  with following cases
 * **success** : Generic type case
 * **failure** : FirebaseHandlerErrors type erro case
 */
enum FirebaseHandlerResult<T>{
    case success(result: T)
    case failure(error:FirebaseHandlerErrors)
}

/**
 This Class provides handler for Firebase remote config.
 */
class FirebaseHandler {
    static let APP_STORE_URL = "https://apps.apple.com/us/app/xls-sheets-view-edit-xls/id1672553988"
    /// Typealias for FirebaseHandlerResult
    typealias remoteConfigCompletion = (_ result: FirebaseHandlerResult<FirebaseConfig>) -> Void
    /**
     This function fetchs remote config from Firebase and transfers the scope to completion handler.
     
     - Parameter block: It is a remoteConfigCompletion type completion handler.
     */
    class func getRemoteConfig(block : @escaping remoteConfigCompletion){
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
    
    class func getUpdatedvalue() -> FirebaseConfig {
        let config = FirebaseConfig()
        config.adConfig = getModelForAdConfig(key: firebaseKeys.AD_CONFIG, defaultvalue: config.adConfig)
        config.subsConfig = getModelForSubsConfig(key: firebaseKeys.SUBS_CONFIG, defaultvalue: config.subsConfig)
        config.versionConfig = getModelForVersionConfig(key: firebaseKeys.VERSION_CONFIG, defaultvalue: config.versionConfig)
        return config
    }
    
    class func getModelForAdConfig(key : String?, defaultvalue : AdsConfiguration) -> AdsConfiguration {
        let item = JSON.init(RemoteConfig.remoteConfig().configValue(forKey : key).jsonValue)
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(item)
            return try JSONDecoder().decode(AdsConfiguration.self, from: jsonData)
        } catch {
            print("\(error)")
            return defaultvalue
        }
    }
    
    class func getModelForSubsConfig(key : String?, defaultvalue : SubsConfig) -> SubsConfig {
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
class FirebaseConfig: Codable {
    var adConfig: AdsConfiguration = AdsConfiguration()
    public var versionConfig = VersionConfig()
    var subsConfig: SubsConfig = SubsConfig(doublePaywallEnabled: false)

    init(){}
    enum CodingKeys: String, CodingKey {
        case adConfig = "ad_config"
        case versionConfig = "version_config"
        case subsConfig = "subs_config"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        adConfig = try! values.decode(AdsConfiguration.self, forKey: .adConfig)
        versionConfig = try! values.decode(VersionConfig.self, forKey: .versionConfig)
        subsConfig = try! values.decode(SubsConfig.self, forKey: .subsConfig)
    }
}

fileprivate struct firebaseKeys{
    static let AD_CONFIG = "ad_config"
    static let VERSION_CONFIG = "version_config"
    static let SUBS_CONFIG = "subs_config"
}

// MARK: - SubsConfig
struct SubsConfig: Codable {
    let doublePaywallEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case doublePaywallEnabled = "double_paywall_enabled"
    }
}
