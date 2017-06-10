//
//  SettingsViewController.swift
//  Pantry
//
//  Created by Justin Oroz on 3/13/17.
//  Copyright © 2017 Justin Oroz. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		self.tabBarController?.tabBar.isHidden = true

    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.navigationItem.hidesBackButton = true
	}


	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		self.navigationItem.hidesBackButton = false
	}


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

	@IBAction func done(_ sender: Any) {
		UIView.beginAnimations("animation", context: nil)
		UIView.setAnimationDuration(0.7)
		UIView.setAnimationTransition(.flipFromRight, for: self.navigationController!.view, cache: false)
		self.tabBarController?.tabBar.isHidden = false
		self.navigationController?.popToRootViewController(animated: false)
		UIView.commitAnimations()
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
