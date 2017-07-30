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

	/// The current logged in User
	static var current: PantryUser?

	/// Sets up the current user
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
		self.authHandle = Auth.auth().addStateDidChangeListener(authStateChanged)
	}

	deinit {
		Auth.auth().removeStateDidChangeListener(self.authHandle!)

		if self.userHandle != nil {
			Database.database().reference().removeObserver(withHandle: self.userHandle!)
		}
	}

	/// Handles Firebase Authentication changes
	/// Signs in Anonymously if no user logged in
	/// Begins observing User directory when logged in
	///
	/// - Parameters:
	///   - auth: Firebase User object
	///   - user: Firebase Auth object
	private func authStateChanged(auth: Auth, user: User?) {
		self.user = user

		if self.userHandle != nil { // remove old observer
			Database.database().reference().removeObserver(withHandle: self.userHandle!)
			self.userHandle = nil
		}

		guard let user = user else {
			fb_log(.info, message: "No User logged in")
			NotificationCenter.default.post(name: .pantryUserDoesNotExist, object: self)

			Auth.auth().signInAnonymously { (_, error) in
				if error != nil {
					fb_log(.error, message: "Could not log in anonymously", args: ["error": error!.localizedDescription])
					// TODO: Alert User, retry
				}
			}
			return
		}

		NotificationCenter.default.post(name: .pantryUserExists, object: self)
		if user.isAnonymous {
			fb_log(.info, message: "User is logged in anonymously")
			NotificationCenter.default.post(name: .pantryUserIsAnonymous, object: self)
		}

		guard !user.isAnonymous else {
			// User is Anonymous
			self.userRef = nil
			self.userHandle = nil
			fb_log(.info, message: "User is logged in anonymously, user directory ignored")
			NotificationCenter.default.post(name: .pantryUserIsAnonymous, object: self)
			return
		}

		self.userRef = Database.database().reference().child("users").child(user.uid)

		self.userHandle = self.userRef!.observe(.value, with: userDirChanged)

		fb_log(.info, message: "A User is logged in", args: ["email": user.email ?? "nil"])
		NotificationCenter.default.post(name: .pantryUserIsLoggedIn, object: self)

	}

	/// Called when data in the user directory is changed
	///
	/// - Parameter snapshot: Firebase snapshot
	private func userDirChanged(snapshot: DataSnapshot) {
		guard self.user != nil else {
			// no user logged in, do nothing
			self.userHandle = nil
			self.userRef = nil
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
			fb_log(.error, message: "User directory snapshot malformed", args: ["snapshot": snapshot.description])
			return
		}

		if let _ = userDict["pantry"] as? Bool {
			self.pantry = Pantry(withId: PantryIdentifier(self.user!.uid, indexedBy: .creator))
		} else if let pantryId = userDict["pantry"] as? String {
			self.pantry = Pantry(withId: PantryIdentifier(pantryId, indexedBy: .pantryId))
		} else {
			self.pantry = nil
		}

		self.userDict = userDict
		NotificationCenter.default.post(name: .pantryUserWasUpdated, object: self)
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
