//
//  LoginViewController.swift
//  Majeshi
//
//  Created by Thabo David Klass on 25/01/2016.
//  Copyright © 2016 Spreebie, Inc. All rights reserved.
//
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseFirestore

/// The Login page class
class LoginViewController: UIViewController, UITextFieldDelegate {
    /// The parent tab bar controlller
    var dialogParent = UITabBarController()
    
    /// If the user data from facebook has been populated
    var userDataPopulated = false
    
    /// Test variable for facebook
    var usernameFBTest: String? = String()
    
    /// Another test variable for facebook
    var emailFBTest: String? = String()
    
    /// The facebook user's objectID
    var objectID: String? = String()
    
    /// The user first name
    var userFirstName: String? = String()
    
    /// The user last name
    var userLastName: String? = String()
    
    /// The back button
    @IBOutlet weak var backButton: UIButton!
    
    /// The user email text field
    //@IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userEmailTextField: MadokaTextField!
    
    /// The user password text field
    @IBOutlet weak var userPasswordTextField: UITextField!
    
    /// The user login button
    @IBOutlet weak var userLoginButton: UIButton!
    
    /// Login page image view
    @IBOutlet weak var loginPageImageView: UIImageView!
    @IBOutlet weak var getCodeButton: UIButton!
    
    /// Facebook login button
    @IBOutlet weak var loginFBSDKLoginButton: FBSDKLoginButton!
    
    /// The current user (Parse)
    //var myUser = PFUser()
    
    /// The user fb_auth name
    var fbAuth: String? = String()
    
    /// The user email name
    var fbEmail: String? = String()
    
    var verificationID: String? = nil
    
    override func viewDidLoad() {
        /// Create rounded corners for the user login button
        let backButtonLayer: CALayer?  = backButton.layer
        backButtonLayer!.cornerRadius = 4
        backButtonLayer!.masksToBounds = true
        
        let userLoginButtonLayer: CALayer?  = userLoginButton.layer
        userLoginButtonLayer!.cornerRadius = 4
        userLoginButtonLayer!.masksToBounds = true
        
        var titleString = NSMutableAttributedString()
        let title = "phone number"
        
        titleString = NSMutableAttributedString(string:title, attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir", size: 14)!]) // Font
        titleString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 169.0/255.0, green: 43.0/255.0, blue: 41.0/255.0, alpha: 0.7), range:NSRange(location:0,length:title.characters.count))    // Color
        //userEmailTextField.attributedPlaceholder = titleString
        
        userEmailTextField.delegate = self
        userPasswordTextField.delegate = self
        
        userEmailTextField.keyboardAppearance = .dark
        
        var titleString2 = NSMutableAttributedString()
        let title2 = "verification code"
        
