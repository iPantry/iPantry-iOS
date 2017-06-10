//
//  SimpleUPC.swift
//  Pantry
//
//  Created by Justin Oroz on 6/9/17.
//  Copyright © 2017 Justin Oroz. All rights reserved.
//
// http://www.simpleupc.com/api/methods/FetchProductByUPC.php

import Alamofire

class SimpleUPC {

	private let host = "api.simpleupc.com"
	private let path = "/v1.php"
	private let auth="Your Auth Code"
	private let method="FetchImageByUPC"

	static func lookup(by upc: String, returned: (([String: AnyObject]?, Error?) -> Void)?) {

		let params = ["upc": barcode]
		let headers = ["Content-Type": "text/json"]

		Alamofire.request("https://api.upcitemdb.com/prod/trial/lookup",
		                  method: .post,
		                  parameters: params,
		                  encoding: JSONEncoding.default,
		                  headers: headers).responseJSON {
							(response) in

							guard response.error == nil,
								let json = response.result.value as? [String: AnyObject]
								else {
									returned?(nil,response.error)
									print("UPCitemdb Lookup Error: \(response.error)")
									return
							}

							print("JSON: \(json)")
							
							
							returned?(json, response.error)
							
			}.resume()

	}
}
