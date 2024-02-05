//
//  AdaptyHandler.swift
//  A1OfficeSDK
//
//  Created by Navnidhi Sharma on 05/01/24.
//

import Foundation
import UIKit
import Adapty
import AdaptyUI

public protocol AdaptyHandlerDelegate: AnyObject {
    func didUpdateSubscription()
    func alertAction(text: String?)
    func loader(isShown: Bool)

    func cancelSubscription()
    func loadFresh()
}

extension AdaptyHandlerDelegate {
    func cancelSubscription() {}
    func loadFresh() {}
}

extension NSNotification.Name {
    static let ReceivedSplashPaywall = NSNotification.Name("ReceivedSplashPaywall")
    static let ReceivedOnboardingPaywall = NSNotification.Name("ReceivedOnboardingPaywall")
}

public class AdaptyHandler: NSObject {
    public static var shared = AdaptyHandler()
    var purchaselyViewController: UIViewController?
    var fromController: UIViewController?
    var delegate: AdaptyHandlerDelegate?
    var delayCount = 0
    var paywalls = [String: AdaptyPaywallController]()
    var isReceivedOnboarding = false
    var isReceivedSplash = false
    public func configureAdapty(key: String, uid: String, completion: @escaping (Int, Error?) -> Void) {
        Adapty.logLevel = .verbose
        Adapty.setLogHandler { time, level, message  in
            print("Adapty time:\(time), level: \(level): \(message)")
        }
        if uid != "", !uid.isEmpty {
            Adapty.activate(key, customerUserId: uid, enableUsageLogs: true)
        } else {
            Adapty.activate(key, enableUsageLogs: true)
        }
//        self.restorePurchase(completionHandler: completion)
    }
    
    public func preFetchOnboarding(onboarding: String) {
        preFetchPaywall(placement: onboarding) { [weak self] success in
            print("Received ONBOARDING")
            self?.isReceivedOnboarding = true
            NotificationCenter.default.post(name: NSNotification.Name.ReceivedOnboardingPaywall, object: nil)
        }
    }

    public func preFetchSplash(splash: String) {
        preFetchPaywall(placement: splash) { [weak self] success in
            print("Received SPLASH")
            self?.isReceivedSplash = true
            NotificationCenter.default.post(name: NSNotification.Name.ReceivedSplashPaywall, object: nil)
        }
    }
                    
    public func showFreeTrial(from: UIViewController, placement: String, content: String = "", delegate: AdaptyHandlerDelegate) {
        guard isReachable else {
            delegate.alertAction(text: Localization.internetError)
            return
        }
        self.delegate = delegate
        delegate.loader(isShown: true)
        delayCount = 0
        let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(delayInPaywall), userInfo: nil, repeats: true)
        EventManager.shared.logEvent(title: AdaptyKey.event_subs_paywall_load_started.rawValue)
        if let visualPaywall = checkExistingPaywall(placement: placement) {
            delegate.loader(isShown: false)
            EventManager.shared.logEvent(title: AdaptyKey.event_subs_paywall_show_requested.rawValue)
            DispatchQueue.main.async {
                from.present(visualPaywall, animated: true) {
                    timer.invalidate()
                    EventManager.shared.logEvent(title: AdaptyKey.event_subs_paywall_screen_shown.rawValue, params: ["loadTime" : "\(self.delayCount)"])
                    self.delayCount = 0
                }
            }
        } else {
            Adapty.getPaywall(placement, locale: "en") { result in
                switch result {
                case let .success(paywall):
                    Adapty.logShowPaywall(paywall)
                    AdaptyUI.getViewConfiguration(forPaywall: paywall, locale: "en") { result in
                        switch result {
                        case let .success(viewConfiguration):
                            self.delegate?.loader(isShown: false)
                            let visualPaywall = AdaptyUI.paywallController(for: paywall, viewConfiguration: viewConfiguration, delegate: self)
                            EventManager.shared.logEvent(title: AdaptyKey.event_subs_paywall_show_requested.rawValue)
                            self.savePaywall(placement: placement, paywall: visualPaywall)
                            from.present(visualPaywall, animated: true) {
                                timer.invalidate()
                                EventManager.shared.logEvent(title: AdaptyKey.event_subs_paywall_screen_shown.rawValue, params: ["loadTime" : "\(self.delayCount)"])
                                self.delayCount = 0
                            }
                            // use loaded configuration
                        case let .failure(error):
                            timer.invalidate()
                            EventManager.shared.logEvent(title: AdaptyKey.event_subs_paywall_load_failed.rawValue, params: ["loadFailTime" : "\(self.delayCount)"])
                            self.delayCount = 0
                            self.delegate?.loader(isShown: false)
                            //let message = error.localizedDescription
                            //self.delegate?.alertAction(text: message)
                            if error.adaptyErrorCode == AdaptyError.ErrorCode.networkFailed {
                                self.delegate?.alertAction(text: Localization.networkError)
                            } else {
                                self.delegate?.alertAction(text: Localization.priceError)
                            }
                        }
                    }
                    // the requested paywall
                case let .failure(error):
                    timer.invalidate()
                    EventManager.shared.logEvent(title: AdaptyKey.event_subs_paywall_load_failed.rawValue, params: ["loadFailTime" : "\(self.delayCount)"])
                    self.delayCount = 0
                    self.delegate?.loader(isShown: false)
                    //let message = error.localizedDescription
                    //self.delegate?.alertAction(text: message)
                    if error.adaptyErrorCode == AdaptyError.ErrorCode.networkFailed {
                        self.delegate?.alertAction(text: Localization.networkError)
                    } else {
                        self.delegate?.alertAction(text: Localization.priceError)
                    }
                }
            }
        }
    }
    
    public func preFetchPaywall(placement: String, completion: @escaping (Bool) -> Void) {
        Adapty.getPaywall(placement, locale: "en") { result in
            switch result {
            case let .success(paywall):
                AdaptyUI.getViewConfiguration(forPaywall: paywall, locale: "en") { result in
                    switch result {
                    case let .success(viewConfiguration):
                        let visualPaywall = AdaptyUI.paywallController(for: paywall, viewConfiguration: viewConfiguration, delegate: self)
                        self.savePaywall(placement: placement, paywall: visualPaywall)
                        completion(true)
                    case .failure(_):
                        completion(false)
                    }
                }
                // the requested paywall
            case .failure(_):
                completion(false)
            }
        }
    }
    
    private func savePaywall(placement: String, paywall: AdaptyPaywallController) {
        paywalls[placement] = paywall
    }
    
    private func checkExistingPaywall(placement: String) -> AdaptyPaywallController? {
        return paywalls[placement]
    }
    
    @objc func delayInPaywall() {
        delayCount += 1
    }
    
    private func restorePurchase(completionHandler: @escaping (Int, Error?) -> Void) {
        Adapty.logout() //clearUser()
        Adapty.restorePurchases { result in
            switch result {
                case let .success(profile):
                print(profile)
                if profile.accessLevels["premium"]?.isActive ?? false {
                    completionHandler(1, nil)
                }else {
                    completionHandler(0, nil)
                }
                case let .failure(error):
                print(error)
                completionHandler(0, error)
            }
        }
    }
    
    private func updateControllers() {
        if delegate != nil {
            delegate?.didUpdateSubscription()
        } else {
            delegate?.loadFresh()
        }
    }
    
}

