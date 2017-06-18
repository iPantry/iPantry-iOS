//
//  PantryUser.swift
//  Pantry
//
//  Created by Justin Oroz on 6/17/17.
//  Copyright © 2017 Justin Oroz. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

final class PantryUser {

	static var current: PantryUser?
	static func configure() {
		guard current == nil else {
			return
		}
		PantryUser.current = PantryUser()
	}

	private var user: User?
	private var authHandle: AuthStateDidChangeListenerHandle?
	private var userRef: DatabaseReference?
	private var userHandle: UInt?
	private var userDict: [String: AnyObject]?
	private(set) var pantry: Pantry?

	private init() {

		self.authHandle = Auth.auth().addStateDidChangeListener { [unowned self] (auth, user) in
			self.user = user
			if self.userHandle != nil { // remove old observer
				Database.database().reference().removeObserver(withHandle: self.userHandle!)
				self.userHandle = nil
			}

			guard let user = user else {
				log(.info, message: "No User logged in")
				NotificationCenter.default.post(name: .pantryUserDoesNotExist, object: self)

				Auth.auth().signInAnonymously { (_, error) in
					if error != nil {
						log(.error, message: "Could not log in anonymously: \(error!.localizedDescription)")
						// TODO: Alert User, retry
					}
				}
				return
			}

			self.userRef = Database.database().reference().child("users").child(user.uid)

			self.userHandle = self.userRef!.observe(.value) { [unowned self] (snapshot) in
				guard self.user != nil else {
					// no user logged in, do nothing
					return
				}

				guard snapshot.exists() else {
					// create user dictionary
					var userDict = [String: AnyObject]()
					var childUpdates = [String: AnyObject]()

					if self.user!.isAnonymous {
						userDict["pantry"] = false as AnyObject
						childUpdates["/users/\(self.user!.uid)"] = userDict as AnyObject
					} else {
						let pantryRef = Database.database().reference().child("pantries")
						let newPantryId = pantryRef.childByAutoId().key

						// add pantry ID to user
						userDict["pantry"] = newPantryId as AnyObject
						childUpdates["/users/\(self.user!.uid)"] = userDict as AnyObject

						// create pantry
						childUpdates["/pantries/\(newPantryId)/members"] = [self.user!.uid: true] as AnyObject
					}

					Database.database().reference().updateChildValues(childUpdates)
					return
				}

				guard let userDict = snapshot.value as? [String: AnyObject] else {
					log(.error, message: "User directory snapshot malformed: \(snapshot.value!)")
					return
				}

				if let _ = userDict["pantry"] as? Bool {
					self.pantry = Pantry(withId: PantryIdentifier(user.uid, indexedBy: .creator))
				} else if let pantryId = userDict["pantry"] as? String {
					self.pantry = Pantry(withId: PantryIdentifier(pantryId, indexedBy: .pantryId))
				} else {
					self.pantry = nil
				}

				self.userDict = userDict
				NotificationCenter.default.post(name: .pantryUserWasUpdated, object: self)
			}

			NotificationCenter.default.post(name: .pantryUserExists, object: self)
			if user.isAnonymous {
				print("[INFO]: User is logged in anonymously")
				NotificationCenter.default.post(name: .pantryUserIsAnonymous, object: self)
			} else {
				print("[INFO]: \(user.email ?? "Someone") is logged in")
				NotificationCenter.default.post(name: .pantryUserIsLoggedIn, object: self)
			}
		}
	}

	deinit {
		Auth.auth().removeStateDidChangeListener(self.authHandle!)

		if self.userHandle != nil {
			Database.database().reference().removeObserver(withHandle: self.userHandle!)
		}
	}

	var state: PantryUserState? {
		guard let user = self.user else {
			return nil
		}

		if user.isAnonymous {
			return .anonymous
		} else {
			return .loggedIn
		}

	}

	var pantryIdentifier: PantryIdentifier? {
		guard let user = self.user else {
			return nil
		}

		if user.isAnonymous {
			return PantryIdentifier(user.uid, indexedBy: .creator)
		} else if let pantryId = self.userDict?["pantry"] as? String {
			return PantryIdentifier(pantryId, indexedBy: .pantryId)
		} else {
			return nil
		}
	}

	var uid: String? {
		return self.user?.uid
	}

	var email: String? {
		return self.user?.email
	}

}

// MARK: - Enums
enum PantryUserState {
	case anonymous
	case loggedIn
}

// MARK: - Notifications
extension Notification.Name {
	static let pantryUserWasUpdated = Notification.Name("pantryUserWasUpdatedNotification")
	static let pantryUserIsAnonymous = Notification.Name("PantryUserIsAnonymousNotification")
	static let pantryUserIsLoggedIn = Notification.Name("PantryUserIsLoggedInNotification")
	static let pantryUserDoesNotExist = Notification.Name("PantryUserDoesNotExistNotification")
	static let pantryUserExists = Notification.Name("PantryUserExistsNotification")
}