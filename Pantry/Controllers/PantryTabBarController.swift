//
//  PantryTabBarController.swift
//  Pantry
//
//  Created by Justin Oroz on 6/10/17.
//  Copyright © 2017 Justin Oroz. All rights reserved.
//

import UIKit
import FirebaseAuth

class PantryTabBarController: UITabBarController, UITabBarControllerDelegate {

	override func viewDidLoad() {
		super.viewDidLoad()
		self.delegate = self
	}

	override func viewWillAppear(_ animated: Bool) {

	}

	override func viewWillDisappear(_ animated: Bool) {

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
		if let controller = viewController as? UINavigationController {
			controller.popToRootViewController(animated: false)
		}
	}

	/*
	// MARK: - Navigation

	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
	}
	*/

}
