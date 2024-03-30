//
//  FourthSignupPageViewController.swift
//  Majeshi
//
//  Created by Thabo David Klass on 31/01/2017.
//  Copyright © 2017 Spreebie, Inc. All rights reserved.
//

/// The fourth signup page class of the Majeshi application
class LastNameSignupViewController: UIViewController, UIViewControllerTransitioningDelegate, UITextFieldDelegate {
    /// This is the sign up button
    @IBOutlet weak var backButton: UIButton!
    
    /// This is the next button
    @IBOutlet weak var nextButton: UIButton!
    
    /// This is the sign up progress indicator
    @IBOutlet weak var signupProgressView: UIProgressView!
    
    /// The user last name text field
    @IBOutlet weak var lastNameUserTextField: UITextField!
    
    /// Fourth page image view
    @IBOutlet weak var fourthSignupPageImageView: UIImageView!
    
    /// The user's email
    var userEmail: String? = String()
    
    /// The user's first name
    var userFirstName: String? = String()
    
    /// The page transition
    //let transition = CircularTransition()
    
    // The user's interests
    var interests = [String]()
    
    var counter:Int = 0 {
        didSet {
            let fractionalProgress = Float(counter) / 100.0
            let animated = counter != 0
            
            signupProgressView.setProgress(fractionalProgress, animated: animated)
        }
    }
    
    override func viewDidLoad() {
        // nothing yet
        
        /// Create a rounder border for the button
        let backButtonLayer: CALayer?  = backButton.layer
        backButtonLayer!.cornerRadius = 4
        backButtonLayer!.masksToBounds = true
        
        let nextButtonLayer: CALayer?  = nextButton.layer
        nextButtonLayer!.cornerRadius = 4
        nextButtonLayer!.masksToBounds = true
        
        var titleString = NSMutableAttributedString()
        let title = "last name"
        
        titleString = NSMutableAttributedString(string:title, attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir", size: 14)!]) // Font
        titleString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 169.0/255.0, green: 43.0/255.0, blue: 41.0/255.0, alpha: 0.7), range:NSRange(location:0,length:title.characters.count))    // Color
        //lastNameUserTextField.attributedPlaceholder = titleString
        
        /// So the textfield delegate functions work
        lastNameUserTextField.delegate = self
        
        lastNameUserTextField.keyboardAppearance = .dark
        
        /// Set the progress of the signup progress indicator
        signupProgressView.setProgress(0.4, animated: false)
        startCount()
        
        /// Log an open event on FB Analytics
        //FBSDKAppEvents.logEvent("fourthSignupOpened")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        fourthSignupPageImageView = nil
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "moveNextToLastFromFourth") {
            weak var psvc = segue.destination as? PasswordSignupViewController
            
            /// Pass the text enter info to the next view controller
            psvc?.userEmail = userEmail
            psvc?.userFirstName = userFirstName
            
            let userLastName = lastNameUserTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            psvc?.userLastName = userLastName
            psvc?.interests = interests
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "moveNextToLastFromFourth" {
            
            if lastNameUserTextField.text!.isEmpty {
                // Empty fields.
                displayMyAlertMessage("Missing field", userMessage: "The last name field is required.")
                return false
            }
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
    
    /// Textfield delegate function
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func startCount() {
        self.counter = 50
        for _ in 50..<75 {
            DispatchQueue.global().async {
                
                sleep(1)
                DispatchQueue.main.async(execute: {
                    self.counter += 1
                    return
                })
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
