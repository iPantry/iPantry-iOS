//
//  UPCDatabase.swift
//  Pantry
//
//  Created by Justin Oroz on 6/18/17.
//  Copyright © 2017 Justin Oroz. All rights reserved.
//

import Foundation

protocol UPCDatabase {
	static func lookup(by barcode: String, returned: (([UPCDatabaseItem]?, Error?) -> Void)?)
}

protocol UPCDatabaseItem {
	init(_ json: [String: AnyObject])
	subscript(index: String) -> AnyObject? {get}
	var title: String? {get}
	var ean: String? {get}
	var description: String? {get}
	var brand: String? {get}
	var size: String? {get}
	var weight: String? {get}
	var imageURLs: [String]? {get}
}

// For easy switch of databases
struct UPCDB {
	static let current: UPCDatabase.Type = UPCitemdb.self
}
