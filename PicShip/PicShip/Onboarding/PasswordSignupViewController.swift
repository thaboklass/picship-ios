//
//  SixthSignupPageViewController.swift
//  Majeshi
//
//  Created by Thabo David Klass on 31/01/2017.
//  Copyright © 2017 Spreebie, Inc. All rights reserved.
//

import FirebaseFirestore

/// The fourth signup page class of the Majeshi application
class PasswordSignupViewController: UIViewController, UITextFieldDelegate {
    /// This is the sign up button
    @IBOutlet weak var backButton: UIButton!
    
    /// This is the next button
    @IBOutlet weak var finishButton: UIButton!
    
    /// This is the sign up progress indicator
    @IBOutlet weak var signupProgressView: UIProgressView!
    
    /// The user passwords text fields
    @IBOutlet weak var passwordUserTextField: UITextField!
    
    //@IBOutlet weak var retypedPasswordUserTextField: UITextField!
    
    /// The sixth page image view
    @IBOutlet weak var sixthSignupPageImageView: UIImageView!
    
    @IBOutlet weak var informativeLabel: UILabel!
    
    
    // The user's email
    var userEmail: String? = String()
    
    /// The user's first name
    var userFirstName: String? = String()
    
    /// The user's last name
    var userLastName: String? = String()
    
    // The user's interests
    var interests = [String]()
    
    var counter:Int = 0 {
        didSet {
            let fractionalProgress = Float(counter) / 100.0
            let animated = counter != 0
            
            signupProgressView.setProgress(fractionalProgress, animated: animated)
        }
    }
    
    var verificationID: String? = nil
    
    override func viewDidLoad() {
        // nothing yet
        
        /// Create a rounder border for the button
        let backButtonLayer: CALayer?  = backButton.layer
        backButtonLayer!.cornerRadius = 4
        backButtonLayer!.masksToBounds = true
        
        let finishButtonLayer: CALayer?  = finishButton.layer
        finishButtonLayer!.cornerRadius = 4
        finishButtonLayer!.masksToBounds = true
        
        var titleString = NSMutableAttributedString()
        let title = "password"
        
        titleString = NSMutableAttributedString(string:title, attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir", size: 14)!]) // Font
        titleString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 169.0/255.0, green: 43.0/255.0, blue: 41.0/255.0, alpha: 0.7), range:NSRange(location:0,length:title.characters.count))    // Color
        //passwordUserTextField.attributedPlaceholder = titleString
        
        var titleString2 = NSMutableAttributedString()
        let title2 = "re-type password"
        
