//
//  AppDelegate.swift
//  Example
//
//  Created by Marius Kazemekaitis on 2020-01-09.
//  Copyright © 2020 Treatwell. All rights reserved.
//

import UIKit
import TWHud

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        TWHud.configure(with:
            TWHud.Configuration(
                maskImage: UIImage(named: "LoaderLogoMask")!,
                //cornerRadius: 10.0,
                //size: CGSize(width: 200, height: 200),
                colours: [
                    UIColor(red: 214.0/255.0, green: 206.0/255.0, blue: 144.0/255.0, alpha: 1.0),
                    UIColor(red: 28.0/255.0, green: 173.0/255.0, blue: 186.0/255.0, alpha: 1.0),
                    UIColor(red: 2.0/255.0, green: 33.0/255.0, blue: 96.0/255.0, alpha: 1.0),
                    UIColor(red: 253.0/255.0, green: 129.0/255.0, blue: 141.0/255.0, alpha: 1.0),
                    UIColor(red: 123.0/255.0, green: 212.0/255.0, blue: 84.0/255.0, alpha: 1.0),
                    UIColor(red: 252.0/255.0, green: 93.0/255.0, blue: 65.0/255.0, alpha: 1.0),
                    UIColor(red: 238.0/255.0, green: 221.0/255.0, blue: 49.0/255.0, alpha: 1.0)
                ]
            )
        )
        
        TWHud.shared?.nextFillColourIndexIsValid = { next, previous in
            var valid: Bool = next != previous
            if valid {
                if next == 0 {
                    valid = next != 6
                } else if next == 6 {
                    valid = next != 0
                } else if next == 3 {
                    valid = next != 5
                } else if next == 5 {
                    valid = next != 3
                }
            }
            
            return valid
        }
        
        return true
    }
}

