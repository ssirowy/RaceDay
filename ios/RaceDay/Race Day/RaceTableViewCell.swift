//
//  RaceTableViewCell.swift
//  RaceDay
//
//  Created by Dick Fickling on 1/4/15.
//  Copyright (c) 2015 Questionable Intent. All rights reserved.
//

import UIKit

class RaceTableViewCell: UITableViewCell {

    @IBOutlet weak var joinButton: BorderedButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
