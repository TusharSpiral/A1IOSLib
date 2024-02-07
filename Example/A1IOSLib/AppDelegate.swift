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
enum LoadPageType {
    case none
    case shareIntent
    case onboarding
}

extension Notification.Name {
    static let adsConfigureCompletion = Notification.Name("AdsConfigureCompletion")
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var loadPageType: LoadPageType = .none
    private let a1Ads: AdsType = Ads.shared
    private let notificationCenter: NotificationCenter = .default
    var isFreshLaunch = false
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        isFreshLaunch = true
        let onboardingDone = UserDefaults.standard.bool(forKey: "onboardingDone")
        if !onboardingDone {
            UserDefaults.standard.set(true, forKey: "onboardingDone")
            UserDefaults.standard.synchronize()
            loadPageType = .onboarding
            
        }
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
        UserDefaults.standard.setValue(adConfig.interInterval, forKey: "interInterval")
        UserDefaults.standard.setValue(adConfig.appOpenInterval, forKey: "appOpenInterval")
        UserDefaults.standard.setValue(adConfig.appOpenInterInterval, forKey: "appOpenInterInterval")
        UserDefaults.standard.setValue(adConfig.interClickInterval, forKey: "interClickInterval")

        UserDefaults.standard.setValue(adConfig.adsEnabled, forKey: "adsEnabled")
        UserDefaults.standard.setValue(adConfig.interEnabled, forKey: "interEnabled")
        UserDefaults.standard.setValue(adConfig.appOpenEnabled, forKey: "appOpenEnabled")
        UserDefaults.standard.setValue(adConfig.bannerEnabled, forKey: "bannerEnabled")

        UserDefaults.standard.setValue(adConfig.appOpenID, forKey: "appOpenID")
        UserDefaults.standard.setValue(adConfig.interID, forKey: "interID")
        UserDefaults.standard.setValue(adConfig.bannerID, forKey: "bannerID")
        UserDefaults.standard.synchronize()
    }

    func getAdConfig() -> AdsConfiguration {
        if let appOpenID = UserDefaults.standard.string(forKey: "appOpenID"), !appOpenID.isEmpty, let bannerID = UserDefaults.standard.string(forKey: "bannerID"), !bannerID.isEmpty, let interID = UserDefaults.standard.string(forKey: "interID"), !interID.isEmpty {
            return AdsConfiguration(interInterval: UserDefaults.standard.integer(forKey: "interInterval"), adsEnabled: UserDefaults.standard.bool(forKey: "adsEnabled"), interEnabled: UserDefaults.standard.bool(forKey: "interEnabled"), interID: interID, appOpenEnabled: UserDefaults.standard.bool(forKey: "appOpenEnabled") , appOpenID: appOpenID, bannerEnabled: UserDefaults.standard.bool(forKey: "bannerEnabled"), bannerID: bannerID, appOpenInterval: UserDefaults.standard.integer(forKey: "appOpenInterval"), appOpenInterInterval: UserDefaults.standard.integer(forKey: "appOpenInterInterval"), interClickInterval: UserDefaults.standard.integer(forKey: "interClickInterval"))
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
                        let splashViewController = AppOpenSplashViewController.buildViewController(imageName: "welcome")
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
