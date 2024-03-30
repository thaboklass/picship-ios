//
//  EmailSignupViewController.swift
//  Majeshi
//
//  Created by Thabo David Klass on 31/01/2017.
//  Copyright © 2017 Spreebie, Inc. All rights reserved.
//

import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseFirestore

/// The email signup page class of the Majeshi application
class EmailSignupViewController: UIViewController, UIViewControllerTransitioningDelegate, UITextFieldDelegate, TagListViewDelegate, FPNTextFieldDelegate {
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
          print(name, dialCode, code)
    }
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        if isValid {
            // Do something...
            phoneNumber = textField.getFormattedPhoneNumber(format: .E164)/*,           // Output "+33600000001"
            textField.getFormattedPhoneNumber(format: .International),  // Output "+33 6 00 00 00 01"
            textField.getFormattedPhoneNumber(format: .National),       // Output "06 00 00 00 01"
            textField.getFormattedPhoneNumber(format: .RFC3966),        // Output "tel:+33-6-00-00-00-01"
            textField.getRawPhoneNumber()*/                               // Output "600000001"
        } else {
            // Do something...
        }
    }
    
    
    /// This is the back button
    @IBOutlet weak var backButton: UIButton!
    
    /// This is the next button
    @IBOutlet weak var nextButton: UIButton!
    
    /// This is the sign up progress indicator
    @IBOutlet weak var signupProgressView: UIProgressView!
    
    /// The user email text field
    //@IBOutlet weak var userEmailTextField: UITextField!
    
    @IBOutlet weak var phoneNumberTextField: FPNTextField!
    /// The second page image view
    @IBOutlet weak var secondSignupPageImageView: UIImageView!
    
    /// The Facebook login button
    @IBOutlet weak var loginFBSDKLoginButton: FBSDKLoginButton!
    
    @IBOutlet weak var interestTagList: TagListView!
    
    
    
    /// The page transition
    //let transition = CircularTransition()
    
    var counter:Int = 0 {
        didSet {
            let fractionalProgress = Float(counter) / 100.0
            let animated = counter != 0
            
            signupProgressView.setProgress(fractionalProgress, animated: animated)
        }
    }
    
    // The user's FB email
    var userFBEmail: String? = nil
    
    /// The user's FB first name
    var userFBFirstName: String? = nil
    
    /// The user's FB last name
    var userFBLastName: String? = nil
    
    /// The facebook profile picture
    var facebookProfilePictureImage: UIImage? = nil
    
    // The user's interests
    var interests = [String]()
    
    var phoneNumber: String? = nil
    
    override func viewDidLoad() {
        /// Create a rounder border for the button
        let backButtonLayer: CALayer?  = backButton.layer
        backButtonLayer!.cornerRadius = 4
        backButtonLayer!.masksToBounds = true
        
        let nextButtonLayer: CALayer?  = nextButton.layer
        nextButtonLayer!.cornerRadius = 4
        nextButtonLayer!.masksToBounds = true
        
        var titleString = NSMutableAttributedString()
        let title = " phone number"
        
        titleString = NSMutableAttributedString(string:title, attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir", size: 14)!]) // Font
        titleString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 169.0/255.0, green: 43.0/255.0, blue: 41.0/255.0, alpha: 0.7), range:NSRange(location:0,length:title.characters.count))    // Color
        //userEmailTextField.attributedPlaceholder = titleString
        
        /// So the textfield delegate functions work
        phoneNumberTextField.delegate = self
        
        phoneNumberTextField.keyboardAppearance = .dark
        
        //cpv = CountryPickerView(frame: CGRect(x: 0, y: 140, width: 120, height: 20))
        
        /*cpv!.isUserInteractionEnabled = true
        let countryTap = UITapGestureRecognizer(target: self, action: #selector(openCountryList))
        cpv!.addGestureRecognizer(countryTap)*/
        
        //userEmailTextField.leftView = cpv
        //userEmailTextField.leftViewMode = .always
        //view.addSubview(cpv!)
        
        /// Set the progress of the signup progress indicator
        signupProgressView.setProgress(0, animated: false)
        startCount()
        
        
        /// Configure the read permissions
        //loginFBSDKLoginButton.readPermissions = ["public_profile", "email"]
        
        /// If somehow, through a bizzare event, the user is already
        /// connected via facebook, move the process forward
        /*if (FBSDKAccessToken.current() == nil) {
            print("Not logged in...")
        } else {
            print("Logged in..")
        }*/
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        /// Log an open event on FB Analytics
        FBSDKAppEvents.logEvent("secondSignupOpened")
    }
    
    @objc func openCountryList() {
        //cpv!.showCountriesList(from: self)
    }
    
    /**
     This get the FB data after user taps the FB button
     
     - Parameters:
     - none
     
     - Returns: void.
     */
    func getFBData() {
        /// The parameters of that we want from Facebook
        let parameters = ["fields": "email, first_name, last_name, picture.type(large)"]
        
        /// Create a graph request to get the user details
        let userDetails = FBSDKGraphRequest(graphPath: "me", parameters: parameters)
        
        /// Start the request
        userDetails?.start(completionHandler: { (connection, result, error) -> Void in
            if error != nil {
                print(error)
                return
            }
            
            /// Convert the result to a dictionary
            let data = result as! [String:AnyObject]
            
            /// Get the user email
            if let email = data["email"] as? String {
                print(email)
                self.userFBEmail = email
            }
            
            /// Get the user first name
            if let firstName = data["first_name"] as? String {
                print(firstName)
                self.userFBFirstName = firstName
            }
            
            /// Get the user last name
            if let lastName = data["last_name"] as? String {
                print(lastName)
                self.userFBLastName = lastName
            }
            
            /// Get the profile picture URL - we do not use this at the
            /// present moment
            if let picture = data["picture"] as? NSDictionary, let data = picture["data"] as? NSDictionary, let url = data["url"] as? String {
                print(url)
            }
            
            /// Perform a seque that skips the unnecessary steps
            self.performSegue(withIdentifier: "goToPasswordsFromFBLogin", sender: nil)
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        secondSignupPageImageView = nil
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Textfield delegate function
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "moveNextToThirdFromSecond") {
            weak var fnsvc = segue.destination as? FirstNameSignupViewController
            
            /// Pass the text enter info to the next view controller
            //let userEmail = userEmailTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let phoneNumber = phoneNumberTextField.getFormattedPhoneNumber(format: .E164)
            
            print(phoneNumberTextField.getRawPhoneNumber())
            print(phoneNumberTextField.getFormattedPhoneNumber(format: .E164))
            
            fnsvc?.userEmail = phoneNumber
            fnsvc?.interests = interests
        }
        
        if (segue.identifier == "goToLoginFromProducts") {
            //weak var lvc = segue.destination as? LoginViewController
            //lvc!.dialogParent = self.navigationController!.tabBarController!
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "moveNextToThirdFromSecond" {
            
            /*if phoneNumberTextField.text!.isEmpty {
                // Empty fields.
                displayMyAlertMessage("Missing field", userMessage: "The email field is required.")
                return false
            }*/
            
            if phoneNumber == nil {
                // Empty fields.
                displayMyAlertMessage("Missing field", userMessage: "The phone number field is required.")
                return false
            }
            
            /*if !isValidEmail(testStr: userEmailTextField.text!) {
                // Empty fields.
                displayMyAlertMessage("Invalid email", userMessage: "The email you entered is not valid. Please try again.")
                return false
            }*/
        }
        return true
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
     Displays and alert.
     
     - Parameters:
     - testStr: The email address to be validated
     
     - Returns: Boolean.
     */
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        return result
    }
    
    func startCount() {
        self.counter = 0
        for _ in 0..<25 {
            DispatchQueue.global().async {
                
                sleep(1)
                DispatchQueue.main.async(execute: {
                    self.counter += 1
                    return
                })
            }
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func termsButtonTapped(_ sender: AnyObject) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: ApplicationConstants.majeshiTermsURL)!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(URL(string: ApplicationConstants.majeshiTermsURL)!)
        }
    }
    
    // MARK: TagListViewDelegate
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        tagView.isSelected = !tagView.isSelected
        
        if interests.contains(title) {
            var count = 0
            for interest in interests {
                if interest == title {
                    interests.remove(at: count)
                    break
                }
                
                count += 1
            }
        } else {
            interests.append(title)
        }
    }
}
