//
//  AdsType.swift
//  A1IOSLib
//
//  Created by Mohammad Zaid on 28/11/23.
//
import GoogleMobileAds

public enum AdsAdUnitIdType {
    case plist
    case custom(String)
}

public enum AdsBannerAdAnimation {
    case none
    case fade(duration: TimeInterval)
    case slide(duration: TimeInterval)
}

public enum AdsBannerAdPosition {
    case top(isUsingSafeArea: Bool)
    case bottom(isUsingSafeArea: Bool)
}

public enum AdsNativeAdLoaderOptions {
    case single
    case multiple(Int)
}

public protocol AdsRequestBuilderType: AnyObject {
    func build() -> GADRequest
}

public protocol AdsType: AnyObject {
    var isAppOpenAdReady: Bool { get }
    var isInterstitialAdReady: Bool { get }
    var isRewardedAdReady: Bool { get }
    var isRewardedInterstitialAdReady: Bool { get }
    var isDisabled: Bool { get }
    
    func configure(from viewController: UIViewController,
                   for environment: AdsEnvironment,
                   requestBuilder: AdsRequestBuilderType)
    
    func makeBannerAd(in viewController: UIViewController,
                      adUnitIdType: AdsAdUnitIdType,
                      position: AdsBannerAdPosition,
                      animation: AdsBannerAdAnimation,
                      onOpen: ((GADBannerView?) -> Void)?,
                      onClose: (() -> Void)?,
                      onError: ((Error) -> Void)?,
                      onWillPresentScreen: (() -> Void)?,
                      onWillDismissScreen: (() -> Void)?,
                      onDidDismissScreen: (() -> Void)?) -> AdsBannerType?
    
    func showAppOpenAd(from viewController: UIViewController,
                      afterInterval interval: Int?,
                      onOpen: (() -> Void)?,
                      onClose: (() -> Void)?,
                      onError: ((Error) -> Void)?)
    
    func showInterstitialAd(from viewController: UIViewController,
                            afterInterval interval: Int?,
                            onOpen: (() -> Void)?,
                            onClose: (() -> Void)?,
                            onError: ((Error) -> Void)?)
    
    func showRewardedAd(from viewController: UIViewController,
                        onOpen: (() -> Void)?,
                        onClose: (() -> Void)?,
                        onError: ((Error) -> Void)?,
                        onNotReady: (() -> Void)?,
                        onReward: @escaping (NSDecimalNumber) -> Void)
    
    func showRewardedInterstitialAd(from viewController: UIViewController,
                                    afterInterval interval: Int?,
                                    onOpen: (() -> Void)?,
                                    onClose: (() -> Void)?,
                                    onError: ((Error) -> Void)?,
                                    onReward: @escaping (NSDecimalNumber) -> Void)
    
    func loadNativeAd(from viewController: UIViewController,
                      adUnitIdType: AdsAdUnitIdType,
                      loaderOptions: AdsNativeAdLoaderOptions,
                      onFinishLoading: (() -> Void)?,
                      onError: ((Error) -> Void)?,
                      onReceive: @escaping (GADNativeAd) -> Void)
    
    func setDisabled(_ isDisabled: Bool)
}
