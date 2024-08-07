//
//  DemoSelectionViewController.swift
//  A1IOSLib_Example
//
//  Created by Mohammad Zaid on 28/11/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//
import UIKit
import A1IOSLib

final class DemoSelectionViewController: UITableViewController {
          
    // MARK: - Types

    enum Section: CaseIterable {
        case main
        case secondary

        func rows(isRequiredToAskForConsent: Bool) -> [Row] {
            switch self {
            case .main:
                return [
                    .viewController,
                    .viewControllerInsideTabBar,
                    .tabBarController,
                    .nativeAd
                ]
            case .secondary:
                return [
                    isRequiredToAskForConsent ? .updateConsent : nil,
                    .disable
                ].compactMap { $0 }
            }
        }
    }
    
    enum Row {
        case viewController
        case viewControllerInsideTabBar
        case tabBarController
        case nativeAd

        case updateConsent
        case disable

        var title: String {
            switch self {
            case .viewController:
                return "ViewController"
            case .viewControllerInsideTabBar:
                return "Debug"
            case .tabBarController:
                return "Rewarded Ad"
            case .nativeAd:
                return "Native Ad"
            case .updateConsent:
                return "Update Consent Status"
            case .disable:
                return "Disable Ads"
            }
        }

        var accessoryType: UITableViewCell.AccessoryType {
            switch self {
            case .updateConsent, .disable:
                return .none
            default:
                return .disclosureIndicator
            }
        }

        var shouldDeselect: Bool {
            switch self {
            case .updateConsent, .disable:
                return true
            default:
                return false
            }
        }
    }
    
    // MARK: - Properties

    private let a1Ads: AdsType
    private let sections = Section.allCases
    private let notificationCenter: NotificationCenter = .default
    private var bannerAd: AdsBannerType?

    // MARK: - Initialization
    
    init(a1Ads: AdsType) {
        self.a1Ads = a1Ads

        if #available(iOS 13.0, *) {
            super.init(style: .insetGrouped)
        } else {
            super.init(style: .grouped)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - De-Initialization

    deinit {
        print("Deinit DemoSelectionViewController")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "A1 iOS Ads Demo"
        tableView.register(BasicCell.self, forCellReuseIdentifier: String(describing: BasicCell.self))
        notificationCenter.addObserver(self, selector: #selector(adsConfigureCompletion), name: .adsConfigureCompletion, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        checkAndShowPermissionPopup()
//        AppUpdate.shared.checkUpdate()
    }

    func showAppOpenAd() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.a1Ads.showAppOpenAd(from: self) {
                
            } onClose: {
                
            } onError: { error in
                
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
        
    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count + 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < sections.count {
            return sections[section].rows(isRequiredToAskForConsent: false).count
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: BasicCell.self), for: indexPath) as! BasicCell
        if indexPath.section < sections.count {
            let row = sections[indexPath.section].rows(isRequiredToAskForConsent: false)[indexPath.row]
            cell.configure(title: row.title, accessoryType: row.accessoryType)
        } else {
            // show banner on any of the view you want to
            let banner = Ads.shared.makeBannerAd(
                in: self,
                onOpen: {
                    print(" banner ad did open")
                },
                onClose: {
                    print(" banner ad did close")
                },
                onError: { error in
                    print(" banner ad error \(error)")
                    self.bannerAd?.remove()
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
            DispatchQueue.main.async {
                self.bannerAd = banner?.0
                if let bannerView = banner?.1 {
                    cell.contentView.addSubview(bannerView)
                    self.bannerAd?.show()
                }
            }

        }
        return cell
        
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section < sections.count {
            let row = sections[indexPath.section].rows(isRequiredToAskForConsent: false)[indexPath.row]
            var viewController: UIViewController?
            
            if row.shouldDeselect {
                tableView.deselectRow(at: indexPath, animated: true)
            }
            
            switch row {
            case .viewController:
                let plainViewController = PlainViewController(a1Ads: a1Ads)
                viewController = plainViewController
            case .viewControllerInsideTabBar:
                viewController = DebugViewController.buildViewController()
            case .tabBarController:
                tableView.deselectRow(at: indexPath, animated: true)
                showRewarded()
            case .nativeAd:
                viewController = NativeAdViewController()
            case .updateConsent: break
            case .disable:
                a1Ads.setDisabled(true)
                bannerAd?.remove()
                bannerAd = nil
                showDisabledAlert()
            }
            
            guard let validViewController = viewController else { return }
            validViewController.navigationItem.title = row.title
            navigationController?.pushViewController(validViewController, animated: true)
        }
    }
    
    func showRewarded() {
        guard AdsHandler.shared.canShowRewardedAd() else { return }
        Ads.shared.showRewardedAd(
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

}

// MARK: - Private Methods

private extension DemoSelectionViewController {

    @objc func adsConfigureCompletion() {
        if bannerAd == nil {
            makeBanner()
        }
        tableView.reloadData()
    }

    func makeBanner() {
        let banner = a1Ads.makeBannerAd(
            in: self,
            onOpen: {
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

    func showDisabledAlert() {
        let alertController = UIAlertController(
            title: "Ads Disabled",
            message: "All ads, except rewarded ads, have been disabled and will no longer display",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in }
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }
    
    func checkAndShowPermissionPopup() {
        if #available(iOS 14, *) {
            let viewModel = TrackingViewModel()
            if viewModel.shouldShowAppTrackingDialog() {
                viewModel.requestAppTrackingPermission { (status) in
                    viewModel.updateCurrentStatus()
                }
            } else {
                print("IDFA", viewModel.getIDFA())
            }
        }
    }
}

