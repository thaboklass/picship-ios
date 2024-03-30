//
//  BackTableVC.swift
//  SlideoutMenu
//
//  Created by Thabo David Klass on 27/05/2019.
//  Copyright © 2019 Open Beacon. All rights reserved.
//

import Foundation

class BackTableVC: UITableViewController {
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
    var isDeaitWiths = [Bool]()
    
    var shipPics = [ShipPic]()
    var filteredShipPics = [ShipPic]()
    
    /// The current logged in user
    var currentUser: String? = KeychainWrapper.standard.string(forKey: ApplicationConstants.majeshiUserIDKey)
    
    
    var tableArray = [String]()
    
    let orangish = UIColor(red: 248.0/255.0, green: 119.0/255.0, blue: 20.0/255.0, alpha: 1.0)
    
    let greenish = UIColor(red: 45.0/255.0, green: 182.0/255.0, blue: 174.0/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        print("inside view did load")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        ApplicationConstants.shipPicEditingJustHappenedForBackTableVC = false
        //tableArray = ["Hello", "Second", "World"]
        getMyShipPics()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("Inside viewDidAppear.")
        
        if ApplicationConstants.shipPicEditingJustHappenedForBackTableVC {
            picShips.removeAll()
            ownerIDs.removeAll()
            titles.removeAll()
            shipPicIDS.removeAll()
            createdAts.removeAll()
            dueAts.removeAll()
            numberOfLikesArray.removeAll()
            imageShiPics.removeAll()
            videoStatuses.removeAll()
            mainShipPicKeys.removeAll()
            isDeaitWiths.removeAll()
            
            shipPics.removeAll()
            filteredShipPics.removeAll()
            
            self.tableView.reloadData()
            
            getMyShipPics()
            
            ApplicationConstants.shipPicEditingJustHappenedForBackTableVC = false
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        
        let ShipPic = filteredShipPics[indexPath.row]
        
        cell.textLabel?.text = ShipPic.title
        cell.textLabel?.textColor = orangish
        cell.textLabel?.font = UIFont(name: "Avenir", size: 16)
        
        if ShipPic.isDealtWith != nil {
            let currentDate = Date()
            let currentTimeStamp = Int(currentDate.timeIntervalSince1970)
            
            print("The time difference is: \(currentTimeStamp - ShipPic.dueAt!)")
            
            if (currentTimeStamp - ShipPic.dueAt!) < 86400 && (currentTimeStamp - ShipPic.dueAt!) > 0 && !ShipPic.isDealtWith! {
                cell.textLabel?.textColor = greenish
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredShipPics.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! ShipsRevealViewController
        
        var indexPath: IndexPath = tableView.indexPathForSelectedRow!
        
        destVC.varView = indexPath.row
        
        let selectedShipPic = filteredShipPics[indexPath.row]
        
        destVC.picShip = selectedShipPic.videoFileURL //picShips[indexPath.row]
        //destVC.ownerID = ownerIDs[indexPath.row]
        destVC.picShipTitle = selectedShipPic.title //titles[indexPath.row]
        destVC.shipPicID = selectedShipPic.shipPicID //shipPicIDS[indexPath.row]
        destVC.createdAt = selectedShipPic.createdAt //createdAts[indexPath.row]
        destVC.dueAt = selectedShipPic.dueAt //dueAts[indexPath.row]
        //destVC.numberOfLikes = numberOfLikesArray[indexPath.row]
        destVC.imageShiPic = selectedShipPic.imageFileURL //imageShiPics[indexPath.row]
        destVC.videoStatus = selectedShipPic.isVideo //videoStatuses[indexPath.row]
        destVC.mainShipPicKey = selectedShipPic.mainKey //mainShipPicKeys[indexPath.row]
        
        if selectedShipPic.isDealtWith != nil {
            destVC.isDealtWith = selectedShipPic.isDealtWith!
        } else {
            destVC.isDealtWith = true
        }
        
        if selectedShipPic.contactUserID != nil {
            destVC.contactUserID = selectedShipPic.contactUserID!
        }
        
        if selectedShipPic.contactName != nil {
            destVC.contactName = selectedShipPic.contactName!
        }
        
        destVC.isTriggeredByTap = true
    }
    
    func getMyShipPics() {
        if currentUser != nil {
            print("Inside getPublicShipPics() 01")
            let dBase = Firestore.firestore()
            
            let picShipRef = dBase.collection("picShip").document(currentUser!).collection("picShips")
            
            picShipRef.order(by: "dueAt", descending: true).getDocuments { (querySnapshot, error) in
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
                            if let videoFileURL = picShipMetaDict["videoFileURL"] as? String, let imageFileURL = picShipMetaDict["imageFileURL"] as? String, let title = picShipMetaDict["title"] as? String, let createdAt = picShipMetaDict["createdAt"] as? Int, let dueAt = picShipMetaDict["dueAt"] as? Int, let isVideo = picShipMetaDict["isVideo"] as? Bool {
                                let key = "\(createdAt)-\(self.currentUser!)"
                                /*self.picShips.append(videoFileURL)
                                self.titles.append(title)
                                self.shipPicIDS.append(key)
                                self.createdAts.append(createdAt)
                                self.dueAts.append(dueAt)
                                self.imageShiPics.append(imageFileURL)
                                self.videoStatuses.append(isVideo)
                                self.mainShipPicKeys.append(mainKey)*/
                                
                                /*if let isDealtWith = picShipMetaDict["isDealtWith"] as? Bool {
                                    self.isDeaitWiths.append(isDealtWith)
                                } else {
                                    self.isDeaitWiths.append(true)
                                }*/
                                
                                let shipPic = ShipPic(shipPicID: key, mainKey: mainKey, shipPicData: picShipMetaDict as Dictionary<String, AnyObject>)
                                self.shipPics.append(shipPic)
                            }
                            
                            print("The dict contents: \(picShipMetaDict)")
                        }
                        
                        self.filteredShipPics = self.shipPics
                        
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self.tableView.reloadData()
                    }
                } else {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    print("Inside getPublicShipPics() 03")
                    print("Error: \(error?.localizedDescription)")
                }
            }
        }
    }
}
