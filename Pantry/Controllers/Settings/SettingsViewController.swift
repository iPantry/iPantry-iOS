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

		self.navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(returnToColorTabs))
		//		self.navigationController?.navigationBar.backItem?.backBarButtonItem?.action = #selector(back)

        // Do any additional setup after loading the view.
    }

	func returnToColorTabs(){
		let _ = self.navigationController?.popViewController(animated: false)
	}


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
