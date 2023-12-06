//
//  AdsInterstitial.swift
//  A1IOSLib
//
//  Created by Mohammad Zaid on 28/11/23.
//

import Foundation

import GoogleMobileAds

protocol AdsInterstitialType: AnyObject {
    var isReady: Bool { get }
    func load()
    func stopLoading()
    func show(from viewController: UIViewController,
              onOpen: (() -> Void)?,
              onClose: (() -> Void)?,
              onError: ((Error) -> Void)?)
}

final class AdsInterstitial: NSObject {

    // MARK: - Properties

    private let environment: AdsEnvironment
    private let adUnitId: String
    private let request: () -> GADRequest
    
    private var onOpen: (() -> Void)?
    private var onClose: (() -> Void)?
    private var onError: ((Error) -> Void)?
    
    private var interstitialAd: GADInterstitialAd?
    
    // MARK: - Initialization
    
    init(environment: AdsEnvironment, adUnitId: String, request: @escaping () -> GADRequest) {
        self.environment = environment
        self.adUnitId = adUnitId
        self.request = request
    }
}

// MARK: - AdsInterstitialType

extension AdsInterstitial: AdsInterstitialType {
    var isReady: Bool {
        interstitialAd != nil
    }
    
    func load() {
        GADInterstitialAd.load(withAdUnitID: adUnitId, request: request()) { [weak self] (ad, error) in
            guard let self = self else { return }

            if let error = error {
                self.onError?(error)
                return
            }

            self.interstitialAd = ad
            self.interstitialAd?.fullScreenContentDelegate = self
        }
    }

    func stopLoading() {
        interstitialAd?.fullScreenContentDelegate = nil
        interstitialAd = nil
    }
    
    func show(from viewController: UIViewController,
              onOpen: (() -> Void)?,
              onClose: (() -> Void)?,
              onError: ((Error) -> Void)?) {
        self.onOpen = onOpen
        self.onClose = onClose
        self.onError = onError
        
        guard let interstitialAd = interstitialAd else {
            load()
            onError?(AdsError.interstitialAdNotLoaded)
            return
        }

        do {
            try interstitialAd.canPresent(fromRootViewController: viewController)
            interstitialAd.present(fromRootViewController: viewController)
        } catch {
            load()
            onError?(error)
        }
    }
}

// MARK: - GADFullScreenContentDelegate

extension AdsInterstitial: GADFullScreenContentDelegate {
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        if case .development = environment {
            print("AdsInterstitial did record impression for ad: \(ad)")
        }
    }

    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        onOpen?()
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        // Nil out reference
        interstitialAd = nil
        // Send callback
        onClose?()
        // Load the next ad so its ready for displaying
        load()
    }

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        onError?(error)
    }
}
