//
//  UserDocuments.swift
//  Pantry
//
//  Created by Justin Oroz on 6/17/17.
//  Copyright © 2017 Justin Oroz. All rights reserved.
//

import Foundation
import UIKit

extension FileManager {

	// https://iosdevcenters.blogspot.com/2016/04/save-and-get-image-from-document.html
	func saveImageToDocumentDirectory(_ image: UIImage, named filename: String, withJPEGQuality quality: CGFloat = 1) {
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let imagePath = (paths[0] as NSString).appendingPathComponent(filename)
		let imageData = UIImageJPEGRepresentation(image, quality)
		self.createFile(atPath: imagePath as String, contents: imageData, attributes: nil)
	}

	func getImageFromDocumentDirectory(named filename: String) -> UIImage? {
		let fileManager = FileManager.default
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let imagePath = (paths[0] as NSString).appendingPathComponent(filename)
		if fileManager.fileExists(atPath: imagePath) {
			return UIImage(contentsOfFile: imagePath)
		} else {
			return nil
		}
	}
}
