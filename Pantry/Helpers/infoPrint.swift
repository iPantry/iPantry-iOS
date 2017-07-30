//
//  infoPrint.swift
//  Pantry
//
//  Created by Justin Oroz on 6/10/17.
//  Copyright © 2017 Justin Oroz. All rights reserved.
//

import Foundation
import FirebaseAnalytics
import os.log

func print(_ type: OSLogType, message: StaticString, args: CVarArg...) {
	os_log(message, log: .default, type: type, args)
}

func fb_log(_ type: OSLogType, message: StaticString, file: StaticString = #file, line: UInt = #line, args: CVarArg...) {

	var info = [NSString]()
	for arg in args {
		if let readable = arg as? NSString {
			info.append(readable)
		}
	}

	var filename: String = file.description

	if let name = file.description.components(separatedBy: "/").last {
		filename = name
	}

	if .fault == type || .error == type {
		Analytics.logEvent(type.description, parameters: [
			"message": message.description as NSString,
			"args": info,
			"file": filename,
			"line": line
			])
	}

	os_log("|%@, %d| [%@]: %@ - %@", log: .default, type: type,
	       filename, line, type.description, message.description, args)
}

extension OSLogType: CustomStringConvertible {
	public var description: String {
		switch self {
		case OSLogType.error:
			return "Error"
		case OSLogType.info:
			return "Info"
		case OSLogType.default:
			return "Default"
		case OSLogType.debug:
			return "Debug"
		case OSLogType.fault:
			return "Fault"
		default:
			return "Unknown"
		}
	}
}
