//
//  SplashViewController.swift
//  A1Office
//
//  Created by Tushar Goyal on 07/03/24.
//

import UIKit
import Lottie

public class SplashViewController: UIViewController {
    
    @IBOutlet weak var viewLottie: UIView!
    
    private var animationView =  LottieAnimationView() // LottieAnimationView(animation: LottieAnimation.named(lottieName))
    private var isPro: Bool = false
    private var firstLaunchAd: Bool = false
    private var adConfig: AdsConfiguration?
    private var completion: ((Bool) -> Void)?
    private var lottieName: String = "LaunchAnimation"

    public override func viewDidLoad() {
        super.viewDidLoad()
        animationView.animation = LottieAnimation.named(lottieName)
        lottie()
        
    }
    
    public func setSetup(isPro: Bool, adConfig: AdsConfiguration, firstLaunchAd: Bool, lottieName: String, completion: ((Bool) -> Void)?) {
        self.isPro = isPro
        self.adConfig = adConfig
        self.firstLaunchAd = firstLaunchAd
        self.completion = completion
        self.lottieName = lottieName
    }
    
    private func lottie() {
        animationView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-150)
        viewLottie.addSubview(animationView)
//        animationView.animationSpeed = 1.5
        animationView.loopMode = .playOnce
        animationView.play { completed in
            self.animationView.stop()
            if ConsentManager.shared.isPrivacyOptionsRequired, !self.isPro, let adConfig = self.adConfig  {
                ConsentManager.shared.showGDPR(from: self, adConfig: adConfig, isPro: self.isPro) { [weak self] in
                    self?.navigateToController()
                }
            }else {
                self.navigateToController()
            }
        }
    }
    
   private func navigateToController() {
        if firstLaunchAd, AdsHandler.shared.canShowAppOpenAd() {
            if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                Ads.shared.showAppOpenAd(from: rootViewController) {
                } onClose: {
                    self.completion?(false)
//                    AppManager.shared.loadFresh()
                } onError: { error in
                    self.completion?(false)
//                    AppManager.shared.loadFresh()
                }
            }
        }else {
            self.completion?(true)
//            AppUserDefaults.firstLaunchAd = true
//            AppManager.shared.loadFresh()
        }
    }
}
