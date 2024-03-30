//
//  ShipPicViewControllerWithScrollView.swift
//  PicShip
//
//  Created by Thabo David Klass on 31/05/2019.
//  Copyright © 2019 Open Beacon. All rights reserved.
//

import UIKit

class ShipPicViewControllerWithScrollView: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var shipPicScrollView: UIScrollView!
    
    var picShips = [String]()
    var ownerIDs = [String]()
    var titles = [String]()
    var shipPicIDS = [String]()
    var createdAts = [Int]()
    var numberOfLikesArray = [Int]()
    var imageShiPics = [String]()
    var videoStatuses = [Bool]()
    var types = [String]()
    
    var firstShipPicView: ShipPicView? = ShipPicView()
    var shipPicViews: [ShipPicView]? = [ShipPicView]()
    
    var isSingleShipPic = false
    var singleShipPicID = ""
    var mainShipPicKey = ""
    var dueAt: Int? = nil
    var image: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shipPicScrollView.frame = view.frame
        shipPicScrollView.delegate = self
        
        /*var shipPicURL00 = "https://v.cdn.vine.co/r/videos/AA3C120C521177175800441692160_38f2cbd1ffb.1.5.13763579289575020226.mp4"
        var shipPicURL01 = "https://kascadastreamingserv-hosting-mobilehub-1600866682.s3.amazonaws.com/1F7E3362-3E84-4A3C-AD85-83BE2372116E.mov"*/
        
        /*picShips = [shipPicURL00, shipPicURL01]
         
         for i in 0..<picShips.count {
         let shipPicView = ShipPicView()
         shipPicView.parentViewController = self
         //let shipPicView = ShipPicView()
         shipPicView.videoUrlString = picShips[i]
         //shipPicView.commonInit()
         shipPicView.contentMode = .scaleAspectFit
         shipPicView.startPlayback()
         
         let xPosition = self.view.frame.width * CGFloat(i)
         shipPicView.frame = CGRect(x: xPosition, y: 0, width: self.shipPicScrollView.frame.width, height: self.shipPicScrollView.frame.height)
         
         shipPicScrollView.contentSize.width = shipPicScrollView.frame.width * CGFloat(i + 1)
         shipPicScrollView.addSubview(shipPicView)
         }*/
        
        print("the mainShipPicKey is: \(mainShipPicKey)")
        
        firstShipPicView!.parentViewController = self
        //let shipPicView = ShipPicView()
        //shipPicView.videoUrlString = picShips[i]
        //shipPicView.commonInit()
        firstShipPicView!.contentMode = .scaleAspectFit
        //shipPicView.startPlayback()
        
        let xPosition = self.view.frame.width * CGFloat(0)
        firstShipPicView!.frame = CGRect(x: xPosition, y: 0, width: self.shipPicScrollView.frame.width, height: self.shipPicScrollView.frame.height)
        
        shipPicScrollView.contentSize.width = shipPicScrollView.frame.width * CGFloat(0 + 1)
        shipPicScrollView.addSubview(firstShipPicView!)
        
        firstShipPicView!.editButton.isEnabled = false
        firstShipPicView!.editButton.isHidden = true
        
        if !isSingleShipPic {
            getPublicShipPics()
        } else {
            getSingleShipPic()
        }
    }
    
    func getPublicShipPics() {
        print("Inside getPublicShipPics() 01")
        let dBase = Firestore.firestore()
        
        let picShipMetaRef = dBase.collection("picShipMeta")
        
        //picShipMetaRef.limit(to: 100)
        
        picShipMetaRef.limit(to: 32).order(by: "id", descending: true).getDocuments { (querySnapshot, error) in
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
                        let key = data.documentID
                        
                        let picShipMetaDict = data.data()
                        if let videoFileURL = picShipMetaDict["videoFileURL"] as? String, let imageFileURL = picShipMetaDict["imageFileURL"] as? String, let ownerID = picShipMetaDict["picShipOwnerID"] as? String, let title = picShipMetaDict["title"] as? String, let createdAt = picShipMetaDict["createdAt"] as? Int, let likes = picShipMetaDict["likes"] as? Int, let isPublic = picShipMetaDict["isPublic"] as? Bool, let isVideo = picShipMetaDict["isVideo"] as? Bool, let type = picShipMetaDict["type"] as? String {
                            if isPublic {
                                self.picShips.append(videoFileURL)
                                self.ownerIDs.append(ownerID)
                                self.titles.append(title)
                                self.shipPicIDS.append(key)
                                self.createdAts.append(createdAt)
                                self.numberOfLikesArray.append(likes)
                                self.imageShiPics.append(imageFileURL)
                                self.videoStatuses.append(isVideo)
                                self.types.append(type)
                            }
                            print("The owner ID is: \(ownerID)")
                            
                            print(self.ownerIDs)
                        }
                        
                        print("The dict contents: \(picShipMetaDict)")
                    }
                    
                    self.insertData()
                }
            } else {
                print("Inside getPublicShipPics() 03")
                print("Error: \(error?.localizedDescription)")
            }
        }
        
        /*dBase.collection("picShipMeta").getDocuments()
         {
         (querySnapshot, err) in
         
         if let err = err
         {
         print("Error getting documents: \(err)");
         }
         else
         {
         var count = 0
         for document in querySnapshot!.documents {
         count += 1
         print("\(document.documentID) => \(document.data())");
         }
         
         print("Count = \(count)");
         }
         }*/
    }
    
    func insertData() {
        for i in 0..<picShips.count {
            if i == 0 {
                shipPicViews!.append(firstShipPicView!)
                
                if !isSingleShipPic {
                    firstShipPicView!.shouldAnimateSwipeLeftLabel = true
                    //firstShipPicView.mainShipPicKey = mainShipPicKey
                }
                
                firstShipPicView!.mainShipPicKey = mainShipPicKey
                print("isSingleShipPic mainShipPicKey: \(mainShipPicKey)")
                
                print("ownerIDs[i]" + ownerIDs[i])
                firstShipPicView!.posterUserID = ownerIDs[i]
                firstShipPicView!.title = titles[i]
                firstShipPicView!.shipPicID = shipPicIDS[i]
                firstShipPicView!.createdAt = createdAts[i]
                firstShipPicView!.type = types[i]
                firstShipPicView!.numberOfLikes = numberOfLikesArray[i]
                firstShipPicView!.setPoserData()
                firstShipPicView!.setTaggedUser()
                
                if firstShipPicView!.posterUserID != currentUser {
                    firstShipPicView!.editButton.isEnabled = false
                    firstShipPicView!.editButton.isHidden = true
                } else {
                    if isSingleShipPic {
                        firstShipPicView!.editButton.isEnabled = true
                        firstShipPicView!.editButton.isHidden = false
                    }
                }
                
                if !videoStatuses[i] {
                    firstShipPicView!.imageFileURL = imageShiPics[i]
                    firstShipPicView!.loadShipPicImage()
                } else {
                    firstShipPicView!.videoUrlString = picShips[i]
                    firstShipPicView!.startPlayback()
                    firstShipPicView!.updateNumberOfViews()
                }
                //firstShipPicView.animateSwipeLeftLabel()
                //firstShipPicView.updateNumberOfViews()
            } else {
                let shipPicView = ShipPicView()
                shipPicViews!.append(shipPicView)
                
                shipPicView.editButton.isEnabled = false
                shipPicView.editButton.isHidden = true
                
                
                shipPicView.parentViewController = self
                
                print("ownerIDs[i]" + ownerIDs[i])
                shipPicView.posterUserID = ownerIDs[i]
                shipPicView.title = titles[i]
                shipPicView.shipPicID = shipPicIDS[i]
                shipPicView.createdAt = createdAts[i]
                shipPicView.type = types[i]
                shipPicView.numberOfLikes = numberOfLikesArray[i]
                shipPicView.setPoserData()
                
                shipPicView.contentMode = .scaleAspectFit
                
                if !videoStatuses[i] {
                    shipPicView.imageFileURL = imageShiPics[i]
                } else {
                    //let shipPicView = ShipPicView()
                    shipPicView.videoUrlString = picShips[i]
                    //shipPicView.updateNumberOfViews()
                    //shipPicView.commonInit()
                    //shipPicView.startPlayback()
                }
                
                let xPosition = self.view.frame.width * CGFloat(i)
                shipPicView.frame = CGRect(x: xPosition, y: 0, width: self.shipPicScrollView.frame.width, height: self.shipPicScrollView.frame.height)
                
                shipPicScrollView.contentSize.width = shipPicScrollView.frame.width * CGFloat(i + 1)
                shipPicScrollView.addSubview(shipPicView)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var targetView: ShipPicView!
        
        for i in 0..<shipPicViews!.count {
            /*if i == 0 {
                targetView = firstShipPicView
            } else {*/
            targetView = shipPicViews![i]
            //}
            
            if scrollView.bounds.contains(targetView.frame) {
                if videoStatuses[i] {
                    shipPicViews![i].startPlayback()
                    shipPicViews![i].updateNumberOfViews()
                } else {
                    shipPicViews![i].loadShipPicImage()
                }
                
                /*if targetView == firstShipPicView {
                    firstShipPicView.updateNumberOfViews()
                }*/
            } else {
                if videoStatuses[i] {
                    targetView.avPlayer.pause()
                }
            }
        }
    }
    
    func getSingleShipPic() {
        if singleShipPicID != "" {
            print("Inside getPublicShipPics() 01")
            let dBase = Firestore.firestore()
            
            let picShipMetaRef = dBase.collection("picShipMeta").document(singleShipPicID)
            
            print("Inside getPublicShipPics() 01 singleShipPicID: \(singleShipPicID)")
            
            picShipMetaRef.getDocument { (querySnapshot, error) in
                print(querySnapshot)
                print("Inside getPublicShipPics() 02")
                if error == nil {
                    print("Inside getPublicShipPics() 04")
                    if let picShipMetaDict = querySnapshot?.data() {
                        
                        let key = querySnapshot!.documentID
                        if let videoFileURL = picShipMetaDict["videoFileURL"] as? String, let imageFileURL = picShipMetaDict["imageFileURL"] as? String, let ownerID = picShipMetaDict["picShipOwnerID"] as? String, let title = picShipMetaDict["title"] as? String, let createdAt = picShipMetaDict["createdAt"] as? Int, let likes = picShipMetaDict["likes"] as? Int, let isPublic = picShipMetaDict["isPublic"] as? Bool, let isVideo = picShipMetaDict["isVideo"] as? Bool, let type = picShipMetaDict["type"] as? String {
                            //if isPublic {
                                self.picShips.append(videoFileURL)
                                self.ownerIDs.append(ownerID)
                                self.titles.append(title)
                                self.shipPicIDS.append(key)
                                self.createdAts.append(createdAt)
                                self.numberOfLikesArray.append(likes)
                                self.imageShiPics.append(imageFileURL)
                                self.videoStatuses.append(isVideo)
                            self.types.append(type)
                            //}
                            print("The owner ID is: \(ownerID)")
                            
                            print(self.ownerIDs)
                        }
                        
                        print("The dict contents: \(picShipMetaDict)")
                    }
                    
                    self.insertData()
                }
            }
        }
    }
    
    deinit {
        /*/avPlayer.removeTimeObserver(timeObserver)
         avPlayer.removeObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp")*/
        //avPlayer = nil
        
        /*for i in 0..<picShips.count {
            if videoStatuses[i] {
                if i == 0 {
                    firstShipPicView!.avPlayer.removeTimeObserver(firstShipPicView!.timeObserver)
                    firstShipPicView!.avPlayer.removeObserver(firstShipPicView!, forKeyPath: "currentItem.playbackLikelyToKeepUp")
                    //firstShipPicView.avPlayer = nil
                } else {
                    let targetView = shipPicViews![i]
                    targetView.avPlayer.removeTimeObserver(firstShipPicView!.timeObserver)
                    targetView.avPlayer.removeObserver(firstShipPicView!, forKeyPath: "currentItem.playbackLikelyToKeepUp")
                }
            }
        }
        
        firstShipPicView = nil
        
        shipPicViews = nil*/
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "openDetailsFromSingleShipPic") {
            let navigationController = segue.destination as! UINavigationController
            let pcdvc = navigationController.viewControllers[0] as! PicShipDetailsViewController
            
            //let navigationController = window?.rootViewController as! UINavigationController
            //let firstVC = navigationController.viewControllers[0] as! NameOfFirstViewController
            
            /*if videoScreenshot == nil {
                print("videoScreenshot is nil")
            } else {
                print("videoScreenshot is not nil")
            }
            
            if newVideoURL == nil {
                pcdvc.shipPicImage = newImage
            } else {
                pcdvc.shipPicImage = videoScreenshot
            }
            pcdvc.shipPicURL = newVideoURL*/
            
            pcdvc.isBeingEdited = true
            
            if mainShipPicKey != "" {
                pcdvc.mainShipPicKeyOnEditing = mainShipPicKey
            }
            
            if firstShipPicView!.title != "" {
                pcdvc.shipPicTitleOnEditing = firstShipPicView!.title
            }
            
            if dueAt != nil {
                pcdvc.shipPicTimeOnEditing = dueAt
            }
            
            if singleShipPicID != "" {
                pcdvc.shipPicIDOnEditing = singleShipPicID
            }
            
            if image != nil {
                pcdvc.imageOnEditing = image
            }
        }
    }
}
