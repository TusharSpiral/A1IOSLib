//
//  HSBeacon.swift
//  A1IOSLib
//
//  Created by Tushar Goyal on 12/09/23.
//

import Foundation
import Beacon

public struct HSBeaconManager {
    
    public static func open(id: String) {
        let settings = HSBeaconSettings(beaconId: id)
        HSBeacon.open(settings)
    }
    
}
