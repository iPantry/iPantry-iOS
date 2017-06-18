//
//  File.swift
//  Pantry
//
//  Created by Justin Oroz on 3/13/17.
//  Copyright © 2017 Justin Oroz. All rights reserved.
//

import UIKit

extension UIViewController {
	static func instantiate(withIdentifier name: String, in storyboard: String, bundle: Bundle? = nil) -> UIViewController {
		let storyboard = UIStoryboard(name: storyboard, bundle: bundle)
		return storyboard.instantiateViewController(withIdentifier: name)
	}
}
