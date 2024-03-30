//
//  MessageContactsTableViewController.swift
//  Chapperone
//
//  Created by Thabo David Klass on 31/08/2018.
//  Copyright © 2018 Chapperone. All rights reserved.
//

import UIKit
import MessageUI
import Contacts
import ContactsUI

protocol UserSearchViewControllerDelegate {
    func setUserData(userID: String?, hasMoveForwardAndChanged: Bool)
}

/// The Products page class of the Spreebie application
class UserSearchViewController: UITableViewController, CNContactPickerDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
    /// The current user
    var currentUser = KeychainWrapper.standard.string(forKey: ApplicationConstants.majeshiUserIDKey)
    
    /// The delegate
    //weak var delegate: MessageContactsTableViewControllerDelegate?
    
    /// The protocol that will get triggered on the chats view
    // when the user picks a contact
    var userDataDelegate: UserSearchViewControllerDelegate?
    
    /// The loop count
    var count: Int = 0
    
    /// The second loop count
    var count2: Int = 0
    
    /// The third loop count
    var count3: Int = 0
    
    var count4: Int = 0
    
    /// The max number of comments in the arrays
    var countMax: Int = 1000
    
    /// The search bad controller
    let searchController = UISearchController(searchResultsController: nil)
    
    var mobileNumbers = [String]()
    
    var registeredContacts = [User]()
    
    /// The currency data parsed from the JSON currency file
    //let currencyData =  NSData(contentsOfFile: Bundle.main.path(forResource: "currencies", ofType: "json")!)
    
    /// The currencies as a JSON object
    //var currencies: JSON?
    
    /// The currencies filtered based on what is typed in the search bar
    //var filteredCurrencies = [JSON]()
    
    /// The parent view controller
    weak var cvc: ChatsViewController?
    
    /// The recipient
    var recipient: String!
    
    /// The messageID
    var messageID: String!
    
    /// Is the current user a teacher
    var currentUserIsTeacher = false
    
    /// The participant ID
    var participantIDs = [String]()
    
    /// The participants
    //var participants = [User]()
    
    /// The participants - sorted
    var sortedRegisteredContacts = [User]()
    
    /// The participants filtered based on what is typed in the search bar
    var filteredRegisteredContacts = [User]()
    
    //
    var repientName = ""
    
    var searchedUserName: String? = nil
    
    /// The type of message
    var messageType: String?
    
    /// The email or mobile number...
    var contactIdentifier: String? = nil
    
    /// The recipient's contact name
    var contactName: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let darkGrayish = UIColor(red: 31.0/255.0, green: 33.0/255.0, blue: 36.0/255.0, alpha: 1.0)
        
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.barTintColor = darkGrayish
        
        
        Timer.scheduledTimer(timeInterval: 12, target: self, selector: #selector(self.reloadTable), userInfo: nil, repeats: false)
        
        /// Search bar user interface stuff
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.tintColor = darkGrayish
        
        searchController.searchBar.keyboardAppearance = .dark
        
        if !currentUserIsTeacher {
            print("The user is a teacher")
        }
        
        getSearchedUsers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredRegisteredContacts.count
        }
        return sortedRegisteredContacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageContactsCell", for: indexPath) as! MessageContactsCell
        
        var registeredUser: User
        
        //var data: JSON
        
        if searchController.isActive && searchController.searchBar.text != "" {
            registeredUser = filteredRegisteredContacts[indexPath.row]
        } else {
            registeredUser = sortedRegisteredContacts[indexPath.row]
        }
        
        //let currencyName = data["name"].stringValue
        //let currencySymbol = data["symbol"].stringValue
        
        //cell.textLabel?.text = currencyName
        //cell.detailTextLabel?.text = currencySymbol
        
        cell.contactFullName.text = registeredUser.fullName
        
        if (registeredUser.status != nil && registeredUser.phoneNumber != nil) {
            cell.contactSchool.text = registeredUser.status!
            
            if registeredUser.displayPhoneNumber! {
                cell.contactRole.text = registeredUser.phoneNumber!
            } else {
                cell.contactRole.text = "Number hidden."
            }
        }
        
        cell.cofigureCell(contact: registeredUser)
        
        return cell
    }
    
    func filterContentForSearchText(searchText: String) {
        filteredRegisteredContacts = sortedRegisteredContacts.filter { participant in
            let fullName = participant.fullName as? String
            return fullName!.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("The selected row is: \(indexPath.row)")
        
        let cell = tableView.cellForRow(at: indexPath)

        var registeredContact: User
        
        if searchController.isActive && searchController.searchBar.text != "" {
            registeredContact = filteredRegisteredContacts[indexPath.row]
        } else {
            registeredContact = sortedRegisteredContacts[indexPath.row]
        }
        
        let userID = registeredContact.key!
        
        if userID != currentUser! {
            self.userDataDelegate!.setUserData(userID: userID, hasMoveForwardAndChanged: true)
            
            if searchController.isActive && searchController.searchBar.text != "" {
                self.dismiss(animated: true, completion: nil)
                self.dismiss(animated: true, completion: nil)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func cancelBarButtonItemTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    
    func containsMatch(person: User) -> Bool {
        for matchingUser in registeredContacts {
            if matchingUser.key! == person.key! {
                return true
            }
        }
        
        
        return false
    }
    
    @objc func reloadTable() {
        tableView.reloadData()
    }
    
    func getSearchedUsers() {
        /*self.count = 0
        
        let contactStore = CNContactStore()
        var contacts = [CNContact]()
        let keys = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey
            ] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        do {
            try contactStore.enumerateContacts(with: request){
                (contact, stop) in
                // Array containing all unified contacts from everywhere
                contacts.append(contact)
                for phoneNumber in contact.phoneNumbers {
                    if let number = phoneNumber.value as? CNPhoneNumber, let label = phoneNumber.label {
                        let localizedLabel = CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: label)
                        print("\(contact.givenName) \(contact.familyName) tel:\(localizedLabel) -- \(number.stringValue), email: \(contact.emailAddresses)")
                        
                        var contactNumber = number.stringValue.replacingOccurrences(of: " ", with: "")
                        print("contactNumber: \(contactNumber)")
                        
                        self.mobileNumbers.append(contactNumber)
                    }
                }
                
                /*let phoneString = ((((contact.phoneNumbers[0] as AnyObject).value(forKey: "labelValuePair") as AnyObject).value(forKey: "value") as AnyObject).value(forKey: "stringValue"))
                 
                 let contactNumber = (phoneString! as? String)!
                 print("contactNumber is: \(contactNumber)")
                 
                 self.mobileNumbers.append(contactNumber)*/
            }
            print(contacts)
        } catch {
            print("unable to fetch contacts")
        }
        
        // Get firestore dBase
        let dBase = Firestore.firestore()
        
        for mobileNumber in mobileNumbers {
            print("mobileNumber is: \(mobileNumber)")
            // Get the reference
            let userRef = dBase.collection("userMeta").document(mobileNumber)
            
            userRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let userDict = document.data() {
                        if let userID = userDict["userID"] as? String {
                            print("The userID is: \(userID)")
                            /// Create a user from the dictionary
                            let user = User(key: userID, userData: userDict as Dictionary<String, AnyObject>)
                            
                            if !self.containsMatch(person: user) {
                                self.registeredContacts.append(user)
                            }
                            
                            if self.registeredContacts.count > 1 {
                                self.sortedRegisteredContacts = self.registeredContacts.sorted(by: { $0.fullName! < $1.fullName! })
                            } else {
                                self.sortedRegisteredContacts = self.registeredContacts
                            }
                            //self.people.append(user)
                            
                            /// Increase the count by one
                            //self.count += 1
                            
                            /// If we've looped through all the snapshot records
                            //if self.count == self.mobileNumbers.count {
                            //UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            self.tableView.reloadData()
                            // }
                        }
                    }
                } else {
                    print("Error: \(String(describing: error?.localizedDescription))")
                }
            }
        }*/
        
        if currentUser != nil && searchedUserName != nil {
            print("Inside part 01")
            // Get firestore dBase
            let dBase = Firestore.firestore()
            
            let userRef = dBase.collection("users")
            userRef.whereField("fullName", isGreaterThanOrEqualTo: searchedUserName!).limit(to: 1000).getDocuments { (querySnapshot, error) in
                print("Inside part 02")
                if error == nil {
                    print("Inside part 03")
                    if let queryDocumentSnapshot = querySnapshot?.documents {
                        if queryDocumentSnapshot.count == 0 {
                            //self.chatButton.isEnabled = true
                        }
                        
                        for data in queryDocumentSnapshot {
                            print("Inside part 04")
                            let userID = data.documentID
                            let userDict = data.data()
                            
                            let user = User(key: userID, userData: userDict as Dictionary<String, AnyObject>)
                            
                            if !self.containsMatch(person: user) {
                                print("Inside part 05")
                                self.registeredContacts.append(user)
                            }
                            
                            if self.registeredContacts.count > 1 {
                                self.sortedRegisteredContacts = self.registeredContacts.sorted(by: { $0.fullName! < $1.fullName! })
                            } else {
                                self.sortedRegisteredContacts = self.registeredContacts
                            }
                        }
                        
                        self.tableView.reloadData()
                    } else {
                        // Do nothing
                    }
                } else {
                    // Do nothing
                }
            }
        }
    }
    
    /**
     This picks a contact and set the nature of the message
     
     - Parameters:
     - sender: The sender view
     
     - Returns: void.
     */
    func pickContact() {
        let alert = UIAlertController(title: "Invite a friend", message: "Choose a messaging type through which you will send your friend an invite.", preferredStyle: UIAlertController.Style.alert)
        
        alert.view.tintColor = UIColor(red: 248.0/255.0, green: 119.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        
        alert.addAction(UIAlertAction(title: "WhatsApp", style: UIAlertAction.Style.default, handler: { (alert) -> Void in
            let kascadeInviteMessage = "Check out the amazing app PicShip that helps you manage relationships, events and tasks through videos and pictures: \(ApplicationConstants.majeshiLandingPageURL)"
            self.sendWhatsAppText(text: kascadeInviteMessage)
        }))
        
        /// SMS contact
        alert.addAction(UIAlertAction(title: "SMS", style: UIAlertAction.Style.default, handler: { (alert) -> Void in
            self.messageType = "SMS"
            
            let entityType = CNEntityType.contacts
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
                self.displayMyAlertMessageOnTroublesomePage("Previously denied", userMessage: "Access to contacts was denied. You can change this in your phone's settings.")
            }
        }))
        
        // Email contact
        alert.addAction(UIAlertAction(title: "Email", style: UIAlertAction.Style.default, handler: { (alert) -> Void in
            self.messageType = "Email"
            
            let entityType = CNEntityType.contacts
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
                self.displayMyAlertMessageOnTroublesomePage("Previously denied", userMessage: "Access to contacts was denied. You can change this in your phone's settings.")
            }
        }))
        
        /// Cancel the action
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { (alert) -> Void in
            //self.createSpreebieBarButtonItem.isEnabled = true
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func sendWhatsAppText(text: String) {
        let escapedText = text.addingPercentEncoding(withAllowedCharacters:CharacterSet.urlQueryAllowed)
        
        let url  = URL(string: "whatsapp://send?text=\(escapedText!)")
        
        if UIApplication.shared.canOpenURL(url! as URL) {
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
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
        
        contactName = "\(contact.givenName) \(contact.familyName)"
        
        /// Assign the picked contact to an attribute
        //self.pickContactButton.setTitle(contact.givenName, for: UIControlState())
        
        /// Assign the contactIdentifier
        if let type = messageType {
            if type == "SMS" {
                if !contact.phoneNumbers.isEmpty {
                    let phoneString = ((((contact.phoneNumbers[0] as AnyObject).value(forKey: "labelValuePair") as AnyObject).value(forKey: "value") as AnyObject).value(forKey: "stringValue"))
                    
                    contactIdentifier = phoneString! as? String
                    
                    if contactIdentifier == nil {
                        
                    } else {
                        Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.sendText), userInfo: nil, repeats: false)
                    }
                } else {
                    self.displayMyAlertMessageOnTroublesomePage("Contact number missing", userMessage: "The contact you selected has no number.")
                }
            } else if type == "Email" {
                if !contact.emailAddresses.isEmpty {
                    let emailString = (((contact.emailAddresses[0] as AnyObject).value(forKey: "labelValuePair") as AnyObject).value(forKey: "value"))
                    
                    contactIdentifier = emailString! as? String
                    
                    if contactIdentifier == nil {
                        
                    } else {
                        Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.sendEmail), userInfo: nil, repeats: false)
                    }
                } else {
                    self.displayMyAlertMessageOnTroublesomePage("Contact email missing", userMessage: "The contact you selected has no email.")
                }
            }
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func sendText() {
        let kascadeInviteMessage = "Check out the amazing app PicShip that helps you manage relationships, events and tasks through videos and pictures: \(ApplicationConstants.majeshiLandingPageURL)"
        
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = kascadeInviteMessage
            controller.recipients = [contactIdentifier!]
            controller.messageComposeDelegate = self
            
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    /**
     Constructs the TellPal email.
     
     - Parameters:
     - none
     
     - Returns: MFMailComposeViewController.
     */
    func configuredMailComposeViewController(recipientName: String, recipient: String, title: String, message: String, hasImage: Bool, fileName: String?, imageData: NSData?) -> MFMailComposeViewController {
        let mailComposeViewController = MFMailComposeViewController()
        mailComposeViewController.mailComposeDelegate = self
        
        mailComposeViewController.setToRecipients([recipient])
        mailComposeViewController.setSubject(title)
        mailComposeViewController.setMessageBody(message, isHTML: false)
        if hasImage {
            mailComposeViewController.addAttachmentData(imageData! as Data, mimeType: "image/jpeg", fileName: fileName!)
        }
        
        return mailComposeViewController
    }
    
    /**
     An delegate method that listens for email events.
     
     - Parameters:
     - controller: MFMailComposeViewController
     - result: The email result
     - error: The error if any
     
     - Returns: void.
     */
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        /// handle email actions
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func sendEmail() {
        let kascadeInviteMessage = "Check out the amazing app PicShip that helps you manage relationships, events and tasks through videos and pictures: \(ApplicationConstants.majeshiLandingPageURL)"
        
        let mailComposeViewController = self.configuredMailComposeViewController(recipientName: contactName!, recipient: contactIdentifier!, title: "Check out PicShip!", message: kascadeInviteMessage, hasImage: false, fileName: nil, imageData: nil)
        
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.displayMyAlertMessageOnTroublesomePage("Could not send email", userMessage: "Your device could not send email. Please check your email setup and try again.")
        }
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
     Displays and alert.
     
     - Parameters:
     - title: The title text
     - userMessage: The message text
     
     - Returns: void.
     */
    func displayMyAlertMessageOnTroublesomePage(_ title: String, userMessage: String) {
        let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertController.Style.alert)
        
        myAlert.view.tintColor = UIColor(red: 248.0/255.0, green: 119.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        myAlert.addAction(okAction)
        
        /// This whole section was done because doing it normally wasn't working
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.windowLevel = UIWindow.Level.alert
        alertWindow.rootViewController = UIViewController()
        alertWindow.makeKeyAndVisible()
        
        alertWindow.rootViewController?.present(myAlert, animated: true, completion: nil)
    }
    
    @IBAction func inviteBarButtonItemTapped(_ sender: Any) {
        pickContact()
    }
}

extension UserSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
