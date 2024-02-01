//
//  AdsBanner.swift
//  A1IOSLib
//
//  Created by Mohammad Zaid on 28/11/23.
//
import GoogleMobileAds

final class AdsBanner: NSObject {
    
    // MARK: - Properties

    private let isDisabled: () -> Bool
    private let request: () -> GADRequest

    private var onOpen: (() -> Void)?
    private var onClose: (() -> Void)?
    private var onError: ((Error) -> Void)?
    private var onWillPresentScreen: (() -> Void)?
    private var onWillDismissScreen: (() -> Void)?
    private var onDidDismissScreen: (() -> Void)?

    private var bannerView: GADBannerView?
    
    // MARK: - Initialization
    
    init(isDisabled: @escaping () -> Bool,
         request: @escaping () -> GADRequest) {
        self.isDisabled = isDisabled
        self.request = request
        super.init()
    }

    // MARK: - Convenience
    
    func prepare(withAdUnitId adUnitId: String,
                 in viewController: UIViewController,
                 onOpen: (() -> Void)?,
                 onClose: (() -> Void)?,
                 onError: ((Error) -> Void)?,
                 onWillPresentScreen: (() -> Void)?,
                 onWillDismissScreen: (() -> Void)?,
                 onDidDismissScreen: (() -> Void)?) -> GADBannerView {
        self.onOpen = onOpen
        self.onClose = onClose
        self.onError = onError
        self.onWillPresentScreen = onWillPresentScreen
        self.onWillDismissScreen = onWillDismissScreen
        self.onDidDismissScreen = onDidDismissScreen
        // Create banner view
        let bannerView = GADBannerView()
        bannerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 60)

        // Keep reference to created banner view
        self.bannerView = bannerView

        // Set ad unit id
        bannerView.adUnitID = adUnitId

        // Set the root view controller that will display the banner view
        bannerView.rootViewController = viewController

        // Set the banner view delegate
        bannerView.delegate = self

        return bannerView
    }
}

// MARK: - AdsBannerType

extension AdsBanner: AdsBannerType {
    func show() {
        EventManager.shared.logEvent(title: AdsKey.event_ad_banner_shown.rawValue)
        guard !isDisabled() else { return }
        guard let bannerView = bannerView else { return }
        bannerView.adSize = GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width)
        bannerView.load(request())
    }
    
    func remove() {
        guard bannerView != nil else { return }
        
        bannerView?.delegate = nil
        bannerView?.removeFromSuperview()
        bannerView = nil
        onClose?()
    }
}

// MARK: - GADBannerViewDelegate

extension AdsBanner: GADBannerViewDelegate {
    // Request lifecycle events
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        print("AdsBanner did record impression for banner ad")
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        onOpen?()
        print("AdsBanner did receive ad from: \(bannerView.responseInfo?.loadedAdNetworkResponseInfo?.adNetworkClassName ?? "not found")")
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        EventManager.shared.logEvent(title: AdsKey.event_ad_banner_load_failed.rawValue)
        EventManager.shared.logEvent(title: AppErrorKey.event_ad_error_load_failed.rawValue, key: "error", value: error.localizedDescription)
        onError?(error)
    }

    // Click-Time lifecycle events
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        EventManager.shared.logEvent(title: AdsKey.event_ad_banner_show_requested.rawValue)
        onWillPresentScreen?()
    }

    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        onWillDismissScreen?()
    }

    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        onDidDismissScreen?()
    }
}
