//
//  UPCitemdb.swift
//  Pantry
//
//  Created by Justin Oroz on 3/12/17.
//  Copyright © 2017 Justin Oroz. All rights reserved.
//

import Alamofire

class UPCitemdb {
	static func lookup(upc barcode: String, returned: (([String: AnyObject]?, Error?) -> Void)?) {

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

			print("JSON: \(json)")

			returned?(json, response.error)

		}.resume()
	}
}
