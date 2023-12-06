//
//  AdsIntervalTracker.swift
//  A1IOSLib
//
//  Created by Mohammad Zaid on 28/11/23.
//

import Foundation

protocol AdsIntervalTrackerType: AnyObject {
    func canShow(forInterval interval: Int) -> Bool
}

final class AdsIntervalTracker {
    private var counter = 0
}

extension AdsIntervalTracker: AdsIntervalTrackerType {
    func canShow(forInterval interval: Int) -> Bool {
        counter += 1
        
        guard counter >= interval else { return false }
        
        counter = 0
        return true
    }
}
