//
//  CommentsViewController.swift
//  Kascada
//
//  Created by Thabo David Klass on 14/11/2017.
//  Copyright © 2017 Open Beacon. All rights reserved.
//

import UIKit
//import AWSS3
//import AWSSNS

/// The CommentsViewController class
class CommentsViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    /// This button takes the user back to the streamer
    @IBOutlet weak var streamerButton: UIButton!
    
    /// This reloads the comments
    @IBOutlet weak var reloadButton: UIButton!
    
    /// This is the number of views label
    @IBOutlet weak var viewsLabel: UILabel!
    
    /// This is the number of likes label
    @IBOutlet weak var likesLabel: UILabel!
    
    /// This the commnets table view - holds all the comments
    @IBOutlet weak var commentsTableView: UITableView!
    
    /// The comment text field
    @IBOutlet weak var commentTextField: UITextField!
    
    /// The post comment button
    @IBOutlet weak var postCommentButton: UIButton!
    
    /// The kascade key/id
    var shipPicID: String?
    
    /// The kascade caption
    var shipPicCaption: String?
    
    /// The kascade's creator
    var picShipUser: String?
    
    /// The kascade creator's ARN
    //var kascadeUserArn: String?
    
    /// The current logged in user
    var currentUser: String? = KeychainWrapper.standard.string(forKey: ApplicationConstants.majeshiUserIDKey)
    
    /// This is a boolean that holds whether the kascade has comments or not
    var kascadeHasComments = false
    
    /// The array of comments
    var comments = [Comment]()
    
    /// The array of sorted kascades
    var sortedComments = [Comment]()
    
    /// The max number of comments that will be retrieved
    var countMax: Int = 1000

    override func viewDidLoad() {
        super.viewDidLoad()
        /// Restore dimming feature
        UIApplication.shared.isIdleTimerDisabled = false

        // Do any additional setup after loading the view.
        /// Keyboard stuff
        
        /// The text field delegate
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        /// Set the textfield delegate
        commentTextField.delegate = self
        
        commentTextField.keyboardAppearance = .dark
        
        /// Create a rounder border for the button
        let postCommentButtonLayer: CALayer?  = postCommentButton.layer
        postCommentButtonLayer!.cornerRadius = 4
        postCommentButtonLayer!.masksToBounds = true
        
        /// Keyboard stuff
        /*NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)*/
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        /// Set the like, views and comment data
        setKascadeLikesAndViews()
        getComments()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedComments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCell(withIdentifier: "Comment", for: indexPath) as! CommentTableViewCell
        
        /// Get the comment
        let comment = sortedComments[indexPath.row]
        
        /// Set the comment text
        myCell.comment.text = comment.comment
        
        /// Set the timestamp
        let unixTimestamp = comment.creationAt
        let date = Date(timeIntervalSince1970: TimeInterval(unixTimestamp!))
        
        let formatter = DateFormatter()
        
        /// Initially set the format based on your datepicker date
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myString = formatter.string(from: date as Date)
        
        /// Convert your string to date
        let yourDate = formatter.date(from: myString)
        
        /// Then again set the date format which type of output you need
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        /// Again convert your date to string
        let myStringafd = formatter.string(from: yourDate!)
        
        myCell.timeStamp.text = "\(myStringafd)"
        let labelLayer: CALayer?  = myCell.timeStamp.layer
        labelLayer!.cornerRadius = 6
        labelLayer!.masksToBounds = true
        
        /// Set the user name
        myCell.userName.text = comment.userFullName!
        
        /// Set up the paths
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
        let documentDirectoryURL = URL(fileURLWithPath: documentDirectory)

        /// Insert the user profile picture
        if comment.userProfilePictureFileName != "empty" {
            let fileName = "s-" + comment.userProfilePictureFileName!
            let downloadSmallFileURL = documentDirectoryURL.appendingPathComponent(fileName)
            
            if FileManager.default.fileExists(atPath: downloadSmallFileURL.path) {
                self.insertProfilePic(myCell, fileName: fileName, downloadFileURL: downloadSmallFileURL)
            } else {
                //self.downloadProfilePic(myCell, fileName: fileName, downloadFileURL: downloadSmallFileURL)
                self.setProfilePic(cell: myCell, posterProfilePictureFileName: comment.userProfilePictureFileName)
            }
        }

        
        return myCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        let comment = sortedComments[indexPath.row]
        
        if currentUser != nil {
            /// Enable deletion if the comment is owned by the current users
            if comment.user! == currentUser! {
                return .delete
            }
        }
        
        return .none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            /// Assign the comment to be deleted
            let commentToDelete = sortedComments[indexPath.row]
            
            if shipPicID != nil {
                /// Delete it from the dbase
                Database.database().reference().child("comment").child(shipPicID!).child(commentToDelete.key!).removeValue()
                
                /// Remove the comment from the comments array
                for (commentIndex, comment) in comments.enumerated() {
                    if comment.key! == commentToDelete.key! {
                        comments.remove(at: commentIndex)
                        break
                    }
                }
                
                /// Remove the comment from the sorted comments array
                for (sortedCommentIndex, sortedComment) in sortedComments.enumerated() {
                    if sortedComment.key! == commentToDelete.key! {
                        sortedComments.remove(at: sortedCommentIndex)
                        break
                    }
                }
                
                /// Delete the row in the table view in an animated way
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            }
        }
    }
    
    @IBAction func returnToStreamer(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    //// Keyboard stuff
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
    
    @IBAction func postCommentButtonTapped(_ sender: Any) {
        /// Keyboard stuff
        dismissKeyboard()
        
        /// Populate comment dbase
        let commentText: String? = commentTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if commentText != nil {
            if commentText! != "" {
                createComment(commentText: commentTextField.text!)
        
                /// Clear text
                commentTextField.text = ""
            }
        }
    }
    
    /**
     This save the comment in the database
     
     - Parameters:
     - commentTex: the text to be saved in the database
     
     - Returns: void.
     */
    func createComment(commentText: String) {
        /// Only run this if the current user is not nil
        if currentUser != nil {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            let currentDate = Date()
            let timeStamp = Int(currentDate.timeIntervalSince1970)
            
            /// Create the comment data
            let commentData: Dictionary<String, AnyObject> = [
                "user": currentUser! as AnyObject,
                "createdAt": timeStamp  as AnyObject,
                "updatedAt": timeStamp  as AnyObject,
                "commentText": commentText as AnyObject
            ]
            
            if shipPicID != nil {
                let dBase = Firestore.firestore()
                
                let commentRef = dBase.collection("comment").document(self.shipPicID!)
                commentRef.collection("comments").addDocument(data: commentData) {  (error) in
                    if let error = error {
                        print("\(error.localizedDescription)")
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        
                        self.displayMajeshiGenericAlert("Error", userMessage: "There was an error posting your comment. Please try again.")
                    } else {
                        /// Remove all the comments from the arrays
                        self.comments.removeAll()
                        self.sortedComments.removeAll()
                        
                        /// Reload the comments
                        self.getComments()
                        
                        /// Send a notification for the first comment
                        if !self.kascadeHasComments {
                            /// Check that neither of the values is nil
                            if (self.picShipUser != nil) && (self.currentUser != nil) {
                                /// Make sure the creator and the current user are not the same
                                /// person
                                if self.picShipUser! != self.currentUser! {
                                    /*if self.kascadeUserArn != nil {
                                     /// If the arn is not empty, send the notification
                                     if self.kascadeUserArn! != "empty" {
                                     //self.sendFirstCommentNotification()
                                     }
                                     }*/
                                }
                            }
                        }
                    }
                }
                
                /// Get a database reference for the new comment
                /*let comment = Database.database().reference().child("comment").child(shipPicID!).childByAutoId()
                
                /// Save the comment to the dbase
                comment.setValue(commentData, withCompletionBlock: { (error, ref) in
                    if error == nil {
                        /// Remove all the comments from the arrays
                        self.comments.removeAll()
                        self.sortedComments.removeAll()
                        
                        /// Reload the comments
                        self.getComments()
                        
                        /// Send a notification for the first comment
                        if !self.kascadeHasComments {
                            /// Check that neither of the values is nil
                            if (self.picShipUser != nil) && (self.currentUser != nil) {
                                /// Make sure the creator and the current user are not the same
                                /// person
                                if self.picShipUser! != self.currentUser! {
                                    /*if self.kascadeUserArn != nil {
                                        /// If the arn is not empty, send the notification
                                        if self.kascadeUserArn! != "empty" {
                                            //self.sendFirstCommentNotification()
                                        }
                                    }*/
                                }
                            }
                        }
                    } else {
                        print(error?.localizedDescription)
                    }
                })*/
            }
        }
    }
    
    /**
     Get the comments from the dbase and put them in the table view
     
     - Parameters:
     - none
     
     - Returns: void.
     */
    func getComments() {
        /// If the kascade key is not nil
        if shipPicID != nil {
            let dBase = Firestore.firestore()
            
            let commentRef = dBase.collection("comment").document(shipPicID!).collection("comments")
            
            commentRef.getDocuments { (querySnapshot, error) in
                if error == nil {
                    if let queryDocumentSnapshot = querySnapshot?.documents {
                        if queryDocumentSnapshot.count == 0 {
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        } else {
                            /// The kascade has comments
                            self.kascadeHasComments = true
                        }
                        
                        /// Loop through the snapshot
                        for data in queryDocumentSnapshot.reversed() {
                            if let commentDict =  data.data() as? Dictionary<String, AnyObject> {
                                /// Get the data key
                                let key = data.documentID
                                /// Create a kascade from the dictionary
                                let comment = Comment(key: key, commentData: commentDict)
                                
                                let userRef = dBase.collection("users").document(comment.user!)
                                
                                userRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        if let userDict = document.data() {
                                            /// Check for nil again
                                            if let fullName = userDict["fullName"] as? String, let email = userDict["phoneNumber"] as? String, let profilePictureFileName = userDict["profilePictureFileName"] as? String {
                                                
                                                /// Set the full name and profile picture file name
                                                comment.userFullName = fullName
                                                comment.userProfilePictureFileName = profilePictureFileName
                                                
                                                /// Store this in the kascades array
                                                self.comments.append(comment)
                                                
                                                /// If all the comments have been appended, populate the table
                                                if self.comments.count == queryDocumentSnapshot.count {
                                                    if self.comments.count > 1 {
                                                        self.sortedComments = self.comments.sorted(by: { $0.creationAt! < $1.creationAt! })
                                                    } else {
                                                        self.sortedComments = self.comments
                                                    }
                                                    
                                                    self.commentsTableView.reloadData()
                                                    self.animateTable()
                                                    /// Scroll to the last message after the loading is done
                                                    self.scrollToBottom(animated: true)
                                                    
                                                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                /// Get the user referesnce
                                /*let userRef = Database.database().reference().child("user").child(comment.user!)
                                
                                userRef.observeSingleEvent(of: .value, with: { (localSnapshot) in
                                    let userDict = localSnapshot.value as? Dictionary<String, AnyObject>
                                    
                                    if userDict != nil {
                                        /// Make sure all the data exists
                                        if let fullName = userDict!["fullName"] as? String, let profilePictureFileName = userDict!["profilePictureFileName"] as? String {
                                            
                                            /// Set the full name and profile picture file name
                                            comment.userFullName = fullName
                                            comment.userProfilePictureFileName = profilePictureFileName
                                            
                                            /// Store this in the kascades array
                                            self.comments.append(comment)
                                            
                                            /// If all the comments have been appended, populate the table
                                            if self.comments.count == snapshot.count {
                                                if self.comments.count > 1 {
                                                    self.sortedComments = self.comments.sorted(by: { $0.creationAt! < $1.creationAt! })
                                                } else {
                                                    self.sortedComments = self.comments
                                                }
                                                
                                                self.commentsTableView.reloadData()
                                                self.animateTable()
                                                /// Scroll to the last message after the loading is done
                                                self.scrollToBottom(animated: true)
                                                
                                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                            }
                                        }
                                    }
                                })*/
                            }
                        }
                    }
                }
            }
            
            /// Get comments for this kascade limited to the latest 1000
            /*Database.database().reference().child("comment").child(shipPicID!).queryLimited(toLast: UInt(countMax)).observeSingleEvent(of: .value, with: { (snapshot) in
                
                /// Get the children of the snapshot as a data snapshot
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    if snapshot.count == 0 {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    } else {
                        /// The kascade has comments
                        self.kascadeHasComments = true
                    }
                    
                    /// Loop through the snapshot
                    for data in snapshot.reversed() {
                        if let commentDict = data.value as? Dictionary<String, AnyObject> {
                            /// Get the data key
                            let key = data.key
                            /// Create a kascade from the dictionary
                            let comment = Comment(key: key, commentData: commentDict)
                            
                            /// Get the user referesnce
                            let userRef = Database.database().reference().child("user").child(comment.user!)
                            
                            userRef.observeSingleEvent(of: .value, with: { (localSnapshot) in
                                let userDict = localSnapshot.value as? Dictionary<String, AnyObject>
                                
                                if userDict != nil {
                                    /// Make sure all the data exists
                                    if let fullName = userDict!["fullName"] as? String, let profilePictureFileName = userDict!["profilePictureFileName"] as? String {
                                        
                                        /// Set the full name and profile picture file name
                                        comment.userFullName = fullName
                                        comment.userProfilePictureFileName = profilePictureFileName
                                        
                                        /// Store this in the kascades array
                                        self.comments.append(comment)
                                        
                                        /// If all the comments have been appended, populate the table
                                        if self.comments.count == snapshot.count {
                                            if self.comments.count > 1 {
                                                self.sortedComments = self.comments.sorted(by: { $0.creationAt! < $1.creationAt! })
                                            } else {
                                                self.sortedComments = self.comments
                                            }
                                            
                                            self.commentsTableView.reloadData()
                                            self.animateTable()
                                            /// Scroll to the last message after the loading is done
                                            self.scrollToBottom(animated: true)
                                            
                                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                        }
                                    }
                                }
                            })
                        }
                    }
                }
            })*/
        }
    }
    
    /**
     Animates the table view.
     
     - Parameters:
     - none
     
     - Returns: void.
     */
    func animateTable() {
        commentsTableView.reloadData()
        
        let cells = commentsTableView.visibleCells
        let tableHeight: CGFloat = commentsTableView.bounds.size.height
        
        for i in cells {
            let cell: UITableViewCell = i as UITableViewCell
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
        
        var index = 0
        
        for m in cells {
            let cell: UITableViewCell = m as UITableViewCell
            UIView.animate(withDuration: 0.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
            index += 1
        }
    }
    
    /**
     Downloads the profile pic from S3, stores it locally and inserts it into the cell.
     
     - Parameters:
     - cell: The Notifications view cell
     - fileName: The name of the file as it is store on S3
     - downloadULR: The local storage url
     
     - Returns: void.
     */
    /*func downloadProfilePic(_ cell: CommentTableViewCell, fileName: String, downloadFileURL: URL) {
        /// The name of our profile pic bucket
        let s3BucketName = "kascadauserprofilepics"
        
        /// Create the request
        let downloadRequest = AWSS3TransferManagerDownloadRequest()
        downloadRequest?.bucket = s3BucketName
        downloadRequest?.key  = fileName
        downloadRequest?.downloadingFileURL = downloadFileURL
        
        /// Create a transfer manager and make the actual request
        let transferManager = AWSS3TransferManager.default()
        transferManager.download(downloadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
            if let error = task.error {
                print("Download error")
            } else {
                DispatchQueue.main.async(execute: { () -> Void in
                    cell.profilePicture.alpha = 0
                    let imageLayer: CALayer?  = cell.profilePicture.layer
                    imageLayer!.cornerRadius = cell.profilePicture.frame.height / 2
                    //imageLayer!.cornerRadius = 6
                    imageLayer!.masksToBounds = true
                    
                    /// On success, insert the image
                    let image = UIImage(named: downloadFileURL.path)
                    cell.profilePicture.image = image
                    UIView.animate(withDuration: 0.5, animations: { () -> Void in
                        cell.profilePicture.alpha = 1
                    })
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                })
            }
            return nil
        })
    }*/
    
    /**
     Retrives the profile pic locally and inserts it into the cell.
     
     - Parameters:
     - cell: The Notifications view cell
     - fileName: The name of the file as it is stored locally
     - downloadULR: The local storage url
     
     - Returns: void.
     */
    func insertProfilePic(_ cell: CommentTableViewCell, fileName: String, downloadFileURL: URL) {
        DispatchQueue.main.async(execute: { () -> Void in
            if UIImage(named: downloadFileURL.path) != nil {
                cell.profilePicture.alpha = 0
                let imageLayer: CALayer?  = cell.profilePicture.layer
                imageLayer!.cornerRadius = cell.profilePicture.frame.height / 2
                //imageLayer!.cornerRadius = 6
                imageLayer!.masksToBounds = true
                
                /// On success, insert the image
                let image = UIImage(named: downloadFileURL.path)
                cell.profilePicture.image = image
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    cell.profilePicture.alpha = 1
                })
            }
        })
    }
    
    func scrollToBottom(animated: Bool) {
        /// Scroll to the last message after the loading is done
        if self.commentsTableView.numberOfRows(inSection: 0) > 0 {
            let lastRow = self.commentsTableView.numberOfRows(inSection: 0) - 1
            let lastIndexPath = IndexPath(row: lastRow, section: 0)
            self.commentsTableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
        }
    }
    
    /// Reload the comments
    @IBAction func reloadButtonTapped(_ sender: Any) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        self.comments.removeAll()
        self.sortedComments.removeAll()
        self.setKascadeLikesAndViews()
        self.getComments()
    }
    
    /**
     Get the comments from the dbase and put them in the table view
     
     - Parameters:
     - none
     
     - Returns: void.
     */
    func setKascadeLikesAndViews() {
        /// Make user the kascade key is not nil
        if shipPicID != nil {
            /// Get the kascade reference
            let kascadeRef = Database.database().reference().child("kascade").child(shipPicID!)
            
            /// Get the snapshot
            kascadeRef.observeSingleEvent(of: .value, with: { (snapshot) in
                let kascadeDict = snapshot.value as? Dictionary<String, AnyObject>
                
                /// Make a check
                if kascadeDict != nil {
                    /// Make another check
                    if let likes = kascadeDict!["likes"] as? Int, let views = kascadeDict!["views"] as? Int {
                        
                        if likes == 1 {
                            self.likesLabel.text = "\(likes) like"
                        } else {
                            self.likesLabel.text = "\(likes) likes"
                        }
                        
                        if views == 1 {
                            self.viewsLabel.text = "\(views) view"
                        } else {
                            self.viewsLabel.text = "\(views) views"
                        }
                    }
                }
            })
        }
    }
    
    /**
     Send a push notification
     
     - Parameters:
     - none
     
     - Returns: void.
     */
    /*func sendFirstCommentNotification() {
        /// Push notification meant for the spreebie uploader
        let sns = AWSSNS.default()
        let request = AWSSNSPublishInput()
        
        request?.messageStructure = "json"
        
        /// The payload
        let dict = ["default": "The default message", ApplicationConstants.kascadaAPNSType: "{\"aps\":{\"alert\": {\"title\":\"Comment on kascade\",\"body\":\"Your kascade captioned '\(kascadeCaption!)' has received a comment.\"},\"sound\":\"default\",\"badge\":0} }"]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
            request?.message = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as? String
            
            request?.targetArn = self.kascadeUserArn!
            
            sns.publish(request!).continueWith
                {
                    (task) -> AnyObject! in
                    if task.error != nil
                    {
                        print("Error sending mesage: \(String(describing: task.error))")
                    }
                    else
                    {
                        print("Success sending message")
                    }
                    return nil
            }
        } catch {
            
        }
    }*/
    
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
    
    
    /**
     Downloads the profile pic.
     
     - Parameters:
     - imageView: The profile pic image view
     - fileName: The name of the file as it is store on S3
     - downloadULR: The local storage url
     
     - Returns: void.
     */
    func setProfilePic(cell: CommentTableViewCell, posterProfilePictureFileName: String?) {
        /// When signing up, the user image is stored as "empty"
        if posterProfilePictureFileName != ApplicationConstants.dbEmptyValue && posterProfilePictureFileName != nil {
            /// Get a reference to the image using the URL
            let ref = Storage.storage().reference(forURL: posterProfilePictureFileName!)
            print("posterProfilePictureFileName: \(posterProfilePictureFileName)")
            
            /// Get the image data
            ref.getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print(ApplicationConstants.profilePictureDownloadErrorMessage)
                } else {
                    if let imageData = data {
                        if let image = UIImage(data: imageData) {
                            cell.profilePicture.alpha = 0
                            let imageLayer: CALayer?  = cell.profilePicture.layer
                            imageLayer!.cornerRadius = cell.profilePicture.frame.height / 2
                            imageLayer!.masksToBounds = true
                            
                            cell.profilePicture.image = image
                            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                               cell.profilePicture.alpha = 1
                            })
                            
                            /// Store the image on the phone
                            /*if fileNameToSaveAs != "empty" {
                                
                                /// The directory of the documents folder
                                let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
                                
                                /// The URL of the documents folder
                                let documentDirectoryURL = URL(fileURLWithPath: documentDirectory)
                                
                                /// The local URL of the profile pic
                                let localURL = documentDirectoryURL.appendingPathComponent(fileNameToSaveAs)
                                
                                /// The local paths of the URLs
                                let localPath = localURL.path
                                
                                /// Write the image data to file
                                try? imageData.write(to: URL(fileURLWithPath: localPath), options: [.atomic])
                            }*/
                        }
                    }
                }
            })
        }
    }
}
