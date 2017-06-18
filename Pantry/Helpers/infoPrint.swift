//
//  infoPrint.swift
//  Pantry
//
//  Created by Justin Oroz on 6/10/17.
//  Copyright © 2017 Justin Oroz. All rights reserved.
//

import Foundation
import FirebaseAnalytics

enum PrintType: String {
	case error = "ERROR"
	case info = "INFO"
	case critical = "CRITICAL"
}

func print(_ type: PrintType, message items: Any...) {
	print("[\(type.rawValue)]:", items)
}

func log(_ type: PrintType, message items: Any...) {

	if .critical == type || .error == type {
		Analytics.logEvent(type.rawValue, parameters: [
			"message": items as [Any]
			])
	}

	print("[\(type.rawValue)]:", items as [Any])
}
