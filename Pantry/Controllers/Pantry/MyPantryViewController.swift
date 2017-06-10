//
//  MyPantryViewController.swift
//  Pantry
//
//  Created by Justin Oroz on 11/12/16.
//  Copyright © 2016 Justin Oroz. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MyPantryViewController: UITableViewController {

	var authHandle: AuthStateDidChangeListenerHandle?

    override func viewDidLoad() {
        super.viewDidLoad()

		authHandle = (self.tabBarController as? PantryTabBarController)?.authHandle


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

//		authHandle = Auth.auth().addStateDidChangeListener() { (auth, user) in
//			guard let user = user else {
//				print("[INFO]: No User logged in")
//				Auth.auth().signInAnonymously() { (user, error) in
//					guard error == nil else {
//						print("[ERROR]: Could not log in anonymously: \(error!.localizedDescription)")
//						// TODO: Alert User, retry
//						return
//					}
//				}
//				return
//			}
//
//			if user.isAnonymous {
//				print("[INFO]: User is logged in anonymously")
//			} else {
//				print("[INFO]: \(user.email ?? "Someone") is logged in")
//			}
//		}
	}




	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		Auth.auth().removeStateDidChangeListener(authHandle!)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! PantryTableViewCell

        // Configure the cell...

		cell.setItemData("Hot Pockets", quantity: 10, expirationDays: -7)
		

        return cell
    }

	@IBAction func showSettings(_ sender: Any) {

		let settingsStory = UIStoryboard(name: "Settings", bundle: nil)
		let rootNav = settingsStory.instantiateViewController(withIdentifier: "settings") as! SettingsViewController


		UIView.beginAnimations("animation", context: nil)
		UIView.setAnimationDuration(0.7)
		self.navigationController?.pushViewController(rootNav, animated: false)
		UIView.setAnimationTransition(.flipFromRight, for: self.navigationController!.view, cache: false)
		UIView.commitAnimations()
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
