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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        EventHandler.shared.configureEventHandler()
        // Override point for customization after application launch.
        let navigationController = UINavigationController()
        let demoSelectionViewController = DemoSelectionViewController(a1Ads: self.a1Ads)
        navigationController.setViewControllers([demoSelectionViewController], animated: true)
        self.configureA1Ads(from: navigationController)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
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
    
            a1Ads.showAppOpenAd(from: rootViewController, afterInterval: 0) {
                
            } onClose: {
                
            } onError: { error in
                
            }
        }
    }
        
    /**    var firebaseConfig: FirebaseConfig = FirebaseConfig()

     Checks for Firebase remote config.
     
     - Parameter success: Completion handler gives FirebaseConfig model
     - Parameter failure: Completion handler gives Error
     */
    func checkFirebaseRemoteConfig() {
        FirebaseApp.configure()
        FirebaseHandler.getRemoteConfig { [weak self] (result) in
            if let settings = self {
                switch result {
                case .success(let result):
                    settings.updateAppUsingConfig()
                    let needed = settings.checkForceUpdateNeeded(config: result)
                    print("Force update needed \(needed)")
                case .failure(let error):
                    print("getRemoteConfig Failure: \(error.localizedDescription)")
                }
            }
        }
    }

    func updateAppUsingConfig() {
        
    }
    
    /// Checks for Firebase - Remote config properties for server maintenance and application update
    /// - Parameter config: FirebaseConfig model
    func checkForceUpdateNeeded(config: FirebaseConfig) -> Bool {
        guard config.versionConfig.forceUpdateRequired == true, config.versionConfig.forceUpdateVersion != "", !config.versionConfig.forceUpdateVersion.isEmpty else {
            return false
        }
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let appComponents = appVersion.components(separatedBy: ".")
        let firebaseVersion = config.versionConfig.forceUpdateVersion
        let firebaseComponents = firebaseVersion.components(separatedBy: ".")
        var isUpgradeNeeded = false
        if firebaseComponents.count > 0 && appComponents.count > 0 {
            for (index, firebaseDigit) in firebaseComponents.enumerated() {
                if appComponents.count > index {
                    let firebaseVersionInt = Int(firebaseDigit) ?? 0
                    let appVersionInt = Int(appComponents[index]) ?? 0
                    if firebaseVersionInt > appVersionInt {
                        isUpgradeNeeded = true
                        break
                    } else if firebaseVersionInt < appVersionInt {
                        break
                    }
                }
            }
        }
        if isUpgradeNeeded {
            let handler: (UIAlertAction) -> () = { [weak self] (alert) in
                self?.openAppStore()
            }
            DispatchQueue.main.async {
                // Show alert message "A new version of our app is available. Please update your app before proceeding"
            }
            return true
        } else {
            return false
        }
    }
    
    /// Opens applications app store URL
    func openAppStore() {
//        let urlString = "https://apps.apple.com/us/app/xls-sheets-view-edit-xls/id1672553988"
//        if let url = URL(string: urlString),
//            UIApplication.shared.canOpenURL(url) {
//            UIApplication.shared.open(url, options:
//                                        convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:])
//                                      ,completionHandler: nil)
//        }
//        return
    }
}

// Helper function inserted by Swift 4.2 migrator.
//func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
//    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
//}

private extension AppDelegate {
    func configureA1Ads(from viewController: UIViewController) {
        /*
        #if DEBUG
        let environment: AdsEnvironment = .development(testDeviceIdentifiers: [])
        #else
        let environment:AdsEnvironment = .production
        #endif
        */
        let environment: AdsEnvironment = .development(testDeviceIdentifiers: [])

        a1Ads.configure(
            from: nil,
            for: environment,
            requestBuilder: AdsRequestBuilder())
            
                // Ads are now ready to be displayed
                self.notificationCenter.post(name: .adsConfigureCompletion, object: nil)
    }
}

private final class AdsRequestBuilder: AdsRequestBuilderType {
    func build() -> GADRequest {
        GADRequest()
    }
}

