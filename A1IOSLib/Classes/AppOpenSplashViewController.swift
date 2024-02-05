//
//  SplashViewController.swift
//  PDFScanner
//
//  Created by Navnidhi Sharma on 11/11/22.
//  Copyright © 2022 PDFScanner. All rights reserved.
//

import UIKit

public enum AppOpenSplashType {
    case foreground
    case normal
}

public class AppOpenSplashViewController: UIViewController {
    public var appOpenAdDidComplete:()->() = {}
    /// Number of seconds remaining to show the app open ad.
    /// This simulates the time needed to load the app.
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var splashImageView: UIImageView!
    private var secondsRemaining: Int = 3
    /// The countdown timer.
    private var countdownTimer: Timer?
    /// Text that indicates the number of seconds left to show an app open ad.
    ///
    private var type: AppOpenSplashType = .normal
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
        if secondsRemaining > 0 {
            label.text = "App is done loading in: \(secondsRemaining)"
        } else {
            label.text = ""
            countdownTimer?.invalidate()
            if AdsHandler.shared.appOpenAdAvailable() {
                AdsHandler.shared.a1Ads.showAppOpenAd(from: self) {
                } onClose: {
                    AdsHandler.shared.appOpenLoadTime = Date()
                    self.startMainScreen()
                } onError: { error in
                    AdsHandler.shared.appOpenLoadTime = nil
                    self.startMainScreen()
                }
            } else {
                startMainScreen()
            }
        }
    }
    
    private func startTimer() {
        label.text = "App is done loading in: \(secondsRemaining)"
        countdownTimer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(AppOpenSplashViewController.decrementCounter),
            userInfo: nil,
            repeats: true)
    }
    
    private func startMainScreen() {
        if type == .foreground {
            self.dismiss(animated: false) {
                print("Dismissed splash")
            }
        } else {
            appOpenAdDidComplete()
        }
    }
    
    private struct Constants {
        static let reuseIdentifier = String(describing: AppOpenSplashViewController.self)
        static let storyboardName = "Splash"
    }
    
    public static func buildViewController(imageName: String, type: AppOpenSplashType = .normal) -> AppOpenSplashViewController {
        if let controller = UIStoryboard(name: Constants.storyboardName,
                                         bundle: .main).instantiateViewController(withIdentifier: Constants.reuseIdentifier) as? AppOpenSplashViewController {
            controller.splashImageName = imageName
            controller.type = type
            return controller
        }
        return AppOpenSplashViewController()
    }
    
}
