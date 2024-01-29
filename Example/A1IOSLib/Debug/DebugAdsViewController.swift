//
//  DebugAdsViewController.swift
//  A1IOSLib
//
//  Created by Navnidhi Sharma on 26/12/23.
//

import UIKit
import A1IOSLib
enum DebugAdsType {
    case appOpen
    case inter
    case rewarded
    case rewardedInter
    case banner
    case native
}
class DebugAdsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var debugTableView: UITableView!
    @IBOutlet weak var bannerContainer: UIView!
    private var bannerAd: AdsBannerType?

    var adsList = ["APP OPEN", "INTER", "REWARDED", "REWARDED INTER", "BANNER", "NATIVE"]
    var adsType: [DebugAdsType] = [.appOpen, .inter, .rewarded, .rewardedInter, .banner, .native]
    var idsText = "ADMOB\t\t\t\tInitialized = true"
    override func viewDidLoad() {
        super.viewDidLoad()
        debugTableView.register(UINib(nibName: "DebugTableViewCell", bundle: nil), forCellReuseIdentifier: "DebugCell")
        debugTableView.register(UINib(nibName: "DebugTextCell", bundle: nil), forCellReuseIdentifier: "DebugTextCell")
        // Do any additional setup after loading the view.
        idsText.append("\n\n\nApp Open Ad unit id\n")
        idsText.append(Ads.shared.getConfiguration?.appOpenAdUnitId ?? "NA")
        idsText.append("\n\n\nInter Ad unit id\n")
        idsText.append(Ads.shared.getConfiguration?.interstitialAdUnitId ?? "NA")
        idsText.append("\n\n\nRewarded Ad unit id\n")
        idsText.append(Ads.shared.getConfiguration?.rewardedAdUnitId ?? "NA")
        idsText.append("\n\n\nBanner Ad unit id\n")
        idsText.append(Ads.shared.getConfiguration?.bannerAdUnitId ?? "NA")
        idsText.append("\n\n\nNative Ad unit id\n")
        idsText.append(Ads.shared.getConfiguration?.nativeAdUnitId ?? "NA")
        idsText.append("\n\n\n")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 6
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Controls"
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "DebugTextCell", for: indexPath) as? DebugTextCell {
                cell.debugTextLabel.text = idsText
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "DebugCell", for: indexPath) as? DebugTableViewCell {
                cell.titleLabel.text = adsList[indexPath.row]
                cell.type = adsType[indexPath.row]
                cell.show = { [weak self] in
                    self?.showAds(type: cell.type)
                }
                cell.load = { [weak self] in
                    self?.loadAds(type: cell.type)
                }
                return cell
            }
        }
        return DebugTableViewCell()
    }
    
    func loadAds(type: DebugAdsType) {
        guard Ads.shared.isDisabled == false else { return }
        switch type {
        case .appOpen:
            loadAppOpen()
        case .inter:
            loadInter()
        case .rewarded:
            loadRewarded()
        case .rewardedInter:
            loadRewardedInter()
        case .banner:
            loadBanner()
        case .native:
            loadNative()
        }
    }
    
    func showAds(type: DebugAdsType) {
        guard Ads.shared.isDisabled == false else { return }
        switch type {
        case .appOpen:
            showAppOpen()
        case .inter:
            showInter()
        case .rewarded:
            showRewarded()
        case .rewardedInter:
            showRewardedInter()
        case .banner:
            showBanner()
        case .native:
            showNative()
        }
    }
    
    func loadAppOpen() {
        
    }
    
    func loadInter() {
        
    }

    func loadRewarded() {
        
    }
    
    func loadRewardedInter() {
        
    }

    func loadBanner() {
        
    }

    func loadNative() {
        
    }
    
    func showAppOpen() {
        Ads.shared.showAppOpenAd(from: self, afterInterval: 0) {
            
        } onClose: {
            
        } onError: { error in
            
        }
    }
    
    func showInter() {
        Ads.shared.showInterstitialAd(
            from: self,
            afterInterval: 0,
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

    func showRewarded() {
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
    
    func showRewardedInter() {
        Ads.shared.showRewardedInterstitialAd(
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

    func showBanner() {
        // show banner on any of the view you want to
        let banner = Ads.shared.makeBannerAd(
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
                self.bannerContainer.addSubview(bannerView)
                self.bannerAd?.show()
            }
        }
    }

    func showNative() {
        let nativeviewController = NativeAdViewController(a1Ads: Ads.shared)
        navigationController?.pushViewController(nativeviewController, animated: true)
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
