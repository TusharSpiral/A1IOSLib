//
//  FirebaseHandler.swift
//  A1Apps
//
//  Created by Navnidhi on 01/01/24.
//  Copyright © 2024 A1Apps. All rights reserved.
//
import Foundation

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
    public let interClickInterval: Int

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
    
    init() {
        interInterval = 10
        adsEnabled = true
        interEnabled = true
        interID = ""
        appOpenEnabled = true
        appOpenID = ""
        bannerEnabled = true
        bannerID = ""
        appOpenInterval = 10
        appOpenInterInterval = 10
        interClickInterval = 2
    }
    
    init(interInterval: Int, adsEnabled: Bool, interEnabled: Bool, interID: String, appOpenEnabled: Bool , appOpenID: String, bannerEnabled: Bool, bannerID: String, appOpenInterval: Int, appOpenInterInterval: Int, interClickInterval: Int) {
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
