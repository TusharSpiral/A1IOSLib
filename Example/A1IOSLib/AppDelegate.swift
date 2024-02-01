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
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        AdsHandler.shared.configureAds(pro: false)
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
            a1Ads.showAppOpenAd(from: rootViewController) {
                
            } onClose: {
                
            } onError: { error in
                
            }
        }
    }
}
