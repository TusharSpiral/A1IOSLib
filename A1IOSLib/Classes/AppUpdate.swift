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
    var versionConfig: VersionConfig?
    var appStoreURL: String?
    
    public func configureAppUpdate(url: String, config: VersionConfig) {
        appStoreURL = url
        versionConfig = config
    }
    
    /**
     Checks for Firebase remote config and check if update needed.
     
     - Parameter success: Completion handler gives FirebaseConfig model
     - Parameter failure: Completion handler gives Error
     */
    public func checkUpdate(canCheckOptionalUpdate: Bool = true) {
        guard let config = versionConfig else { return }
        let forceUpdate = checkForceUpdateNeeded(config: config)
        print("Old Force update needed \(forceUpdate)")
        if forceUpdate == false, canCheckOptionalUpdate == true {
            let optionalUpdate = checkOptionalUpdateNeeded(config: config)
            print("Old Optional update needed \(optionalUpdate)")
        }
    }
    
    /// Checks for Firebase - Remote config properties for server maintenance and application update
    /// - Parameter config: FirebaseConfig model
    func checkForceUpdateNeeded(config: VersionConfig) -> Bool {
        guard config.stableVersion != "", !config.stableVersion.isEmpty else {
            return false
        }
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let appComponents = appVersion.components(separatedBy: ".")
        let firebaseVersion = config.stableVersion
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
                var title = config.forceTitle
                if title == "" || title.isEmpty {
                    title = "App update required"
                }
                var message = config.forceMessage
                if message == "" || message.isEmpty {
                    message = "A new version is available. Please update your app before proceeding."
                }
                Utility.showAlert(title:title, message:message, defaultTitle: "Update Now", defaultHandler: handler)
            }
            return true
        } else {
            return false
        }
    }
    
    func checkOptionalUpdateNeeded(config: VersionConfig) -> Bool {
        guard isOptionalUpdateShown == false else { return false }
        guard config.minVersion != "", !config.minVersion.isEmpty else {
            return false
        }
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let appComponents = appVersion.components(separatedBy: ".")
        let firebaseVersion = config.minVersion
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
                var title = config.optionalTitle
                if title == "" || title.isEmpty {
                    title = "App update available"
                }
                var message = config.optionalMessage
                if message == "" || message.isEmpty {
                    message = "We have incorporated several innovative enhancements in this latest update."
                }
                Utility.showAlert(title: title, message: message, defaultTitle: "Maybe Later", defaultHandler: handler, isCancel: true, cancelTitle: "Update Now", cancelHandler: handler1)
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
}
