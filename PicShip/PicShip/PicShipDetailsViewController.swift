//
//  PicShipDetailsViewController.swift
//  PicShip
//
//  Created by Thabo David Klass on 30/05/2019.
//  Copyright © 2019 Open Beacon. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class PicShipDetailsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, /*UITextViewDelegate,*/ CNContactPickerDelegate, TagContactViewControllerDelegate {
    @IBOutlet weak var shipPicImageView: UIImageView!
    @IBOutlet weak var shipPicTitleTextField: UITextField!
    @IBOutlet weak var picShipTypePickerView: UIPickerView!
    @IBOutlet weak var pickContactButton: UIButton!
    @IBOutlet weak var picShipPublicSwitch: UISwitch!
    @IBOutlet weak var picShipUserStatusLabel: UILabel!
    @IBOutlet weak var picShipDescriptionTextView: UITextView!
    @IBOutlet weak var picShipDatePicker: UIDatePicker!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    /// The current user
    var currentUser: String? = KeychainWrapper.standard.string(forKey: ApplicationConstants.majeshiUserIDKey)
    
    var shipPicImage: UIImage? = nil
    var shipPicURL: URL? = nil
    var pickerData: [String] = [String]()
    var pickedType = "Anniversary"
    var pickedContactName = "empty"
    var pickedContactNumber = "empty"
    var shipPicTitle = ""
    var shipPicDescription = ""
    var isVideo = false
    var isPublic = false
    var scrollViewBottomInset: CGFloat = 0.0
    var shipPickTimeStamp: Int? = nil
    
    var isBeingEdited = false
    var imageOnEditing: UIImage? = nil
    var shipPicTitleOnEditing: String? = nil
    var shipPicTimeOnEditing: Int? = nil
    var mainShipPicKeyOnEditing: String? = nil
    var shipPicIDOnEditing: String? = nil
    
    var taggedContactUserID: String? = nil
    var taggedContactUserName: String? = nil
    
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
        
        /// Rounded corners
        /*let picShipDescriptionTextViewLayer: CALayer?  = picShipDescriptionTextView.layer
        picShipDescriptionTextViewLayer!.cornerRadius = 10
        picShipDescriptionTextViewLayer!.masksToBounds = true*/
        
        /// So the textfield delegate functions work
        shipPicTitleTextField.delegate = self
        //picShipDescriptionTextView.delegate = self
        shipPicTitleTextField.keyboardAppearance = .dark
        
        // Connect data:
        self.picShipTypePickerView.delegate = self
        self.picShipTypePickerView.dataSource = self
        
        let pickContactButtonLayer: CALayer?  = self.pickContactButton.layer
        pickContactButtonLayer!.cornerRadius = pickContactButton.frame.height / 2
        pickContactButtonLayer!.masksToBounds = true
        
        let doneButtonLayer: CALayer?  = self.doneButton.layer
        doneButtonLayer!.cornerRadius = 10
        doneButtonLayer!.masksToBounds = true
        
        let greenish = UIColor(red: 112.0/255.0, green: 214.0/255.0, blue: 210.0/255.0, alpha: 1.0)
        
        /// Set the switch color
        picShipPublicSwitch.onTintColor = greenish
        picShipPublicSwitch.tintColor = greenish
        
        pickerData = ["Anniversary", "Birthday", "Decision", "Event", "Meeting", "Memory", "Note", "Reminder", "Task", "Other"]

        ApplicationConstants.justMovedBackFromDatePicker = false
        if shipPicImage != nil {
            print("This mofo does have an image")
            
            /// Find out the width and height of the image in order
            /// to make the said image a square
            let imageHeight: Double = Double(shipPicImage!.size.height)
            let imageWidth: Double = Double(shipPicImage!.size.width)
            
            var size = Double()
            
            if imageWidth > imageHeight {
                size = imageHeight
            } else {
                size = imageWidth
            }
            
            shipPicImageView.image = ImageManipulation().cropToBounds(shipPicImage!, width: size, height: size)
        } else {
            print("Molimo!")
        }
        
        if shipPicURL != nil {
            isVideo = true
            print("This mofo does have a video")
        }
        
        
        let orange = UIColor(red: 248.0/255.0, green: 119.0/255.0, blue: 19.0/255.0, alpha: 1.0)
        
        picShipDatePicker.setValue(orange, forKeyPath: "textColor")
        
        
        /// Animation
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 80, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        trackLayer.path = circularPath.cgPath
        
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 10
        trackLayer.fillColor = UIColor.white.cgColor
        trackLayer.lineCap = CAShapeLayerLineCap.round
        trackLayer.position = contentView.center
        
        view.layer.addSublayer(trackLayer)
        
        shapeLayer.path = circularPath.cgPath
        
        let lightGreeen = UIColor(red: 41.0/255.0, green: 169.0/255.0, blue: 158.0/255.0, alpha: 1.0)
        shapeLayer.strokeColor = lightGreeen.cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        shapeLayer.position = contentView.center
        
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        
        shapeLayer.strokeEnd = 0
        
        view.layer.addSublayer(shapeLayer)
        
        view.addSubview(percentageLabel)
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        percentageLabel.center = contentView.center
        
        //let maroonish = UIColor(red: 169.0/255.0, green: 43.0/255.0, blue: 41.0/255.0, alpha: 1.0)
        let orangish = UIColor(red: 248.0/255.0, green: 119.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        percentageLabel.textColor = orangish
        
        percentageLabel.isHidden = true
        trackLayer.isHidden = true
        shapeLayer.isHidden = true
        
        
        /// Configure the text view
        //picShipDescriptionTextView.delegate = self
        /*picShipDescriptionTextView.text = "Type out your message here..."
        picShipDescriptionTextView.textColor = .white
        picShipDescriptionTextView.isEditable = true*/
        
        /// Keyboard stuff
        /*NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIResponder.keyboardWillShowNotification, object: nil)
         
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIResponder.keyboardWillHideNotification, object: nil)*/
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        if isBeingEdited {
            setTaggedUser()
            
            // Set the image
            if imageOnEditing != nil {
                shipPicImageView.image = imageOnEditing
            }
            
            // Set the title
            shipPicTitleTextField.text = shipPicTitleOnEditing
            
            // Set the time
            if shipPicTimeOnEditing != nil {
                picShipDatePicker.setDate(Date.init(timeIntervalSince1970: TimeInterval.init(exactly: shipPicTimeOnEditing!)!), animated: true)
            }
            
            pickContactButton.isEnabled = false
            picShipUserStatusLabel.text = "Not editable."

            //Date.init(timeIntervalSince1970: TimeInterval.init(exactly: shipPicTimeOnEditing!)!)
        }
        
        if currentUser == nil {
            pickContactButton.isEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //scrollView.setContentOffset(CGPoint(x: 0, y: -self.scrollView.contentInset.top), animated: true)
        
        if ApplicationConstants.justMovedBackFromDatePicker {
            print("view will appear")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 1700)
        
        if ApplicationConstants.justMovedBackFromDatePicker {
            print("view did appear")
            //self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        // Assign the initial value of the ContentView's bottom inset. This will be used as a point of reference (to re-position back to) when scrolling programatically
        scrollViewBottomInset = scrollView.contentInset.bottom
        
        //let scrollSize = CGSize(width: view.frame.width, height: view.frame.height)
        view.frame.size.height = 1200
        /*scrollView.contentSize.height = 1200
        scrollView.contentSize.width = view.frame.width*/
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 1700)
    }
    
    // Return the ScrollView's ContentView to its original inset configurations when the keyboard hides
    /*@objc func keyboardWillHide(notification: Notification) {
        
        scrollView.setContentOffset(CGPoint(x: 0, y: -self.scrollView.contentInset.top), animated: true)
        self.scrollView.contentInset.bottom = self.scrollViewBottomInset
    }
    
    
    // if the keyboard's CGRect intersects with the CGRect of the TextField being edited, re-adjust the position of the ScrollView by changing the bottom inset of its ContentView
    @objc func keyboardWillChangeFrame(notification: Notification) {
        if let textField = currentlyActiveTextField {
            
            if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect {
                // Convert the CGrect/Rectangle of the keyboard's coordinate system to that of the ScrollView's ContentView
                let convertedKeyboardFrame = self.view.convert(keyboardFrame, to: self.contentView)
                
                if convertedKeyboardFrame.intersects(textField.frame) {
                    
                    // Re-adjust the position of the ContentView's bottom inset here>>
                    self.scrollView.contentInset.bottom = convertedKeyboardFrame.size.height
                    
                }
            }
        }
    }*/
    
    @IBAction func goBackToCamera(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickedType = pickerData[row]
        print(pickedType)
    }
    
    /// Textfield delegate function
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func pickContactButtonTapped(_ sender: Any) {
        /*let entityType = CNEntityType.contacts
        let authStatus = CNContactStore.authorizationStatus(for: entityType)
        
        if authStatus == CNAuthorizationStatus.notDetermined {
            let contactStore = CNContactStore.init()
            
            contactStore.requestAccess(for: entityType, completionHandler: { (success, nil) in
                if success {
                    
                } else {
                    print("Not authorized.")
                }
            })
        } else if authStatus == CNAuthorizationStatus.authorized {
            self.openContacts()
        } else if authStatus == CNAuthorizationStatus.denied {
            self.displayMyAlertMessage("Previously denied", userMessage: "Access to contacts was denied. You can change this in your phone's settings.")
        }*/
    }
    
    
    /**
     Opens a contact picker
     
     - Parameters:
     - none
     
     - Returns: nothing
     */
    func openContacts() {
        let contactPicker = CNContactPickerViewController.init()
        contactPicker.delegate = self
        self.present(contactPicker, animated: true, completion: nil)
    }
    
    /// Do nothing is contact picking is cancelled
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        picker.dismiss(animated: true) {
            
        }
    }
    
    /**
     This is an delegate method that opens up a contact picker and
     and assigns the to attributes in the application
     
     - Parameters:
     - picker: The contact picker view controller
     = conctact: The selected contact
     
     - Returns: void.
     */
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        /// When the user selects a contact
        pickedContactName = "\(contact.givenName) \(contact.familyName)"
        print("The contact name is: \(pickedContactName)")
        picShipUserStatusLabel.text = pickedContactName
        //pickContactButton.setTitle(picShipUserStatusLabel, for: UIControl.State.normal)
        
        if !contact.phoneNumbers.isEmpty {
            let phoneString = ((((contact.phoneNumbers[0] as AnyObject).value(forKey: "labelValuePair") as AnyObject).value(forKey: "value") as AnyObject).value(forKey: "stringValue"))
            
            pickedContactNumber = (phoneString! as? String)!
        }
        
        /// Assign the picked contact to an attribute
        //self.pickContactButton.setTitle(contact.givenName, for: UIControlState())
        
        /// Assign the contactIdentifier
        /*if let type = messageType {
         if type == "SMS" {
         if !contact.phoneNumbers.isEmpty {
         let phoneString = ((((contact.phoneNumbers[0] as AnyObject).value(forKey: "labelValuePair") as AnyObject).value(forKey: "value") as AnyObject).value(forKey: "stringValue"))
         
         contactIdentifier = phoneString! as? String
         }
         } else if type == "Email" {
         if !contact.emailAddresses.isEmpty {
         let emailString = (((contact.emailAddresses[0] as AnyObject).value(forKey: "labelValuePair") as AnyObject).value(forKey: "value"))
         
         contactIdentifier = emailString! as? String
         }
         }
         }*/
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
    
    /// Keyboard stuff
    @objc func keyboardWillShow(notify: NSNotification) {
        if let keyboardSize = (notify.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notify: NSNotification) {
        if let keyboardSize = (notify.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /// Has a segue just happened
        //ApplicationConstants.hasASeguedHappenedInTheHomePage = true
        
        /*if (segue.identifier == "OpenUserFolder") {
         weak var ufvc = segue.destination as? UserFilesViewController
         
         ufvc?.folderOwner = selectedFolderOwner
         ufvc?.ownerFirstName = selectedFolderOwnerFirstName
         }*/
        
        if (segue.identifier == "openDatePickerFromDetails") {
            print("inside the segue identifier openPicShipDetails")
            weak var psdpvc = segue.destination as? PicShipDatePickerViewController
            
            psdpvc?.shipPicLocalVideoURL = shipPicURL
            psdpvc?.shipPic = shipPicImage
            psdpvc?.isVideo = isVideo
            
            if picShipPublicSwitch.isOn {
                isPublic = true
            }
            
            psdpvc?.isPublic = isPublic
            psdpvc?.contactNumber = pickedContactNNumber
            psdpvc?.contactName = pickedContactName
            psdpvc?.type = pickedType
            
            if shipPicTitleTextField.text != nil {
                shipPicTitle = shipPicTitleTextField.text!
            }
            
            if picShipDescriptionTextView != nil {
                shipPicDescription = picShipDescriptionTextView.text!
            }
            
            psdpvc?.picShipTitle = shipPicTitle
            psdpvc?.picShipDescription = shipPicDescription
            
            /// Pass the text enter info to the next view controller
            /*psvc?.userEmail = userEmail
            psvc?.userFirstName = userFirstName
            
            let userLastName = lastNameUserTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            psvc?.userLastName = userLastName
            psvc?.interests = interests*/
        }
    }*/
    
   /* func textViewDidBeginEditing(_ textView: UITextView) {
        print("Typing happening here...")
        if (textView.text == "Type out your message here...") {
            textView.text = ""
            //tymrTextViewEdited = true
            textView.textColor = .white
        }
        textView.becomeFirstResponder() //Optional
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView.text == "") {
            textView.text = "Type out your message here..."
            textView.textColor = .lightGray
        }
        textView.resignFirstResponder()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }*/
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        if currentUser != nil {
            let validationTimeInterval = self.picShipDatePicker?.date.timeIntervalSince(Date())
            
            if Int(validationTimeInterval!) > 0 {
                
                if shipPicTitleTextField.text != "" {
                    if isBeingEdited {
                        updateShipPicData()
                    } else {
                        shipPicTitle = shipPicTitleTextField.text!
                        
                        /// Create a local notification that will alert the user at the scheduled time
                        if shipPicTitle != "" {
                            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                                if settings.authorizationStatus == .authorized {
                                    /// Schedule a push notification
                                    self.scheduleNotification(title: self.shipPicTitle)
                                } else {
                                    /// User has not given permission
                                    UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .badge, .alert], completionHandler: { (granted, error) in
                                        if let error = error {
                                            print(error)
                                        } else {
                                            if granted {
                                                self.scheduleNotification(title: self.shipPicTitle)
                                            }
                                        }
                                    })
                                }
                            }
                        }
                        
                        isPublic = picShipPublicSwitch.isOn
                        
                        let timeInterval = self.picShipDatePicker?.date.timeIntervalSince1970
                        shipPickTimeStamp = Int(timeInterval!)
                        
                        let currentTimeInterval = NSDate().timeIntervalSince1970
                        let currentTimeStamp = Int(currentTimeInterval)
                        
                        if (shipPickTimeStamp! - currentTimeStamp) >= 60 {
                            print("The time stamp is: \(shipPickTimeStamp)")
                            
                            doneButton.isEnabled = false
                            doneButton.setTitle("PLEASE WAIT...", for: .normal)
                            
                            if shipPicURL != nil {
                                uploadTOFireBaseVideo(url: shipPicURL!, success: { (success) in
                                    //
                                }) { (error) in
                                    //
                                    self.doneButton.isEnabled = true
                                    self.doneButton.setTitle("DONE", for: .normal)
                                }
                            } else {
                                uploadShipPicJPEGAlone()
                                print("shipPicLocalVideoURL is nil")
                            }
                        } else {
                            self.displayMajeshiGenericAlert("Date and Time Issue", userMessage: "Please choose a date and time in the future.")
                        }
                    }
                } else {
                    self.displayMajeshiGenericAlert("Title Missing", userMessage: "Please fill in your ShipPic's title first and then tap 'DONE'.")
                }
            } else {
                self.displayMajeshiGenericAlert("Date Issue", userMessage: "Please pick a date in the future.")
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
        } else {
            self.displayMajeshiGenericAlert("Please log in", userMessage: "To post your ShipPic, you have be logged in. Please go back and log in.")
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
    
    func uploadTOFireBaseVideo(url: URL, success : @escaping (String) -> Void, failure : @escaping (Error) -> Void) {
        let imageUUID = NSUUID().uuidString
        let name = "\(imageUUID).mp4"
        
        var data: Data? = nil
        do {
            data = try NSData(contentsOf: url, options: .mappedIfSafe) as Data
        } catch {
            print(error)
            self.displayMajeshiGenericAlert("Error", userMessage: "There was an error creating your ShipPic. Please try again.")
            doneButton.isEnabled = true
            self.doneButton.setTitle("DONE", for: .normal)
            return
        }
        
        let storageRef = Storage.storage().reference().child(name)
        if let uploadData = data as Data? {
            let metadata = StorageMetadata()
            metadata.contentType = "video/mp4"
            
            percentageLabel.isHidden = false
            trackLayer.isHidden = false
            shapeLayer.isHidden = false
            
            self.trackLayer.position = self.contentView.center
            self.shapeLayer.position = self.contentView.center
            self.percentageLabel.center = self.contentView.center
            
            let uploadTask = storageRef.putData(uploadData, metadata: metadata, completion: { (metadata, error) in
                if let error = error {
                    failure(error)
                    self.displayMajeshiGenericAlert("Error", userMessage: "There was an error creating your ShipPic. Please try again.")
                    self.doneButton.isEnabled = true
                    self.doneButton.setTitle("DONE", for: .normal)
                } else {
                    //let strPic:String = (metadata?.downloadURL()?.absoluteString)!
                    //success(strPic)
                    //self.displayMajeshiGenericAlert("Success!", userMessage: "Your video was uploaded successfully!.")
                    Storage.storage().reference().child(name).downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            // Uh-oh, an error occurred!
                            self.displayMajeshiGenericAlert("Error", userMessage: "There was an error creating your ShipPic. Please try again.")
                            self.doneButton.isEnabled = true
                            self.doneButton.setTitle("DONE", for: .normal)
                            
                            return
                        }
                        
                        let downloadURLString = downloadURL.absoluteString
                        
                        self.uploadShipPicJPEG(randomizedFileName: imageUUID, videoFileURL: downloadURLString)
                    }
                }
            })
            
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
        if shipPicImage != nil {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            //kascadaUploadProfilePictureButton.isEnabled = false
            
            if let data = shipPicImage!.jpegData(compressionQuality: 0.0) {
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
                        
                        self.displayMajeshiGenericAlert("Error", userMessage: "There was an error creating your ShipPic. Please try again.")
                        self.doneButton.isEnabled = true
                        self.doneButton.setTitle("DONE", for: .normal)
                        return
                    }
                    
                    // You can also access to download URL after upload.
                    Storage.storage().reference().child(pictureFileName).downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            // Uh-oh, an error occurred!
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            
                            self.displayMajeshiGenericAlert("Error", userMessage: "There was an error creating your ShipPic. Please try again.")
                            self.doneButton.isEnabled = true
                            self.doneButton.setTitle("DONE", for: .normal)
                            return
                        }
                        
                        let downloadURLString = downloadURL.absoluteString
                        
                        if self.currentUser != nil {
                            /// Create the unix time stamp
                            let currentDate = Date()
                            let timeStamp = Int(currentDate.timeIntervalSince1970)
                            
                            var contactUserID = "empty"
                            var contactName = "empty"
                            
                            if self.taggedContactUserID != nil {
                                contactUserID = self.taggedContactUserID!
                            }
                            
                            if self.taggedContactUserName != nil {
                                contactName = self.taggedContactUserName!
                            }
                            
                            let picShipData: Dictionary<String, AnyObject> = [
                                "imageFileName": pictureFileName as AnyObject,
                                "imageFileURL": downloadURLString as AnyObject,
                                "videoFileName": videoFileName as AnyObject,
                                "videoFileURL": videoFileURL as AnyObject,
                                "isVideo": self.isVideo as AnyObject,
                                "dueAt": self.shipPickTimeStamp as AnyObject,
                                "description": self.shipPicDescription as AnyObject,
                                "type": self.pickedType  as AnyObject,
                                "title": self.shipPicTitle as AnyObject,
                                "isPublic": self.isPublic as AnyObject,
                                "contactName": contactName as AnyObject,
                                "contactUserID": contactUserID as AnyObject,
                                "createdAt": timeStamp as AnyObject,
                                "isDealtWith": false as AnyObject
                            ]
                            
                            let dBase = Firestore.firestore()
                            
                            var picShipRef: DocumentReference? = nil
                            picShipRef = dBase.collection("picShip").document(self.currentUser!).collection("picShips").addDocument(data: picShipData) {  (error) in
                                if let error = error {
                                    print("\(error.localizedDescription)")
                                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                    
                                    self.displayMajeshiGenericAlert("Error", userMessage: "There was an error creating your ShipPic. Please try again.")
                                    self.doneButton.isEnabled = true
                                    self.doneButton.setTitle("DONE", for: .normal)
                                } else {
                                    print("Document was successfully created and written.")
                                    
                                    let picShipMetaData: Dictionary<String, AnyObject> = [
                                        "picShipID": picShipRef!.documentID as AnyObject,
                                        "imageFileName": pictureFileName as AnyObject,
                                        "imageFileURL": downloadURLString as AnyObject,
                                        "videoFileName": videoFileName as AnyObject,
                                        "videoFileURL": videoFileURL as AnyObject,
                                        "isVideo": self.isVideo as AnyObject,
                                        "dueAt": self.shipPickTimeStamp as AnyObject,
                                        "description": self.shipPicDescription as AnyObject,
                                        "type": self.pickedType  as AnyObject,
                                        "title": self.shipPicTitle as AnyObject,
                                        "isPublic": self.isPublic as AnyObject,
                                        "contactName": contactName as AnyObject,
                                        "contactUserID": contactUserID as AnyObject,
                                        "createdAt": timeStamp as AnyObject,
                                        "picShipOwnerID": self.currentUser! as AnyObject,
                                        "likes": 0 as AnyObject,
                                        "views": 0 as AnyObject,
                                        "id": "\(timeStamp)-\(self.currentUser!)" as AnyObject
                                    ]
                                    
                                    if self.taggedContactUserID != nil {
                                        dBase.collection("tagged").document("\(self.taggedContactUserID!)").collection("picShips").addDocument(data: picShipMetaData)
                                    }
                                    //self.displayMajeshiGenericAlert("Success", userMessage: "You ShipPic was successfully created!")
                                    //self.navigationController?.popToRootViewController(animated: true)
                                    /*let picShipMetaRef = dBase.collection("picShipMeta")/*.document("\(timeStamp)")
                                    picShipMetaRef.collection(picShipRef.documentID)*/picShipMetaRef.addDocument(data: picShipMetaData) {  (error) in
                                        if let error = error {
                                            print("\(error.localizedDescription)")
                                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                            
                                            self.displayMajeshiGenericAlert("Error", userMessage: "There was an error creating your ShipPic. Please try again.")
                                            self.doneButton.isEnabled = true
                                            self.doneButton.setTitle("DONE", for: .normal)
                                        } else {
                                            print("Document was successfully created and written.")
                                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                            //self.displayMajeshiGenericAlert("Success", userMessage: "Your new ShipPic was successfully created!")
                                            
                                            self.dismiss(animated: true, completion: nil)
                                            //self.presentingViewController?.dismiss(animated: true, completion: nil)
                                            ApplicationConstants.justMovedBackFromDatePicker = true
                                        }
                                    }*/
                                    
                                    dBase.collection("picShipMeta").document("\(timeStamp)-\(self.currentUser!)").setData(picShipMetaData, completion: { (error) in
                                        if let error = error {
                                            print("\(error.localizedDescription)")
                                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                            
                                            self.displayMajeshiGenericAlert("Error", userMessage: "There was an error creating your ShipPic. Please try again.")
                                            self.doneButton.isEnabled = true
                                            self.doneButton.setTitle("DONE", for: .normal)
                                        } else {
                                            print("Document was successfully created and written.")
                                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                            //self.displayMajeshiGenericAlert("Success", userMessage: "Your new ShipPic was successfully created!")
                                            
                                            
                                            self.dismiss(animated: true, completion: nil)
                                            //self.presentingViewController?.dismiss(animated: true, completion: nil)
                                            ApplicationConstants.justMovedBackFromDatePicker = true
                                        }
                                    })
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
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                displayMajeshiGenericAlert("Missing field(s)", userMessage: "Please make sure that all the fields have been filled.")
            }
        }
    }
    
    
    func uploadShipPicJPEGAlone() {
        if shipPicImage != nil {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            //kascadaUploadProfilePictureButton.isEnabled = false
            
            if let data = shipPicImage!.jpegData(compressionQuality: 0.0) {
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
                        
                        self.displayMajeshiGenericAlert("Error", userMessage: "There was an error creating your ShipPic. Please try again.")
                        self.doneButton.isEnabled = true
                        return
                    }
                    
                    // You can also access to download URL after upload.
                    Storage.storage().reference().child(pictureFileName).downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            // Uh-oh, an error occurred!
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            
                            self.displayMajeshiGenericAlert("Error", userMessage: "There was an error creating your ShipPic. Please try again.")
                            self.doneButton.isEnabled = true
                            return
                        }
                        
                        let downloadURLString = downloadURL.absoluteString
                        
                        if self.currentUser != nil {
                            /// Create the unix time stamp
                            let currentDate = Date()
                            let timeStamp = Int(currentDate.timeIntervalSince1970)
                            
                            var contactUserID = "empty"
                            var contactName = "empty"
                            
                            if self.taggedContactUserID != nil {
                                contactUserID = self.taggedContactUserID!
                            }
                            
                            if self.taggedContactUserName != nil {
                                contactName = self.taggedContactUserName!
                            }
                            
                            let picShipData: Dictionary<String, AnyObject> = [
                                "imageFileName": pictureFileName as AnyObject,
                                "imageFileURL": downloadURLString as AnyObject,
                                "videoFileName": "empty" as AnyObject,
                                "videoFileURL": "empty" as AnyObject,
                                "isVideo": false as AnyObject,
                                "dueAt": self.shipPickTimeStamp as AnyObject,
                                "description": self.shipPicDescription as AnyObject,
                                "type": self.pickedType  as AnyObject,
                                "title": self.shipPicTitle as AnyObject,
                                "isPublic": self.isPublic as AnyObject,
                                "contactName": contactName as AnyObject,
                                "contactUserID": contactUserID as AnyObject,
                                "createdAt": timeStamp as AnyObject,
                                "isDealtWith": false as AnyObject
                            ]
                            
                            let dBase = Firestore.firestore()
                            
                            var picShipRef: DocumentReference? = nil
                            picShipRef = dBase.collection("picShip").document(self.currentUser!).collection("picShips").addDocument(data: picShipData) {  (error) in
                                if let error = error {
                                    print("\(error.localizedDescription)")
                                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                    
                                    self.displayMajeshiGenericAlert("Error", userMessage: "There was an error creating your ShipPic. Please try again.")
                                    self.doneButton.isEnabled = true
                                } else {
                                    print("Document was successfully created and written.")
                                    
                                    let picShipMetaData: Dictionary<String, AnyObject> = [
                                        "picShipID": picShipRef!.documentID as AnyObject,
                                        "imageFileName": pictureFileName as AnyObject,
                                        "imageFileURL": downloadURLString as AnyObject,
                                        "videoFileName": "empty" as AnyObject,
                                        "videoFileURL": "empty" as AnyObject,
                                        "isVideo": false as AnyObject,
                                        "dueAt": self.shipPickTimeStamp as AnyObject,
                                        "description": self.shipPicDescription as AnyObject,
                                        "type": self.pickedType  as AnyObject,
                                        "title": self.shipPicTitle as AnyObject,
                                        "isPublic": self.isPublic as AnyObject,
                                        "contactName": contactName as AnyObject,
                                        "contactUserID": contactUserID as AnyObject,
                                        "createdAt": timeStamp as AnyObject,
                                        "picShipOwnerID": self.currentUser! as AnyObject,
                                        "likes": 0 as AnyObject,
                                        "views": 0 as AnyObject,
                                        "id": "\(timeStamp)-\(self.currentUser!)" as AnyObject
                                    ]
                                    
                                    if self.taggedContactUserID != nil {
                                        dBase.collection("tagged").document("\(self.taggedContactUserID!)").collection("picShips").addDocument(data: picShipMetaData)
                                    }
                                    
                                    //self.displayMajeshiGenericAlert("Success", userMessage: "You ShipPic was successfully created!")
                                    //self.navigationController?.popToRootViewController(animated: true)
                                    
                                    
                                    dBase.collection("picShipMeta").document("\(timeStamp)-\(self.currentUser!)").setData(picShipMetaData, completion: { (error) in
                                        if let error = error {
                                            print("\(error.localizedDescription)")
                                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                            
                                            self.displayMajeshiGenericAlert("Error", userMessage: "There was an error creating your ShipPic. Please try again.")
                                            self.doneButton.isEnabled = true
                                            self.doneButton.setTitle("DONE", for: .normal)
                                        } else {
                                            print("Document was successfully created and written.")
                                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                            //self.displayMajeshiGenericAlert("Success", userMessage: "Your new ShipPic was successfully created!")
                                            
                                            
                                            self.dismiss(animated: true, completion: nil)
                                            //self.presentingViewController?.dismiss(animated: true, completion: nil)
                                            ApplicationConstants.justMovedBackFromDatePicker = true
                                        }
                                    })
                                    
                                    
                                    /*let picShipMetaRef = dBase.collection("picShipMeta")
                                    picShipMetaRef.document("\(timeStamp)").addDocument(data: picShipMetaData) {  (error) in
                                        if let error = error {
                                            print("\(error.localizedDescription)")
                                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                            
                                            self.displayMajeshiGenericAlert("Error", userMessage: "There was an error creating your ShipPic. Please try again.")
                                            self.doneButton.isEnabled = true
                                            self.doneButton.setTitle("DONE", for: .normal)
                                        } else {
                                            print("Document was successfully created and written.")
                                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                            //self.displayMajeshiGenericAlert("Success", userMessage: "Your new ShipPic was successfully created!")
                                            
                                            
                                            self.dismiss(animated: true, completion: nil)
                                            //self.presentingViewController?.dismiss(animated: true, completion: nil)
                                            ApplicationConstants.justMovedBackFromDatePicker = true
                                        }
                                    }*/
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
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                displayMajeshiGenericAlert("Missing field(s)", userMessage: "Please make sure that all the fields have been filled.")
            }
        }
    }
    
    func updateShipPicData() {
        if self.currentUser != nil {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            doneButton.isEnabled = false
            doneButton.setTitle("PLEASE WAIT...", for: .normal)
            
            
            let timeInterval = self.picShipDatePicker?.date.timeIntervalSince1970
            shipPickTimeStamp = Int(timeInterval!)
            
            shipPicTitle = shipPicTitleTextField.text!
            
            isPublic = picShipPublicSwitch.isOn
            
            /// Create a local notification that will alert the user at the scheduled time
            if shipPicTitle != "" {
                UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                    if settings.authorizationStatus == .authorized {
                        /// Schedule a push notification
                        self.scheduleNotification(title: self.shipPicTitle)
                    } else {
                        /// User has not given permission
                        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .badge, .alert], completionHandler: { (granted, error) in
                            if let error = error {
                                print(error)
                            } else {
                                if granted {
                                    self.scheduleNotification(title: self.shipPicTitle)
                                }
                            }
                        })
                    }
                }
            }
            
            
            if mainShipPicKeyOnEditing != nil && shipPicIDOnEditing != nil {
                let picShipData: Dictionary<String, AnyObject> = [
                    "dueAt": self.shipPickTimeStamp as AnyObject,
                    "type": self.pickedType  as AnyObject,
                    "title": self.shipPicTitle as AnyObject,
                    "isPublic": self.isPublic as AnyObject
                ]
                
                let dBase = Firestore.firestore()
                
                let picShipRef = dBase.collection("picShip").document(self.currentUser!)
                picShipRef.collection("picShips").document(mainShipPicKeyOnEditing!).updateData(picShipData) {  (error) in
                    if let error = error {
                        print("\(error.localizedDescription)")
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        
                        self.displayMajeshiGenericAlert("Error", userMessage: "There was an error creating your ShipPic. Please try again.")
                        self.doneButton.isEnabled = true
                        self.doneButton.setTitle("DONE", for: .normal)
                    } else {
                        print("Document was successfully created and written.")
                        
                        //citiesRef.whereField("state", isEqualTo: "CA")
                        
                        let picShipMetaData: Dictionary<String, AnyObject> = [
                            "dueAt": self.shipPickTimeStamp as AnyObject,
                            "type": self.pickedType  as AnyObject,
                            "title": self.shipPicTitle as AnyObject,
                            "isPublic": self.isPublic as AnyObject
                        ]
                        
                        if self.taggedContactUserID != nil {
                            dBase.collection("tagged").document(self.taggedContactUserID!).collection("picShips").whereField("picShipID", isEqualTo: self.mainShipPicKeyOnEditing!).getDocuments(completion: { (snapshot, error) in
                                if let querySnapshot = snapshot?.documents {
                                    for data in querySnapshot {
                                        let documentID = data.documentID
                                        
                                        dBase.collection("tagged").document(self.taggedContactUserID!).collection("picShips").document(documentID).updateData(picShipMetaData)
                                        
                                        dBase.collection("picShipMeta").document(self.shipPicIDOnEditing!).updateData(picShipMetaData, completion: { (error) in
                                            if let error = error {
                                                print("\(error.localizedDescription)")
                                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                                
                                                self.displayMajeshiGenericAlert("Error", userMessage: "There was an error creating your ShipPic. Please try again.")
                                                self.doneButton.isEnabled = true
                                                self.doneButton.setTitle("DONE", for: .normal)
                                            } else {
                                                print("Document was successfully created and written.")
                                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                                
                                                
                                                self.dismiss(animated: true, completion: nil)
                                                //self.presentingViewController?.dismiss(animated: true, completion: nil)
                                                ApplicationConstants.justMovedBackFromDatePicker = true
                                            }
                                        })
                                    }
                                }
                            })
                        } else {
                            dBase.collection("picShipMeta").document(self.shipPicIDOnEditing!).updateData(picShipMetaData, completion: { (error) in
                                if let error = error {
                                    print("\(error.localizedDescription)")
                                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                    
                                    self.displayMajeshiGenericAlert("Error", userMessage: "There was an error creating your ShipPic. Please try again.")
                                    self.doneButton.isEnabled = true
                                    self.doneButton.setTitle("DONE", for: .normal)
                                } else {
                                    print("Document was successfully created and written.")
                                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                    
                                    
                                    self.dismiss(animated: true, completion: nil)
                                    //self.presentingViewController?.dismiss(animated: true, completion: nil)
                                    ApplicationConstants.justMovedBackFromDatePicker = true
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    /**
     This constructs and sets a local notification.
     
     - Parameters:
     - contactName: The contact's name
     
     - Returns: void.
     */
    func scheduleNotification(title: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = "Your scheduled ShipPic is now ready to be dealt with."
        content.sound = UNNotificationSound.default
        
        let timeInterval = self.picShipDatePicker?.date.timeIntervalSince(Date())
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval!, repeats: false)
        
        let notificationRequest = UNNotificationRequest(identifier: "PicShipLocalNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            if let error = error {
                print(error)
            } else {
                print("Notification scheduled")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "openContactToBeTagged") {
            print("inside the segue identifier openPicShipDetails")
            let navigationController = segue.destination as! UINavigationController
            let tcvc = navigationController.viewControllers[0] as! TagContactViewController
                
            tcvc.userDataDelegate = self
        }
    }
    
    func setUserData(userID: String?, userName: String?) {
        self.taggedContactUserID = userID
        self.taggedContactUserName = userName
        
        if self.taggedContactUserName != nil {
            picShipUserStatusLabel.text = self.taggedContactUserName
        }
    }
    
    func setTaggedUser() {
        if currentUser != nil {
        let dBase = Firestore.firestore()
        
        let picShipRef = dBase.collection("picShipMeta").document(shipPicIDOnEditing!)
            
            picShipRef.getDocument { (documentSnapshot, error) in
                if error == nil {
                    if let picShipMetaDict = documentSnapshot?.data() {
                        if let contactUserID = picShipMetaDict["contactUserID"] as? String {
                            if contactUserID != "empty" {
                                self.taggedContactUserID = contactUserID
                                
                                print("The tagged user ID is: \(self.taggedContactUserID!)")
                                print("The picShipID: \(self.mainShipPicKeyOnEditing!)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = textField.text
        
        textField.text = text
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let text = textField.text
        
        textField.text = text
        
        return true
    }
}
