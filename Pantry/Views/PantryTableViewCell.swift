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

	func configure(from pantryItem: PantryItem) {
		self.nameLabel.text = pantryItem.title
		self.countLabel.text = String(describing: pantryItem.quantity ?? 1)
		self.expirationLabel.text = getExpirationDescription(days: pantryItem.expirationEstimate)
	}

	private func getExpirationDescription(days: Int?) -> String {
		guard let days = days else {
			return "?"
		}

		switch days {
		case -6 ..< -2:
			return "\(days) Days Ago"
		case -1:
			return "Yesterday"
		case 0:
			return "Today"
		case 1:
			return "\(days) Day"
		case 2..<7:
			return "\(days) Days"
		case 7..<14:
			return "\(days/7) Week"
		case 14..<365:
			return "\(days/7) Weeks"
		case 365..<730:
			return "\(days/7) Year"
		default:
			if days > 0 {
				return "\(days/365) Years"
			} else {
				return "Over a week ago"
			}
		}

	}

	private func setItemData(_ name: String, quantity: Int = 1, expirationDays: Int) {
		nameLabel.text = name
		countLabel.text = "\(quantity)"

	}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