extension AdaptyHandler: AdaptyPaywallControllerDelegate {
    public func paywallController(_ controller: AdaptyPaywallController,
                           didPerform action: AdaptyUI.Action) {

        switch action {
            case .close:
            EventManager.shared.logEvent(title: AdaptyKey.event_subs_paywall_cross_clicked.rawValue)
            self.delegate?.cancelSubscription()
                controller.dismiss(animated: true)
            case let .openURL(url):
                UIApplication.shared.open(url, options: [:])
            case let .custom(id):
                if id == "login" {
                   // implement login flow
                }
                break
        }
    }
    
    public func paywallController(_ controller: AdaptyPaywallController,
                           didSelectProduct product: AdaptyPaywallProduct) {
        print("didSelectProduct")
        //vendorProductId == "monthly_subscription_v3", "yearly_subscription_v2"
        if product.vendorProductId == "monthly_subscription_v3" {
            EventManager.shared.logEvent(title: AdaptyKey.event_subs_paywall_monthly_plan_selected.rawValue)
        } else if product.vendorProductId == "yearly_subscription_v2" {
            EventManager.shared.logEvent(title: AdaptyKey.event_subs_paywall_yearly_plan_selected.rawValue)
        } else {
            print("Unknown plan selected")
        }
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                           didStartPurchase product: AdaptyPaywallProduct) {
        print("didStartPurchase")
    }
    public func paywallController(_ controller: AdaptyPaywallController,
                           didCancelPurchase product: AdaptyPaywallProduct) {
        print("didCancelPurchase")

    }
    public func paywallController(_ controller: AdaptyPaywallController,
                           didFinishPurchase product: AdaptyPaywallProduct,
                           purchasedInfo: AdaptyPurchasedInfo) {
        EventManager.shared.logEvent(title: AdaptyKey.event_subs_purchase_acknowledged.rawValue)
        self.updateControllers()
        controller.dismiss(animated: true)
    }
    public func paywallController(_ controller: AdaptyPaywallController,
                           didFailPurchase product: AdaptyPaywallProduct,
                           error: AdaptyError) {
        EventManager.shared.logEvent(title: AdaptyKey.event_subs_paywall_payment_failed.rawValue)
        print("didFailPurchase")

    }
    public func paywallController(_ controller: AdaptyPaywallController,
                           didFinishRestoreWith profile: AdaptyProfile) {
        if profile.accessLevels["premium"]?.isActive ?? false {
            self.updateControllers()
        }else {
            self.delegate?.alertAction(text: "Nothing to Restore")
        }
        print("didFinishRestoreWith")

    }
    public func paywallController(_ controller: AdaptyPaywallController,
                                  didFailRestoreWith error: AdaptyError) {
        print("didFailRestoreWith")

    }
    public func paywallController(_ controller: AdaptyPaywallController,
                                  didFailLoadingProductsWith error: AdaptyError) -> Bool {
        return true
    }
    public func paywallController(_ controller: AdaptyPaywallController,
                                  didFailRenderingWith error: AdaptyError) {
        print("didFailRenderingWith")

    }
}
