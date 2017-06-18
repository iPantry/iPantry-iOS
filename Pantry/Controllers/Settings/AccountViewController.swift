//
//  AccountViewController.swift
//  Pantry
//
//  Created by Justin Oroz on 6/16/17.
//  Copyright © 2017 Justin Oroz. All rights reserved.
//

import UIKit
import FirebaseAuth

class AccountViewController: UIViewController {

	@IBOutlet weak var userImage: UIImageView!
	@IBOutlet weak var userEmail: UILabel!
	@IBOutlet weak var signOutButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
		self.userEmail.text = Auth.auth().currentUser?.email

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	@IBAction func signOut(_ sender: Any) {
		do {
			try Auth.auth().signOut()
			self.navigationController?.popViewController()
		} catch {
			log(.error, message: "Failed to sign out")
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
