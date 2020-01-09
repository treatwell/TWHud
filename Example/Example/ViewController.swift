//
//  ViewController.swift
//  Example
//
//  Created by Marius Kazemekaitis on 2020-01-09.
//  Copyright © 2020 Treatwell. All rights reserved.
//

import UIKit
import TWHud

class ViewController: UIViewController {
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        container.backgroundColor = .lightGray
    }
    @IBAction func hideKeyboard(_ sender: Any) {
        textField.resignFirstResponder()
    }
    
    @IBAction func showHud() {
        TWHud.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            TWHud.dismiss()
        }
    }
    
    @IBAction func showHudInView() {
        let hud = TWHud.showIn(view: container, configuration: TWHud.Configuration(
            maskImage: UIImage(named: "LoaderLogoMask64")!,
            hudBackgroundColour: UIColor.lightGray,
            containerBackgroundColour: UIColor.lightGray,
            colours: [.red, .green, .blue, .yellow])
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            hud.dismiss()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showHud()
    }
}

