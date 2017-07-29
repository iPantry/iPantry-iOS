//
//  SettingsViewController.swift
//  Pantry
//
//  Created by Justin Oroz on 6/10/17.
//  Copyright © 2017 Justin Oroz. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseFacebookAuthUI
import FirebaseDatabase

class SettingsViewController: UITableViewController, FUIAuthDelegate {

	let authUI = FUIAuth.defaultAuthUI()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
		self.authUI?.delegate = self

		let providers: [FUIAuthProvider] = [
			FUIGoogleAuth(),
			FUIFacebookAuth()
			]
		self.authUI?.providers = providers

    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.navigationItem.hidesBackButton = true
		self.tabBarController?.tabBar.isHidden = true
		if PantryUser.current != nil {
			NotificationCenter.default.addObserver(self, selector: #selector(pantryUser), name: nil, object: PantryUser.current)
		}
	}

	@objc func pantryUser(notification: Notification) {
		switch notification.name {
		case Notification.Name.pantryUserWasUpdated, Notification.Name.pantryUserDoesNotExist :
			// Do stuff
			DispatchQueue.main.async {
				self.tableView.reloadSections([0], with: .fade)
			}

		default:
			// some other notification
			return
		}

	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		if PantryUser.current != nil {
			NotificationCenter.default.removeObserver(self, name: nil, object: PantryUser.current)
		}

		self.navigationItem.hidesBackButton = true
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

	// MARK: - FirebaseUI Auth Delegate
	func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
	}

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		switch section {
		case 0:
			return 1
		case 1:
			return 5
		default:
			return 0
		}
    }

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch indexPath.section {
		case 0:
			return 80
		case 1:
			return 60
		default:
			return 0
		}
	}

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			// check if logged in and present proper cell

			if let state = PantryUser.current?.state, state == .loggedIn {
				guard let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath) as? SettingsAccountCell
					else {
						fb_log(.error, message: "Unable to dequeue accountCell")
						return UITableViewCell()
				}
				// Configure the cell...

				return cell
			} else {
				guard let cell = tableView.dequeueReusableCell(withIdentifier: "signInCell", for: indexPath) as? SettingsSignInCell
					else {
						fb_log(.error, message: "Unable to dequeue signInCell")
						return UITableViewCell()
				}
				// Configure the cell...

				return cell
			}
		} else {
			// other settings cells
			let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath)
			// Configure the cell...

			return cell
		}

    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 0 {
			if tableView.cellForRow(at: indexPath)?.reuseIdentifier == "signInCell" {
				self.present(authUI!.authViewController(), animated: true, completion: nil)
			} else {
				let accountPage = UIViewController.instantiate(withIdentifier: "account", in: "Settings")
				self.navigationController?.pushViewController(accountPage)
			}
		}
	}

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
