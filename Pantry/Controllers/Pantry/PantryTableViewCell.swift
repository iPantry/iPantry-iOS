//
//  PantryTableViewCell.swift
//  Pantry
//
//  Created by Justin Oroz on 11/12/16.
//  Copyright © 2016 Justin Oroz. All rights reserved.
//

import UIKit

class PantryTableViewCell: UITableViewCell {
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var countLabel: UILabel!
	@IBOutlet weak var expirationLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

	func setItemData(_ name: String, quantity: Int = 1, expirationDays: Int){
		nameLabel.text = name
		countLabel.text = "\(quantity)"


		switch expirationDays {
		case -6 ..< -2:
			expirationLabel.text = "\(expirationDays) Days Ago"
		case -1:
			expirationLabel.text = "Yesterday"
		case 0:
			expirationLabel.text = "Today"
		case 1:
			expirationLabel.text = "\(expirationDays) Day"
		case 2..<7:
			expirationLabel.text = "\(expirationDays) Days"
		case 7..<14:
			expirationLabel.text = "\(expirationDays/7) Week"
		case 14..<365:
			expirationLabel.text = "\(expirationDays/7) Weeks"
		case 365..<730:
			expirationLabel.text = "\(expirationDays/7) Year"
		default:
			if expirationDays > 0 {
				expirationLabel.text = "\(expirationDays/365) Years"
			} else {
				expirationLabel.text = "Over a week ago"
			}
		}
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
