//
//  MessageContactsCell.swift
//  Chapperone
//
//  Created by Thabo David Klass on 30/08/2018.
//  Copyright © 2018 Chapperone. All rights reserved.
//

import UIKit

class MessageContactsCell: UITableViewCell {
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var contactFullName: UILabel!
    @IBOutlet weak var contactSchool: UILabel!
    @IBOutlet weak var contactRole: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        /// Start the image view out as invisible
        contactImageView.alpha = 0
        
        /// Create rounded corners
        let cellImageLayer: CALayer? = contactImageView.layer
        cellImageLayer!.borderWidth = 0
        cellImageLayer!.borderColor = UIColor.gray.cgColor
        
        cellImageLayer!.cornerRadius = contactImageView.frame.height / 2 // 6
        //cellImageLayer!.cornerRadius = 8
        cellImageLayer!.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /**
     Sets the cell data from Firebase.
     
     - Parameters:
     - none
     
     - Returns: void.
     */
    func cofigureCell(contact: User) {
        /// Get a database reference to recipient
        if contact.key != nil {
            /*let recipientData = Database.database().reference().child("user").child(contact.key!)
             
             /// Get a single event snapshot of the recipient's user data
             recipientData.observeSingleEvent(of: .value, with: { (snapshot) in
             /// Get the snapshot value
             let data = snapshot.value as! Dictionary<String, AnyObject>
             
             /// Get the image URL (which is stored on Firebase)
             let userImage = data["profilePictureFileName"] as? String
             
             if userImage != nil {
             /// When signing up, the user image is store as "empty"
             if userImage != "empty" {
             /// Get a reference to the image using the URL
             let ref = Storage.storage().reference(forURL: userImage!)
             
             /// Get the image data
             ref.getData(maxSize: 1000000, completion: { (data, error) in
             if error != nil {
             print("Could not load image.")
             } else {
             if let imageData = data {
             if let image = UIImage(data: imageData) {
             /// Store the image data inside the image view
             self.contactImageView.image = image
             
             /// Animate the image view will a duration of 0.5 seconds
             UIView.animate(withDuration: 0.5, animations: { () -> Void in
             self.contactImageView.alpha = 1
             })
             }
             }
             }
             })
             } else {
             // If the image URL is somehow nil, load the default empty pic
             let image = UIImage(named: "empy_profile_pic")
             self.contactImageView.image = image
             UIView.animate(withDuration: 0.5, animations: { () -> Void in
             self.contactImageView.alpha = 1
             })
             }
             } else {
             // If the image URL is somehow nil, load the default empty pic
             let image = UIImage(named: "empy_profile_pic")
             self.contactImageView.image = image
             UIView.animate(withDuration: 0.5, animations: { () -> Void in
             self.contactImageView.alpha = 1
             })
             }
             })
             }*/
            
            let dBase = Firestore.firestore()
            
            let userRef = dBase.collection("users").document(contact.key!)
            
            userRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let userDict = document.data() {
                        /// Check for nil again
                        if let userImage = userDict["profilePictureFileName"] as? String {
                            /// When signing up, the user image is store as "empty"
                            if userImage != ApplicationConstants.dbEmptyValue {
                                /// Get a reference to the image using the URL
                                let ref = Storage.storage().reference(forURL: userImage)
                                
                                /// Get the image data
                                ref.getData(maxSize: 1000000, completion: { (data, error) in
                                    if error != nil {
                                        print(ApplicationConstants.profilePictureDownloadErrorMessage)
                                    } else {
                                        if let imageData = data {
                                            if let image = UIImage(data: imageData) {
                                                /// Store the image data inside the image view
                                                self.contactImageView.image = image
                                                
                                                /// Animate the image view will a duration of 0.5 seconds
                                                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                                                    self.contactImageView.alpha = 1
                                                })
                                            }
                                        }
                                    }
                                })
                            } else {
                                /// If the image URL is "empty", load the default empty pic
                                let image = #imageLiteral(resourceName: "empy_profile_pic")
                                self.contactImageView.image = image
                                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                                    self.contactImageView.alpha = 1
                                })
                            }
                        }
                    }
                }
            }
        }
    }
    
    func setEmpyProfilePic() {
        /// If the image URL is somehow nil, load the default empty pic
        let image = UIImage(named: "empy_profile_pic")
        self.contactImageView.image = image
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.contactImageView.alpha = 1
        })
    }
}
