//
//  Item.swift
//  Pantry
//
//  Created by Justin Oroz on 7/29/17.
//  Copyright © 2017 Justin Oroz. All rights reserved.
//

import Foundation
import Alamofire
import FirebaseAuth

struct Item {
	///
	let ean: String
	public let suggestions: FirebaseSuggestions
	public let UPCResults: [UPCDatabaseItem]
	private var modified = FireDictionary()
	public var UPCResultIndex = 0

	private(set) var expirationEstimate: Int?

	public var selectedUPCResult: UPCDatabaseItem? {
		guard UPCResults.count > 0 else {
			return nil
		}
		return UPCResults[UPCResultIndex]
	}

	/// Returns data which can be sent to Firebase
	var data: FireDictionary {
		return modified
	}

	var title: String? {
		get {
			if let userItem = self.modified["title"] as? String {
				return userItem
			} else if !self.UPCResults.isEmpty, let upcItem = self.UPCResults[UPCResultIndex].title {
				return upcItem
			} else {
				return nil
			}
		}
		set {
			self.modified["title"] = newValue
		}
	}

	var description: String? {
		get {
			if let userItem = self.modified["description"] as? String {
				return userItem
			} else if !self.UPCResults.isEmpty, let upcItem = self.UPCResults[UPCResultIndex].description {
				return upcItem
			} else {
				return nil
			}
		}
		set {
			self.modified["description"] = newValue
		}
	}

	var quantity: UInt? {
		return self.modified["quantity"] as? UInt
	}

	var purchasedDate: String? {
		return self.modified["purchasedDate"] as? String
	}

	var weight: String? {
		get {
			if let userItem = self.modified["weight"] as? String {
				return userItem
			} else if !self.UPCResults.isEmpty, let upcItem = self.UPCResults[UPCResultIndex].weight {
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
			if let userItem = self.modified["size"] as? String {
				return userItem
			} else if !self.UPCResults.isEmpty, let upcItem = self.UPCResults[UPCResultIndex].size {
				return upcItem
			} else {
				return nil
			}
		}
		set {
			self["size"] = newValue
		}
	}

	// init from firebase and possible upcdb data
	init(_ ean: String, _ suggestions: FirebaseSuggestions? = nil, _ upcData: [UPCDatabaseItem]? = nil) {

		self.ean = ean
		self.suggestions = suggestions ?? FirebaseSuggestions()
		self.UPCResults = upcData ?? [UPCDatabaseItem]()
	}

	subscript(index: String) -> FireValue? {
		get {
			let upcInfo = (UPCResults.count > 0) ? UPCResults[UPCResultIndex] : nil
			return modified[index] ?? upcInfo?[index] as? FireValue
		}
		set(newValue) { //can only modify string: values

			if newValue == nil {
				modified[index] = newValue
				return
			}

			// UPC results are empty, save the data
			if UPCResults.count == 0 {
				modified[index] = newValue
				return
			}
			// if not in UPC results
			if UPCResults[UPCResultIndex][index] == nil {
				modified[index] = newValue
				return
			}

			switch newValue!.type {
			case .bool(let val):
				if UPCResults[UPCResultIndex][index] as? Bool != val {
					modified[index] = val
				} else {
					// do not allow uploading of same data
					modified[index] = nil
				}
			case .string(let val):
				if UPCResults[UPCResultIndex][index] as? String != val {
					modified[index] = val
				} else {
					modified[index] = nil
				}
			default:
				return
			}
		}
	}

	static func lookup(by UPC: String, completion: ((Item?, Error?) -> Void)?) {
		let dispatch = DispatchGroup()
		var upcData = [UPCDatabaseItem]()
		var firebaseSuggestions = FirebaseSuggestions()
		var itemError: Error?

		// TODO: Return Item instead
		dispatch.enter()
		UPCDB.current.lookup(by: UPC, returned: { (data, error) in
			defer { dispatch.leave() }

			guard error == nil,
				data != nil
				else {
					itemError = error
					//completion?(nil, itemError)
					return
			}

			upcData = data!
		})

		// TODO: Request Firebase Suggestions
		dispatch.enter()
		//firebaseData = ["": ""]
		dispatch.leave()

		// after both requests are complete
		dispatch.notify(queue: DispatchQueue.global(qos: DispatchQoS.userInitiated.qosClass)) {

			guard itemError == nil else {
				completion?(nil, itemError)
				return
			}

			let item = Item(UPC, firebaseSuggestions, upcData)

			// If no data or suggestions, alert user
			guard !firebaseSuggestions.isEmpty || upcData.count > 0 else {
				completion?(nil, nil)
				return
			}

			completion?(item, nil)
		}
	}
}
