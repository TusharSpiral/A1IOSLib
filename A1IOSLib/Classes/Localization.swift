//
//  Localization.swift
//  A1OfficeSDK
//
//  Created by Tushar Goyal on 06/09/23.
//

import Foundation

extension String {
    var localized: String{
      return NSLocalizedString(self, comment: "")
    }
}

struct Localization {
    static let internetError: String = "Internet connection appears to be offline.";
    static let networkError: String = "The network connection was lost.";
    static let priceError: String  = "There was an error fetching prices - please try again";
    static let fetchPlansError: String = "Unable to fetch subscription plans.";
}
