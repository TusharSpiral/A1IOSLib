//
//  AdsRewarded.swift
//  A1IOSLib
//
//  Created by Mohammad Zaid on 28/11/23.
//

import Foundation
import GoogleMobileAds

protocol AdsRewardedType: AnyObject {
    var isReady: Bool { get }
    var isShowing: Bool { get }
    func load()
    func show(from viewController: UIViewController,
              onOpen: (() -> Void)?,
              onClose: (() -> Void)?,
              onError: ((Error) -> Void)?,
              onNotReady: (() -> Void)?,
              onReward: @escaping (NSDecimalNumber) -> Void)
}

final class AdsRewarded: NSObject {

    // MARK: - Properties

    private let adUnitId: String
    private let request: () -> GADRequest
    
    private var onOpen: (() -> Void)?
    private var onClose: (() -> Void)?
    private var onError: ((Error) -> Void)?
    
    private var isShowingRewardedAd = false
    private var rewardedAd: GADRewardedAd?

    // MARK: - Initialization
    
    init(adUnitId: String, request: @escaping () -> GADRequest) {
        self.adUnitId = adUnitId
        self.request = request
    }
}

// MARK: - AdsRewardedType

extension AdsRewarded: AdsRewardedType {
    var isReady: Bool {
        rewardedAd != nil
    }
    
    var isShowing: Bool {
        isShowingRewardedAd
    }
    
    func load() {
        GADRewardedAd.load(withAdUnitID: adUnitId, request: request()) { [weak self] (ad, error) in
            guard let self = self else { return }

            if let error = error {
                self.onError?(error)
                return
            }

            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
            
        }
    }
 
    func show(from viewController: UIViewController,
              onOpen: (() -> Void)?,
              onClose: (() -> Void)?,
              onError: ((Error) -> Void)?,
              onNotReady: (() -> Void)?,
              onReward: @escaping (NSDecimalNumber) -> Void) {
        self.onOpen = onOpen
        self.onClose = onClose
        self.onError = onError
        
        guard let rewardedAd = rewardedAd else {
            load()
            onError?(AdsError.rewardedAdNotLoaded)
            onNotReady?()
            return
        }

        do {
            try rewardedAd.canPresent(fromRootViewController: viewController)
            let rewardAmount = rewardedAd.adReward.amount
            rewardedAd.present(fromRootViewController: viewController, userDidEarnRewardHandler: {
                onReward(rewardAmount)
            })
        } catch {
            load()
            onError?(error)
            onNotReady?()
            return
        }
    }
}

// MARK: - GADFullScreenContentDelegate

extension AdsRewarded: GADFullScreenContentDelegate {
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("AdsRewarded did record impression for ad: \(ad)")
    }

    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        isShowingRewardedAd = true
        onOpen?()
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        // Nil out reference
        isShowingRewardedAd = false
        rewardedAd = nil
        // Send callback
        onClose?()
        // Load the next ad so its ready for displaying
        load()
    }

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        onError?(error)
    }
}
