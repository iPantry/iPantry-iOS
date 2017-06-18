//
//  UPCScannerView.swift
//  Pantry
//
//  Created by Justin Oroz on 6/17/17.
//  Copyright © 2017 Justin Oroz. All rights reserved.
//

import UIKit
import MTBBarcodeScanner
import PermissionScope
import DeviceKit
import SwifterSwift

@IBDesignable
final class UPCScannerView: UIView, UITextFieldDelegate {

	var scanner: MTBBarcodeScanner?
	let pscope = PermissionScope()
	@IBOutlet weak var delegate: UPCScannerViewDelegate?

	@IBOutlet weak var scannerLoadingIndicator: UIActivityIndicatorView!
	@IBOutlet weak var backgroundImage: UIImageView!
	@IBOutlet weak var blurView: UIVisualEffectView!
	@IBOutlet weak var permissionsRequiredView: UIView!
	@IBOutlet weak var manualPermissionsButton: UIButton!
	@IBOutlet weak var dismissKeyboardButton: UIButton!
	@IBOutlet weak var manualUPCInputView: UIView!
	@IBOutlet weak var manualUPCViewBottomConstraint: NSLayoutConstraint!
	@IBOutlet weak var manualSearchButtonWidth: NSLayoutConstraint!
	@IBOutlet weak var upcField: UITextField!

	// MARK: - Lifecycle

	override init(frame: CGRect) {
		super.init(frame: frame)

		initialize()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		initialize()
	}

	private func initialize() {
		pscope.addPermission(CameraPermission(), message: "Required for scanning UPC's")
		scannerSetup()
	}

	func scannerSetup() {
		scanner = MTBBarcodeScanner(previewView: self)
		scanner!.allowTapToFocus = true
		scanner!.didStartScanningBlock = {
			self.scannerLoading(done: true)
		}
	}

	// MARK: - View Lifecycle

	override func awakeFromNib() {
		if let placeholderImage = FileManager.default.getImageFromDocumentDirectory(named: "scannerPlaceholderImage") {
			self.backgroundImage.image = placeholderImage
		}
	}

