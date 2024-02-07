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
    fetchConfig()
    
    func fetchConfig() {
        FirebaseHandler.getRemoteConfig { [weak self] (result) in
            if let settings = self {
                switch result {
                case .success(let result):
                    settings.saveConfigInUserDefaults(result: result)
                    AdsHandler.shared.configureAds(config: settings.getAdConfig(), pro: false)
                case .failure(let error):
                    print("getRemoteConfig Failure: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func saveConfigInUserDefaults(result: FirebaseConfig) {
        
        let adConfig = result.adConfig
        
        AppUserDefaults.interInterval = adConfig.interInterval
        AppUserDefaults.appOpenInterval = adConfig.appOpenInterval
        AppUserDefaults.appOpenInterInterval = adConfig.appOpenInterInterval
        AppUserDefaults.interClickInterval = adConfig.interClickInterval
        
        AppUserDefaults.adsEnabled = adConfig.adsEnabled
        AppUserDefaults.interEnabled = adConfig.interEnabled
        AppUserDefaults.appOpenEnabled = adConfig.appOpenEnabled
        AppUserDefaults.bannerEnabled = adConfig.bannerEnabled
        
        AppUserDefaults.appOpenID = adConfig.appOpenID
        AppUserDefaults.interID = adConfig.interID
        AppUserDefaults.bannerID = adConfig.bannerID
    }

    func getAdConfig() -> AdsConfiguration {
        
        let appOpenID = AppUserDefaults.appOpenID
        let bannerID = AppUserDefaults.bannerID
        let interID = AppUserDefaults.interID
        
        if !appOpenID.isEmpty, !bannerID.isEmpty, !interID.isEmpty {
            
            return AdsConfiguration(
                interInterval: AppUserDefaults.interInterval,
                adsEnabled: AppUserDefaults.adsEnabled,
                interEnabled: AppUserDefaults.interEnabled,
                interID: interID,
                appOpenEnabled: AppUserDefaults.appOpenEnabled,
                appOpenID: appOpenID,
                bannerEnabled: AppUserDefaults.bannerEnabled,
                bannerID: bannerID,
                appOpenInterval: AppUserDefaults.appOpenInterval,
                appOpenInterInterval: AppUserDefaults.appOpenInterInterval,
                interClickInterval: AppUserDefaults.interClickInterval
            )
            
        }
        
        return AdsConfiguration()
    }

        
2. Scene delegate sceneWillEnterForeground method
Show app open ad on visible view controller - If ad available then show directly otherwise add spalsh screen with 3 seconds timer, check ad availability every second. If not received ad in 3 seconds then skip app open ad and remove splash screen.

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

        if AdsHandler.shared.canShowAppOpenAd()  {
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
    Add Shimmer for banner ad:
        Create shimmer view using ShimmerView class and add on screen
        call startAnimating() method if want to start animate
        call stopAnimating() method if want to hide shimmer
        
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
                    AppUpdate.shared.configureAppUpdate(url: APP_STORE_URL, config: result.versionConfig)
                case .failure(let error):
                    print("getRemoteConfig Failure: \(error.localizedDescription)")
                }
            }
        }
        
2. Scene delegate sceneWillEnterForeground method - check for force update only
        if isFreshLaunch == false {
            AppUpdate.shared.checkUpdate(canCheckOptionalUpdate: false)
        }

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
