
// swiftlint:disable
import Foundation
import FireWrap

var test: FirebaseDictionary = FirebaseDictionary()

test["array"] = FirebaseArray(from: ["string" as AnyObject, "string2" as AnyObject, 10 as AnyObject])

test["string"] = "testing"

test["number"] = 123 as FirebaseValue

test["innerDict"] = FirebaseDictionary(from: ["test":"test" as AnyObject])

let upload = test.uploadable

let outarray = upload["array"] as? [AnyObject]

if let _ = test["innerDict"] as? FirebaseDictionary {
	print("success")
}

switch test["innerDict"]?.Type() {
case let .dictionary(dict)?:
	print("dict: \(dict)")
default:
	print("nil")
}
