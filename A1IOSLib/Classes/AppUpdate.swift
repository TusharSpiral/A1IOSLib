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
public class AppUpdate {
    public static var shared = AppUpdate()
    private var isOptionalUpdateShown = false
    public var versionConfig: VersionConfig?
    public var appStoreURL: String?
    
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
        if !checkForceUpdateNeeded(config: config), canCheckOptionalUpdate {
            _ = checkOptionalUpdateNeeded(config: config)
        }
    }
    
    /// Checks for Firebase - Remote config properties for server maintenance and application update
    /// - Parameter config: FirebaseConfig model
    private func checkForceUpdateNeeded(config: VersionConfig) -> Bool {
        guard !config.stableVersion.isEmpty, let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return false
        }
        if config.stableVersion.compare(appVersion, options: .numeric) == .orderedDescending {
            print("force version is newer than app version")
            let handler: (UIAlertAction) -> () = { [weak self] (alert) in
                if let urlString = self?.appStoreURL {
                    Utility.openAppStore(urlString: urlString)
                }
            }
            DispatchQueue.main.async {
                Utility.showAlert(title:config.forceTitle, message:config.forceMessage, defaultTitle: "Update Now", defaultHandler: handler)
            }
            return true
        } else {
            return false
        }
    }
    
    private func checkOptionalUpdateNeeded(config: VersionConfig) -> Bool {
        guard isOptionalUpdateShown == false, let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return false }
        guard !config.minVersion.isEmpty else {
            return false
        }
        if config.minVersion.compare(appVersion, options: .numeric) == .orderedDescending {
            print("optional version is newer than app version")
            let handler: (UIAlertAction) -> () = { [weak self] (alert) in
                self?.isOptionalUpdateShown = true
            }
            let handler1: (UIAlertAction) -> () = { [weak self] (alert) in
                self?.isOptionalUpdateShown = true
                if let urlString = self?.appStoreURL {
                    Utility.openAppStore(urlString: urlString)
                }
            }
            DispatchQueue.main.async {
                Utility.showAlert(title: config.optionalTitle, message: config.optionalMessage, defaultTitle: "Maybe Later", defaultHandler: handler, isCancel: true, cancelTitle: "Update Now", cancelHandler: handler1)
            }
            return true
        } else {
            return false
        }
    }
}
