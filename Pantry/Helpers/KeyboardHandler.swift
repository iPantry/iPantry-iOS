//
//  KeyboardHandler.swift
//  Pantry
//
//  Created by Justin Oroz on 3/12/17.
//  Copyright © 2017 Justin Oroz. All rights reserved.
//

import UIKit

class KeyboardHandler {

	var layoutSetup: ((_ isHiding: Bool, _ keyBoardHeight: CGFloat) -> Void)?
	var animations: ((_ isHiding: Bool, _ keyBoardHeight: CGFloat) -> Void)?
	var completion: ((_ completed: Bool) -> Void)?

	func animateWithKeyboardWillChange(on notification: NSNotification, in view: UIView) {
		let userInfo = notification.userInfo!

		guard let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
			let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
				return
		}
		let convertedKeyboardEndFrame = view.convert(keyboardEndFrame, from: view.window)

		guard var rawAnimationCurve = (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.uint32Value else {
			return
		}

		rawAnimationCurve = rawAnimationCurve << 16
		let animationCurve = UIViewAnimationOptions(rawValue: UInt(rawAnimationCurve))

		let isHiding = (notification.name == .UIKeyboardWillHide)
		let keyboardHeight = view.bounds.maxY - convertedKeyboardEndFrame.minY

		layoutSetup?(isHiding, keyboardHeight)

		UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.beginFromCurrentState, animationCurve], animations: {

			self.animations?(isHiding, keyboardHeight)

		}, completion: completion)
	}
}
