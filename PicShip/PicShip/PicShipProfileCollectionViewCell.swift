//
//  PicShipProfileCollectionViewCell.swift
//  PicShip
//
//  Created by Thabo David Klass on 25/06/2019.
//  Copyright © 2019 Open Beacon. All rights reserved.
//

import UIKit

class PicShipProfileCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var shipPicImageView: UIImageView!{
        didSet {
            self.layer.cornerRadius = 2.0
        }
    }
    
    @IBOutlet weak var shipPicActivityIndicatorView: UIActivityIndicatorView!
    
    
    @IBOutlet weak var videoIcon: UIImageView!
    
    override func awakeFromNib() {
        /*let greenish = UIColor(red: 45.0/255.0, green: 182.0/255.0, blue: 174.0/255.0, alpha: 1.0)
        
        let shipPicImageViewLayer: CALayer?  = shipPicImageView.layer
        shipPicImageViewLayer!.borderWidth = 1
        shipPicImageViewLayer!.borderColor = greenish.cgColor*/
    }
}
