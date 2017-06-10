//
//  SecondViewController.swift
//  Pantry
//
//  Created by Justin Oroz on 9/1/16.
//  Copyright © 2016 Justin Oroz. All rights reserved.
//

import UIKit
import MTBBarcodeScanner
import PermissionScope
import DeviceKit
import SwifterSwift

class UPCScanViewController: UIViewController {

	@IBOutlet weak var camView: UIView!
	@IBOutlet weak var upcField: UITextField!
	@IBOutlet weak var backButton: UIButton!
	@IBOutlet weak var addManualButton: UIButton!
	@IBOutlet weak var torchButton: UIButton!
	@IBOutlet weak var permissionImage: UIImageView!
	@IBOutlet weak var permissonLabel: UILabel!
	@IBOutlet weak var manualPermissionsButton: UIButton!
	@IBOutlet weak var scannerActivity: UIActivityIndicatorView!
	@IBOutlet weak var upcFieldBottomConstraint: NSLayoutConstraint!
	@IBOutlet weak var dismissKeyboardButton: UIButton!
	@IBOutlet weak var manualUPCInputView: UIView!
	@IBOutlet weak var manualSearchButton: UIButton!
	@IBOutlet weak var manualSearchButtonWidth: NSLayoutConstraint!

	var scanner: MTBBarcodeScanner?
	let pscope = PermissionScope()

	override func viewDidLoad() {
		super.viewDidLoad()

		scanner = MTBBarcodeScanner(previewView: camView)
		scanner!.allowTapToFocus = true
		self.navigationController?.setNavigationBarHidden(true, animated: false)
		self.tabBarController?.tabBar.isHidden = true
		self.setNeedsStatusBarAppearanceUpdate()

		self.scanner?.didStartScanningBlock = {
			self.scannerActivity.stopAnimating()
		}

		if pscope.statusCamera() == .authorized {
			self.cameraWillAppear()
			self.beginScanning()
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: .UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification), name: .UIKeyboardWillHide, object: nil)

		if pscope.statusCamera() != .authorized {

			pscope.addPermission(CameraPermission(), message: "Required for scanning UPC's")

			pscope.show({ (finished, results) in
				if finished {
					self.beginScanning()
				}

			}) { (results) in
				// TODO: Show a view over the camera view or button to ask permission
				self.manualPermissionsButton.isHidden = false
			}
		} else {
			self.manualPermissionsButton.isHidden = true
			self.beginScanning()
		}

	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
		NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
		self.navigationController?.setNavigationBarHidden(false, animated: true)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

	}

	func beginScanning() {
		// start scan only if not a simulator or is not already scanning
		guard !scanner!.isScanning(),
			!Device().isSimulator else {
			return
		}

		self.cameraWillAppear()

		try? self.scanner!.startScanning(resultBlock: { (codes) in

			guard let codeObjects = codes else {
				return
			}

			guard !codeObjects.isEmpty else {
				return
			}

			self.upcField.text = codeObjects[0].stringValue

			for code in codeObjects {
				print(code.stringValue)
			}

			self.scanner!.freezeCapture()
			self.scanner!.stopScanning()

			UPCitemdb.lookup(upc: codeObjects[0].stringValue!, returned: { (data, error) in
				guard error == nil else {
					self.scanner!.unfreezeCapture()
					self.beginScanning()
					// TODO: - Alert User, begin scanning again when dismissed
					return
				}

				var productInfo:[String : Any] = [:]

				if data != nil {
					productInfo += data!
				}

				productInfo["ean"] = codeObjects[0].stringValue

				self.performSegue(withIdentifier: "editDetails", sender: productInfo)
			})
		})
	}

	func cameraWillAppear() {
		self.permissonLabel.isHidden = true
		self.permissionImage.isHidden = true
		self.backButton.isHidden = false
		self.addManualButton.isHidden = false
		self.torchButton.isHidden = false
		self.manualPermissionsButton.isHidden = true
		self.scannerActivity.startAnimating()

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent //or default
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier! {
		case "editDetails":
			guard let destination = segue.destination as? EditItemDetailsViewController,
			let data = sender as? [String: AnyObject] else { return }

			destination.data = data
			destination.ean = data["ean"] as? String!

		default:
			break
		}
	}


}

// MARK: - Button Methods
extension UPCScanViewController {

	@IBAction func back(_ sender: Any) {
		let _ = self.navigationController?.popViewController(animated: true)
	}

	@IBAction func requestPermissions(_ sender: Any) {
		pscope.show({ (finished, results) in
			if self.pscope.statusCamera() == .authorized {
				self.beginScanning()
			}
		}) { (results) in
			// TODO: Show a view over the camera view or button to ask permission
			self.manualPermissionsButton.isHidden = false
		}
	}

	@IBAction func torchToggle(_ sender: Any) {
		scanner!.toggleTorch()
	}

	@IBAction func manualUPCInput(_ sender: Any) {
		self.upcField.becomeFirstResponder()
	}

	@IBAction func beganEditing(_ sender: Any) {
		//self.upcField.isHidden = false
	}

	@IBAction func endEditing(_ sender: Any) {
		//self.upcField.isHidden = true
	}

}

// MARK: - TextFieldDelegate Methods

extension UPCScanViewController: UITextFieldDelegate {

	@IBAction func upcFieldModified(_ sender: Any) {
		if upcField.text!.isEmpty {
			// hide button
			self.manualSearchButtonWidth.constant = 0;

		} else {
			self.manualSearchButtonWidth.constant = 60;
		}

		UIView.animate(withDuration: 0.1, delay: 0.0, options: [.beginFromCurrentState] , animations: {
			self.manualUPCInputView.layoutIfNeeded()

		}, completion: nil)
	}

}


// MARK: - Keyboard Functions

extension UPCScanViewController { // http://effortlesscode.com/auto-layout-keyboard-shown-hidden/

	func keyboardWillShowNotification(notification: NSNotification) {

		self.dismissKeyboardButton.isHidden = false
		self.view.bringSubview(toFront: self.dismissKeyboardButton)
		updateBottomLayoutConstraintWithNotification(notification: notification)
	}

	func keyboardWillHideNotification(notification: NSNotification) {
		self.dismissKeyboardButton.isHidden = true
		self.view.sendSubview(toBack: self.dismissKeyboardButton)
		updateBottomLayoutConstraintWithNotification(notification: notification)
	}

	func updateBottomLayoutConstraintWithNotification(notification: NSNotification) {

		let handler = KeyboardHandler()

		handler.layoutSetup = {
			(isHiding, keyboardHeight) in

			self.upcFieldBottomConstraint.constant = keyboardHeight
		}

		handler.animations = {
			(isHiding, keyboardHeight) in

			self.view.layoutIfNeeded()

			if self.upcFieldBottomConstraint.constant == 0 {
				self.manualUPCInputView.isHidden = true
			} else {
				self.manualUPCInputView.isHidden = false
			}
		}

		handler.animateWithKeyboardWillChange(on: notification, in: self.view)

	}

	@IBAction func dismissKeyboard(_ sender: Any) {
		self.view.endEditing(false)
	}

}


