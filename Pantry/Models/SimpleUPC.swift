//
//  SimpleUPC.swift
//  Pantry
//
//  Created by Justin Oroz on 6/9/17.
//  Copyright © 2017 Justin Oroz. All rights reserved.
//
// http://www.simpleupc.com/api/methods/FetchProductByUPC.php

import Alamofire

final class SimpleUPC: UPCDatabase {

	static private let host = "api.simpleupc.com"
	static private let path = "/v1.php"
	static private let auth = (UIApplication.shared.delegate as? AppDelegate)?.apikeys?["SimpleUPC"]

	static func lookup(by barcode: String, returned: (([UPCDatabaseItem]?, Error?) -> Void)?) {

		guard let auth = self.auth else {
			print("[ERROR]: No SimpleUPC API Key Found")
			return
		}

		let method = "FetchImageByUPC"
		let params = ["upc": barcode]

		let request: [String: Any] = [
			"auth": auth,
			"method": method,
			"params": params
		]
		let headers = ["Content-Type": "text/json"]

		Alamofire.request("https://api.upcitemdb.com/prod/trial/lookup",
		                  method: .post,
		                  parameters: request,
		                  encoding: JSONEncoding.default,
		                  headers: headers).responseJSON { (response) in

												guard response.error == nil,
													let json = response.result.value as? [String: AnyObject]
													else {
														returned?(nil, response.error!)
														print("SimpleUPC Lookup Error: \(response.error!)")
														return
												}

												print("JSON: \(json)")

												returned?([SimpleUPCItem(json)], nil)

			}.resume()
	}
}

struct SimpleUPCItem: UPCDatabaseItem {
	subscript(index: String) -> AnyObject? {
		return self.data[index]
	}

	init(_ json: [String : AnyObject]) {
		self.data = json
	}

	private let data: [String : AnyObject]

	var title: String?

	var ean: String?

	var description: String?

	var brand: String?

	var size: String?

	var weight: String?

	var imageURLs: [String]?

}
