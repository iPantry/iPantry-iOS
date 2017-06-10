//
//  FirebaseObject.swift
//  Pantry
//
//  Created by Justin Oroz on 3/15/17.
//  Copyright © 2017 Justin Oroz. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol FirebaseObject {
	var snapshot: DataSnapshot? {get}
	func update(from snapshot: DataSnapshot)
	static func retrieve(uid: String)

}

typealias FIRSnapshotCompletion = (DataSnapshot) -> Void

class PantryItem {

	internal static let ref = Database.database().reference().child("items")

	internal let location: DatabaseReference
	private var refHandle: UInt!

	private var initialized: Bool = false


	// Returns boolean if the location exists or not. Returns nil if not yet initialized
	var exists: Bool? {
		get{
			guard initialized else {
				return nil
			}

			guard snapshot != nil else {
				return false
			}

			return true

		}
	}


	init(createWith ean: String, creator: String, pantry: String?) {
		self.location = PantryItem.ref.childByAutoId()

		var dict: [String: Any] = ["ean": ean,
		                           "creator": creator]

		if pantry == nil {
			dict["pantry"] = false
		} else {
			dict["pantry"] = pantry!
		}

		self.location.setValue(dict)

		refHandle = self.location.observe(.value, with: self.update)
	}

	init?(createWith dictionary: [String: Any]) {
		self.location = PantryItem.ref.childByAutoId()

		guard dictionary["ean"] != nil,
			dictionary["creator"] != nil
		else {
			return nil
		}

		var mutable = dictionary

		if dictionary["pantry"] == nil{
			mutable["pantry"] = false
		}

		self.location.setValue(mutable)

		refHandle = self.location.observe(.value, with: self.update)
	}

	init(fromUID uid: String, result: @escaping (PantryItem) -> Void) {
		self.location = PantryItem.ref.child(uid)
		refHandle = self.location.observe(.value, with: { (snapshot) in
			if !self.initialized {
				result(self)
			}
			self.update(from: snapshot)
		})
	}

	deinit {
		self.location.removeObserver(withHandle: refHandle)
	}


	private(set) var snapshot: DataSnapshot?

	internal func update(from snapshot: DataSnapshot) {
		self.initialized = true
		self.snapshot = snapshot
	}
}

// MARK: - Properties
extension PantryItem {

}


extension PantryItem: FirebaseObject {


	static func retrieve(uid: String) {
		//
	}
}
