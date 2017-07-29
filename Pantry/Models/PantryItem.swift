//
//  PantryItem.swift
//  Pantry
//
//  Created by Justin Oroz on 6/15/17.
//  Copyright © 2017 Justin Oroz. All rights reserved.
//

import Foundation

struct PantryItem: Hashable {
	var hashValue: Int {
		return self.identifier!.hash
	}

	static func == (left: PantryItem, right: PantryItem) -> Bool {

		if left.identifier != nil || right.identifier != nil {
			return left.identifier == right.identifier
		} else {
			return right.upcData.ean == left.upcData.ean
		}
	}

	static func != (left: PantryItem, right: PantryItem) -> Bool {
		if left.identifier != nil || right.identifier != nil {
			return left.identifier != right.identifier
		} else {
			return right.upcData.ean != left.upcData.ean
		}
	}

	subscript(index: String) -> FireValue? {
		get {
			return modified[index] ?? itemDict[index] ?? upcData[index] as? FireValue
		}
		set(newValue) { //can only modify string: values

			// if neither places have data, add it
			guard (upcData[index] == nil) && (modified[index] == nil) else {
				modified[index] = newValue
				return
			}

			guard let new = newValue as? String else {
				return
			}

			if let upc = upcData[index] as? String {
				if upc == new {
					// Clear item detail newValue is same
					modified[index] = nil
				} else if let item = itemDict[index] as? String {
					if item != new {
						// Only add modify if newValue is unique
						modified[index] = newValue
					}
				}
			}

		}
	}

	// create new item to load to firebase
	init?(_ creator: String, _ upcData: UPCDatabaseItem) {
		guard let ean = upcData["ean"] as? String else {
			fb_log(.error, message: "Failed to create new PantryItem, no EAN")
			return nil
		}

		self.creator = creator
		self.ean = ean
		self.upcData = upcData
		self.itemDict = [:]

		// a modified dictionary for storing changes.
		// move this init to small temporary class for creating new Items, Idenitifier should be a requirement
	}

	// init from firebase
	init?(_ itemId: String, _ itemDict: FireDictionary, _ upcData: UPCDatabaseItem) {
		guard let ean = itemDict["ean"] as? String,
			let creator = itemDict["creator"] as? String else {
				fb_log(.error, message: "New Pantry Item failed with ID", args: ["id": itemId])
				return nil
		}

		self.ean = ean
		self.creator = creator
		self.identifier = itemId
		self.itemDict = itemDict
		self.upcData = upcData
	}


	///
	private(set) var identifier: String?
	private var itemDict: FireDictionary
	private let upcData: UPCDatabaseItem
	private var modified = FireDictionary()

	mutating func update(_ itemDict: FireDictionary) {
		//self.itemDict += itemDict
		itemDict.forEach({ self.itemDict[$0.0] = $0.1})
	}

	private(set) var expirationEstimate: Int?

	var title: String? {
		if let userItem = self.itemDict["title"] as? String {
			return userItem
		} else if let upcItem = self.upcData.title {
			return upcItem
		} else {
			return nil
		}
	}

	let ean: String
	var creator: String

	var quantity: UInt? {
		return self.itemDict["quantity"] as? UInt
	}

	var lasted: UInt? {
		return self.itemDict["lasted"] as? UInt
	}

	var purchasedDate: String? {
		return self.itemDict["purchasedDate"] as? String
	}

	var weight: String? {
		get {
			if let userItem = self.itemDict["weight"] as? String {
				return userItem
			} else if let upcItem = self.upcData.weight {
				return upcItem
			} else {
				return nil
			}
		}
		set {
			self["size"] = newValue
		}
	}

	var size: String? {
		get {
			if let userItem = self.itemDict["size"] as? String {
				return userItem
			} else if let upcItem = self.upcData.size {
				return upcItem
			} else {
				return nil
			}
		}
		set {
			self["size"] = newValue
		}

	}

	var pantry: String? {
		return self.itemDict["pantry"] as? String
	}
}
