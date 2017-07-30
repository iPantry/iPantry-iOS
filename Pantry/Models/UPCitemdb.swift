//
//  UPCitemdb.swift
//  Pantry
//
//  Created by Justin Oroz on 3/12/17.
//  Copyright © 2017 Justin Oroz. All rights reserved.
//

import Alamofire

final class UPCitemdb: UPCDatabase {

	static func lookup(by barcode: String, returned: (([UPCDatabaseItem]?, Error?) -> Void)?) {

		let params = ["upc": barcode]
		let headers = ["Content-Type": "application/json"]

		Alamofire.request("https://api.upcitemdb.com/prod/trial/lookup",
		                  method: .post,
		                  parameters: params,
		                  encoding: JSONEncoding.default,
		                  headers: headers).responseJSON { (response) in

												guard response.error == nil,
													let json = response.result.value as? [String: AnyObject]
													else {
														returned?(nil, response.error)
														print("UPCitemdb Lookup Error: \(String(describing: response.error))")
														return
												}

												guard let items = json["items"] as? [[String:AnyObject]] else {

													return
												}

												var itemObjects = [UPCDatabaseItem]()

												for item in items {
													itemObjects.append(UPCitemdbItem(item))
												}

												returned?(itemObjects, response.error)

			}.resume()
	}
}

struct UPCitemdbItem: UPCDatabaseItem {
	subscript(index: String) -> AnyObject? {
		return self.data[index]
	}

	init(_ json: [String: AnyObject]) {
		self.data = json
	}

	private let data: [String: AnyObject]

	var title: String? {
		return data["title"] as? String
	}

	var ean: String? {
		return data["ean"] as? String
	}

	var description: String? {
		return data["description"] as? String
	}

	var brand: String? {
		return data["brand"] as? String
	}

	var size: String? {
		return data["size"] as? String
	}

	var weight: String? {
		return data["weight"] as? String
	}

	var imageURLs: [String]? {
		return data["images"] as? [String]
	}
}
