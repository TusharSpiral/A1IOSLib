//
//  ConsentManager.swift
//  A1IOSLib_Example
//
//  Created by Tushar Goyal on 06/03/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import UserMessagingPlatform

class ConsentManager {
    
    init() {
        self.requestConsent()
    }
    
    private func requestConsent() {
        let parameters = UMPRequestParameters()
        
        // You can optionally set the `tagForUnderAgeOfConsent` property here
        // parameters.tagForUnderAgeOfConsent = true
        
        UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: parameters) { error in
            if let error = error {
                print("Consent info update failed: \(error.localizedDescription)")
            } else {
                // Check if consent form is available and required
                self.loadForm()
            }
        }
    }
    
    private func loadForm() {
        UMPConsentForm.load { [weak self] (form, error) in
            if let error = error {
                print("Failed to load form: \(error.localizedDescription)")
            } else if let form = form {
                DispatchQueue.main.async {
                    // Show the consent form
                    if let vc = UIApplication.shared.windows.first?.rootViewController {
                        form.present(from: vc) { (dismissError) in
                            if UMPConsentInformation.sharedInstance.consentStatus == .required {
                                print("Consent required but not obtained")
                                // Handle the case where consent is required but not obtained.
                            } else {
                                // Consent obtained or not required; proceed with personalized or non-personalized ads
                                print("Consent status: \(UMPConsentInformation.sharedInstance.consentStatus.rawValue)")
                            }
                        }
                    }
                }
            }
        }
    }
}
