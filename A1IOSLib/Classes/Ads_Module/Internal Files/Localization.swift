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
    static let internetError: String = "INTERNET_ERROR".localized
    static let networkError: String = "NETWORK_ERROR".localized
    static let priceError: String  = "PRICE_ERROR".localized
    static let fetchPlansError: String = "FETCH_PLANS_ERROR".localized
    static let updateNow: String  = "UPDATE_NOW".localized
    static let maybeLater: String  = "MAYBE_LATER".localized
//    static let : String  = "".localized
}
