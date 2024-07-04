//
//  ViewController.swift
//  A1IOSLib
//
//  Created by TusharSpiral on 09/08/2023.
//  Copyright (c) 2023 TusharSpiral. All rights reserved.
//

import UIKit
import A1IOSLib

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        EventHandler.shared.logEvent(title: .testing)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func btnHSBeaconTapped(_ sender: Any) {
        HSBeaconManager.open(id: "08c6e40e-271f-4a8f-b74d-5b9d73ce3251")
    }
    
    @IBAction func setAds(_ sender: Any) {
        
    }
    
    
    
}
