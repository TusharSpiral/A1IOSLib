//
//  FirebaseHandler.swift
//  A1Apps
//
//  Created by Navnidhi on 01/01/24.
//  Copyright © 2024 A1Apps. All rights reserved.
//
import Foundation

// MARK: - AdConfig
public struct AdsConfiguration: Codable {
    public let interInterval: Int
    public let adsEnabled, interEnabled: Bool
    public let interID: String
    public let appOpenEnabled: Bool
    public let appOpenID: String
    public let bannerEnabled: Bool
    public let bannerID: String
    public let appOpenInterval, appOpenInterInterval: Int
    public let interClickInterval: Int
    public var rewardedID: String = ""
    public var rewardedInterstitialID: String = ""
    public var nativeID: String = ""

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
        case interClickInterval = "inter_click_interval"
    }
    
//    public init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        number = try? values.decode(String.self, forKey: .number)
//        passenger = try? values.decode(Passenger.self, forKey: .passenger)
//    }
//    
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(number, forKey: .number)
//        try container.encode(passenger, forKey: .passenger)
//    }
    
    public init() {
        interInterval = 10
        adsEnabled = true
        interEnabled = true
        interID = "ca-app-pub-3940256099942544/4411468910"
        appOpenEnabled = true
        appOpenID = "ca-app-pub-3940256099942544/9257395921"
        bannerEnabled = true
        bannerID = "ca-app-pub-3940256099942544/2934735716"
        appOpenInterval = 10
        appOpenInterInterval = 10
        interClickInterval = 2
        rewardedID = "ca-app-pub-3940256099942544/1712485313"
        rewardedInterstitialID = "ca-app-pub-3940256099942544/6978759866"
        nativeID = "ca-app-pub-3940256099942544/3986624511"
    }
    
    public init(interInterval: Int, adsEnabled: Bool, interEnabled: Bool, interID: String, appOpenEnabled: Bool , appOpenID: String, bannerEnabled: Bool, bannerID: String, appOpenInterval: Int, appOpenInterInterval: Int, interClickInterval: Int) {
        self.interInterval = interInterval
        self.adsEnabled = adsEnabled
        self.interEnabled = interEnabled
        self.interID = interID
        self.appOpenEnabled = appOpenEnabled
        self.appOpenID = appOpenID
        self.bannerEnabled = bannerEnabled
        self.bannerID = bannerID
        self.appOpenInterval = appOpenInterval
        self.appOpenInterInterval = appOpenInterInterval
        self.interClickInterval = interClickInterval
    }
}

// MARK: - VersionConfig
public struct VersionConfig: Codable {
    public let forceTitle, forceMessage, optionalTitle, optionalMessage: String
    public let minVersion, stableVersion: String

    enum CodingKeys: String, CodingKey {
        case forceTitle = "force_title"
        case forceMessage = "force_message"
        case optionalTitle = "optional_title"
        case optionalMessage = "optional_message"
        case minVersion, stableVersion
    }
}
