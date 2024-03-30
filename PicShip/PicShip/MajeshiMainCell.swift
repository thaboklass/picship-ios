//
//  MajeshiMainCell.swift
//  Majeshi
//
//  Created by Thabo David Klass on 26/05/2018.
//  Copyright © 2018 Spreebie, Inc. All rights reserved.
//

import UIKit

class MajeshiMainCell: UITableViewCell {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var folderOwnerImageView: UIImageView!
    @IBOutlet weak var institutionLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var chatButtonActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var borderView: UIView!
    
    var onChatButtonTapped: (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        folderOwnerImageView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func configureCell() {
        
    }
    
    @IBAction func chatButtonTapped(_ sender: Any) {
        if let onChatButtonTapped = self.onChatButtonTapped {
            onChatButtonTapped()
        }
    }
}
