//
//  PicShipDatePickerViewController.swift
//  PicShip
//
//  Created by Thabo David Klass on 30/05/2019.
//  Copyright © 2019 Open Beacon. All rights reserved.
//

import UIKit

class PicShipDatePickerViewController: UIViewController {
    @IBOutlet weak var shipPicImage: UIImageView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    /// The current user
    var currentUser: String? = KeychainWrapper.standard.string(forKey: ApplicationConstants.majeshiUserIDKey)
    
    var shipPic: UIImage? = nil
    var shipPicLocalVideoURL: URL? = nil
    var pickerData: [String] = [String]()
    var pickedType = "Anniversary"
    var pickedContactName = ""
    var pickedContactNameNumber: String? = nil
    var shipPickTimeStamp: Int? = nil
    var imageFileName = "empty"
    var imageFileRUL = "empty"
    var videoFileName = "empty"
    var videoFileURL = "empty"
    var picShipDescription = ""
    var picShipTitle = ""
    var type = "Anniversary"
    var isPublic = false
    var isVideo = false
    var contactName = "empty"
    var contactNumber = "empty"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if shipPic != nil {
            print("shipPic is not nil")
        } else {
            print("shipPic is nil")
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        let timeInterval = self.datePicker?.date.timeIntervalSince1970
        shipPickTimeStamp = Int(timeInterval!)
        
        print("The time stamp is: \(shipPickTimeStamp)")
        
        if shipPicLocalVideoURL != nil {
            uploadTOFireBaseVideo(url: shipPicLocalVideoURL!, success: { (success) in
                //
            }) { (error) in
                //
            }
        } else {
            uploadShipPicJPEGAlone()
            print("shipPicLocalVideoURL is nil")
        }
        
        /*if kascadaProfilePictureImageView.image != nil {
         UIApplication.shared.isNetworkActivityIndicatorVisible = true
         kascadaUploadProfilePictureButton.isEnabled = false
         
         if let data = UIImageJPEGRepresentation(kascadaProfilePictureImageView.image!, 0.0) {
         shapeLayer.strokeEnd = 0
         
         percentageLabel.isHidden = false
         trackLayer.isHidden = false
         shapeLayer.isHidden = false
         
         let imageUUID: String = NSUUID().uuidString
         let metadata = StorageMetadata()
         metadata.contentType = "image/jpeg"
         
         // Upload the file to the path "images/rivers.jpg"
         let uploadTask = Storage.storage().reference().child(imageUUID).putData(data, metadata: metadata) { (metadata, error) in
         guard let metadata = metadata else {
         // Uh-oh, an error occurred!
         UIApplication.shared.isNetworkActivityIndicatorVisible = false
         self.kascadaUploadProfilePictureButton.isEnabled = true
         
         self.displayMajeshiGenericAlert("Error", userMessage: "Could not upload image. Please try again.")
         return
         }
         
         // You can also access to download URL after upload.
         Storage.storage().reference().child(imageUUID).downloadURL { (url, error) in
         guard let downloadURL = url else {
         // Uh-oh, an error occurred!
         return
         }
         
         let downloadURLString = downloadURL.absoluteString
         
         let profilePictureData = [
         "profilePictureFileName": downloadURLString
         ]
         
         if self.currentUser != nil {
         let dBase = Firestore.firestore()
         let userRef = dBase.collection("users").document(self.currentUser!)
         
         userRef.updateData(profilePictureData) { err in
         if let err = err {
         UIApplication.shared.isNetworkActivityIndicatorVisible = false
         self.kascadaUploadProfilePictureButton.isEnabled = true
         
         self.displayMajeshiGenericAlert("Error!", userMessage: "There was an error saving your data. Please try again.")
         } else {
         UIApplication.shared.isNetworkActivityIndicatorVisible = false
         self.kascadaUploadProfilePictureButton.isEnabled = true
         
         self.displayMajeshiGenericAlertAndMoveBack("Success!", userMessage: "Your profile picture was uploaded successfully!.")
         }
         }
         }
         }
         }
         
         uploadTask.observe(.progress) { snapshot in
         // Download reported progress
         let percentCompleteDouble = 100.0 * Double(snapshot.progress!.completedUnitCount)
         / Double(snapshot.progress!.totalUnitCount)
         if !percentCompleteDouble.isNaN {
         let percentComplete = Int(percentCompleteDouble)
         print("Done: \(percentComplete)%")
         
         let progress = Double(snapshot.progress!.completedUnitCount)
         / Double(snapshot.progress!.totalUnitCount)
         
         /// Animate the progress thing
         self.percentageLabel.text = "\(percentComplete)%"
         self.shapeLayer.strokeEnd = CGFloat(progress)
         
         }
         }
         
         uploadTask.observe(.success) { snapshot in
         // Download completed successfully
         print("Uploaded successfully")
         self.percentageLabel.isHidden = true
         self.trackLayer.isHidden = true
         self.shapeLayer.isHidden = true
         }
         }
         } else {
         displayMajeshiGenericAlert("Missing field(s)", userMessage: "Please make sure that all the fields have been filled.")
         }
         
         
         
         self.navigationController?.popToRootViewController(animated: true)
         //self.presentingViewController?.dismiss(animated: true, completion: nil)
         ApplicationConstants.justMovedBackFromDatePicker = true*/
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
    
    func uploadTOFireBaseVideo(url: URL, success : @escaping (String) -> Void, failure : @escaping (Error) -> Void) {
        let imageUUID = NSUUID().uuidString
        let name = "\(imageUUID).mp4"
        
        var data: Data? = nil
        do {
            data = try NSData(contentsOf: url, options: .mappedIfSafe) as Data
        } catch {
            print(error)
            return
        }
        
        let storageRef = Storage.storage().reference().child(name)
        if let uploadData = data as Data? {
            let metadata = StorageMetadata()
            metadata.contentType = "video/mp4"
            
            storageRef.putData(uploadData, metadata: metadata, completion: { (metadata, error) in
                if let error = error {
                    failure(error)
                    self.displayMajeshiGenericAlert("Error", userMessage: "There was an error creating your ShipPic. Please try again.")
                } else {
                    //let strPic:String = (metadata?.downloadURL()?.absoluteString)!
                    //success(strPic)
                    //self.displayMajeshiGenericAlert("Success!", userMessage: "Your video was uploaded successfully!.")
                    Storage.storage().reference().child(name).downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            // Uh-oh, an error occurred!
                            return
                        }
                        
                        let downloadURLString = downloadURL.absoluteString
                        
                        self.uploadShipPicJPEG(randomizedFileName: imageUUID, videoFileURL: downloadURLString)
                    }
                }
            })
        }
    }
    
    func convertVideo(toMPEG4FormatForVideo inputURL: URL, outputURL: URL, handler: @escaping (AVAssetExportSession) -> Void) {
        try! FileManager.default.removeItem(at: outputURL as URL)
        let asset = AVURLAsset(url: inputURL as URL, options: nil)
        
        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)!
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.exportAsynchronously(completionHandler: {
            handler(exportSession)
        })
    }
    
    func uploadShipPicJPEG(randomizedFileName: String, videoFileURL: String) {
        if shipPic != nil {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            //kascadaUploadProfilePictureButton.isEnabled = false
            
            if let data = shipPic!.jpegData(compressionQuality: 0.0) {
                /*shapeLayer.strokeEnd = 0
                 
                 percentageLabel.isHidden = false
                 trackLayer.isHidden = false
                 shapeLayer.isHidden = false*/
                
                //let imageUUID: String = NSUUID().uuidString
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                
                let pictureFileName = randomizedFileName + ".jpg"
                let videoFileName = randomizedFileName + ".mp4"
                
                // Upload the file to the path "images/rivers.jpg"
                let uploadTask = Storage.storage().reference().child(pictureFileName).putData(data, metadata: metadata) { (metadata, error) in
                    guard let metadata = metadata else {
                        // Uh-oh, an error occurred!
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        //self.kascadaUploadProfilePictureButton.isEnabled = true
                        
                        self.displayMajeshiGenericAlert("Error", userMessage: "Could not upload image. Please try again.")
                        return
                    }
                    
                    // You can also access to download URL after upload.
                    Storage.storage().reference().child(pictureFileName).downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            // Uh-oh, an error occurred!
                            return
                        }
                        
                        let downloadURLString = downloadURL.absoluteString
                        
                        if self.currentUser != nil {
                            /// Create the unix time stamp
                            let currentDate = Date()
                            let timeStamp = Int(currentDate.timeIntervalSince1970)
                            
                            let picShipData: Dictionary<String, AnyObject> = [
                                "imageFileName": pictureFileName as AnyObject,
                                "imageFileURL": downloadURLString as AnyObject,
                                "videoFileName": videoFileName as AnyObject,
                                "videoFileURL": videoFileURL as AnyObject,
                                "isVideo": self.isVideo as AnyObject,
                                "dueAt": self.shipPickTimeStamp as AnyObject,
                                "description": self.picShipDescription as AnyObject,
                                "type": self.type  as AnyObject,
                                "title": self.picShipTitle as AnyObject,
                                "isPublic": self.isPublic as AnyObject,
                                "contactName": self.contactName as AnyObject,
                                "contactNumber": self.contactNumber as AnyObject,
                                "createdAt": timeStamp as AnyObject
                            ]
                            
                            let dBase = Firestore.firestore()
                            
                            let picShipRef = dBase.collection("picShip").document(self.currentUser!)
                            picShipRef.collection("picShips").addDocument(data: picShipData) {  (error) in
                                if let error = error {
                                    print("\(error.localizedDescription)")
                                } else {
                                    print("Document was successfully created and written.")
                                    //self.displayMajeshiGenericAlert("Success", userMessage: "You ShipPic was successfully created!")
                                    self.navigationController?.popToRootViewController(animated: true)
                                    //self.presentingViewController?.dismiss(animated: true, completion: nil)
                                    ApplicationConstants.justMovedBackFromDatePicker = true
                                }
                            }
                            /*dBase.collection("picShip").document(self.currentUser!).collection("picShips").document(self.currentUser!).setData(picShipData) { (error) in
                                if let error = error {
                                    print("\(error.localizedDescription)")
                                } else {
                                    print("Document was successfully created and written.")
                                    //self.displayMajeshiGenericAlert("Success", userMessage: "You ShipPic was successfully created!")
                                    self.navigationController?.popToRootViewController(animated: true)
                                    //self.presentingViewController?.dismiss(animated: true, completion: nil)
                                    ApplicationConstants.justMovedBackFromDatePicker = true
                                }
                            }*/
                        }
                    }
                }
                
                uploadTask.observe(.progress) { snapshot in
                 // Download reported progress
                 /*let percentCompleteDouble = 100.0 * Double(snapshot.progress!.completedUnitCount)
                 / Double(snapshot.progress!.totalUnitCount)
                 if !percentCompleteDouble.isNaN {
                 let percentComplete = Int(percentCompleteDouble)
                 print("Done: \(percentComplete)%")
                 
                 let progress = Double(snapshot.progress!.completedUnitCount)
                 / Double(snapshot.progress!.totalUnitCount)
                 
                 /// Animate the progress thing
                 self.percentageLabel.text = "\(percentComplete)%"
                 self.shapeLayer.strokeEnd = CGFloat(progress)
                 
                 }*/
                 }
                 
                 uploadTask.observe(.success) { snapshot in
                 // Download completed successfully
                 print("Uploaded successfully")
                 /*self.percentageLabel.isHidden = true
                 self.trackLayer.isHidden = true
                 self.shapeLayer.isHidden = true
                 }*/
                 }
            } else {
                displayMajeshiGenericAlert("Missing field(s)", userMessage: "Please make sure that all the fields have been filled.")
            }
        }
    }
    
    func uploadShipPicJPEGAlone() {
        if shipPic != nil {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            //kascadaUploadProfilePictureButton.isEnabled = false
            
            if let data = shipPic!.jpegData(compressionQuality: 0.0) {
                /*shapeLayer.strokeEnd = 0
                 
                 percentageLabel.isHidden = false
                 trackLayer.isHidden = false
                 shapeLayer.isHidden = false*/
                
                //let imageUUID: String = NSUUID().uuidString
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                
                let pictureFileName = NSUUID().uuidString + ".jpg"
                //let videoFileName = randomizedFileName + ".mp4"
                
                // Upload the file to the path "images/rivers.jpg"
                let uploadTask = Storage.storage().reference().child(pictureFileName).putData(data, metadata: metadata) { (metadata, error) in
                    guard let metadata = metadata else {
                        // Uh-oh, an error occurred!
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        //self.kascadaUploadProfilePictureButton.isEnabled = true
                        
                        self.displayMajeshiGenericAlert("Error", userMessage: "Could not upload image. Please try again.")
                        return
                    }
                    
                    // You can also access to download URL after upload.
                    Storage.storage().reference().child(pictureFileName).downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            // Uh-oh, an error occurred!
                            return
                        }
                        
                        let downloadURLString = downloadURL.absoluteString
                        
                        if self.currentUser != nil {
                            /// Create the unix time stamp
                            let currentDate = Date()
                            let timeStamp = Int(currentDate.timeIntervalSince1970)
                            
                            let picShipData: Dictionary<String, AnyObject> = [
                                "imageFileName": pictureFileName as AnyObject,
                                "imageFileURL": downloadURLString as AnyObject,
                                "videoFileName": "empty" as AnyObject,
                                "videoFileURL": "empty" as AnyObject,
                                "isVideo": false as AnyObject,
                                "dueAt": self.shipPickTimeStamp as AnyObject,
                                "description": self.picShipDescription as AnyObject,
                                "type": self.type  as AnyObject,
                                "title": self.picShipTitle as AnyObject,
                                "isPublic": self.isPublic as AnyObject,
                                "contactName": self.contactName as AnyObject,
                                "contactNumber": self.contactNumber as AnyObject,
                                "createdAt": timeStamp as AnyObject
                            ]
                            
                            let dBase = Firestore.firestore()
                            
                            let picShipRef = dBase.collection("picShip").document(self.currentUser!)
                            picShipRef.collection("picShips").addDocument(data: picShipData) {  (error) in
                                if let error = error {
                                    print("\(error.localizedDescription)")
                                } else {
                                    print("Document was successfully created and written.")
                                    //self.displayMajeshiGenericAlert("Success", userMessage: "You ShipPic was successfully created!")
                                    self.navigationController?.popToRootViewController(animated: true)
                                    //self.presentingViewController?.dismiss(animated: true, completion: nil)
                                    ApplicationConstants.justMovedBackFromDatePicker = true
                                }
                            }
                            /*dBase.collection("picShip").document(self.currentUser!).collection("picShips").document(self.currentUser!).setData(picShipData) { (error) in
                             if let error = error {
                             print("\(error.localizedDescription)")
                             } else {
                             print("Document was successfully created and written.")
                             //self.displayMajeshiGenericAlert("Success", userMessage: "You ShipPic was successfully created!")
                             self.navigationController?.popToRootViewController(animated: true)
                             //self.presentingViewController?.dismiss(animated: true, completion: nil)
                             ApplicationConstants.justMovedBackFromDatePicker = true
                             }
                             }*/
                        }
                    }
                }
                
                uploadTask.observe(.progress) { snapshot in
                    // Download reported progress
                    /*let percentCompleteDouble = 100.0 * Double(snapshot.progress!.completedUnitCount)
                     / Double(snapshot.progress!.totalUnitCount)
                     if !percentCompleteDouble.isNaN {
                     let percentComplete = Int(percentCompleteDouble)
                     print("Done: \(percentComplete)%")
                     
                     let progress = Double(snapshot.progress!.completedUnitCount)
                     / Double(snapshot.progress!.totalUnitCount)
                     
                     /// Animate the progress thing
                     self.percentageLabel.text = "\(percentComplete)%"
                     self.shapeLayer.strokeEnd = CGFloat(progress)
                     
                     }*/
                }
                
                uploadTask.observe(.success) { snapshot in
                    // Download completed successfully
                    print("Uploaded successfully")
                    /*self.percentageLabel.isHidden = true
                     self.trackLayer.isHidden = true
                     self.shapeLayer.isHidden = true
                     }*/
                }
            } else {
                displayMajeshiGenericAlert("Missing field(s)", userMessage: "Please make sure that all the fields have been filled.")
            }
        }
    }
}
