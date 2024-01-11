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
    
}

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

