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

	var authHandle: AuthStateDidChangeListenerHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
		self.delegate = self

		authHandle = Auth.auth().addStateDidChangeListener() { (auth, user) in
			guard let user = user else {
				print("[INFO]: No User logged in")
				Auth.auth().signInAnonymously() { (user, error) in
					guard error == nil else {
						print("[ERROR]: Could not log in anonymously: \(error!.localizedDescription)")
						// TODO: Alert User, retry
						return
					}
				}
				return
			}

			if user.isAnonymous {
				print("[INFO]: User is logged in anonymously")
			} else {
				print("[INFO]: \(user.email ?? "Someone") is logged in")
			}
		}
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
