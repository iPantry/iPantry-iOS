//
//  SecondViewController.swift
//  Pantry
//
//  Created by Justin Oroz on 9/1/16.
//  Copyright © 2016 Justin Oroz. All rights reserved.
//

import UIKit
import MTBBarcodeScanner
import PermissionScope
import DeviceKit
import SwifterSwift

class UPCScanViewController: UIViewController, UPCScannerViewDelegate {

	var upcScannerView: UPCScannerView {
		// swiftlint:disable:next force_cast
		return self.view as! UPCScannerView
	}

	// MARK: - View Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()

		self.setNeedsStatusBarAppearanceUpdate()
		self.upcScannerView.delegate = self
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.navigationController?.setNavigationBarHidden(true, animated: false)
		self.tabBarController?.tabBar.isHidden = true

	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.navigationController?.setNavigationBarHidden(false, animated: true)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent //or default
	}

	// MARK: - Layout

	// MARK: - User Interaction

	// MARK: - ScannerDelegate
	func scanner(didFind upc: String, completion: @escaping (Bool) -> Void) {
		// TODO: Search Firebase for Suggestions
		// Search UPCDB for data

		Item.lookup(by: upc) { (item, error) in
			let alert = UIAlertController()

			guard error == nil else {
				alert.title = "Error"
				alert.message = "An error occured checking the UPC. Please try again"
				alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { _ in
					completion(true)
				}))
				DispatchQueue.main.async {
					alert.show()
				}
				return
			}

			guard let item = item else {
				alert.title = "UPC Not Found"
				alert.message = "Would you like to continue anyway?"
				alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
					completion(false)
					self.performSegue(withIdentifier: "editDetails", sender: Item(upc))
				}))
				alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
					completion(true)
				}))
				DispatchQueue.main.async {
					alert.show()
				}
				return
			}

			DispatchQueue.main.async {
				self.performSegue(withIdentifier: "editDetails", sender: item)
			}
		}
	}

	func backWasTapped() {
		let _ = self.navigationController?.popViewController(animated: true)
	}

	// MARK: - Additional Helpers

	// MARK: - Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier! {
		case "editDetails":
			guard let destination = segue.destination as? EditItemDetailsViewController,
				let data = sender as? Item else { return }
			// TODO: Change data to Item
			destination.item = data

		default:
			break
		}
	}
}
