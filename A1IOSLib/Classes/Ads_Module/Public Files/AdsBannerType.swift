//
//  AdsBannerType.swift
//  A1IOSLib
//
//  Created by Mohammad Zaid on 28/11/23.
//

import Foundation

public protocol AdsBannerType: AnyObject {
    /// Show the banner ad.
    ///
    /// - parameter isLandscape: If true banner is sized for landscape, otherwise portrait.
    func show(isLandscape: Bool)

    /// Hide the banner ad.
    func hide()

    /// Removes the banner from its superview.
    func remove()
    
    func show()
}
