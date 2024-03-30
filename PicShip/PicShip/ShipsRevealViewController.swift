//
//  ShipsRevealViewController.swift
//  PicShip
//
//  Created by Thabo David Klass on 28/05/2019.
//  Copyright © 2019 Open Beacon. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class ShipsRevealViewController: UIViewController, UISearchBarDelegate {
    @IBOutlet weak var openBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var shipPicsButton: UIButton!
    @IBOutlet weak var picShipImageView: UIImageView!
    @IBOutlet weak var picShipTitleLabel: UILabel!
    @IBOutlet weak var picShipDueDateLabel: UILabel!
    @IBOutlet weak var shipPicActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var viewButton: UIButton!
    
    @IBOutlet weak var shipPicSearchBar: UISearchBar!
    @IBOutlet weak var markAsDealtWithButton: UIButton!
    
    
    var varView = Int()
    
    var picShip: String? = nil
    var ownerID: String? = nil
    var picShipTitle: String? = nil
    var shipPicID: String? = nil
    var createdAt: Int? = nil
    var dueAt: Int? = nil
    var numberOfLikes: Int? = nil
    var imageShiPic: String? = nil
    var videoStatus: Bool? = nil
    var mainShipPicKey: String? = nil
    
    var isTriggeredByTap = false
    
    var shipPic: ShipPic? = nil
    
    var isDealtWith = true
    
    var contactUserID = "empty"
    var contactName = "empty"
    
    /// The message ID
    var messageID: String!
    
    
    /// The current logged in user
    var currentUser: String? = KeychainWrapper.standard.string(forKey: ApplicationConstants.majeshiUserIDKey)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shipPicSearchBar.delegate = self
        
        let orangish = UIColor(red: 248.0/255.0, green: 119.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        
        shipPicSearchBar.keyboardAppearance = .dark
        
        if let textfield = shipPicSearchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = orangish
            //textfield.backgroundColor = UIColor.yellow
        }
        
        let darkGrayish = UIColor(red: 31.0/255.0, green: 33.0/255.0, blue: 36.0/255.0, alpha: 1.0)
        
        view.backgroundColor = darkGrayish
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let viewButtonLayer: CALayer?  = self.viewButton.layer
        viewButtonLayer!.borderWidth = 1.0
        viewButtonLayer!.borderColor = UIColor.white.cgColor
        
        viewButtonLayer!.cornerRadius = viewButton.frame.height / 2
        viewButtonLayer!.masksToBounds = true
        
        shipPicActivityIndicator.isHidden = true
        shipPicActivityIndicator.stopAnimating()
        
        markAsDealtWithButton.isEnabled = false
        markAsDealtWithButton.isHidden = true
        
        if isTriggeredByTap {
            picShipTitleLabel.text = picShipTitle
            
            if imageShiPic != nil {
                print("Inside the the not nil")
                shipPicActivityIndicator.isHidden = false
                shipPicActivityIndicator.startAnimating()
                
                print(imageShiPic!)
                
                downloadProfilePic(picShipImageView, fileNameURL: imageShiPic!)
            }
            
            if dueAt != nil {
                picShipDueDateLabel.text = "Due on: " + convertTimeStampToDate(timeStamp: dueAt!)
                    
                let currentDate = Date()
                let currentTimeStamp = Int(currentDate.timeIntervalSince1970)
                
                print("The time difference is: \(currentTimeStamp - self.dueAt!)")
                
                if (currentTimeStamp - self.dueAt!) < 86400 && (currentTimeStamp - self.dueAt!) > 0 && !self.isDealtWith {
                    self.markAsDealtWithButton.isEnabled = true
                    self.markAsDealtWithButton.isHidden = false
                    
                    print("The contactUserID value is: \(self.contactUserID )")
                    
                    if self.contactUserID != "empty" {
                        let alert = UIAlertController(title: "Private ShipPic", message: "Would you like to send this ShipPic as a private message to \(self.contactName)?", preferredStyle: UIAlertController.Style.alert)
                        
                        alert.view.tintColor = UIColor(red: 248.0/255.0, green: 119.0/255.0, blue: 20.0/255.0, alpha: 1.0)
                        
                        // add the actions (buttons)
                        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { (alert) -> Void in
                            let dBase = Firestore.firestore()
                            
                            let messageRef = dBase.collection("users").document(self.currentUser!).collection("messages")
                            
                            messageRef.getDocuments { (querySnapshot, error) in
                                if error == nil {
                                    if let queryDocumentSnapshot = querySnapshot?.documents {
                                        if queryDocumentSnapshot.count == 0 {
                                            //self.chatButton.isEnabled = true
                                        }
                                        
                                        for data in queryDocumentSnapshot {
                                            let messageDict = data.data()
                                            
                                            if let recipientID = messageDict["recipient"] as? String {
                                                if recipientID == self.contactUserID {
                                                    self.messageID = data.documentID
                                                    
                                                    break
                                                }
                                            }
                                        }
                                        
                                        self.performSegue(withIdentifier: "openMessagesFromDueShipPic", sender: nil)
                                    } else {
                                        // Do nothing
                                    }
                                } else {
                                    // Do nothing
                                }
                            }
                        }))
                        
                        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        } else {
            getMyLastShipPic()
        }
        
        //shipPicsButton.target(forAction: Selector("revealToggle:"), withSender: self.revealViewController())// = self.revealViewController()
        //shipPicsButton.action = Selector("revealToggle:")
        
        shipPicsButton.addTarget(self.revealViewController(), action: Selector("revealToggle:"), for: .touchUpInside)
        
        
        self.view.addGestureRecognizer(self.revealViewController()!.panGestureRecognizer())
        
        /*if varView == 0 {
            label.text = "Strings"
        } else {
            label.text = "Others"
        }*/
        
        let shipPicsButtonLayer: CALayer?  = shipPicsButton.layer
        shipPicsButtonLayer!.cornerRadius = 4
        shipPicsButtonLayer!.masksToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("Inside viewDidAppear.")
        if ApplicationConstants.shipPicEditingJustHappened {
            getMyLastShipPic()
            
            ApplicationConstants.shipPicEditingJustHappened = false
        }
    }
    
    @IBAction func goBackToCamera(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /**
     Displays and alert.
     
     - Parameters:
     - title: The title text
     - userMessage: The message text
     
     - Returns: void.
     */
    func displayMyAlertMessage(_ title: String, userMessage: String) {
        let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertController.Style.alert)
        
        myAlert.view.tintColor = UIColor(red: 248.0/255.0, green: 119.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion: nil)
    }
    
    /**
     Downloads the profile pic from S3, stores it locally and inserts it into the cell.
     
     - Parameters:
     - imageView: The profile pic image view
     - fileName: The name of the file as it is store on S3
     - downloadULR: The local storage url
     
     - Returns: void.
     */
    func downloadProfilePic(_ imageView: UIImageView, fileNameURL: String) {
        /// When signing up, the user image is stored as "empty"
        if fileNameURL != ApplicationConstants.dbEmptyValue {
            /// Get a reference to the image using the URL
            let ref = Storage.storage().reference(forURL: fileNameURL)
            
            /// Get the image data
            ref.getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print(ApplicationConstants.profilePictureDownloadErrorMessage)
                    
                    self.shipPicActivityIndicator.isHidden = true
                    self.shipPicActivityIndicator.stopAnimating()
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    
                    print("Inside the error")
                } else {
                    if let imageData = data {
                        self.shipPicActivityIndicator.isHidden = true
                        self.shipPicActivityIndicator.stopAnimating()
                        
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        
                        if let image = UIImage(data: imageData) {
                            print("Inside the thing")
                            
                            imageView.alpha = 0
                            let imageLayer: CALayer?  = imageView.layer
                            //imageLayer!.cornerRadius = imageView.frame.height / 2
                            //imageLayer!.cornerRadius = 6
                            imageLayer!.masksToBounds = true
                            
                            imageView.image = image
                            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                                imageView.alpha = 1
                            })
                        }
                    }
                }
            })
        }
    }
    
    /**
     Convert the time stamp to a readable date
     
     - Parameters:
     - timeStamp: The timestamp as an int
     
     - Returns: void.
     */
    func convertTimeStampToDate(timeStamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timeStamp))
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        let localDate = dateFormatter.string(from: date)
        
        return localDate
    }
    
    func getMyLastShipPic() {
        if currentUser != nil {
            print("Inside getPublicShipPics() 01")
            let dBase = Firestore.firestore()
            
            let picShipRef = dBase.collection("picShip").document(currentUser!).collection("picShips")
            
            picShipRef.limit(to: 1).order(by: "dueAt", descending: true).getDocuments { (querySnapshot, error) in
                print(querySnapshot)
                print("querySnapshot count: \(querySnapshot?.count)")
                querySnapshot?.count
                print("Inside getPublicShipPics() 02")
                if error == nil {
                    print("Inside getPublicShipPics() 04")
                    if let queryDocumentSnapshot = querySnapshot?.documents {
                        print(queryDocumentSnapshot)
                        print("Inside getPublicShipPics() 05")
                        print("The number of documents is: \(queryDocumentSnapshot.count)")
                        
                        for data in queryDocumentSnapshot {
                            print(data)
                            print("Inside getPublicShipPics() 06")
                            let mainKey = data.documentID
                            
                            let picShipMetaDict = data.data()
                            if let videoFileURL = picShipMetaDict["videoFileURL"] as? String, let imageFileURL = picShipMetaDict["imageFileURL"] as? String, let title = picShipMetaDict["title"] as? String, let createdAt = picShipMetaDict["createdAt"] as? Int, let dueAt = picShipMetaDict["dueAt"] as? Int, let isVideo = picShipMetaDict["isVideo"] as? Bool, let contactUserID = picShipMetaDict["contactUserID"] as? String, let contactName = picShipMetaDict["contactName"] as? String {
                                let key = "\(createdAt)-\(self.currentUser!)"
                                
                                self.picShip = videoFileURL
                                self.picShipTitle = title
                                self.shipPicID = key
                                self.createdAt = createdAt
                                self.dueAt = dueAt
                                self.imageShiPic = imageFileURL
                                self.videoStatus = isVideo
                                self.mainShipPicKey = mainKey
                                self.contactUserID = contactUserID
                                self.contactName = contactName
                                
                                if let isDealtWith = picShipMetaDict["isDealtWith"] as? Bool {
                                    self.isDealtWith = isDealtWith
                                    
                                    let currentDate = Date()
                                    let currentTimeStamp = Int(currentDate.timeIntervalSince1970)
                                    
                                    print("The time difference is: \(currentTimeStamp - self.dueAt!)")
                                    
                                    if (currentTimeStamp - self.dueAt!) < 86400 && (currentTimeStamp - self.dueAt!) > 0 && !self.isDealtWith {
                                        self.markAsDealtWithButton.isEnabled = true
                                        self.markAsDealtWithButton.isHidden = false
                                        
                                        if self.contactUserID != "empty" {
                                            let alert = UIAlertController(title: "Private ShipPic", message: "Would you like to send this ShipPic as a private message \(self.contactName)?", preferredStyle: UIAlertController.Style.alert)
                                            
                                            alert.view.tintColor = UIColor(red: 248.0/255.0, green: 119.0/255.0, blue: 20.0/255.0, alpha: 1.0)
                                            
                                            // add the actions (buttons)
                                            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { (alert) -> Void in
                                                self.performSegue(withIdentifier: "openMessagesFromDueShipPic", sender: nil)
                                            }))
                                            
                                            alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: nil))
                                            self.present(alert, animated: true, completion: nil)
                                        }
                                    }
                                }
                                
                                self.shipPic = ShipPic(shipPicID: key, mainKey: mainKey, shipPicData: picShipMetaDict as Dictionary<String, AnyObject>)
                            }
                            
                            print("The dict contents: \(picShipMetaDict)")
                        }
                        
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        
                        self.shipPicActivityIndicator.isHidden = true
                        self.shipPicActivityIndicator.stopAnimating()
                        
                        self.picShipTitleLabel.text = self.shipPic?.title //self.picShipTitle
                        
                        if self.shipPic?.imageFileURL != nil /*self.imageShiPic != nil*/ {
                            print("Inside the the not nil")
                            self.self.shipPicActivityIndicator.isHidden = false
                            self.shipPicActivityIndicator.startAnimating()
                            
                            //print(self.imageShiPic!)
                            
                            self.downloadProfilePic(self.picShipImageView, fileNameURL: (self.shipPic?.imageFileURL)!)
                        }
                        
                        if self.shipPic?.dueAt != nil {
                            self.picShipDueDateLabel.text = "Due on: " + self.convertTimeStampToDate(timeStamp: (self.self.shipPic?.dueAt)!)
                        }
                    }
                } else {
                    print("Inside getPublicShipPics() 03")
                    print("Error: \(error?.localizedDescription)")
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "openShipPicFromShipPics") {
            print("inside the segue identifier openShipPicFromShipPics")
            //let navigationController = segue.destination as! UINavigationController
            let spvc = segue.destination as! ShipPicViewControllerWithScrollView
            
            //if selectedIndex != nil {
                spvc.isSingleShipPic = true
            if shipPicID != nil {
                print("shipPicID: \(shipPicID)")
                spvc.singleShipPicID = shipPicID!
            }
            
            if mainShipPicKey != nil {
                print("mainShipPicKey: \(mainShipPicKey)")
                spvc.mainShipPicKey = mainShipPicKey!
            }
            
            if dueAt != nil {
                print("dueAt: \(dueAt)")
                spvc.dueAt = dueAt
            }
                
                
                //let selectedCell = shipPicCollectionView.cellForItem(at: selectedIndexPath!) as! PicShipProfileCollectionViewCell
            
            spvc.image = picShipImageView.image
            //}
        }
        
        if (segue.identifier == "openMessagesFromDueShipPic") {
            let navigationController = segue.destination as! UINavigationController
            //let usvc = navigationController.viewControllers[0] as! UserSearchViewController
            let mvc = navigationController.viewControllers[0] as! ShipPicMessageViewController
            
            mvc.recipient = contactUserID
            mvc.messageID = messageID
            mvc.recipientName = contactName
            mvc.imageURL = imageShiPic
            mvc.shipPicID = shipPicID
            mvc.shipPicMainKey = mainShipPicKey
        }
    }
    
    @IBAction func viewButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "openShipPicFromShipPics", sender: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let mainView = self.revealViewController()?.rearViewController as! BackTableVC
        
        guard !searchBar.text!.isEmpty else {
            mainView.filteredShipPics = mainView.shipPics;
            mainView.tableView.reloadData()
            return
        }
        
        mainView.filteredShipPics = mainView.shipPics.filter({ (shipPic) -> Bool in
            //guard let text = searchBar.text else { return false }
            shipPic.title!.lowercased().contains(searchText.lowercased())
        })
        
        mainView.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        //
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //searchActive = false
        searchBar.endEditing(true)
        self.revealViewController()!.revealToggle(nil)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    @IBAction func markAsDealtWithButtonTapped(_ sender: Any) {
        let picShipData: Dictionary<String, AnyObject> = [
            "isDealtWith": true as AnyObject
        ]
        
        let dBase = Firestore.firestore()
        
        let picShipRef = dBase.collection("picShip").document(self.currentUser!)
        picShipRef.collection("picShips").document(mainShipPicKey!).updateData(picShipData) {  (error) in
            if let error = error {
                print("\(error.localizedDescription)")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                self.displayMajeshiGenericAlert("Error", userMessage: "There was an error marking your ShipPic. Please try again.")
            } else {
                self.markAsDealtWithButton.isEnabled = false
                self.markAsDealtWithButton.isHidden = true
                
                self.displayMajeshiGenericAlert("Success!", userMessage: "Your ShipPic has been marked as dealt with.")
            }
        }
    }
    
    /**
     Displays an alert.
     
     - Parameters:
     - title: The title text
     - userMessage: The message text
     
     - Returns: void.
     */
    func displayMajeshiGenericAlert(_ title: String, userMessage: String) {
        let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertController.Style.alert)
        
        myAlert.view.tintColor = UIColor(red: 248.0/255.0, green: 119.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion: nil)
    }
}
