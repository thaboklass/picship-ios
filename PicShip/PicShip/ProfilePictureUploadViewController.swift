//
//  SpreebieProfilePictureUploadViewController.swift
//  Spreebie
//
//  Created by Thabo David Klass on 03/01/2016.
//  Copyright © 2016 Spreebie, Inc. All rights reserved.
//

import UIKit
import FirebaseFirestore
//import AWSS3

/// This class helps the user upload their profile pic
class ProfilePictureUploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    /// The profile picture image view
    @IBOutlet weak var kascadaProfilePictureImageView: UIImageView!
    
    /// This button opens up the camera or the picture library
    @IBOutlet weak var addProfilePictureButton: UIButton!
    
    /// This button uploads the picture
    @IBOutlet weak var kascadaUploadProfilePictureButton: UIButton!
    
    /// The local URL of the picture
    var uploadProfilePicURL = URL(string: "")
    
    /// The file name of the profile pic
    var uploadProfilePicFileName = String()
    
    /// The local URL of the small version of the profile pic
    var uploadProfilePicURLSmall = URL(string: "")
    
    /// The file name of the small version of the profile pic
    var uploadProfilePicFileNameSmall = String()
    
    /// The small version of the selected image. This is declared
    /// outside the function for firebase
    var imageSmall: UIImage!
    
    /// The current firebase user
    var currentUser = KeychainWrapper.standard.string(forKey: ApplicationConstants.majeshiUserIDKey)
    
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
        
        // Do any additional setup after loading the view.
        
        //self.navigationController?.navigationBar.tintColor = UIColor(red: 61.0/255.0, green: 61.0/255.0, blue: 61.0/255.0, alpha: 1)
        
        /// Add a rounded border around the add profile pic
        /// button
        let addProfilePictureButtonLayer: CALayer?  = addProfilePictureButton.layer
        addProfilePictureButtonLayer!.cornerRadius = 4
        addProfilePictureButtonLayer!.masksToBounds = true
        
        /// Add a rounded border around the upload button
        let kascadaUploadProfilePictureButtonLayer: CALayer?  = kascadaUploadProfilePictureButton.layer
        kascadaUploadProfilePictureButtonLayer!.cornerRadius = 4
        kascadaUploadProfilePictureButtonLayer!.masksToBounds = true
        
        /// Animation
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 80, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        trackLayer.path = circularPath.cgPath
        
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 10
        trackLayer.fillColor = UIColor.white.cgColor
        trackLayer.lineCap = CAShapeLayerLineCap.round
        trackLayer.position = kascadaProfilePictureImageView.center
        
        view.layer.addSublayer(trackLayer)
        
        shapeLayer.path = circularPath.cgPath
        
        let lightGreeen = UIColor(red: 41.0/255.0, green: 169.0/255.0, blue: 158.0/255.0, alpha: 1.0)
        shapeLayer.strokeColor = lightGreeen.cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        shapeLayer.position = kascadaProfilePictureImageView.center
        
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        
        shapeLayer.strokeEnd = 0
        
        view.layer.addSublayer(shapeLayer)
        
        view.addSubview(percentageLabel)
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        percentageLabel.center = kascadaProfilePictureImageView.center
        
        //let maroonish = UIColor(red: 169.0/255.0, green: 43.0/255.0, blue: 41.0/255.0, alpha: 1.0)
        let orangish = UIColor(red: 248.0/255.0, green: 119.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        percentageLabel.textColor = orangish
        
        percentageLabel.isHidden = true
        trackLayer.isHidden = true
        shapeLayer.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     This open up an alert where a user can choose the image source.
     
     - Parameters:
     - sender: The view that sent the action
     
     - Returns: void.
     */
    @IBAction func addKascadaProfilePictureButtonTapped(_ sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let actionSheet = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        actionSheet.view.tintColor = UIColor(red: 248.0/255.0, green: 119.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: UIAlertAction.Style.default, handler: { (alert: UIAlertAction) -> Void in
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            self.present(imagePicker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Camera Roll", style: UIAlertAction.Style.default, handler: { (alert: UIAlertAction) -> Void in
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    /**
     This is a delegate method that runs afer the picture has been picked.
     
     - Parameters:
     - picker: A UIImagePickerController
     - info: Information pertaining to the image picked
     
     - Returns: void.
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImage: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
            kascadaProfilePictureImageView.image = selectedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
            kascadaProfilePictureImageView.image = selectedImage
        }
        
        /// This returns the image picked
        //kascadaProfilePictureImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        /// Make sure that the image picked is not somehow empty
        if kascadaProfilePictureImageView.image != nil {
            
            /// Find out the width and height of the image in order
            /// to make the said image a square
            let imageHeight: Double = Double(self.kascadaProfilePictureImageView.image!.size.height)
            let imageWidth: Double = Double(self.kascadaProfilePictureImageView.image!.size.width)
            
            var size = Double()
            
            if imageWidth > imageHeight {
                size = imageHeight
            } else {
                size = imageWidth
            }
            
            self.kascadaProfilePictureImageView.image! = ImageManipulation().cropToBounds(self.kascadaProfilePictureImageView.image!, width: size, height: size)
            
            /// The directory of the documents folder
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
            
            /// The URL of the documents folder
            let documentDirectoryURL = URL(fileURLWithPath: documentDirectory)
            
            /// Assign the imahe a unique name
            uploadProfilePicFileName = UUID().uuidString + ".jpg"
            
            /// Append "s-" to indicate a small version of the picture
            uploadProfilePicFileNameSmall = "s-" + uploadProfilePicFileName
            
            /// The local URL of the profile pic
            let localURL = documentDirectoryURL.appendingPathComponent(uploadProfilePicFileName)
            
            /// The local URL of the small profile pic
            let localURLSmall = documentDirectoryURL.appendingPathComponent(uploadProfilePicFileNameSmall)
            
            /// The local paths of the URLs
            let localPath = localURL.path
            let localPathSmall = localURLSmall.path
            
            /// Write the image data to file
            let data = self.kascadaProfilePictureImageView.image!.jpegData(compressionQuality: 0.0) //UIImageJPEGRepresentation(self.kascadaProfilePictureImageView.image!, 0.0)
            try? data!.write(to: URL(fileURLWithPath: localPath), options: [.atomic])
            
            /// Write the small image data to file
            imageSmall = resizeImage(self.kascadaProfilePictureImageView.image!, toTheSize: CGSize(width: 80, height: 80))
            let dataSmall = imageSmall.jpegData(compressionQuality: 0.0) //UIImageJPEGRepresentation(imageSmall, 0.0)
            try? dataSmall!.write(to: URL(fileURLWithPath: localPathSmall), options: [.atomic])
            
            /// The location of the profile pic
            uploadProfilePicURL = URL(fileURLWithPath: localPath)
            
            /// The location of the small profile pic
            uploadProfilePicURLSmall = URL(fileURLWithPath: localPathSmall)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
     This uploads the profile pic when the upload button is tapped.
     
     - Parameters:
     - picker: A UIImagePickerController
     - info: Information pertaining to the image picked
     
     - Returns: void.
     */
    @IBAction func uploadProfilePictureButtonTapped(_ sender: AnyObject) {
        if kascadaProfilePictureImageView.image != nil {
            ApplicationConstants.profilePictureUpdated = true
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            kascadaUploadProfilePictureButton.isEnabled = false
            
            if let data = kascadaProfilePictureImageView.image?.jpegData(compressionQuality: 0.0) /*UIImageJPEGRepresentation(kascadaProfilePictureImageView.image!, 0.0)*/ {
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
    }
    
    
    /**
     Resize a UIImage.
     
     - Parameters:
     - image: The input UIImage
     - size: The output size
     
     - Returns: A resized UIImage.
     */
    func resizeImage(_ image: UIImage, toTheSize size: CGSize) -> UIImage {
        let scale = CGFloat(max(size.width/image.size.width,
                                size.height/image.size.height))
        let width:CGFloat  = image.size.width * scale
        let height:CGFloat = image.size.height * scale;
        
        let rr:CGRect = CGRect( x: 0, y: 0, width: width, height: height);
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        image.draw(in: rr)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return newImage!
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
    
    func displayMajeshiGenericAlertAndMoveBack(_ title: String, userMessage: String) {
        var alert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertController.Style.alert)
        
        alert.view.tintColor = UIColor(red: 248.0/255.0, green: 119.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        
        let okAction = UIAlertAction(title:"OK", style:UIAlertAction.Style.default) { (UIAlertAction) -> Void in
            if let nav = self.navigationController {
                nav.popViewController(animated: true)
            }
        }
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}
