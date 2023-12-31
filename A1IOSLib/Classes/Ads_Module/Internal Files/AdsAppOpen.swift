//
//  AdsAppOpen.swift
//  A1IOSLib
//
//  Created by Mohammad Zaid on 29/11/23.
//

import Foundation

import GoogleMobileAds

protocol AdsAppOpenType: AnyObject {
    var isReady: Bool { get }
    var isShowing: Bool { get }
    func load()
    func stopLoading()
    func show(from viewController: UIViewController,
              onOpen: (() -> Void)?,
              onClose: (() -> Void)?,
              onError: ((Error) -> Void)?)
}

protocol AppOpenAdManagerDelegate: AnyObject {
  /// Method to be invoked when an app open ad life cycle is complete (i.e. dismissed or fails to
  /// show).
  func appOpenAdManagerAdDidComplete(_ appOpenAdManager: AppOpenAdManager)
}

final class AppOpenAdManager: NSObject {
    private let environment: AdsEnvironment
    private let adUnitId: String
    private let request: () -> GADRequest

  /// Ad references in the app open beta will time out after four hours,
  /// but this time limit may change in future beta versions. For details, see:
  /// https://support.google.com/admob/answer/9341964?hl=en
  let timeoutInterval: TimeInterval = 4 * 3_600
  /// The app open ad.
  var appOpenAd: GADAppOpenAd?
  /// Maintains a reference to the delegate.
  weak var appOpenAdManagerDelegate: AppOpenAdManagerDelegate?
  /// Keeps track of if an app open ad is loading.
  var isLoadingAd = false
  /// Keeps track of if an app open ad is showing.
  var isShowingAd = false
  /// Keeps track of the time when an app open ad was loaded to discard expired ad.
  var loadTime: Date?
    
    private var onOpen: (() -> Void)?
    private var onClose: (() -> Void)?
    private var onError: ((Error) -> Void)?

  //static let shared = AppOpenAdManager()
    
    init(environment: AdsEnvironment, adUnitId: String, request: @escaping () -> GADRequest) {
        self.environment = environment
        self.adUnitId = adUnitId
        self.request = request
    }

  private func wasLoadTimeLessThanNHoursAgo(timeoutInterval: TimeInterval) -> Bool {
    // Check if ad was loaded more than n hours ago.
    if let loadTime = loadTime {
      return Date().timeIntervalSince(loadTime) < timeoutInterval
    }
    return false
  }

  private func isAdAvailable() -> Bool {
    // Check if ad exists and can be shown.
    return appOpenAd != nil && wasLoadTimeLessThanNHoursAgo(timeoutInterval: timeoutInterval)
  }

  private func appOpenAdManagerAdDidComplete() {
    // The app open ad is considered to be complete when it dismisses or fails to show,
    // call the delegate's appOpenAdManagerAdDidComplete method if the delegate is not nil.
    appOpenAdManagerDelegate?.appOpenAdManagerAdDidComplete(self)
  }

  func loadAd() {
    // Do not load ad if there is an unused ad or one is already loading.
    if isLoadingAd || isAdAvailable() {
      return
    }
    isLoadingAd = true
    print("Start loading app open ad.")
    GADAppOpenAd.load(
      withAdUnitID: adUnitId,
      request: GADRequest(),
      orientation: UIInterfaceOrientation.portrait
    ) { ad, error in
      self.isLoadingAd = false
      if let error = error {
        self.appOpenAd = nil
        self.loadTime = nil
        print("App open ad failed to load with error: \(error.localizedDescription)")
        return
      }

      self.appOpenAd = ad
      self.appOpenAd?.fullScreenContentDelegate = self
      self.loadTime = Date()
      print("App open ad loaded successfully.")
    }
  }

  func showAdIfAvailable(viewController: UIViewController,
                         onOpen: (() -> Void)?,
                         onClose: (() -> Void)?,
                         onError: ((Error) -> Void)?) {
      self.onOpen = onOpen
      self.onClose = onClose
      self.onError = onError
    // If the app open ad is already showing, do not show the ad again.
    if isShowingAd {
      print("App open ad is already showing.")
      return
    }
    // If the app open ad is not available yet but it is supposed to show,
    // it is considered to be complete in this example. Call the appOpenAdManagerAdDidComplete
    // method and load a new ad.
    if !isAdAvailable() {
      print("App open ad is not ready yet.")
      appOpenAdManagerAdDidComplete()
      loadAd()
      return
    }
    if let ad = appOpenAd {
      print("App open ad will be displayed.")
      isShowingAd = true
      ad.present(fromRootViewController: viewController)
    }
  }
}

// MARK: - GADFullScreenContentDelegate

extension AppOpenAdManager: GADFullScreenContentDelegate {
  func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("App open ad is will be presented.")
    onOpen?()
  }

  func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    appOpenAd = nil
    isShowingAd = false
    print("App open ad was dismissed.")
    appOpenAdManagerAdDidComplete()
      // Send callback
      onClose?()
      // Load the next ad so its ready for displaying
      loadAd()
  }

  func ad(
    _ ad: GADFullScreenPresentingAd,
    didFailToPresentFullScreenContentWithError error: Error
  ) {
    appOpenAd = nil
    isShowingAd = false
    print("App open ad failed to present with error: \(error.localizedDescription)")
    appOpenAdManagerAdDidComplete()
    loadAd()
  }
}

extension AppOpenAdManager: AdsAppOpenType {
    var isReady: Bool {
        return isAdAvailable()
    }
    
    var isShowing: Bool {
        return isShowingAd
    }

    func load() {
        loadAd()
    }
    
    func stopLoading() {
        appOpenAd?.fullScreenContentDelegate = nil
        appOpenAd = nil
    }
    
    func show(from viewController: UIViewController, onOpen: (() -> Void)?, onClose: (() -> Void)?, onError: ((Error) -> Void)?) {
        self.onOpen = onOpen
        self.onClose = onClose
        self.onError = onError
        
//        guard let appOpenAd = appOpenAd else {
//            load()
//            onError?(AdsError.appOpenAdNotLoaded)
//            return
//        }
        
//        do {
//            try appOpenAd.canPresent(fromRootViewController: viewController)
//            appOpenAd.present(fromRootViewController: viewController)
//        } catch {
//            load()
//            onError?(error)
//        }
        
        showAdIfAvailable(viewController: viewController,
                          onOpen: onOpen,
                          onClose: onClose,
                          onError: onError
        )
    }
    
    
}
