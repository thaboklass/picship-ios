//
//  MajeshiUserProfileTableViewCell.swift
//  Majeshi
//
//  Created by Thabo David Klass on 06/06/2018.
//  Copyright © 2018 Spreebie, Inc. All rights reserved.
//

import UIKit

class MajeshiUserProfileTableViewCell: UITableViewCell {
    @IBOutlet weak var majeshiIcon: UIImageView!
    @IBOutlet weak var majeshiTitle: UILabel!
    @IBOutlet weak var majeshiMeta: UILabel!
    @IBOutlet weak var majeshiMetaBackground: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
