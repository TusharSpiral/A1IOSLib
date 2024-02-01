//
//  MasterTabbarController.swift
//  A1IOSLib_Example
//
//  Created by Navnidhi Sharma on 01/01/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import A1IOSLib
import GoogleMobileAds
class MasterTabbarController: UITabBarController {
    private var bannerAd: AdsBannerType?
    var adsContainer = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeBanner()
    }
    
    func makeBanner() {
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
    
    func adBannerOnTabBar(banner: GADBannerView) {
        self.tabBar.addSubview(banner)
        banner.translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint(item: banner, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: tabBar, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
        tabBar.addConstraint(constraint)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