        titleString2 = NSMutableAttributedString(string:title2, attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir", size: 14)!]) // Font
        titleString2.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 169.0/255.0, green: 43.0/255.0, blue: 41.0/255.0, alpha: 0.7), range:NSRange(location:0,length:title2.characters.count))    // Color
        //retypedPasswordUserTextField.attributedPlaceholder = titleString2
        
        /// So the textfields delegate functions work
        passwordUserTextField.delegate = self
        //retypedPasswordUserTextField.delegate = self
        
        passwordUserTextField.keyboardAppearance = .dark
        
        /// Set the progress of the signup progress indicator
        signupProgressView.setProgress(0.8, animated: false)
        startCount()
        
        if userEmail != nil {
            print("The phone number is: \(userEmail!)")
            
            sendVerificationCode(phoneNumber: userEmail!)
        }
        
        /// Log an open event on FB Analytics
        //FBSDKAppEvents.logEvent("sixthSignupOpened")
        
        AMTooltipView(message: "A verification code has been sent to your phone via SMS. Enter that number into the field and tap the 'Finish' button to complete your registration.",
                      focusView: informativeLabel, //pass view you want show tooltip over it
            target: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        sixthSignupPageImageView = nil
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func finishButtonTapped(_ sender: Any) {
        let userPassword = passwordUserTextField.text
        
        /*if userPassword!.isEmpty || (passwordUserTextField.text! != retypedPasswordUserTextField.text!) {
            // Empty fields.
            displayMyAlertMessage("Missing field/mismatch", userMessage: "The password fields are required. They must match.")
        } else {*/
            if (userPassword?.characters.count)! >= 1 {
                /// Disable the registration button to prevent unnecessary taps
                finishButton.isEnabled = false
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                
                /// Sign up on Firebase as well
                /*Auth.auth().createUser(withEmail: self.userEmail!, password: userPassword!) { (fireUser, error) in
                    if error == nil {
                        // Set the Majeshi user ID
                        KeychainWrapper.standard.set((fireUser?.user.uid)!, forKey: ApplicationConstants.majeshiUserIDKey)
                        
                        // Set recently logged in to true. This will be used to refresh data
                        // on the HomeViewController
                        KeychainWrapper.standard.set(ApplicationConstants.majeshiSmallYesValue, forKey: ApplicationConstants.majeshiUserJustLoggedInValue)
                        
                        self.setUserData(firstName: self.userFirstName!, lastName: self.userLastName!, phoneNumber: self.userEmail!, uid: ((fireUser?.user.uid)!))
                        self.presentingViewController?.presentingViewController?.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    } else {
                        self.displayMyAlertMessage("Error", userMessage: (error?.localizedDescription)!)
                        self.finishButton.isEnabled = true
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                }*/
                
                let credential = PhoneAuthProvider.provider().credential(
                    withVerificationID: verificationID!,
                    verificationCode: userPassword!)
                
                Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                    if let error = error {
                        self.displayMyAlertMessage("Error", userMessage: error.localizedDescription)
                        self.finishButton.isEnabled = true
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        
                        return
                    }
                    
                    // Set the Majeshi user ID
                    KeychainWrapper.standard.set((authResult?.user.uid)!, forKey: ApplicationConstants.majeshiUserIDKey)
                    
                    // Set recently logged in to true. This will be used to refresh data
                    // on the HomeViewController
                    KeychainWrapper.standard.set(ApplicationConstants.majeshiSmallYesValue, forKey: ApplicationConstants.majeshiUserJustLoggedInValue)
                    
                    self.setUserData(firstName: self.userFirstName!, lastName: self.userLastName!, phoneNumber: self.userEmail!, uid: ((authResult?.user.uid)!))
                }
            } else {
                self.displayMyAlertMessage("Password error", userMessage: "The password must be 1 character(s) long or more.")
            }
        //}
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
     This sets the user as logged in.
     
     - Parameters:
     - none
     
     - Returns: void.
     */
    func setAsLoggedIn() {
        UserDefaults.standard.set(true, forKey: "isUserLoggedInPicShip")
        UserDefaults.standard.synchronize()
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
     This enables all the tabs after successful login.
     
     - Parameters:
     - patriarch: The parent tab bar controller
     
     - Returns: void.
     */
    func enableTabsThatReguireLogin(_ patriarch: UITabBarController) {
        let arrayOfTabBarItems = patriarch.tabBar.items as [UITabBarItem]?
        if arrayOfTabBarItems != nil {
            let tabBarItem2 = arrayOfTabBarItems![2]
            tabBarItem2.isEnabled = true
            let tabBarItem3 = arrayOfTabBarItems![3]
            tabBarItem3.isEnabled = true
            let tabBarItem4 = arrayOfTabBarItems![4]
            tabBarItem4.isEnabled = true
        }
    }
    
    /// Textfield delegate function
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func startCount() {
        //progressLabel.text = "0%"
        self.counter = 75
        for _ in 75..<100 {
            DispatchQueue.global().async {
                
                sleep(1)
                DispatchQueue.main.async(execute: {
                    self.counter += 1
                    return
                })
            }
        }
    }
    
    /**
     This saves the new user to the database.
     
     - Parameters:
     - user: The user name
     - uid: The unique ID
     
     - Returns: void.
     */
    func setUserData(firstName: String, lastName: String, phoneNumber: String, uid: String) {
        /// Create the unix time stamp
        let currentDate = Date()
        let timeStamp = Int(currentDate.timeIntervalSince1970)
        
        let fullName = firstName + " " + lastName
        
        let userData: Dictionary<String, AnyObject> = [
            "firstName": firstName as AnyObject,
            "lastName": lastName as AnyObject,
            "fullName": fullName as AnyObject,
            "phoneNumber": phoneNumber as AnyObject,
            "deviceToken": ApplicationConstants.dbEmptyValue as AnyObject,
            "deviceArn": ApplicationConstants.dbEmptyValue as AnyObject,
            "profilePictureFileName": ApplicationConstants.dbEmptyValue as AnyObject,
            "measuringSystem": "imperial" as AnyObject,
            "creationAt": timeStamp  as AnyObject,
            "updatedAt": timeStamp  as AnyObject,
            "status": "Hi there! I'm using PicShip!" as AnyObject,
            "interests": interests as AnyObject,
            "displayPhoneNumber": true as AnyObject
        ]
        
        let dBase = Firestore.firestore()
        
        dBase.collection("users").document(uid).setData(userData) { (error) in
            if let error = error {
                print("\(error.localizedDescription)")
            } else {
                print("Document was successfully created and written.")
                
                let userMetaData: Dictionary<String, AnyObject> = [
                    "firstName": firstName as AnyObject,
                    "lastName": lastName as AnyObject,
                    "fullName": fullName as AnyObject,
                    "phoneNumber": phoneNumber as AnyObject,
                    "userID": uid as AnyObject,
                    "deviceToken": ApplicationConstants.dbEmptyValue as AnyObject,
                    "deviceArn": ApplicationConstants.dbEmptyValue as AnyObject,
                    "profilePictureFileName": ApplicationConstants.dbEmptyValue as AnyObject,
                    "measuringSystem": "imperial" as AnyObject,
                    "creationAt": timeStamp  as AnyObject,
                    "updatedAt": timeStamp  as AnyObject,
                    "status": "Hi there! I'm using PicShip!" as AnyObject,
                    "interests": self.interests as AnyObject,
                    "displayPhoneNumber": true as AnyObject
                ]
                
                dBase.collection("userMeta").document(phoneNumber).setData(userMetaData) { (error) in
                    if let error = error {
                        print("\(error.localizedDescription)")
                    } else {
                        print("Document was successfully created and written.")
                        
                        self.presentingViewController?.presentingViewController?.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func sendVerificationCode(phoneNumber: String) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                //self.showMessagePrompt(error.localizedDescription)
                print(error.localizedDescription)
                return
            }
            // Sign in using the verificationID and the code sent to the user
            // ...
            self.verificationID = verificationID
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
