//
//  AppDelegate.swift
//  A1IOSLib
//
//  Created by TusharSpiral on 09/08/2023.
//  Copyright (c) 2023 TusharSpiral. All rights reserved.
//

import UIKit
import A1IOSLib
import GoogleMobileAds
import FirebaseCore

extension Notification.Name {
    static let adsConfigureCompletion = Notification.Name("AdsConfigureCompletion")
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private let a1Ads: AdsType = Ads.shared
    private let notificationCenter: NotificationCenter = .default
    var isFreshLaunch = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        isFreshLaunch = true
        EventHandler.shared.configureEventHandler()
        // Override point for customization after application launch.
        let navigationController = UINavigationController()
        let demoSelectionViewController = DemoSelectionViewController(a1Ads: self.a1Ads)
        navigationController.setViewControllers([demoSelectionViewController], animated: true)
        AdsHandler.shared.configureAds(config: getAdConfig(), pro: AppUserDefaults.isPro)
        fetchConfig()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }
    
    func fetchConfig() {
        FirebaseApp.configure()
        FirebaseHandler.getRemoteConfig { [weak self] (result) in
            if let settings = self {
                switch result {
                case .success(let result):
                    settings.saveConfigInUserDefaults(result: result)
                    AdsHandler.shared.configureAds(config: settings.getAdConfig(), pro: AppUserDefaults.isPro)
                    AppUpdate.shared.configureAppUpdate(url: "https://apps.apple.com/us/app/xls-sheets-view-edit-xls/id1672553988", config: result.versionConfig)
                case .failure(let error):
                    print("getRemoteConfig Failure: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func saveConfigInUserDefaults(result: FirebaseConfig) {
        
        let adConfig = result.adConfig
        
        AppUserDefaults.interInterval = adConfig.interInterval
        AppUserDefaults.appOpenInterval = adConfig.appOpenInterval
        AppUserDefaults.appOpenInterInterval = adConfig.appOpenInterInterval
        AppUserDefaults.interClickInterval = adConfig.interClickInterval
        
        AppUserDefaults.adsEnabled = adConfig.adsEnabled
        AppUserDefaults.interEnabled = adConfig.interEnabled
        AppUserDefaults.appOpenEnabled = adConfig.appOpenEnabled
        AppUserDefaults.bannerEnabled = adConfig.bannerEnabled
        AppUserDefaults.rewardedEnabled = adConfig.rewardedEnabled

        AppUserDefaults.appOpenID = adConfig.appOpenID
        AppUserDefaults.interID = adConfig.interID
        AppUserDefaults.bannerID = adConfig.bannerID
        AppUserDefaults.rewardedID = adConfig.rewardedID
    }

    func getAdConfig() -> AdsConfiguration {
        
        let appOpenID = AppUserDefaults.appOpenID
        let bannerID = AppUserDefaults.bannerID
        let interID = AppUserDefaults.interID
        
        if !appOpenID.isEmpty, !bannerID.isEmpty, !interID.isEmpty {
            
            return AdsConfiguration(
                interInterval: AppUserDefaults.interInterval,
                adsEnabled: AppUserDefaults.adsEnabled,
                interEnabled: AppUserDefaults.interEnabled,
                interID: interID,
                appOpenEnabled: AppUserDefaults.appOpenEnabled,
                appOpenID: appOpenID,
                bannerEnabled: AppUserDefaults.bannerEnabled,
                bannerID: bannerID,
                appOpenInterval: AppUserDefaults.appOpenInterval,
                appOpenInterInterval: AppUserDefaults.appOpenInterInterval,
                interClickInterval: AppUserDefaults.interClickInterval,
                rewardedEnabled: AppUserDefaults.rewardedEnabled,
                rewardedID: AppUserDefaults.rewardedID
            )
            
        }
        
        return AdsConfiguration()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        let rootViewController = application.windows.first(
            where: { $0.isKeyWindow })?.rootViewController
        ///Enable if app open ads need to show
        if let rootViewController = rootViewController {
            // Do not show app open ad if the current view controller is DemoSelectionViewController.
            if rootViewController is DemoSelectionViewController {
                return
            }
            if isFreshLaunch == false {
                AppUpdate.shared.checkUpdate(canCheckOptionalUpdate: false)
            } else {
                isFreshLaunch = false
            }
            if AdsHandler.shared.canShowAppOpenAd()  {
                if let vc = visibleViewController(rootViewController: window?.rootViewController) {
                    if AdsHandler.shared.appOpenAdAvailable() {
                        Ads.shared.showAppOpenAd(from: vc) {
                        } onClose: {
                        } onError: { error in
                        }
                    } else {
                        let splashViewController = AppOpenSplashViewController.buildViewController(imageName: "welcome", delegate: rootViewController)
                        vc.presentVC(splashViewController, animated: false)
                    }
                }
            }
        }
    }
    
    func visibleViewController(rootViewController:UIViewController?) -> UIViewController? {
        if rootViewController == nil { return nil }
        
        if rootViewController is UINavigationController {
            let rootNavControler:UINavigationController = rootViewController as! UINavigationController
            return visibleViewController(rootViewController:rootNavControler.visibleViewController)
        }
        else if rootViewController is UITabBarController {
            let rootTabControler:UITabBarController = rootViewController as! UITabBarController
            return visibleViewController(rootViewController:rootTabControler.selectedViewController)
        }
        else if (rootViewController?.presentedViewController != nil) {
            return visibleViewController(rootViewController:rootViewController?.presentedViewController)
        }
        
        return rootViewController
    }

}

extension UIViewController {
    func presentVC(_ vc: UIViewController, animated: Bool, style:UIModalPresentationStyle = .fullScreen, completion: (() -> Void)? = nil) {
        vc.modalPresentationStyle = style
        self.present(vc, animated: animated, completion: completion)
    }
}
