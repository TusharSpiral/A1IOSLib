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
                return "Debug using pods"
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
        //makeBanner()
        //bannerAd?.show(isLandscape: view.frame.width > view.frame.height)
        //showAppOpenAd()
    }

    func showAppOpenAd() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.a1Ads.showAppOpenAd(from: self, afterInterval: 0) {
                
            } onClose: {
                
            } onError: { error in
                
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.bannerAd?.show(isLandscape: size.width > size.height)
        })
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
            let banner = a1Ads.makeBannerAd(
                in: self,
                position: .bottom(isUsingSafeArea: true),
                animation: .fade(duration: 1.5),
                onOpen: { bannerView in
                    print(" banner ad did open")
                    if let myBanner = bannerView {
                        bannerView?.frame = CGRectMake(0, 0, myBanner.frame.width, myBanner.frame.height)
                        cell.contentView.addSubview(myBanner)
                    }
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
                let storyboard = UIStoryboard(name: "Debug", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "DebugViewController") as? DebugViewController {
                    navigationController?.pushViewController(vc, animated: true)
                }
            case .tabBarController:
//                if let vc = a1Ads.getDebugScreen() {
//                    navigationController?.pushViewController(vc, animated: true)
//                }
//                let vc = DebugViewController()
//                navigationController?.pushViewController(vc, animated: true)
                //let bundleName = Bundle(for: EventHandler.self)
//                dump()
//                let storyboard = UIStoryboard(name: "Debug", bundle: A1IOSLib.nibBundle?.bundleURL)
//                if let vc = storyboard.instantiateViewController(withIdentifier: "DebugViewController") as? DebugViewController {
//                    self.navigationController?.pushViewController(vc, animated: true)
//                }
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                if let vc = storyboard.instantiateViewController(withIdentifier: "MasterTabbarController") as? MasterTabbarController {
//                    navigationController?.pushViewController(vc, animated: true)
//                }
                break
            case .nativeAd:
                viewController = NativeAdViewController(a1Ads: a1Ads)
            case .updateConsent:
                break
                
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
}

// MARK: - Private Methods

private extension DemoSelectionViewController {

    @objc func adsConfigureCompletion() {
        if bannerAd == nil {
            makeBanner()
        }
        bannerAd?.show(isLandscape: view.frame.width > view.frame.height)
        tableView.reloadData()
    }

    func makeBanner() {
        let banner = a1Ads.makeBannerAd(
            in: self,
            position: .bottom(isUsingSafeArea: true),
            animation: .fade(duration: 1.5),
            onOpen: { bannerView in
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
}

