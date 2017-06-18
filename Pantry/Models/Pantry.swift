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

	init(withId pantryId: PantryIdentifier) {
		//setup firebase listener
		log(.info, message: "Creating Pantry object for id \(pantryId.value), keyed by \(pantryId.type.rawValue)")

		let ref = Database.database().reference()
		self.pantryId = pantryId

		// check if user has pantry specified

		if self.pantryId.type == .pantryId { //only check for pantry members if user is not anonymous
			let usersRef = ref.child("pantries").child(self.pantryId.value)

			let usersHandle = usersRef.observe(DataEventType.value, with: { [unowned self] (snapshot) in

				guard snapshot.exists() else {
					log(.error, message: "Pantry directory missing")
					// TODO: Create the directory
					return
				}

				// update User list and invited list
				guard let pantryDict = snapshot.value as? [String: AnyObject] else {
						log(.error, message: "User data snapshot invalid: \(String(describing: snapshot.value))")
						return
				}

				guard let userDict = pantryDict["members"] as? [String: Bool] else {
					log(.error, message: "Pantry missing required member information")
					return
				}

				self.memberIds.removeAll()
				for member in userDict.keys {
					self.memberIds.insert(member)
				}
				NotificationCenter.default.post(name: .pantryMembersWereUpdated, object: self)

				self.invitedIds.removeAll()
				if let invitedDict = pantryDict["invited"] as? [String: Bool] {
					for invited in invitedDict.keys {
						self.invitedIds.insert(invited)
					}
					NotificationCenter.default.post(name: .pantryInvitedWereUpdated, object: self)
				}

				print(snapshot)

			})

			self.observerHandles.insert(usersHandle)
		}

		let pantryRef = ref.child("items").queryOrdered(byChild: pantryId.type.rawValue).queryEqual(toValue: pantryId.value)

		let pantryHandle = pantryRef.observe(.value, with: { [unowned self] (snapshot) in
			self.list = []		// clear list

			// update list
			guard let pantryDict = snapshot.value as? [String: AnyObject] else {
				log(.error, message: "Pantry data snapshot invalid: \(String(describing: snapshot.value))")
				return
			}

			log(.info, message: "\(pantryDict.count) items found in pantry")
			for item in pantryDict {
				if let itemDict = item.value as? [String: AnyObject] {
					self.list.append(PantryItem(itemDict))
				}
			}

			print(snapshot, " translated to ", self.list.count, " objects")
			NotificationCenter.default.post(name: .pantryListWasUpdated, object: self)
		})

		self.observerHandles.insert(pantryHandle)
	}

	deinit {
		for handle in observerHandles {
			Database.database().reference().removeObserver(withHandle: handle)
		}
	}

	private(set) var memberIds = Set<String>()
	private(set) var invitedIds = Set<String>()

	private(set) var pantryId: PantryIdentifier

	private var observerHandles = Set<UInt>()

	private(set) var list: [PantryItem] = []

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
