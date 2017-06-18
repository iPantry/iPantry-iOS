//
//  BarcodeDatabaseTestingViewController.swift
//  Pantry
//
//  Created by Justin Oroz on 10/17/16.
//  Copyright © 2016 Justin Oroz. All rights reserved.
//

import UIKit
import Alamofire

class BarcodeDatabaseTestingViewController: UIViewController {

	@IBOutlet weak var barcodeInput: UITextField!
	@IBOutlet weak var submitButton: UIButton!
	@IBOutlet weak var submitActivity: UIActivityIndicatorView!

	var data: [String: String]?

//	("https://api.upcitemdb.com/prod/trial/search",
//	method: .post,
//	parameters: ["upc": self.barcodeInput.text!],
//	encoding: JSONEncoding.default,
//	headers: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

		if let dataDict = data {
			if let upc = dataDict["upc"] {
				self.barcodeInput.text = upc
			}
		}

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	@IBAction func submit(_ sender: AnyObject) {

		self.submitActivity.startAnimating()
		self.submitButton.isHidden = true

		let params = ["upc": self.barcodeInput.text!]
		let headers = ["Content-Type": "application/json"]

		Alamofire.request("https://api.upcitemdb.com/prod/trial/lookup", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in

			// finished loading, stop graphics
			DispatchQueue.main.async {
				self.submitActivity.stopAnimating()
				self.submitButton.isHidden = false
			}

			// if success transition after puling data
			if let json = response.result.value as? [String: AnyObject] {
				print("JSON: \(json)")

				if let code = json["code"] as? String {
					if code == "OK" {
						print("Success, filling in data")
						self.performSegue(withIdentifier: "verifydetails", sender: json["items"])
					} else { // UPC search unsuccessful
						print("UPC not found, manual data required")
						self.performSegue(withIdentifier: "verifydetails", sender: nil)
						// TODO: ERROR CHECKING
					}
				} else { //Bad Response
					// TODO: ERROR CHECKING
				}

			} else { // Bad response
				// TODO: ERROR CHECKING
			}

		}.resume()

	}

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

		switch segue.identifier {
		case "verifydetails"?:
			guard let target = segue.destination as? EditItemDetailsViewController
				else {
					print(.error, message: "Segue target is not correct")
					return
			}

			if let list = sender as? [[String:AnyObject]] {
				target.data = list[0]
			}
			break
		default:
			// nothing
			break
		}
    }
}
