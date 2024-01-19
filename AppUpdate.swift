//
//  AppUpdate.swift
//  A1Office
//
//  Created by Navnidhi Sharma on 19/01/24.
//

import UIKit

// Prerequisits
// Firebase configure method must call before requesting the firebase config
// app store url must be set before checking update
public class AppUpdate: NSObject {
    public static var shared = AppUpdate()
    var isOptionalUpdateShown = false
    var firebaseConfig: FirebaseConfig = FirebaseConfig()
    var isConfigFetched = false
    var appStoreURL: String?
    
    public func setAppStoreURL(url: String) {
        appStoreURL = url
    }
    /**
     Checks for Firebase remote config and check if update needed.
     
     - Parameter success: Completion handler gives FirebaseConfig model
     - Parameter failure: Completion handler gives Error
     */
    public func checkUpdate(canCheckOptionalUpdate: Bool = true) {
        if isConfigFetched == true {
            let forceUpdate = checkForceUpdateNeeded(config: firebaseConfig)
            print("Old Force update needed \(forceUpdate)")
            if forceUpdate == false, canCheckOptionalUpdate == true {
                let optionalUpdate = checkOptionalUpdateNeeded(config: firebaseConfig)
                print("Old Optional update needed \(optionalUpdate)")
            }
        } else {
            FirebaseHandler.getRemoteConfig { [weak self] (result) in
                if let self = self {
                    switch result {
                    case .success(let result):
                        self.isConfigFetched = true
                        self.firebaseConfig = result
                        let forceUpdate = self.checkForceUpdateNeeded(config: result)
                        print("Fresh Force update needed \(forceUpdate)")
                        if forceUpdate == false, canCheckOptionalUpdate == true {
                            let optionalUpdate = self.checkOptionalUpdateNeeded(config: result)
                            print("Fresh Optional update needed \(optionalUpdate)")
                        }
                    case .failure(let error):
                        print("getRemoteConfig Failure: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    /// Checks for Firebase - Remote config properties for server maintenance and application update
    /// - Parameter config: FirebaseConfig model
    func checkForceUpdateNeeded(config: FirebaseConfig) -> Bool {
        let config = firebaseConfig
        guard config.versionConfig.stableVersion != "", !config.versionConfig.stableVersion.isEmpty else {
            return false
        }
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let appComponents = appVersion.components(separatedBy: ".")
        let firebaseVersion = config.versionConfig.stableVersion
        let firebaseComponents = firebaseVersion.components(separatedBy: ".")
        var isUpgradeNeeded = false
        if firebaseComponents.count > 0 && appComponents.count > 0 {
            for (index, firebaseDigit) in firebaseComponents.enumerated() {
                if appComponents.count > index {
                    let firebaseVersionInt = Int(firebaseDigit) ?? 0
                    let appVersionInt = Int(appComponents[index]) ?? 0
                    if firebaseVersionInt > appVersionInt {
                        isUpgradeNeeded = true
                        break
                    } else if firebaseVersionInt < appVersionInt {
                        break
                    }
                }
            }
        }
        if isUpgradeNeeded {
            let handler: (UIAlertAction) -> () = { [weak self] (alert) in
                self?.openAppStore()
            }
            DispatchQueue.main.async {
                var title = config.versionConfig.forceTitle
                if title == "" || title.isEmpty {
                    title = "App update required"
                }
                var message = config.versionConfig.forceMessage
                if message == "" || message.isEmpty {
                    message = "A new version is available. Please update your app before proceeding."
                }
                AppUpdate.showAlert(title:title, message:message, defaultTitle: "Update Now", defaultHandler: handler)
            }
            return true
        } else {
            return false
        }
    }
    
    func checkOptionalUpdateNeeded(config: FirebaseConfig) -> Bool {
        guard isOptionalUpdateShown == false else { return false }
        let config = firebaseConfig
        guard config.versionConfig.minVersion != "", !config.versionConfig.minVersion.isEmpty else {
            return false
        }
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let appComponents = appVersion.components(separatedBy: ".")
        let firebaseVersion = config.versionConfig.minVersion
        let firebaseComponents = firebaseVersion.components(separatedBy: ".")
        var isUpgradeNeeded = false
        if firebaseComponents.count > 0 && appComponents.count > 0 {
            for (index, firebaseDigit) in firebaseComponents.enumerated() {
                if appComponents.count > index {
                    let firebaseVersionInt = Int(firebaseDigit) ?? 0
                    let appVersionInt = Int(appComponents[index]) ?? 0
                    if firebaseVersionInt > appVersionInt {
                        isUpgradeNeeded = true
                        break
                    } else if firebaseVersionInt < appVersionInt {
                        break
                    }
                }
            }
        }
        if isUpgradeNeeded {
            let handler: (UIAlertAction) -> () = { [weak self] (alert) in
                self?.isOptionalUpdateShown = true
            }
            let handler1: (UIAlertAction) -> () = { [weak self] (alert) in
                self?.isOptionalUpdateShown = true
                self?.openAppStore()
            }
            DispatchQueue.main.async {
                var title = config.versionConfig.optionalTitle
                if title == "" || title.isEmpty {
                    title = "App update available"
                }
                var message = config.versionConfig.optionalMessage
                if message == "" || message.isEmpty {
                    message = "We have incorporated several innovative enhancements in this latest update."
                }
                AppUpdate.showAlert(title: title, message: message, defaultTitle: "Maybe Later", defaultHandler: handler, isCancel: true, cancelTitle: "Update Now", cancelHandler: handler1)
            }
            return true
        } else {
            return false
        }
    }

    /// Opens applications app store URL
    func openAppStore() {
        if let urlString = appStoreURL {
            if let url = URL(string: urlString),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options:
                                            convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:])
                                          ,completionHandler: nil)
            }
        }
        return
    }

    class func showAlert(title:String = "Alert", message: String, defaultTitle: String? = "Ok", defaultHandler: ((UIAlertAction) -> Void)? = nil, isCancel: Bool = false, cancelTitle: String? = "Cancel", cancelHandler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: defaultTitle, style: UIAlertAction.Style.default, handler: defaultHandler))
        if isCancel {
            alert.addAction(UIAlertAction(title: cancelTitle, style: UIAlertAction.Style.cancel, handler: cancelHandler))
        }
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1;
        
        if let keyWindow = UIApplication.shared.windows.first,
           let rootViewController = keyWindow.rootViewController {
            rootViewController.present(alert, animated: true, completion: nil)

//            if rootViewController is InitialViewController,
//               let presentedVc = rootViewController.presentedViewController as? ParentViewController {
//                presentedVc.present(alert, animated: true, completion: nil)
//            } else {
//                rootViewController.present(alert, animated: true, completion: nil)
//            }
        }
    }

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
