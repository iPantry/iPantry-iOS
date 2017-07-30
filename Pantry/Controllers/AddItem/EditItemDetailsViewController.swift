//
//  EditItemDetailsViewController.swift
//  Pods
//
//  Created by Justin Oroz on 1/26/17.
//
//

import UIKit
import Alamofire
import AlamofireImage
import FirebaseDatabase
import FirebaseAuth
import SwifterSwift

class EditItemDetailsViewController: UIViewController {

	@IBOutlet weak var itemTitle: UITextField!
	@IBOutlet weak var itemImage: UIImageView!

	var item: Item!
	var selectedItem: UPCDatabaseItem?
	var ref: DatabaseReference!
	var ean: String!

	override func viewDidLoad() {
		super.viewDidLoad()
		ref = Database.database().reference()

		if item.UPCResults.count > 1 {
			print("[ALERT] More than one item found with ean")
			// TODO: Let user pick
		} else {
			self.selectedItem = item.selectedUPCResult

			self.itemTitle.text = self.selectedItem?.title

			if let imageURLs = self.selectedItem?.imageURLs {
				downloadImages(from: imageURLs)
			}
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func downloadImages(from urls: [String]) {
		guard !urls.isEmpty else {
			return
		}

		itemImage.animationImages = []

		for url in urls {
			Alamofire.request(url).responseImage(completionHandler: { (data) in

				guard let image = data.result.value else {
					return
				}

				if url == urls[0] {
					self.itemImage.image = image
				}

				self.itemImage.animationImages?.append(image)

			}).resume()

			self.itemImage.startAnimating()

		}

	}

	@IBAction func save(_ sender: Any) {
		guard let user = Auth.auth().currentUser else {
			// TODO: Alert User theyre not signed in
			return
		}

		if selectedItem == nil {
			// save all fields for fully custom item

			self.item.title =  self.itemTitle.text
		} else {
			// only save modified fields for found items

			if self.itemTitle.text != selectedItem!.title {
				self.item.title = self.itemTitle.text
			}
		}

		let itemRef = self.ref.child("items")

		// add who created the item
		self.item["createdBy"] = user.uid

		if user.isAnonymous {
			self.item["pantry"] = false
			print("Saving: \(self.item.title ?? self.item.description ?? "Item")")
			itemRef.childByAutoId().setValue(item.data)
			let _ = self.navigationController?.popToRootViewController(animated: true)
		} else { // TODO: Use PantryUser
			self.item["pantry"] = PantryUser.current?.pantryIdentifier?.value
			ref.child("users").child(user.uid).child("pantry").observeSingleEvent(of: .value, with: { (snapshot) in
				self.item["pantry"] = snapshot.fire as? String
				print("Saving: \(self.item.title ?? self.item.description ?? "Item")")
				itemRef.childByAutoId().setValue(self.item.data)
				let _ = self.navigationController?.popToRootViewController(animated: true)
			})

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

extension EditItemDetailsViewController: UINavigationBarDelegate {
	func position(for bar: UIBarPositioning) -> UIBarPosition {
		return UIBarPosition.topAttached
	}
}
