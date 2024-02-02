//
//  DebugViewController.swift
//  A1IOSLib_Example
//
//  Created by Navnidhi Sharma on 27/12/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

extension Bundle {
    var applicationName: String {

        if let displayName: String = self.infoDictionary?["CFBundleDisplayName"] as? String {
            return displayName
        } else if let name: String = self.infoDictionary?["CFBundleName"] as? String {
            return name
        }
        return "No Name Found"
    }
    
    public var shortVersion: String {
        if let result = infoDictionary?["CFBundleShortVersionString"] as? String {
            return result
        } else {
            assert(false)
            return ""
        }
    }

    public var buildVersion: String {
        if let result = infoDictionary?["CFBundleVersion"] as? String {
            return result
        } else {
            assert(false)
            return ""
        }
    }

    public var fullVersion: String {
        return "\(shortVersion)(\(buildVersion))"
    }
}

public class DebugViewController: UIViewController {
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var adsFlagLabel: UILabel!
    
    // MARK: - Initializers

//    public required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        commonInit()
//    }
//
//    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//        commonInit()
//    }
//
//    // MARK: - Common Initialization
//
//    private func commonInit() {
////        let bundle = Bundle(for: DebugViewController.self)
////        print(bundle)
////        if let bundlePath = bundle.resourcePath,
////           let bundleContents = try? FileManager.default.contentsOfDirectory(atPath: bundlePath) {
////            print(bundlePath)
////            print("Bundle Contents: \(bundleContents)")
////        }
//        if let bundlePath = Bundle(for: DebugViewController.self).resourcePath,
//           let bundleContents = try? FileManager.default.contentsOfDirectory(atPath: bundlePath) {
//            print(bundleContents)
//            let storyboards = bundlePath + "/Base.lproj"
//            if let bundleContents = try? FileManager.default.contentsOfDirectory(atPath: storyboards) {
//                print(bundleContents)
//            }
//        }
//        let storyboard = UIStoryboard(name: "Debug", bundle: nil)
//        if let viewController = storyboard.instantiateInitialViewController() as? DebugViewController {
//            // Optionally, you can configure the view controller before presenting or pushing
//            // For example: viewController.property = value
//            // Then present or push the view controller
////            present(viewController, animated: true, completion: nil)
//        }
//    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        let name = Bundle.main.applicationName
        let version = Bundle.main.fullVersion
        guard versionLabel != nil, adsFlagLabel != nil else { return }
#if DEBUG
    print("I'm running in DEBUG mode")
        versionLabel.text = "Version Name = \(name)-\(version)-internal"
#else
    print("I'm running in a non-DEBUG mode")
        versionLabel.text = "Version Name = \(name)-\(version)-production"
#endif
        if Ads.shared.isDisabled == true {
            adsFlagLabel.text = "false"
        } else {
            adsFlagLabel.text = "true"
        }
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func adsAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Debug", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "DebugAdsViewController") as? DebugAdsViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }

}
