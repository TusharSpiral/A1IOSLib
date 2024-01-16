//
//  PlainViewController.swift
//  A1IOSLib_Example
//
//  Created by Mohammad Zaid on 28/11/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import A1IOSLib

final class PlainViewController: UIViewController {

    // MARK: - Properties

    private let a1Ads: AdsType
    private var bannerAd: AdsBannerType?
    
    private lazy var interstitialAdButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show Interstitial ad (2 interval)", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(showInterstitialAdButtonPressed), for: .touchUpInside)
        return button
    }()

    private lazy var rewardedAdButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show rewarded ad", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(showRewardedAdButtonPressed), for: .touchUpInside)
        return button
    }()

    private lazy var rewardedInterstitialAdButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show rewarded interstitial ad", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(showRewardedInterstitialAdButtonPressed), for: .touchUpInside)
        return button
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [interstitialAdButton, rewardedAdButton, rewardedInterstitialAdButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 32
        return stackView
    }()

    // MARK: - Init

    init(a1Ads: AdsType) {
        self.a1Ads = a1Ads
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - De-Initialization

    deinit {
        print("Deinit PlainViewController")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubviews()

       let banner = a1Ads.makeBannerAd(
            in: self,
            position: .bottom(isUsingSafeArea: true),
            animation: .slide(duration: 1.5),
            onOpen: {_ in 
                print(" banner ad did open")
            },
            onClose: {
                print(" banner ad did close")
            },
            onError: { error in
                print(" banner ad error \(error)")
            },
            onWillPresentScreen: {
                print(" banner ad was tapped and is about to present screen")
            },
            onWillDismissScreen: {
                print(" banner ad screen is about to be dismissed")
            },
            onDidDismissScreen: {
                print(" banner did dismiss screen")
            }
        )
        // show banner on any of the view you want to
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bannerAd?.show(isLandscape: view.frame.width > view.frame.height)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.bannerAd?.show(isLandscape: size.width > size.height)
        })
    }
}

// MARK: - Private Methods

private extension PlainViewController {

    func addSubviews() {
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc func showInterstitialAdButtonPressed() {
        a1Ads.showInterstitialAd(
            from: self,
            afterInterval: 2,
            onOpen: {
                print(" interstitial ad did open")
            },
            onClose: {
                print(" interstitial ad did close")
            },
            onError: { error in
                print(" interstitial ad error \(error)")
            }
        )
    }
    
    @objc func showRewardedAdButtonPressed() {
        a1Ads.showRewardedAd(
            from: self,
            onOpen: {
                print(" rewarded ad did open")
            },
            onClose: {
                print(" rewarded ad did close")
            },
            onError: { error in
                print(" rewarded ad error \(error)")
            },
            onNotReady: { [weak self] in
                guard let self = self else { return }
                let alertController = UIAlertController(
                    title: "Sorry",
                    message: "No video available to watch at the moment.",
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(title: "Ok", style: .cancel))
                DispatchQueue.main.async {
                    self.present(alertController, animated: true)
                }
            },
            onReward: ({ rewardAmount in
                print(" rewarded ad did reward user with \(rewardAmount)")
            })
        )
    }

    @objc func showRewardedInterstitialAdButtonPressed() {
        a1Ads.showRewardedInterstitialAd(
            from: self,
            afterInterval: nil,
            onOpen: {
                print(" rewarded interstitial ad did open")
            },
            onClose: {
                print(" rewarded interstitial ad did close")
            },
            onError: { error in
                print(" rewarded interstitial ad error \(error)")
            },
            onReward: { rewardAmount in
                print(" rewarded interstitial ad did reward user with \(rewardAmount)")
            }
        )
    }
}
