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

	var data: [String: Any]!
	var items: [[String: Any]] = []
	var selectedItem: [String: Any]?
	var ref: DatabaseReference!
	var ean: String!
	var customItem: [String: Any] = [:]


	override func viewDidLoad() {
		super.viewDidLoad()
		ref = Database.database().reference()

		self.customItem["ean"] = self.ean


		guard let items = data["items"] as? [[String: AnyObject]] else {
			// TODO: Error Handle
			// Improper return object
			return
		}

		self.items = items

		guard !self.items.isEmpty else {
			// TODO: Error Handle
			// no items found
			return
		}

		if items.count > 1 {
			print("[ALERT] More than one item found with ean")
			// TODO: Let user pick
		} else {
			self.selectedItem = items[0]

			self.itemTitle.text = self.selectedItem!["title"] as? String

			if let imageURLs = self.selectedItem!["images"] as? [String] {
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
			Alamofire.request(url).responseImage(completionHandler: {
				(data) in

				guard let image = data.result.value else {
					return
				}

				if url == urls[0] {
					self.itemImage.image = image
				}

				self.itemImage.animationImages?.append(image)

			}).resume()

		}

	}

	@IBAction func save(_ sender: Any) {
		guard let user = Auth.auth().currentUser else {
			// TODO: Alert User theyre not signed in
			return
		}

		if selectedItem == nil {
			// save all fields for fully custom item

			self.customItem["title"] = self.itemTitle.text
		} else {
			// only save modified fields for found items

			if self.itemTitle.text != selectedItem!["title"] as? String {
				self.customItem["title"] = self.itemTitle.text
			}
		}

		let itemRef = self.ref.child("items")


		self.customItem["creator"] = user.uid



		if user.isAnonymous {
			self.customItem["pantry"] = false
			print("Saving: \(self.customItem.description)")
			itemRef.childByAutoId().setValue(customItem)
			let _ = self.navigationController?.popToRootViewController(animated: true)
		} else {
			ref.child("users").child(user.uid).child("pantry").observeSingleEvent(of: .value, with: { (snapshot) in
				self.customItem["pantry"] = snapshot.value
				print("Saving: \(self.customItem.description)")
				itemRef.childByAutoId().setValue(self.customItem)
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
