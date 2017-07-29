//
//  SettingsAccountCell.swift
//  Pantry
//
//  Created by Justin Oroz on 6/10/17.
//  Copyright © 2017 Justin Oroz. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsAccountCell: UITableViewCell {

	@IBOutlet weak var emailLabel: UILabel!
	@IBOutlet weak var userImage: UIImageView!

	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code

		if let user = PantryUser.current {
			self.emailLabel.text = user.email
		}
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)

		// Configure the view for the selected state
	}

}
