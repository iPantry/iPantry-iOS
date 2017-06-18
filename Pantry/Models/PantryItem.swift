//
//  PantryItem.swift
//  Pantry
//
//  Created by Justin Oroz on 6/15/17.
//  Copyright © 2017 Justin Oroz. All rights reserved.
//

import Foundation

struct PantryItem {
	init(_ itemDict: [String: AnyObject]) {
		self.itemDict = itemDict
	}

	private let itemDict: [String: AnyObject]

	var title: String? {
		return self.itemDict["title"] as? String
	}

	var ean: String? {
		return self.itemDict["ean"] as? String
	}

	var creator: String? {
		return self.itemDict["creator"] as? String
	}

	var pantry: String? {

		if let _ = self.itemDict["pantry"] as? Bool {
			return nil
		} else if let pantry = self.itemDict["pantry"] as? String {
			return pantry
		} else {
			return nil
		}
	}
}
