//
//  Utility.swift
//  A1IOSLib
//
//  Created by Navnidhi Sharma on 22/01/24.
//

import UIKit

class Utility {
    class func showAlert(title:String = "Alert", message: String, defaultTitle: String? = "Ok", defaultHandler: ((UIAlertAction) -> Void)? = nil, isCancel: Bool = false, cancelTitle: String? = "Cancel", cancelHandler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: defaultTitle, style: UIAlertAction.Style.default, handler: defaultHandler))
        if isCancel {
            alert.addAction(UIAlertAction(title: cancelTitle, style: UIAlertAction.Style.cancel, handler: cancelHandler))
        }
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1;
        
        if let keyWindow = UIApplication.shared.windows.first,
           let rootViewController = keyWindow.rootViewController {
            rootViewController.present(alert, animated: true, completion: nil)

//            if rootViewController is InitialViewController,
//               let presentedVc = rootViewController.presentedViewController as? ParentViewController {
//                presentedVc.present(alert, animated: true, completion: nil)
//            } else {
//                rootViewController.present(alert, animated: true, completion: nil)
//            }
        }
    }

}

// Helper function inserted by Swift 4.2 migrator.
func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
