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

	override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.delegate = self
		self.tableView.dataSource = self

		NotificationCenter.default.addObserver(self, selector: #selector(pantry), name: .pantryListWasUpdated, object: nil)

		// Uncomment the following line to preserve selection between presentations
		// self.clearsSelectionOnViewWillAppear = false

		// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
		// self.navigationItem.rightBarButtonItem = self.editButtonItem()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.tableView.reloadData()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		NotificationCenter.default.removeObserver(self, name: .pantryListWasUpdated, object: nil)
	}

	@objc func pantry (notification: Notification) {
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: - Table view data source

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return PantryUser.current?.pantry?.list.count ?? 0
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? PantryTableViewCell,
			let item = PantryUser.current?.pantry?.list[indexPath.row]
			else {
				// TODO: Return an Error Cell
				return UITableViewCell()
		}

		// Configure the cell...

		cell.configure(from: item)

		return cell
	}

	@IBAction func showSettings(_ sender: Any) {

		let settingsStory = UIStoryboard(name: "Settings", bundle: nil)
		guard let rootNav = settingsStory.instantiateViewController(withIdentifier: "settings") as? SettingsViewController
			else {
				return
		}

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
