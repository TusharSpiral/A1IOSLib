//
//  SplashViewController.swift
//  PDFScanner
//
//  Created by Navnidhi Sharma on 11/11/22.
//  Copyright © 2022 PDFScanner. All rights reserved.
//

import UIKit

public class AppOpenSplashViewController: UIViewController {
    /// Number of seconds remaining to show the app open ad.
    /// This simulates the time needed to load the app.
    @IBOutlet private weak var splashImageView: UIImageView!
    private var secondsRemaining: Int = 3
    /// The countdown timer.
    private var countdownTimer: Timer?
    /// Text that indicates the number of seconds left to show an app open ad.
    ///
    private var splashImageName: String = "welcome"
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        if splashImageView != nil {
            splashImageView.image = UIImage(named: splashImageName)
        }
        startTimer()
    }
    
    @objc private func decrementCounter() {
        secondsRemaining -= 1
        if AdsHandler.shared.appOpenAdAvailable() {
            countdownTimer?.invalidate()
            showAppOpenAd()
        } else if secondsRemaining <= 0 {
            countdownTimer?.invalidate()
            if AdsHandler.shared.appOpenAdAvailable() {
                showAppOpenAd()
            } else {
                startMainScreen()
            }
        }
    }
    
    private func showAppOpenAd() {
        AdsHandler.shared.a1Ads.showAppOpenAd(from: self) {
        } onClose: {
            AdsHandler.shared.appOpenLoadTime = Date()
            self.startMainScreen()
        } onError: { error in
            AdsHandler.shared.appOpenLoadTime = nil
            self.startMainScreen()
        }
    }
    
    private func startTimer() {
        countdownTimer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(AppOpenSplashViewController.decrementCounter),
            userInfo: nil,
            repeats: true)
    }
    
    private func startMainScreen() {
        self.dismiss(animated: false) {
            print("Dismissed splash")
        }
    }
    
    private struct Constants {
        static let reuseIdentifier = String(describing: AppOpenSplashViewController.self)
        static let storyboardName = "Splash"
    }
    
    public static func buildViewController(imageName: String) -> AppOpenSplashViewController {
        if let controller = UIStoryboard(name: Constants.storyboardName,
                                         bundle: .main).instantiateViewController(withIdentifier: Constants.reuseIdentifier) as? AppOpenSplashViewController {
            controller.splashImageName = imageName
            return controller
        }
        return AppOpenSplashViewController()
    }
    
}
