//
//  MessageContactsTableViewController.swift
//  Chapperone
//
//  Created by Thabo David Klass on 31/08/2018.
//  Copyright © 2018 Chapperone. All rights reserved.
//

import UIKit
import Contacts

protocol MessageContactsTableViewControllerDelegate {
    func setMessageData(messageID: String?, recipientID: String?, recipientName: String?, hasMoveForwardAndChanged: Bool)
}

/// The Products page class of the Spreebie application
class MessageContactsTableViewController: UITableViewController {
    /// The current user
    var currentUser = KeychainWrapper.standard.string(forKey: ApplicationConstants.majeshiUserIDKey)
    
    /// The delegate
    //weak var delegate: MessageContactsTableViewControllerDelegate?
    
    /// The protocol that will get triggered on the chats view
    // when the user picks a contact
    var messageDataDelegate: MessageContactsTableViewControllerDelegate?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Timer.scheduledTimer(timeInterval: 12, target: self, selector: #selector(self.reloadTable), userInfo: nil, repeats: false)
        
        let darkGrayish = UIColor(red: 31.0/255.0, green: 33.0/255.0, blue: 36.0/255.0, alpha: 1.0)
        
        /// Sets the navigation graphic primitives to a light blue color
        //let lightBlue = UIColor(red: 0.0/255.0, green: 162.0/255.0, blue: 227.0/255.0, alpha: 1.0)
        //self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: lightBlue]
        
        /// The the actual JSON parsing
        /*do {
            currencies = try JSON(data: currencyData! as Data)
        } catch {
            
        }*/
        
        /// Search bar user interface stuff
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.tintColor = darkGrayish
        
        searchController.searchBar.keyboardAppearance = .dark
        
        /// Get the participants
        //getPartipantsInMyTrips()
        //getOtherParicipantsInTripsIParticipateIn()
        //getPartipantsInTripsIChaperone()
        
        if !currentUserIsTeacher {
            print("The user is a teacher")
        }
        
        getPhoneContacts()
        
        /// Log the open event on FB Analytics
        //FBSDKAppEvents.logEvent("currencyListOpened")
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
            cell.contactRole.text = registeredUser.phoneNumber!
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
        /*sstvc!.currencyButton.setTitle("Currency - \(String(describing: cell!.textLabel!.text!)) (\(String(describing: cell!.detailTextLabel!.text!)))", for: UIControlState())*/
        
        //var data: JSON
        var registeredContact: User
        
        if searchController.isActive && searchController.searchBar.text != "" {
            registeredContact = filteredRegisteredContacts[indexPath.row]
        } else {
            registeredContact = sortedRegisteredContacts[indexPath.row]
        }
        
        repientName = registeredContact.fullName!
        recipient = registeredContact.key!
        messageID = nil
            
            if recipient != currentUser! {
                /*Database.database().reference().child("user").child(currentUser!).child("messages").observeSingleEvent(of: .value, with: { snapshotAtLevelOne in
                    if let snapshotAtLevelOne = snapshotAtLevelOne.children.allObjects as? [DataSnapshot] {
                        var userWithExistingConversationFound = false
                        
                        for currentUserData in snapshotAtLevelOne.reversed() {
                            let data = currentUserData.value as? Dictionary<String, AnyObject>
                            
                            if let recipientID = data!["recipient"] as? String {
                                if recipientID == self.recipient {
                                    userWithExistingConversationFound = true
                                    
                                    //print("The recipientiD is: \(recipientID)")
                                    //print("The currentUser is: \(self.currentUser!)")
                                    
                                    self.messageID = currentUserData.key
                                    /*if self.currentUser! == self.trip!.tripLeaderUserID! {
                                        self.performSegue(withIdentifier: "OpenMessageFromTripDetail", sender: nil)
                                    } else if (self.currentUserIsTeacher && recipientID != self.currentUser! ) {
                                        self.performSegue(withIdentifier: "OpenMessageFromTripDetail", sender: nil)
                                    } else {
                                        if recipientID == self.trip!.tripLeaderUserID! {
                                            self.performSegue(withIdentifier: "OpenMessageFromTripDetail", sender: nil)
                                        }
                                    }*/
                                    
                                    /*self.cvc?.messageID = self.messageID
                                    self.cvc?.recipient = self.recipient
                                    self.cvc?.movedForwardAndSelectedContact = true*/
                                    
                                    self.messageDataDelegate!.setMessageData(messageID: self.messageID, recipientID: self.recipient, recipientName: self.repientName, hasMoveForwardAndChanged: true)
                                    
                                    break
                                }
                            }
                        }
                        
                        if !userWithExistingConversationFound {
                            /*if self.currentUser! == self.trip!.tripLeaderUserID! {
                                self.performSegue(withIdentifier: "OpenMessageFromTripDetail", sender: nil)
                            } else if (self.currentUserIsTeacher && userID != self.currentUser! ) {
                                self.performSegue(withIdentifier: "OpenMessageFromTripDetail", sender: nil)
                            } else {
                                if userID == self.trip!.tripLeaderUserID! {
                                    self.performSegue(withIdentifier: "OpenMessageFromTripDetail", sender: nil)
                                }
                            }*/
                            
                            /*self.cvc?.messageID = self.messageID
                            self.cvc?.recipient = self.recipient
                            self.cvc?.movedForwardAndSelectedContact = true*/
                            
                            self.messageDataDelegate!.setMessageData(messageID: self.messageID, recipientID: self.recipient, recipientName: self.repientName, hasMoveForwardAndChanged: true)
                        }
                        
                        self.dismiss(animated: true, completion: nil)
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        self.dismiss(animated: true, completion: nil)
                        self.dismiss(animated: true, completion: nil)
                    }
                })*/
                
                let dBase = Firestore.firestore()
                
                dBase.collection("users").document(currentUser!).collection("messages").addSnapshotListener { (querySnapshot, error) in
                    if error == nil {
                        if let queryDocumentSnapshot = querySnapshot?.documents {
                            var userWithExistingConversationFound = false
                            
                            /// Clear the message detail array
                            //self.messageDetail.removeAll()
                            //self.sortedMessageDetail.removeAll()
                            
                            for data in queryDocumentSnapshot {
                                let key = data.documentID
                                
                                let messageDict = data.data()
                                
                                if let recipientID = messageDict["recipient"] as? String {
                                    if recipientID == self.recipient {
                                        userWithExistingConversationFound = true
                                        
                                        self.messageID = key
                                        
                                        if self.messageDataDelegate != nil {
                                            self.messageDataDelegate!.setMessageData(messageID: self.messageID, recipientID: self.recipient, recipientName: self.repientName, hasMoveForwardAndChanged: true)
                                            self.messageDataDelegate = nil
                                        }
                                        
                                        print("Found Someone!")
                                        
                                        break
                                    }
                                }
                            }
                            
                            if !userWithExistingConversationFound {
                                if self.messageDataDelegate != nil {
                                    self.messageDataDelegate!.setMessageData(messageID: self.messageID, recipientID: self.recipient, recipientName: self.repientName, hasMoveForwardAndChanged: true)
                                    self.messageDataDelegate = nil
                                }
                            }
                            
                            self.dismiss(animated: true, completion: nil)
                            self.dismiss(animated: true, completion: nil)
                        }  else {
                            self.dismiss(animated: true, completion: nil)
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
            //performSegue(withIdentifier: "OpenMessageFromTripDetail", sender: nil)
        
        //sstvc!.currencyCode = data["cc"].stringValue
        
        //self.dismiss(animated: true, completion: nil)
        //self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelBarButtonItemTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    

    /**
     Populate the contacts
     
     - Parameters:
     - none
     
     - Returns: void.
     */
    /*func getContacts() {
        print(participantIDs)
        for participantID in participantIDs {
            
            count3 = 0
            
            /// Get the user reference
            let userRef = Database.database().reference().child("user").child(participantID)
            
            /// Get the snapshot
            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                /// Make the snapshot value into a dictionary
                let userDict = snapshot.value as? Dictionary<String, AnyObject>
                
                /// Check for nil
                if userDict != nil {
                    /// Get the data key
                    let key = snapshot.key
                    /// Create a trip from the dictionary
                    let user = User(key: key, userData: userDict!)
                    
                    if let school = userDict!["school"] as? String {
                        //user.school = school
                    }
                    
                    if let role = userDict!["role"] as? String {
                        //user.role = role
                    }
                    
                    if !self.containsMatch(person: user) && participantID != self.currentUser! {
                        self.participants.append(user)
                    }
                }
                
                self.count3 += 1
                //print(self.count3)
                //print(participantID)
                
                /// If we've looped through all the snapshot records
                //if self.count3 == self.participantIDs.count {
                    if self.participants.count > 1 {
                        self.sortedParticipants = self.participants.sorted(by: { $0.fullName! < $1.fullName! })
                    } else {
                        self.sortedParticipants = self.participants
                    }
                    
                    self.tableView.reloadData()
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                //}
            })
        }
    }*/
    
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
    
    func getPhoneContacts() {
        self.count = 0
        
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
        }
    }
}

extension MessageContactsTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
