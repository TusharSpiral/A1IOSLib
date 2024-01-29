//
//  AdsHandler.swift
//  A1Apps
//
//  Created by Navnidhi Sharma on 24/01/24.
//  Copyright © 2024 A1Apps. All rights reserved.
//

import UIKit
import GoogleMobileAds

public class AdsHandler {
    public var a1Ads = Ads.shared
    public static var shared = AdsHandler()
    private let notificationCenterAds: NotificationCenter = .default
    private var showAds = true
    private var isPro = false
    private var adConfig = AdConfig(interInterval: 0, adsEnabled: false, interEnabled: false, interID: "", appOpenEnabled: false , appOpenID: "", bannerEnabled: false, bannerID: "", appOpenInterval: 0, appOpenInterInterval: 0, interClickInterval: 0)
    private var interTriedCount = 0
    private var interMaxCount = 2
    private var interLoadTime: Date?
    private var interTimeoutInterval: TimeInterval = 10
    private var appOpenLoadTime: Date?
    private var appOpenTimeoutInterval: TimeInterval = 10
    private var appOpenToInterInterval: TimeInterval = 10
    private var loadTimeRating: Date?
    private var isBannerEnabled = false
    private var isAppOpenEnabled = true
    private var isInterEnabled = true
    
    public func configureAds(config: AdConfig, pro: Bool) {
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
                configureA1Ads(AdsConfiguration.customIds(bannerId: config.bannerID, appOpenId: config.appOpenID, interId: config.interID, rewardedId: "", rewardedInterId: "", nativeId: ""))
            } else {
                isPro = pro
                adConfig = config
            }
            Ads.shared.setDisabled(false)
        }
    }
    
    public func appOpenAdAvailable() -> Bool {
        return a1Ads.isAppOpenAdReady
    }
    
    public func appOpenAdShowing() -> Bool {
        return a1Ads.isAppOpenAdShowing
    }
    
    public func canShowBannerAd() -> Bool {
        return isReachable && !isPro && showAds == true && isBannerEnabled
    }
    
    public func canShowInterAd() -> Bool {
        guard isReachable && !isPro && showAds == true && isInterEnabled else { return false }
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
            if Date().timeIntervalSince(loadTime) < interTimeoutInterval || interTriedCount < interMaxCount + 1 {
                return false
            } else {
                interTriedCount = 0
            }
        }
        return true
    }
    
    public func canShowAds() -> Bool {
        return (!isPro && showAds)
    }
    
    public func canShowAppOpenAd() -> Bool {
        guard isReachable && !isPro && showAds == true && isAppOpenEnabled else { return false }
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
            
    private func configureA1Ads(_ customIds: AdsConfiguration? = nil) {
        Ads.shared.configure(from: customIds,
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
