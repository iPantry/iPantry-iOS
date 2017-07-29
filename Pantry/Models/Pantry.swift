//
//  Pantry.swift
//  Pantry
//
//  Created by Justin Oroz on 6/12/17.
//  Copyright © 2017 Justin Oroz. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

final class Pantry {

	let ref = Database.database().reference()

	init(withId pantryId: PantryIdentifier) {
		//setup firebase listener
		fb_log(.debug, message: "Creating Pantry object", args: [pantryId.type.rawValue: pantryId.value])

		self.pantryId = pantryId

		if self.pantryId.type == .pantryId { //only check for pantry members if user is not anonymous
			let usersRef = ref.child("pantries").child(self.pantryId.value)

			let usersHandle = usersRef.observe(DataEventType.value, with: pantryModified)
			self.observerHandles.insert(usersHandle)
		}

		let pantryRef = ref.child("items").queryOrdered(byChild: pantryId.type.rawValue).queryEqual(toValue: pantryId.value)

		let childAddedHandle = pantryRef.observe(.childAdded, with: itemAdded)
		self.observerHandles.insert(childAddedHandle)
	}

	private func pantryModified(snapshot: DataSnapshot) {
		guard snapshot.exists() else {
			fb_log(.error, message: "Pantry directory missing")

			// Create the directory
			if let uid = PantryUser.current?.uid {
				fb_log(.info, message: "Creating Pantry directory")
				let newData: FireDictionary = [uid: true]
				ref.child("/pantries/\(self.pantryId)/members").setValue(newData.uploadable)
			}
			return
		}

		// update User list and invited list
		guard let pantry = FireDictionary(snapshot.value) else {
			fb_log(.error, message: "User data snapshot invalid", args: ["snapshot": snapshot.description])
			return
		}

		guard let userDict = pantry["members"] as? FireDictionary else {
			self.memberIds = Set<String>()
			fb_log(.error, message: "Pantry missing required member information")
			return
		}

		self.memberIds = Set<String>(userDict.keys)
		NotificationCenter.default.post(name: .pantryMembersWereUpdated, object: self)

		if let invited = pantry["invited"] as? FireDictionary {
			self.invitedIds = Set<String>(invited.keys)
			NotificationCenter.default.post(name: .pantryInvitedWereUpdated, object: self)
		} else {
			self.invitedIds = Set<String>()
		}

		print(snapshot)
	}

	private func itemAdded(snapshot: DataSnapshot) {

		// update list
		guard let item = FireDictionary(snapshot.value),
			let ean = item["ean"] as? String else {
				fb_log(.error, message: "Pantry data snapshot invalid", args: ["snapshot": snapshot.description])
				return
		}

		UPCDB.current.lookup(by: ean) { (upcItems, error) in
			//TODO: Pull correct item from UPC DB if multiple
			guard error == nil,
				upcItems != nil else {
					fb_log(.error, message: "UPC Database lookup returned error",
					       args: ["error": error?.localizedDescription ?? "upcData is nil"])
					//UPCDB.current.lookup(by: self.ean!, returned: upcDataReturned)
					return
			}

			if let newItemObject = PantryItem(snapshot.key, item, upcItems?[0]) {
				self.list.append(newItemObject)
				fb_log(.debug, message: "Item added to pantry")
				NotificationCenter.default.post(name: .pantryListWasUpdated, object: self)
			} else {
				fb_log(.error, message: "Failed to add item to pantry")
			}
		}

		print(snapshot)
	}

	deinit {
		for handle in observerHandles {
			ref.removeObserver(withHandle: handle)
		}
	}

	private(set) var memberIds = Set<String>()
	private(set) var invitedIds = Set<String>()

	private(set) var pantryId: PantryIdentifier

	private var observerHandles = Set<UInt>()

	private(set) var list: [PantryItem] = []

	private func save() {

	}

	private func load() {

	}

}

// MARK: - Notifications
extension Notification.Name {
	static let pantryListWasUpdated = Notification.Name("pantryListWasUpdatedNotification")
	static let pantryMembersWereUpdated = Notification.Name("pantryMembersWereUpdatedNotification")
	static let pantryInvitedWereUpdated = Notification.Name("pantryInvitedWereUpdatedNotification")
}

enum PantryError: String {
	case noPantryId = "No Pantry ID Key Found"
	case pantryIdForm = "Pantry ID not bool or string"
}

enum PantryResult<T> {
	case Success(PantryIdentifier)
	case Error(PantryError)
}

enum PantryIdentifierType: String {
	case creator = "creator"
	case pantryId = "pantry"
}

struct PantryIdentifier {
	init(_ pantryId: String, indexedBy type: PantryIdentifierType) {
		self.value = pantryId
		self.type = type
	}
	let value: String
	let type: PantryIdentifierType
}