	override func didMoveToWindow() {
		if self.window != nil {
			// swiftlint:disable line_length
			NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: .UIKeyboardWillShow, object: nil)
			NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification), name: .UIKeyboardWillHide, object: nil)
			NotificationCenter.default.addObserver(self, selector: #selector(tryScanning), name: .UIApplicationDidBecomeActive, object: nil)
			NotificationCenter.default.addObserver(self, selector: #selector(stopScanning), name: .UIApplicationWillResignActive, object: nil)
			// swiftlint:enable line_length

			tryScanning()
		}

	}

	override func willMove(toWindow newWindow: UIWindow?) {
		if newWindow == nil {
			NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
			NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
			NotificationCenter.default.removeObserver(self, name: .UIApplicationDidBecomeActive, object: nil)
			NotificationCenter.default.removeObserver(self, name: .UIApplicationWillResignActive, object: nil)

			self.scanner?.stopScanning()
		}
	}

	// MARK: - Layout

	func scannerLoading(done: Bool = false) {
		if !done {
			self.blurView.isHidden = false
			self.backgroundImage.isHidden = false
			self.scannerLoadingIndicator.startAnimating()
		} else {
			self.blurView.isHidden = true
			self.backgroundImage.isHidden = true
			self.scannerLoadingIndicator.stopAnimating()
		}
	}

	// MARK: - User Interaction

	@IBAction func back(_ sender: Any) {
		savePlaceholderImage()
		self.delegate?.backWasTapped()
	}

	@IBAction func requestPermissions(_ sender: Any) {
		self.permissionsRequiredView.isHidden = false

		pscope.show({ (finished, results) in
			if finished {
				self.tryScanning()
			}

		}) { (results) in
			// TODO: Show a view over the camera view or button to ask permission
			self.manualPermissionsButton.isEnabled = true
		}
	}

	@IBAction func torchToggle(_ sender: Any) {
		guard let device = AVCaptureDevice.default(for: .video) else { return }

		if device.hasTorch {
			do {
				try device.lockForConfiguration()

				if device.isTorchActive {
					device.torchMode = .off
				} else {
					try device.setTorchModeOn(level: 0.1)
				}

				device.unlockForConfiguration()
			} catch {

			}
		}
	}

	@IBAction func manualUPCInput(_ sender: Any) {
		self.upcField.becomeFirstResponder()
	}

	@IBAction func manualUPCSearch(_ sender: Any) {
		lookupUPC(upc: upcField.text!)
	}

	@objc func keyboardWillShowNotification(notification: NSNotification) {
		savePlaceholderImage()

		self.dismissKeyboardButton.isHidden = false
		self.blurView.isHidden = false
		self.bringSubview(toFront: self.dismissKeyboardButton)
		self.bringSubview(toFront: self.manualUPCInputView)
		updateBottomLayoutConstraintWithNotification(notification: notification)
	}

	@objc func keyboardWillHideNotification(notification: NSNotification) {
		self.dismissKeyboardButton.isHidden = true
		self.blurView.isHidden = true
		self.sendSubview(toBack: self.dismissKeyboardButton)
		updateBottomLayoutConstraintWithNotification(notification: notification)
	}

	@objc func updateBottomLayoutConstraintWithNotification(notification: NSNotification) {

		let handler = KeyboardHandler()

		handler.layoutSetup = {
			(isHiding, keyboardHeight) in
			self.manualUPCViewBottomConstraint.constant = keyboardHeight
		}

		handler.animations = {
			(isHiding, keyboardHeight) in

			self.layoutIfNeeded()

			if self.manualUPCViewBottomConstraint.constant == 0 {
				self.manualUPCInputView.isHidden = true
			} else {
				self.manualUPCInputView.isHidden = false
			}
		}

		handler.animateWithKeyboardWillChange(on: notification, in: self)

	}

	@IBAction func dismissKeyboard(_ sender: Any) {
		self.endEditing(false)
	}

	// MARK: - UITextfield Delegate

	@IBAction func upcFieldModified(_ sender: Any) {
		if upcField.text!.isEmpty {
			// hide button
			self.manualSearchButtonWidth.constant = 0

		} else {
			self.manualSearchButtonWidth.constant = 60
		}

		UIView.animate(withDuration: 0.1, delay: 0.0, options: [.beginFromCurrentState], animations: {
			self.manualUPCInputView.layoutIfNeeded()

		}, completion: nil)
	}

	// MARK: - Additional Helpers

	@objc private func stopScanning() {
		guard let scanner = self.scanner else {
			return
		}

		scanner.stopScanning()
	}

	@objc private func tryScanning() {
		self.manualPermissionsButton.isEnabled = false

		if pscope.statusCamera() != .authorized {
			self.requestPermissions(true)
		} else {
			self.permissionsRequiredView.isHidden = true
			self.beginScanning()
		}
	}

	private func beginScanning() {
		// start scan only if not a simulator or is not already scanning
		guard !Device().isSimulator else {
			return
		}

		guard !scanner!.isScanning() else {
			return
		}

		self.scannerLoading()
		try? self.scanner!.startScanning(resultBlock: { (codes) in

			guard self.dismissKeyboardButton.isHidden, // if keyboard is shown, dont act on scans
				let codeObjects = codes, // codes are empty
				!codeObjects.isEmpty else {
					return
			}

			for code in codeObjects {
				print(code.stringValue as Any)
			}

			self.savePlaceholderImage()
			self.scannerLoading()
			self.scanner!.stopScanning()
			self.lookupUPC(upc: codeObjects[0].stringValue!)
		})
	}

	private func lookupUPC(upc: String) {
		UPCitemdb.lookup(upc: upc, returned: { (data, error) in
			guard error == nil else {
				self.scannerLoading(done: true)
				self.tryScanning()
				// TODO: Alert User, begin scanning again when dismissed
				return
			}

			var productInfo: [String: Any] = [:]

			if data != nil {
				productInfo += data!
			}

			productInfo["ean"] = upc

			self.delegate?.scanner(didFind: productInfo)
		})
	}

	private func savePlaceholderImage() {
		guard pscope.statusCamera() == .authorized else {
			return
		}

		self.scanner?.captureStillImage { (image, error) in
			guard error == nil, image != nil else {
				return
			}

			self.backgroundImage.image = image
			FileManager.default.saveImageToDocumentDirectory(image!, named: "scannerPlaceholderImage", withJPEGQuality: 0.7)
		}
	}

}

@objc protocol UPCScannerViewDelegate: class {
	func scanner(didFind item: [String: Any])
	func backWasTapped()
}
