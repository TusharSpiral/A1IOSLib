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
    
    public static func open(id: String, appVersion: String, osVersion: String, device: String, isPro: Bool) {
        let user = HSBeaconUser()
        user.addAttribute(withKey: "App version", value: appVersion)
        user.addAttribute(withKey: "OS version", value: osVersion)
        user.addAttribute(withKey: "Device", value: device)
        user.addAttribute(withKey: "Premium Status", value: isPro.description)
        HSBeacon.identify(user)
        let settings = HSBeaconSettings(beaconId: id)
        HSBeacon.open(settings)
    }
    
}
