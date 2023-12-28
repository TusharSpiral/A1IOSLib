//
//  AdsConfiguration.swift
//  A1IOSLib
//
//  Created by Mohammad Zaid on 28/11/23.
//

import Foundation

public struct AdsConfiguration: Decodable, Equatable {
    public let appOpenAdUnitId: String?
    public let bannerAdUnitId: String?
    public let interstitialAdUnitId: String?
    public let rewardedAdUnitId: String?
    public let rewardedInterstitialAdUnitId: String?
    public let nativeAdUnitId: String?
}

public extension AdsConfiguration {
    static func production(bundle: Bundle = .main) -> AdsConfiguration {
        guard let url = bundle.url(forResource: "AdsUnitId", withExtension: "plist") else {
            fatalError("AdsUnitId could not find AdsUnitId.plist in the main bundle.")
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            return try decoder.decode(AdsConfiguration.self, from: data)
        } catch {
            fatalError("AdsUnitId decoding AdsUnitId.plist error: \(error).")
        }
    }

    // https://developers.google.com/admob/ios/test-ads
    static func debug() -> AdsConfiguration {
        AdsConfiguration(
            appOpenAdUnitId: "ca-app-pub-3940256099942544/9257395921",
            bannerAdUnitId: "ca-app-pub-3940256099942544/2934735716",
            interstitialAdUnitId: "ca-app-pub-3940256099942544/4411468910",
            rewardedAdUnitId: "ca-app-pub-3940256099942544/1712485313",
            rewardedInterstitialAdUnitId: "ca-app-pub-3940256099942544/6978759866",
            nativeAdUnitId: "ca-app-pub-3940256099942544/3986624511"
        )
    }
}
