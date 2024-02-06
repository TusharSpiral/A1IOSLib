# A1IOSLib

[![CI Status](https://img.shields.io/travis/TusharSpiral/A1IOSLib.svg?style=flat)](https://travis-ci.org/TusharSpiral/A1IOSLib)
[![Version](https://img.shields.io/cocoapods/v/A1IOSLib.svg?style=flat)](https://cocoapods.org/pods/A1IOSLib)
[![License](https://img.shields.io/cocoapods/l/A1IOSLib.svg?style=flat)](https://cocoapods.org/pods/A1IOSLib)
[![Platform](https://img.shields.io/cocoapods/p/A1IOSLib.svg?style=flat)](https://cocoapods.org/pods/A1IOSLib)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.
Module 1. How to use Ads module?

1. AppDelegate.swift didFinishLaunchingWithOptions method
First launch
Initiate ads using default configuration and after that fetch remote config and save configuration in persistant storage and update the ad units, show / hide ad formats and update intervals accordingly
Second launch onwards
Initiate ads using persistant storage configuration using remote config and after that fetch remote config and save configuration in persistant storage and update the ad units, show / hide ad formats and update intervals accordingly

        AdsHandler.shared.configureAds(config: getAdConfig() pro: AppUserDefaults.isPro)
        FirebaseHandler.getRemoteConfig { [weak self] (result) in
            if let settings = self {
                switch result {
                case .success(let result):
                    saveConfigInUserDefaults(result: result)
                    AdsHandler.shared.configureAds(config: getAdConfig() pro: AppUserDefaults.isPro)
                case .failure(let error):
                    print("getRemoteConfig Failure: \(error.localizedDescription)")
                }
            }
        }
        
        func saveConfigInUserDefaults(result: FirebaseConfig) {
            let adConfig = result.adConfig
            UserDefaults.standard.setValue(adConfig.interInterval, forKey: "interInterval")
            UserDefaults.standard.setValue(adConfig.appOpenInterval, forKey: "appOpenInterval")
            UserDefaults.standard.setValue(adConfig.appOpenInterInterval, forKey: "appOpenInterInterval")
            UserDefaults.standard.setValue(adConfig.interClickInterval, forKey: "interClickInterval")

            UserDefaults.standard.setValue(adConfig.adsEnabled, forKey: "adsEnabled")
            UserDefaults.standard.setValue(adConfig.interEnabled, forKey: "interEnabled")
            UserDefaults.standard.setValue(adConfig.appOpenEnabled, forKey: "appOpenEnabled")
            UserDefaults.standard.setValue(adConfig.bannerEnabled, forKey: "bannerEnabled")

            UserDefaults.standard.setValue(adConfig.appOpenID, forKey: "appOpenID")
            UserDefaults.standard.setValue(adConfig.interID, forKey: "interID")
            UserDefaults.standard.setValue(adConfig.bannerID, forKey: "bannerID")
            UserDefaults.standard.synchronize()
        }

        func getAdConfig() -> AdsConfiguration {
            return AdsConfiguration(interInterval: UserDefaults.standard.integer(forKey: "interInterval"), adsEnabled: UserDefaults.standard.bool(forKey: "adsEnabled"), interEnabled: UserDefaults.standard.bool(forKey: "interEnabled"), interID: UserDefaults.standard.string(forKey: "interID") ?? "", appOpenEnabled: UserDefaults.standard.bool(forKey: "appOpenEnabled") , appOpenID: UserDefaults.standard.string(forKey: "appOpenID") ?? "", bannerEnabled: UserDefaults.standard.bool(forKey: "bannerEnabled"), bannerID: UserDefaults.standard.string(forKey: "bannerID") ?? "", appOpenInterval: UserDefaults.standard.integer(forKey: "appOpenInterval"), appOpenInterInterval: UserDefaults.standard.integer(forKey: "appOpenInterInterval"), interClickInterval: UserDefaults.standard.integer(forKey: "interClickInterval"))
        }

        
2. Scene delegate sceneWillEnterForeground method
Show app open ad on visible view controller - If ad available then show directly otherwise add spalsh screen with 3 seconds timer, check ad availability every second. If not received ad in 3 seconds then skip app open ad and remove splash screen.
We are avoiding app open ad showing for below conditions
    1. The first launch of app - as per apple guidelines we should allow user to use the app before showing app open ad.
    2. If opening app via share intent
    3. If app open ad showing already - two ads shouldn't overlap
    4. If Inter ad showing already - two ads shouldn't overlap

        func visibleViewController(rootViewController:UIViewController?) -> UIViewController? {
            if rootViewController == nil { return nil }
            
            if rootViewController is UINavigationController {
                let rootNavControler:UINavigationController = rootViewController as! UINavigationController
                return visibleViewController(rootViewController:rootNavControler.visibleViewController)
            }
            else if rootViewController is UITabBarController {
                let rootTabControler:UITabBarController = rootViewController as! UITabBarController
                return visibleViewController(rootViewController:rootTabControler.selectedViewController)
            }
            else if (rootViewController?.presentedViewController != nil) {
                return visibleViewController(rootViewController:rootViewController?.presentedViewController)
            }
            
            return rootViewController
        }

        if AdsHandler.shared.canShowAppOpenAd(), AppManager.shared.loadPageType != .onboarding, AppManager.shared.loadPageType != .shareIntent {
            if let vc = visibleViewController(rootViewController: window?.rootViewController) {
                if AdsHandler.shared.appOpenAdAvailable() {
                    Ads.shared.showAppOpenAd(from: vc) {
                    } onClose: {
                    } onError: { error in
                    }
                } else {
                    let splashViewController = AppOpenSplashViewController.buildViewController(imageName: "welcome")
                    vc.presentVC(splashViewController, animated: false)
                }
            }
        }
3. Show inter ad preferred from screen navigation, tab change, paywall closing, creatng new document etc.
you will receive inter ad as full screen ad and will be presented on provided controller
    func showInterAd() {
        guard AdsHandler.shared.canShowInterAd() else {
            proceedAfterInterAd()
            return
        }
        AdsHandler.shared.a1Ads.showInterstitialAd(
            from: self,
            onOpen: {
                print(" interstitial ad did open")
            },
            onClose: {
                print(" interstitial ad did close")
                AdsHandler.shared.interLoadTime = Date()
                self.proceedAfterInterAd()
            },
            onError: { error in
                print(" interstitial ad error \(error)")
                self.proceedAfterInterAd()
            }
        )
    }
        
    func proceedAfterInterAd() {
        // Show next screen user selected
    }

4. Show banner ad - you will receive banner ad view you can add on containerView placed anywhere on screen.
    Add Shimmer on banner ad container:
        Create ad container view using ShimmerView class
        call containerView.startAnimating() method if want to start animate
        call containerView.stopAnimating() method if want to stop animate
        
    Show banner on containerView
    func showBanner() {
        guard AdsHandler.shared.canShowBannerAd() else {
            return
        }
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
        DispatchQueue.main.async {
            self.bannerAd = banner?.0
            if let bannerView = banner?.1 {
                self.containerView.addSubview(bannerView)
                self.bannerAd?.show()
            }
        }
    }

Module 2. How to use force update feature?
1. AppDelegate.swift didFinishLaunchingWithOptions method
Provide app store url and version config after fetching from remote config and save version config in local for the current session
        FirebaseHandler.getRemoteConfig { [weak self] (result) in
            if let settings = self {
                switch result {
                case .success(let result):
                    saveVersionConfigInLocalStorage()
                    AppUpdate.shared.configureAppUpdate(url: APP_STORE_URL, config: result.versionConfig)
                case .failure(let error):
                    print("getRemoteConfig Failure: \(error.localizedDescription)")
                }
            }
        }
        
2. Scene delegate sceneWillEnterForeground method - check for force update only
        AppUpdate.shared.checkUpdate(canCheckOptionalUpdate: false)

3. Home screen view will appear method - check for force and optional update
    AppUpdate.shared.checkUpdate()
    
Module 3. How to use debug module?

Create instance of DebugViewController and push from navigation controller. Preferrered to keep a debug option in settings.
    let viewController = DebugViewController.buildViewController()
    navigationController?.pushViewController(validViewController, animated: true)
    
Note: This module is only for the internal builds. So, please make sure remove / hide this option before going live.

Module 4. How to use events module?

1. AppDelegate.swift didFinishLaunchingWithOptions method - configure event manager - by default event_app_first_open event will be triggered from this method
    appMetrica and mixpanel is optional. Firebase and facebook is true by default if you don't want to use simply pass false
    EventManager.shared.configureEventManager(appMetricaKey: "", mixPanelKey: "", firebase: false, facebook: false)
2. Log any event
    logEvent(title: EVENT_NAME, keys: EVENT_KEYS_LIST, values: EVENT_VALUES_LIST)
    
Module 5. How to use Purchasely module?

1. AppDelegate.swift didFinishLaunchingWithOptions method - configure purchasely
        PurchaselyHelper.shared.configurePurchasely()

2. Show paywall and implement listeners
        PurchaselyHelper.shared.showFreeTrial(from: self, placement: PLACEMENT_IDENTIFIER, content: CONTENT_IDENTIFIER, delegate: self)
        Required Listener:
            func didUpdateSubscription() - called when user successfully purchased subscription
            func alertAction(text: String?) - called if any alert need to show on screen
            func loader(isShown: Bool) - used to show/hide loader on screen
        Optional Listener:
            func cancelSubscription() - called when user cancelled the subscription

Module 6. How to get IDFA tracking user permission?
    Call checkAndShowPermissionPopup method from first landing screen viewWillAppear of your app
    
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



## Requirements

## Installation

A1IOSLib is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'A1IOSLib'
```

## Author

TusharSpiral, TusharSpiral@github.com

## License

A1IOSLib is available under the MIT license. See the LICENSE file for more info.
