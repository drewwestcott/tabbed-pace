//
//  SecondViewController.swift
//  tabbed-pace
//
//  Created by Drew Westcott on 22/03/2017.
//  Copyright © 2017 Drew Westcott. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {
	
	@IBOutlet weak var settingsSwitch: UISwitch!
	
	let settingsData = UserDefaults.standard
	
	override func viewDidLoad() {
		super.viewDidLoad()

		if let distanceSetting = settingsData.string(forKey: "distanceSetting") {
			if distanceSetting == "miles" {
				
				
			}
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