        titleString2 = NSMutableAttributedString(string:title2, attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir", size: 14)!]) // Font
        titleString2.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 169.0/255.0, green: 43.0/255.0, blue: 41.0/255.0, alpha: 0.7), range:NSRange(location:0,length:title2.characters.count))    // Color
        //userPasswordTextField.attributedPlaceholder = titleString2
        
        
        userPasswordTextField.keyboardAppearance = .dark
        
        /// Make this class the delegate for the Facebook button
        //loginFBSDKLoginButton.delegate = self
        
        /// Configure read permissions
        //loginFBSDKLoginButton.readPermissions = ["public_profile", "email"]
        /*loginFBSDKLoginButton.isEnabled = false
        loginFBSDKLoginButton.isHidden = true*/
        
        /// If somehow, through a bizzare event, the user is already
        /// connected via facebook, move the process forward
        if (FBSDKAccessToken.current() == nil) {
            print("Not logged in...")
        } else {
            print("Logged in..")
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        FBSDKAppEvents.logEvent("loginOpened")
        
        AMTooltipView(message: "To log in, first enter your mobile number complete with country code. After that, tap the 'Get Code' button to receive a verification code via SMS. Enter the code into the 'Verification Code' field and tap 'Login'.",
                      focusView: getCodeButton, //pass view you want show tooltip over it
            target: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        loginPageImageView = nil
    }
    
    /**
     This reacts to the login button tapped action
     
     - Parameters:
     - sender: The login button
     
     - Returns: void.
     */
    @IBAction func loginButtonTapped(_ sender: AnyObject) {
        if verificationID != nil {
            let userEmail = userEmailTextField.text
            let userPassword = userPasswordTextField.text
            
            if userEmail!.isEmpty || userPassword!.isEmpty {
                // Empty fields.
                displayMyAlertMessage("Missing field(s)", userMessage: "The email and password fields are required.")
            } else {
                self.userLoginButton.isEnabled = false
                //self.loginFBSDKLoginButton.isEnabled = false
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                
                /// Login on Firebase as well
                /*Auth.auth().signIn(withEmail: userEmail!, password: userPassword!) { (fireUser, error) in
                 if error == nil {
                 KeychainWrapper.standard.set((fireUser?.user.uid)!, forKey: ApplicationConstants.majeshiUserIDKey)
                 KeychainWrapper.standard.set(ApplicationConstants.majeshiSmallYesValue, forKey: ApplicationConstants.majeshiUserJustLoggedInValue)
                 
                 self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                 } else {
                 self.userLoginButton.isEnabled = true
                 self.loginFBSDKLoginButton.isEnabled = true
                 UIApplication.shared.isNetworkActivityIndicatorVisible = false
                 
                 self.displayMyAlertMessage("Error", userMessage: "The login data you entered is incorrect. Please try again.")
                 }
                 }*/
                
                let credential = PhoneAuthProvider.provider().credential(
                    withVerificationID: verificationID!,
                    verificationCode: userPassword!)
                
                Auth.auth().signIn(with: credential) { (authResult, error) in
                    if let error = error {
                        self.userLoginButton.isEnabled = true
                        //self.loginFBSDKLoginButton.isEnabled = true
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        
                        self.displayMyAlertMessage("Error", userMessage: "The login data you entered is incorrect. Please try again.")
                        
                        return
                    }
                    
                    KeychainWrapper.standard.set((authResult?.uid)!, forKey: ApplicationConstants.majeshiUserIDKey)
                    KeychainWrapper.standard.set(ApplicationConstants.majeshiSmallYesValue, forKey: ApplicationConstants.majeshiUserJustLoggedInValue)
                    
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            self.displayMyAlertMessage("Get Code", userMessage: "Please tap the 'Get Code' button to get the verification code before logging in.")
        }
    }
    
    /**
     This resets your password
     
     - Parameters:
     - sender: The password reset button
     
     - Returns: void.
     */
    @IBAction func resetButtonTapped(_ sender: AnyObject) {
        let userEmail = userEmailTextField.text
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        if userEmail!.isEmpty {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            // Empty fields.
            displayMyAlertMessage("Fill mobile number", userMessage: "Please enter mobile number with country code to get verification code.")
        } else {
            /*UIApplication.shared.isNetworkActivityIndicatorVisible = true
            Auth.auth().sendPasswordReset(withEmail: userEmail!) { error in
                if error != nil {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    let errorMessage = error!.localizedDescription
                    self.displayMyAlertMessage("Reset Error", userMessage: errorMessage)
                } else {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.displayMyAlertMessage("Reset email", userMessage: "A reset message has been sent to your email. Please make sure your reset password is 6 characters or longer.")
                }
            }*/
            
            PhoneAuthProvider.provider().verifyPhoneNumber(userEmail!, uiDelegate: nil) { (verificationID, error) in
                if let error = error {
                    //self.showMessagePrompt(error.localizedDescription)
                    print(error.localizedDescription)
                    return
                }
                // Sign in using the verificationID and the code sent to the user
                // ...
                self.verificationID = verificationID
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.displayMyAlertMessage("Code sent", userMessage: "A verification code has been sent to you phone. Enter the verification code and login.")
            }
        }
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
     This disables all the tabs that requier login.
     
     - Parameters:
     - patriarch: The parent tab bar controller
     
     - Returns: void.
     */
    func disableTabsThatReguireLogin(_ patriarch: UITabBarController) {
        let arrayOfTabBarItems = patriarch.tabBar.items as [UITabBarItem]?
        if arrayOfTabBarItems != nil {
            let tabBarItem2 = arrayOfTabBarItems![2]
            tabBarItem2.isEnabled = false
            let tabBarItem3 = arrayOfTabBarItems![3]
            tabBarItem3.isEnabled = false
            let tabBarItem4 = arrayOfTabBarItems![4]
            tabBarItem4.isEnabled = false
        }
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
    
    /// Textfield delegate function
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        userEmailTextField.resignFirstResponder()
        userPasswordTextField.resignFirstResponder()
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*if (segue.identifier == "goToRegisterFromLogin") {
            weak var rvc = segue.destination as? RegisterViewController
            rvc!.dialogParent = self.dialogParent
        }*/
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
     This saves the new user to Majeshi Firebase dBase.
     
     - Parameters:
     - user: The user name
     - uid: The unique ID
     
     - Returns: void.
     */
    func setFireUserName(userName: String, uid: String) {
        let userData = [
            "username": userName,
            "userImg": ApplicationConstants.dbEmptyValue
        ]
        
        let user = Database.database().reference().child("users").child(uid)
        
        user.setValue(userData)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /*func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out of facebook")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            self.userLoginButton.isEnabled = true
            self.loginFBSDKLoginButton.isEnabled = true
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            return
        }
        
        self.userLoginButton.isEnabled = false
        self.loginFBSDKLoginButton.isEnabled = false
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        signIn()
    }
    
    func signIn() {
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (connection, result, err) in
            
            if err != nil {
                print("Failed to start graph request:", err ?? "")
                self.userLoginButton.isEnabled = true
                self.loginFBSDKLoginButton.isEnabled = true
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                return
            } else {
                guard let result = result as? NSDictionary,
                    let email = result["email"] as? String,
                    let name = result["name"] as? String else {
                        return
                }
                
                let accessToken = FBSDKAccessToken.current()
                guard let accessTokenString = accessToken?.tokenString else { return }
                
                let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
                Auth.auth().signIn(with: credentials, completion: { (user, error) in
                    if error != nil {
                        print("Something went wrong with our FB user: ", error ?? "")
                        self.userLoginButton.isEnabled = true
                        self.loginFBSDKLoginButton.isEnabled = true
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        
                        return
                    } else {
                        // Set the Majeshi user ID
                        KeychainWrapper.standard.set((user?.uid)!, forKey: ApplicationConstants.majeshiUserIDKey)
                        
                        // Set recently logged in to true. This will be used to refresh data
                        // on the HomeViewController
                        KeychainWrapper.standard.set(ApplicationConstants.majeshiSmallYesValue, forKey: ApplicationConstants.majeshiUserJustLoggedInValue)
                        
                        let dBase = Firestore.firestore()
                        let userRef = dBase.collection("users").document((user?.uid)!)
                        
                        userRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                                print("User already exists")
                            } else {
                                self.setUserDataFacebook(fullName: name, email: email, uid: (user?.uid)!)
                            }
                        }
                        
                        self.userLoginButton.isEnabled = true
                        self.loginFBSDKLoginButton.isEnabled = true
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        
                        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    }
                    
                    print("Successfully logged in with our user: ", user ?? "")
                })
            }
            print(result ?? "")
        }
    }*/
    
    /**
     This saves the new user to the database.
     
     - Parameters:
     - user: The user name
     - uid: The unique ID
     
     - Returns: void.
     */
    func setUserDataFacebook(fullName: String, email: String, uid: String) {
        /// Create the unix time stamp
        let currentDate = Date()
        let timeStamp = Int(currentDate.timeIntervalSince1970)
        
        let userData: Dictionary<String, AnyObject> = [
            "firstName": ApplicationConstants.dbEmptyValue as AnyObject,
            "lastName": ApplicationConstants.dbEmptyValue as AnyObject,
            "fullName": fullName as AnyObject,
            "email": email as AnyObject,
            "deviceToken": ApplicationConstants.dbEmptyValue as AnyObject,
            "deviceArn": ApplicationConstants.dbEmptyValue as AnyObject,
            "profilePictureFileName": ApplicationConstants.dbEmptyValue as AnyObject,
            "measuringSystem": "imperial" as AnyObject,
            "creationAt": timeStamp  as AnyObject,
            "updatedAt": timeStamp  as AnyObject,
            "status": "Hi there! I'm using PicShip!" as AnyObject
        ]
        
        let dBase = Firestore.firestore()
        
        dBase.collection("users").document(uid).setData(userData) { (error) in
            if let error = error {
                print("\(error.localizedDescription)")
            } else {
                print("Document was successfully created and written.")
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        /*let text = textField.text
        
        textField.text = text*/
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
