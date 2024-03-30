//
//  UserProfileViewController.swift
//  PicShip
//
//  Created by Thabo David Klass on 27/05/2019.
//  Copyright © 2019 Open Beacon. All rights reserved.
//

import UIKit
import StoreKit

class UserProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userHandleLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var bookerButton: UIButton!
    @IBOutlet weak var shipPicSegmentedControl: UISegmentedControl!
    @IBOutlet weak var shipPicCollectionView: UICollectionView!
    @IBOutlet weak var settingsBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var chatActivityIndicatorView: UIActivityIndicatorView!
    
    var picShips = [String]()
    var ownerIDs = [String]()
    var titles = [String]()
    var shipPicIDS = [String]()
    var createdAts = [Int]()
    var dueAts = [Int]()
    var numberOfLikesArray = [Int]()
    var imageShiPics = [String]()
    var videoStatuses = [Bool]()
    var mainShipPicKeys = [String]()
    
    /// The current logged in user
    var currentUser: String? = KeychainWrapper.standard.string(forKey: ApplicationConstants.majeshiUserIDKey)
    
    /// The cell spacing of the collection view
    fileprivate var leftRightAndCellSpacing: CGFloat = 32.0
    
    /// The number of cells per row
    fileprivate let numberOfItemsPerRow: CGFloat = 3.0
    
    /// The height adjustment of the cells
    fileprivate let heightAdjustment: CGFloat = 30.0
    
    var selectedIndex: Int? = nil
    var selectedIndexPath: IndexPath? = nil
    
    var searchedUserID: String? = nil
    
    var userToLookUp: String? = nil
    
    /// The message ID
    var messageID: String!
    
    var userFullName = ""
    
    var userFiles = [String]()
    
    var userFilesTotalSize: Int64 = 0
    
    // In-App Stuff
    /// In-App purchases
    var sharedSecret = ""
    
    // This is the In-App Purchase product list
    var inAppProductList = [SKProduct]()
    
    // The product being bought
    var activeProduct = SKProduct()
    
    /// The space allocated for the folder
    var spaceAllocated: Int64 = 100 * 1024 * 1024
    
    /// Has the space been exceeed
    var spaceAllocatedExceeded = false
    
    /// The duration of the subscription = 30 days
    let subscriptionDuration: Int = 43200
    
    /// Progress animation
    let shapeLayer = CAShapeLayer()
    let trackLayer = CAShapeLayer()
    
    let percentageLabel: UILabel = {
        let label = UILabel()
        label.text = "0%"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 32)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let darkGrayish = UIColor(red: 31.0/255.0, green: 33.0/255.0, blue: 36.0/255.0, alpha: 1.0)
        
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.barTintColor = darkGrayish
        
        chatButton.isEnabled = false
        chatActivityIndicatorView.hidesWhenStopped = true
        
        
        let greenish = UIColor(red: 45.0/255.0, green: 182.0/255.0, blue: 174.0/255.0, alpha: 1.0)
        
        let orangish = UIColor(red: 248.0/255.0, green: 119.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        
        let imageLayer: CALayer?  = self.userImageView.layer
        imageLayer!.borderWidth = 2.0
        imageLayer!.borderColor = UIColor.black.cgColor
        
        imageLayer!.cornerRadius = userImageView.frame.height / 2
        imageLayer!.masksToBounds = true
        
        let borderLayer: CALayer?  = self.borderView.layer
        borderLayer!.borderWidth = 2.5
        borderLayer!.borderColor = orangish.cgColor
        
        borderLayer!.cornerRadius = borderView.frame.height / 2
        borderLayer!.masksToBounds = true
        
        let settingsButtonLayer: CALayer?  = settingsButton.layer
        settingsButtonLayer!.cornerRadius = 4
        settingsButtonLayer!.masksToBounds = true
        
        let bookerButtonLayer: CALayer?  = bookerButton.layer
        bookerButtonLayer!.cornerRadius = 4
        bookerButtonLayer!.masksToBounds = true
        
        
        /// Animation
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 59, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        trackLayer.path = circularPath.cgPath
        
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 4
        trackLayer.fillColor = UIColor.white.cgColor
        trackLayer.lineCap = CAShapeLayerLineCap.round
        trackLayer.position = userImageView.center
        
        view.layer.addSublayer(trackLayer)
        
        shapeLayer.path = circularPath.cgPath
        
        let lightGreeen = UIColor(red: 41.0/255.0, green: 169.0/255.0, blue: 158.0/255.0, alpha: 1.0)
        shapeLayer.strokeColor = lightGreeen.cgColor
        shapeLayer.lineWidth = 4
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        shapeLayer.position = userImageView.center
        
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        
        shapeLayer.strokeEnd = 0
        
        view.layer.addSublayer(shapeLayer)
        
        view.addSubview(percentageLabel)
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        percentageLabel.center = userImageView.center
        
        //let maroonish = UIColor(red: 169.0/255.0, green: 43.0/255.0, blue: 41.0/255.0, alpha: 1.0)
        percentageLabel.textColor = orangish
        
        percentageLabel.isHidden = true
        trackLayer.isHidden = true
        shapeLayer.isHidden = true

        
        //let maroonish = UIColor(red: 169.0/255.0, green: 43.0/255.0, blue: 41.0/255.0, alpha: 1.0)
        //settingsButton.layer.backgroundColor = maroonish.cgColor
        
        /// Adjust the collection view to fit all sizes of phone
        let width = (view.frame.width - leftRightAndCellSpacing) / numberOfItemsPerRow
        let layout = shipPicCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)
        
        /// Enable paging for the collection view
        shipPicCollectionView.isPagingEnabled = true
        
        shipPicCollectionView.dataSource = self
        shipPicCollectionView.delegate = self
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // Add all the In-App Purchases - in this case, there is only one
        // - a non-renewable. From there, start the In-App Purchase system.
        if (SKPaymentQueue.canMakePayments()) {
            print("In-App Purchases loading...")
            let productID: NSSet = NSSet(objects: ApplicationConstants.picShipInAppPurchasesID)
            let request: SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
            request.delegate = self
            request.start()
        } else {
            print("Please enable In-App Purchases.")
        }
        
        userToLookUp = currentUser
        
        if searchedUserID != nil {
            userToLookUp = searchedUserID
            
            settingsButton.isEnabled = false
            settingsBarButtonItem.isEnabled = false
            
            bookerButton.isEnabled = false
            
            profilePictureButton.isEnabled = false
        }
        
        if userToLookUp == currentUser {
            chatButton.isEnabled = false
        }
        
        setUserData()
        
        getMyShipPics()
        //getTaggedShipPics()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("Inside viewDidAppear.")
        if ApplicationConstants.shipPicEditingJustHappened {
            self.picShips.removeAll()
            self.titles.removeAll()
            self.shipPicIDS.removeAll()
            self.createdAts.removeAll()
            self.dueAts.removeAll()
            self.imageShiPics.removeAll()
            self.videoStatuses.removeAll()
            self.mainShipPicKeys.removeAll()
            
            userFiles.removeAll()
            
            if shipPicSegmentedControl.selectedSegmentIndex == 0 {
                getMyShipPics()
            } else {
                getTaggedShipPics()
            }
            
            ApplicationConstants.shipPicEditingJustHappened = false
        }
        
        if ApplicationConstants.profilePictureUpdated {
            setUserData()
            
            ApplicationConstants.profilePictureUpdated = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if ApplicationConstants.justMovedBackFromSignOut {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cameraBarButtonItemTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shipPicIDS.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        /// The last visible index path
        //self.indexPath = indexPath
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PicShipProfileCollectionViewCell", for: indexPath) as! PicShipProfileCollectionViewCell
        
        let greenish = UIColor(red: 45.0/255.0, green: 182.0/255.0, blue: 174.0/255.0, alpha: 1.0)
        
        //cell.videoIcon.isHidden = true
        //cell.videoIcon.tintColor = greenish
        
        //cell.spreebieDistanceAwayLabel.alpha = 0
        
        /*let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
         let documentDirectoryURL = URL(fileURLWithPath: documentDirectory)*/
        
        /// If the spreebieFileName is not nil
        if imageShiPics[indexPath.row] != "" {
            print("Beneath the indexPath")
            
            /*if videoStatuses[indexPath.row] {
             cell.videoIcon.isHidden = false
             }*/
            //let smallFileName = "s-" + self.spreebieFileNames[indexPath.row]!
            //let downloadSmallFileURL = documentDirectoryURL.appendingPathComponent(smallFileName)
            
            /// Download or insert inmage into the cell if it already exists locally
            /*if FileManager.default.fileExists(atPath: downloadSmallFileURL.path) {
             self.insertSpreebieImage(cell, fileName: smallFileName, downloadFileURL: downloadSmallFileURL)
             } else {
             cell.spreebieActivityIndicator.alpha = 1
             cell.spreebieActivityIndicator.startAnimating()*/
            
            loadShipPicImageForCell(cell: cell, imageFileURL: imageShiPics[indexPath.row])
            //}
            
            /*if spreebieLocations[indexPath.row] != nil {
             if currentLocation != nil {
             let spreebieLocationGeoPoint = spreebieLocations[indexPath.row]
             let latitude = CLLocationDegrees((spreebieLocationGeoPoint?.latitude)!)
             let longitude = CLLocationDegrees((spreebieLocationGeoPoint?.longitude)!)
             
             let spreebieLocation = CLLocation(latitude: latitude, longitude: longitude)
             let distanceApart = calculateDistanceApart(spreebieLocation)
             
             cell.spreebieDistanceAwayLabel.text = distanceApart
             } else {
             self.distancesAway.append(nil)
             cell.spreebieDistanceAwayLabel.text = "Distance unknown"
             }
             } else {
             self.distancesAway.append(nil)
             cell.spreebieDistanceAwayLabel.text = "Distance unknown"
             }*/
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        selectedIndexPath = indexPath
        
        self.performSegue(withIdentifier: "openShipPicFromProfile", sender: nil)
    }
    
    func getMyShipPics() {
        if userToLookUp != nil {
            print("Inside getPublicShipPics() 01")
            let dBase = Firestore.firestore()
            
            let picShipRef = dBase.collection("picShip").document(userToLookUp!).collection("picShips")
            
            picShipRef.order(by: "createdAt", descending: true).getDocuments { (querySnapshot, error) in
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
                            if let videoFileURL = picShipMetaDict["videoFileURL"] as? String, let imageFileURL = picShipMetaDict["imageFileURL"] as? String, let title = picShipMetaDict["title"] as? String, let createdAt = picShipMetaDict["createdAt"] as? Int, let dueAt = picShipMetaDict["dueAt"] as? Int, let isVideo = picShipMetaDict["isVideo"] as? Bool, let isPublic = picShipMetaDict["isPublic"] as? Bool {
                                if isPublic {
                                    let key = "\(createdAt)-\(self.userToLookUp!)"
                                    self.picShips.append(videoFileURL)
                                    self.titles.append(title)
                                    self.shipPicIDS.append(key)
                                    self.createdAts.append(createdAt)
                                    self.dueAts.append(dueAt)
                                    self.imageShiPics.append(imageFileURL)
                                    self.videoStatuses.append(isVideo)
                                    self.mainShipPicKeys.append(mainKey)
                                } else {
                                    if self.userToLookUp == self.currentUser {
                                        let key = "\(createdAt)-\(self.userToLookUp!)"
                                        self.picShips.append(videoFileURL)
                                        self.titles.append(title)
                                        self.shipPicIDS.append(key)
                                        self.createdAts.append(createdAt)
                                        self.dueAts.append(dueAt)
                                        self.imageShiPics.append(imageFileURL)
                                        self.videoStatuses.append(isVideo)
                                        self.mainShipPicKeys.append(mainKey)
                                    }
                                }
                                
                                if isVideo {
                                    self.userFiles.append(videoFileURL)
                                } else {
                                    self.userFiles.append(imageFileURL)
                                }
                            }
                            
                            print("The dict contents: \(picShipMetaDict)")
                        }
                        
                        self.updateSpaceAllocation()
                        
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self.shipPicCollectionView.reloadData()
                    } else {
                        self.updateSpaceAllocation()
                    }
                } else {
                    print("Inside getPublicShipPics() 03")
                    print("Error: \(error?.localizedDescription)")
                }
            }
        }
    }
    
    func getTaggedShipPics() {
        if userToLookUp != nil {
            print("Inside getPublicShipPics() 01")
            let dBase = Firestore.firestore()
            
            let picShipRef = dBase.collection("tagged").document(userToLookUp!).collection("picShips")
            
            picShipRef.order(by: "createdAt", descending: true).getDocuments { (querySnapshot, error) in
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
                            //let mainKey = ""
                            
                            let picShipMetaDict = data.data()
                            if let videoFileURL = picShipMetaDict["videoFileURL"] as? String, let imageFileURL = picShipMetaDict["imageFileURL"] as? String, let title = picShipMetaDict["title"] as? String, let createdAt = picShipMetaDict["createdAt"] as? Int, let dueAt = picShipMetaDict["dueAt"] as? Int, let isVideo = picShipMetaDict["isVideo"] as? Bool, let picShipID = picShipMetaDict["picShipID"] as? String, let picShipOwnerID = picShipMetaDict["picShipOwnerID"] as? String, let isPublic = picShipMetaDict["isPublic"] as? Bool {
                                if isPublic {
                                    let key = "\(createdAt)-\(picShipOwnerID)"
                                    self.picShips.append(videoFileURL)
                                    self.titles.append(title)
                                    self.shipPicIDS.append(key)
                                    self.createdAts.append(createdAt)
                                    self.dueAts.append(dueAt)
                                    self.imageShiPics.append(imageFileURL)
                                    self.videoStatuses.append(isVideo)
                                    self.mainShipPicKeys.append(picShipID)
                                } else {
                                    if self.userToLookUp == self.currentUser || self.currentUser == picShipOwnerID {
                                        let key = "\(createdAt)-\(picShipOwnerID)"
                                        self.picShips.append(videoFileURL)
                                        self.titles.append(title)
                                        self.shipPicIDS.append(key)
                                        self.createdAts.append(createdAt)
                                        self.dueAts.append(dueAt)
                                        self.imageShiPics.append(imageFileURL)
                                        self.videoStatuses.append(isVideo)
                                        self.mainShipPicKeys.append(picShipID)
                                    }
                                }
                            }
                            
                            print("The dict contents: \(picShipMetaDict)")
                        }
                        
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self.shipPicCollectionView.reloadData()
                    }
                } else {
                    print("Inside getPublicShipPics() 03")
                    print("Error: \(error?.localizedDescription)")
                }
            }
        }
    }
    
    func loadShipPicImageForCell(cell: PicShipProfileCollectionViewCell, imageFileURL: String) {
        print("Ïnside loadShipPicImage() 01")
        /*seekSlider.isEnabled = false
         seekSlider.isHidden = true
         
         playbackButton.isEnabled = false
         playbackButton.isHidden = true
         
         loadingActivityIndicatorView.stopAnimating()
         loadingActivityIndicatorView.isHidden = true*/
        
        cell.shipPicActivityIndicatorView.startAnimating()
        
        
        if imageFileURL != "" {
            print("Ïnside loadShipPicImage() 02")
            /// Get a reference to the image using the URL
            let ref = Storage.storage().reference(forURL: imageFileURL)
            
            /// Get the image data
            ref.getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print(ApplicationConstants.profilePictureDownloadErrorMessage)
                    
                    cell.shipPicActivityIndicatorView.stopAnimating()
                    cell.shipPicActivityIndicatorView.isHidden = true
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                } else {
                    if let imageData = data {
                        if let image = UIImage(data: imageData) {
                            cell.shipPicImageView.alpha = 0
                            //self.shipPicImageView.alpha = 0
                            
                            //self.shipPicImageView.image = image
                            
                            let imageHeight: Double = Double(image.size.height)
                            let imageWidth: Double = Double(image.size.width)
                            
                            var size = Double()
                            
                            if imageWidth > imageHeight {
                                size = imageHeight
                            } else {
                                size = imageWidth
                            }
                            
                            cell.shipPicImageView.image = ImageManipulation().cropToBounds(image, width: size, height: size)
                            
                            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                                cell.shipPicImageView.alpha = 1
                                
                                cell.shipPicActivityIndicatorView.stopAnimating()
                                cell.shipPicActivityIndicatorView.isHidden = true
                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                
                                /*if self.shouldAnimateSwipeLeftLabel {
                                 self.animateSwipeLeftLabel()
                                 }*/
                            })
                        }
                    }
                }
            })
        }
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
            //let ref = Storage.storage().reference(forURL: fileNameURL)
            
            /// Get the image data
            /*ref.getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print(ApplicationConstants.profilePictureDownloadErrorMessage)
                } else {
                    if let imageData = data {
                        if let image = UIImage(data: imageData) {
                            imageView.alpha = 0
                            let imageLayer: CALayer?  = imageView.layer
                            imageLayer!.cornerRadius = imageView.frame.height / 2
                            //imageLayer!.cornerRadius = 6
                            imageLayer!.masksToBounds = true
                            
                            imageView.image = image
                            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                                imageView.alpha = 1
                            })
                        }
                    }
                }
            })*/
            
            shapeLayer.strokeEnd = 0
            
            percentageLabel.isHidden = false
            trackLayer.isHidden = false
            shapeLayer.isHidden = false
            
            /// Get a reference to the image using the URL
            let ref = Storage.storage().reference(forURL: fileNameURL)
            
            let fileNameToSaveAs = "profile_" + userToLookUp! + ".jpg"
            
            /// The directory of the documents folder
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
            
            /// The URL of the documents folder
            let documentDirectoryURL = URL(fileURLWithPath: documentDirectory)
            
            /// The local URL of the profile pic
            let localURL = documentDirectoryURL.appendingPathComponent(fileNameToSaveAs)
            
            let downloadTask = ref.write(toFile: localURL)
            
            downloadTask.observe(.progress) { snapshot in
                let percentCompleteDouble = 100.0 * Double(snapshot.progress!.completedUnitCount)
                    / Double(snapshot.progress!.totalUnitCount)
                if !percentCompleteDouble.isNaN {
                    let percentComplete = Int(percentCompleteDouble)
                    print("Done: \(percentComplete)%")
                    
                    let progress = Double(snapshot.progress!.completedUnitCount)
                        / Double(snapshot.progress!.totalUnitCount)
                    
                    self.percentageLabel.text = "\(percentComplete)%"
                    self.shapeLayer.strokeEnd = CGFloat(progress)
                    
                }
            }
            
            downloadTask.observe(.success) { snapshot in
                // Download completed successfully
                print("Downloaded successfully")
                self.percentageLabel.isHidden = true
                self.trackLayer.isHidden = true
                self.shapeLayer.isHidden = true
                
                if let image = UIImage(contentsOfFile: localURL.path) {
                    imageView.alpha = 0
                    let imageLayer: CALayer?  = imageView.layer
                    imageLayer!.cornerRadius = imageView.frame.height / 2
                    //imageLayer!.cornerRadius = 6
                    imageLayer!.masksToBounds = true
                    
                    imageView.image = image
                    UIView.animate(withDuration: 0.5, animations: { () -> Void in
                        imageView.alpha = 1
                    })
                }
            }
        }
    }
    
    /// Sets the user data into the table
    func setUserData() {
        /// Check for nil
        if userToLookUp != nil {
            let dBase = Firestore.firestore()
            let userRef = dBase.collection("users").document(userToLookUp!)
            
            userRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let userDict = document.data() {
                        /// Check for nil again
                        if let fullName = userDict["fullName"] as? String, let email = userDict["phoneNumber"] as? String, let profilePictureFileName = userDict["profilePictureFileName"] as? String, let displayPhoneNumber = userDict["displayPhoneNumber"] as? Bool {
                            
                            /// Set the text data
                            //self.userNameLabel.text = fullName
                            self.userFullName = fullName
                            self.navigationItem.title = fullName
                            
                            if self.userToLookUp != self.currentUser {
                                self.chatButton.isEnabled = true
                            }
                            
                            if displayPhoneNumber {
                                self.userHandleLabel.text = email
                            } else {
                                self.userHandleLabel.text = "Number hidden."
                            }
                            //self.currentEmail = email
                            
                            /// Set the profile picture data
                            if profilePictureFileName != ApplicationConstants.dbEmptyValue {
                                //self.profilePictureFileName = profilePictureFileName
                                //self.setProfilePicture()
                                self.downloadProfilePic(self.userImageView, fileNameURL: profilePictureFileName)
                            } else {
                                /*if !self.popupShown {
                                 DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                 self.performSegue(withIdentifier: "OpenPopupFromSettings", sender: nil)
                                 })
                                 
                                 self.popupShown = true
                                 }*/
                            }
                            
                            /// Enable the interface
                            //self.enableInterface()
                            //UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        }
                    }
                } else {
                    print("Error: \(error?.localizedDescription)")
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "openShipPicFromProfile") {
            print("inside the segue identifier openPicShipDetails")
            //let navigationController = segue.destination as! UINavigationController
            let spvc = segue.destination as! ShipPicViewControllerWithScrollView
            
            if selectedIndex != nil {
                spvc.isSingleShipPic = true
                spvc.singleShipPicID = shipPicIDS[selectedIndex!]
                spvc.mainShipPicKey = mainShipPicKeys[selectedIndex!]
                spvc.dueAt = dueAts[selectedIndex!]
                
                
                let selectedCell = shipPicCollectionView.cellForItem(at: selectedIndexPath!) as! PicShipProfileCollectionViewCell
                
                spvc.image = selectedCell.shipPicImageView.image
            }
        }
        
        if (segue.identifier == "OpenMessagesFromProfile") {
            weak var mvc = segue.destination as? MessagesViewController
            
            mvc!.recipient = userToLookUp!
            mvc!.messageID = messageID
            mvc!.recipientName = userFullName
        }
    }
    
    @IBAction func chatButtonTapped(_ sender: Any) {
        if userToLookUp != currentUser {
            chatActivityIndicatorView.startAnimating()
            chatButton.alpha = 0
            
            let dBase = Firestore.firestore()
            
            let messageRef = dBase.collection("users").document(self.currentUser!).collection("messages")
            
            messageRef.getDocuments { (querySnapshot, error) in
                if error == nil {
                    if let queryDocumentSnapshot = querySnapshot?.documents {
                        if queryDocumentSnapshot.count == 0 {
                            //self.chatButton.isEnabled = true
                            self.chatActivityIndicatorView.stopAnimating()
                            self.chatButton.alpha = 1
                        }
                        
                        for data in queryDocumentSnapshot {
                            let messageDict = data.data()
                            
                            if let recipientID = messageDict["recipient"] as? String {
                                if recipientID == self.userToLookUp! {
                                    self.messageID = data.documentID
                                    
                                    self.chatActivityIndicatorView.stopAnimating()
                                    self.chatButton.alpha = 1
                                    
                                    break
                                }
                            }
                        }
                        
                        self.performSegue(withIdentifier: "OpenMessagesFromProfile", sender: nil)
                    } else {
                        self.chatActivityIndicatorView.stopAnimating()
                        self.chatButton.alpha = 1
                    }
                } else {
                    self.chatActivityIndicatorView.stopAnimating()
                    self.chatButton.alpha = 1
                }
            }
        }
    }
    
    @IBAction func shipPicSegmentedControlTapped(_ sender: Any) {
        let segmentedControl = sender as! UISegmentedControl
        
        self.picShips.removeAll()
        self.titles.removeAll()
        self.shipPicIDS.removeAll()
        self.createdAts.removeAll()
        self.dueAts.removeAll()
        self.imageShiPics.removeAll()
        self.videoStatuses.removeAll()
        self.mainShipPicKeys.removeAll()
        
        userFiles.removeAll()
        
        
        if segmentedControl.selectedSegmentIndex == 0 {
            getMyShipPics()
        } else {
            getTaggedShipPics()
        }
    }
    
    func getTotalFileSize() {
        userFilesTotalSize = 0
        
        var count = 0
        for userFile in userFiles {
            print("Ïnside getTotalFileSize 01")
            /// Get a reference to the image using the URL
            let ref = Storage.storage().reference(forURL: userFile)
            
            ref.getMetadata { (metaData, error) in
                if error != nil {
                    // Do nothing
                     print(error)
                } else {
                     print("Ïnside getTotalFileSize 03")
                    print((metaData?.name)! + ": \(String(describing: metaData?.size))")
                    
                    self.userFilesTotalSize = self.userFilesTotalSize + metaData!.size
                    
                    count = count + 1
                    
                    if count == self.userFiles.count {
                        print("The total file size is: \(self.userFilesTotalSize)")
                        
                        let spaceUsedString = self.userFilesTotalSize.picShipStringFromByteCount()
                        self.userNameLabel.text = spaceUsedString + " of \(self.spaceAllocated.picShipStringFromByteCount()) Used"
                        
                        if self.userToLookUp != self.currentUser {
                            let spaceUsedString = self.userFilesTotalSize.picShipStringFromByteCount()
                            self.userNameLabel.text = spaceUsedString + " Used"
                        }
                    }
                }
            }
        }
        
        if userFiles.count < 1 {
            let spaceUsedString = self.userFilesTotalSize.picShipStringFromByteCount()
            self.userNameLabel.text = spaceUsedString + " of \(self.spaceAllocated.picShipStringFromByteCount()) Used"
            
            if self.userToLookUp != self.currentUser {
                let spaceUsedString = self.userFilesTotalSize.picShipStringFromByteCount()
                self.userNameLabel.text = spaceUsedString + " Used"
            }
        }
    }
    
    
    func subscribeForNineHundredExtraMegs() {
        if currentUser != nil {
            let currentDate = Date()
            let timeStamp = Int(currentDate.timeIntervalSince1970)
            
            let subscriptionData = [
                "creationAt": timeStamp,
                "dealtWith": false
                ] as [String : Any]
            
            let dBase = Firestore.firestore()
            dBase.collection("subscriptions").document(currentUser!).collection(ApplicationConstants.picShipInAppPurchasesID).addDocument(data: subscriptionData) { (error) in
                if error == nil {
                    self.updateSpaceAllocation()
                    self.displayMajeshiGenericAlert("Congratulations!", userMessage: "You have successfully subscribed for 900 extra megabytes for a period of 30 days.")
                }
            }
        }
    }
    
    /// MARK - The In-App Purchase Stuff
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Product request")
        let products = response.products
        for product in products {
            print("Product added")
            print(product.productIdentifier)
            print(product.localizedTitle)
            print(product.localizedDescription)
            print(product.price)
            
            inAppProductList.append(product)
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("Transactions restored")
        for transaction in queue.transactions {
            let t: SKPaymentTransaction = transaction
            let prodID = t.payment.productIdentifier as String
            
            switch prodID {
            case ApplicationConstants.picShipInAppPurchasesID:
                print("Subscribe for ten extra spaces.")
                subscribeForNineHundredExtraMegs()
            default:
                print("In-App Purchase not found.")
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("Add payment")
        
        for transaction: AnyObject in transactions {
            let trans = transaction as! SKPaymentTransaction
            
            switch trans.transactionState {
            case .purchased:
                print("Buy OK, unlock In-App Purchase here.")
                print(activeProduct.productIdentifier)
                
                let prodID = activeProduct.productIdentifier
                
                switch prodID {
                case ApplicationConstants.picShipInAppPurchasesID:
                    print("Subscribe for 900 extra megs.")
                    subscribeForNineHundredExtraMegs()
                default:
                    print("In-App Purchase not found.")
                }
                queue.finishTransaction(trans)
                break
            case .failed:
                print("Buy error.")
                displayMajeshiGenericAlert("Purchasing issue", userMessage: "There seems to have been an issue with your in-app purchase. Please try again later.")
                queue.finishTransaction(trans)
                break
            default:
                print("Default")
                break
            }
        }
    }
    
    func buyProduct() {
        print("Buy " + activeProduct.productIdentifier)
        let pay = SKPayment(product: activeProduct)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(pay as SKPayment)
    }
    
    
    
    @IBAction func buySpaceButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Extra space: Buy 900 more megabytes", message: "Create more ShipPics by buying more space. Buy 900 more megabytes of storage for 30 days. Tap 'Buy 900 more megabytes' to continue.", preferredStyle: UIAlertController.Style.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Buy 900 more megabytes", style: UIAlertAction.Style.default, handler: { (alert) -> Void in
            for product in self.inAppProductList {
                let productID = product.productIdentifier
                if (productID == ApplicationConstants.picShipInAppPurchasesID) {
                    self.activeProduct = product
                    self.buyProduct()
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { (alert) -> Void in
            //self.createSpreebieBarButtonItem.isEnabled = true
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
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
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func updateSpaceAllocation() {
        /// Check for nil
        if currentUser != nil {
            let dBase = Firestore.firestore()
            let subscriptionRef = dBase.collection("subscriptions").document(currentUser!).collection("PicShip900MegsFor30Days")
            
            subscriptionRef.getDocuments { (querySnapshot, error) in
                if error == nil {
                    if let queryDocumentSnapshot = querySnapshot?.documents {
                        for data in queryDocumentSnapshot {
                            let subscriptionDict = data.data()
                            
                            if let creationAtTimeStamp = subscriptionDict["creationAt"] as? Int {
                                let currentDate = Date()
                                let creationAt = Date(timeIntervalSince1970: TimeInterval(creationAtTimeStamp))
                                
                                let minuteDifference: Double = currentDate.timeIntervalSince(creationAt) / 60.0
                                let minuteDifferenceInt = Int(minuteDifference)
                                
                                let timeLeftOnSubscription: Int = self.subscriptionDuration - minuteDifferenceInt
                                
                                if timeLeftOnSubscription > 0 {
                                    self.bookerButton.isEnabled = false
                                    self.spaceAllocated = 1024 * 1024 * 1024;
                                    
                                    //self.getTotalFileSize()
                                } else {
                                    self.bookerButton.isEnabled = true
                                    self.spaceAllocated = 100 * 1024 * 1024;
                                    
                                    //self.getTotalFileSize()
                                }
                                
                                if timeLeftOnSubscription <= 4319 && timeLeftOnSubscription > 0 {
                                    if self.userToLookUp == self.currentUser {
                                        self.displayMajeshiGenericAlert("Subscription info", userMessage: "Your subscription for '9OO MB Extra Space for 30 Days' will expire in less than 3 days.")
                                    }
                                }
                                
                                if timeLeftOnSubscription > 0 {
                                    break
                                }
                            }
                        }
                
                        self.getTotalFileSize()
                    } else {
                        self.getTotalFileSize()
                    }
                }
            }
        }
    }
}

extension Int64 {
    fileprivate func picShipStringFromByteCount() -> String {
        if self < 1024 {
            return "\(self) B"
        }
        if self < 1024 * 1024 {
            return "\(self / 1024) KB"
        }
        if self < 1024 * 1024 * 1024 {
            return "\(self / 1024 / 1024) MB"
        }
        return "\(self / 1024 / 1024 / 1024) GB"
    }
}
