//
//  AdsHandler.swift
//  A1Apps
//
//  Created by Navnidhi Sharma on 24/01/24.
//  Copyright © 2024 A1Apps. All rights reserved.
//

import UIKit
import GoogleMobileAds

public class AdsHandler: NSObject {
    private let notificationCenterAds: NotificationCenter = .default
    private var a1Ads = Ads.shared
    var showAds = true
    var isPro = false
    static var shared = AdsHandler()
    var adConfig = AdConfig()
    var interTriedCount = 0
    var interMaxCount = 2
    var interLoadTime: Date?
    var interTimeoutInterval: TimeInterval = 10
    var appOpenLoadTime: Date?
    var appOpenTimeoutInterval: TimeInterval = 10
    var appOpenToInterInterval: TimeInterval = 10
    var loadTimeRating: Date?
    var isAppOpnAdShowing = false
    var isBannerEnabled = false
    var isAppOpenEnabled = true
    var isInterEnabled = true
    
    func configureAds(config: AdConfig, pro: Bool) {
        if pro {
            Ads.shared.setDisabled(true)
        } else {
            showAds = config.adsEnabled
            interTimeoutInterval = TimeInterval(config.interInterval)
            appOpenTimeoutInterval = TimeInterval(config.appOpenInterval)
            appOpenToInterInterval = TimeInterval(config.appOpenInterInterval)
            isBannerEnabled = config.bannerEnabled
            isInterEnabled = config.interEnabled
            isAppOpenEnabled = config.appOpenEnabled
            interMaxCount = config.interClickInterval
            
            if config.adsEnabled != adConfig.adsEnabled || config.appOpenID != adConfig.appOpenID || config.interID != adConfig.interID || config.bannerID != adConfig.bannerID || pro != isPro {
                isPro = pro
                adConfig = config
                configureA1Ads(AdsConfiguration.customIds(bannerId: config.bannerID, appOpenId: config.appOpenID, interId: config.interID, rewardedId: "NA", rewardedInterId: "NA", nativeId: "NA"))
            } else {
                isPro = pro
                adConfig = config
                Ads.shared.setDisabled(false)
            }
        }
    }
    func canShowBannerAd() -> Bool {
        return isBannerEnabled
    }
    func canShowInterAd() -> Bool {
        guard isInterEnabled else { return false }
        print("Inter interval is \(interTimeoutInterval) count is \(interTriedCount)")
        // Check if ad was loaded more than n hours ago.
        if let openLoadTime = appOpenLoadTime {
            print("Inter - App open diff \(Date().timeIntervalSince(openLoadTime))")
            if Date().timeIntervalSince(openLoadTime) < appOpenToInterInterval {
                return false
            }
        }
        if let loadTime = interLoadTime {
            print("Inter diff \(Date().timeIntervalSince(loadTime))")
            if Date().timeIntervalSince(loadTime) < interTimeoutInterval || interTriedCount < 3 {
                return false
            } else {
                interTriedCount = 0
            }
        }
        return true
    }
    func canShowAppOpenAd() -> Bool {
        guard isAppOpenEnabled else { return false }
        print("App open interval is \(appOpenTimeoutInterval)")
        // Check if ad was loaded more than n hours ago.
        if let interTime = interLoadTime {
            print("inter - App open diff \(Date().timeIntervalSince(interTime))")
            if Date().timeIntervalSince(interTime) < appOpenToInterInterval {
                return false
            }
        }
        if let loadTime = appOpenLoadTime {
            print("App open diff \(Date().timeIntervalSince(loadTime))")
            return Date().timeIntervalSince(loadTime) > appOpenTimeoutInterval
        }
        return true
    }
    
    func canShowAds() -> Bool {
        if isReachable && !isPro && showAds == true {
            return true
        }
        return false
    }
        
    private func configureA1Ads(_ customIds: AdsConfiguration? = nil) {
        let environment: AdsEnvironment = .production
        Ads.shared.configure(from: customIds,
                             for: environment,
                             requestBuilder: AdsRequestBuilder())

        // Ads are now ready to be displayed
        notificationCenterAds.post(name: .adsConfigureCompletion, object: nil)
        Ads.shared.showAppOpenAd(from: UIViewController(), afterInterval: 0) {
        } onClose: {
        } onError: { error in
        }
    }

}
private final class AdsRequestBuilder: AdsRequestBuilderType {
    func build() -> GADRequest {
        GADRequest()
    }
}
extension Notification.Name {
    static let adsConfigureCompletion = Notification.Name("AdsConfigureCompletion")
}
