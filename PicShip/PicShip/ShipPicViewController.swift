//
//  ShipPicViewController.swift
//  PicShip
//
//  Created by Thabo David Klass on 24/05/2019.
//  Copyright © 2019 Open Beacon. All rights reserved.
//

import UIKit
import AVFoundation

class ShipPicViewController: UIViewController, UIGestureRecognizerDelegate {
    /// The audio-visual player
    var avPlayer = AVPlayer()
    
    /// The player layer
    var avPlayerLayer: AVPlayerLayer!
    
    /// The invisible button
    let invisibleButton = UIButton()
    
    /// This observes the time443
    var timeObserver: AnyObject!
    
    /// The play rate
    var playerRateBeforeSeek: Float = 0
    
    /// The activity indicator
    let loadingIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
    
    /// The prefix
    var prefix: String?
    
    /// The marker
    var marker: String?
    
    /// The contents of AWS folders
    /*var contents: [AWSContent]?
    
    /// The content manager - helps navigate the content
    var manager: AWSContentManager!*/
    
    /// Have all the contents been loaded?
    var didLoadAllContents: Bool!
    
    /// Time remaining label
    //let timeRemainingLabel = UILabel()
    @IBOutlet weak var timeRemainingLabel: UILabel!
    
    /// The slider
    //let seekSlider = UISlider()
    @IBOutlet weak var seekSlider: UISlider!
    
    /// The cancel button
    //var cancelButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    /// The playback button
    //var playbackButton: UIButton!
    @IBOutlet weak var playbackButton: UIButton!
    
    /// The report abuse button
    //var reportAbuseButton: UIButton!
    @IBOutlet weak var reportAbuseButton: UIButton!
    
    /// The like button
    //var likeButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    /// The comment button
    //var commentButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    
    /// Is the GUI visible
    var GUIVisible = true
    
    /// The user label
    //let userLabel = UILabel()
    @IBOutlet weak var userLabel: UILabel!
    
    /// The user image
    //let userImageView = UIImageView()
    @IBOutlet weak var userImageView: UIImageView!
    
    /// The caption label
    //let captionLabel = UILabel()
    @IBOutlet weak var captionLabel: UILabel!
    
    @IBOutlet weak var loadingShipPicView: UIActivityIndicatorView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var viewsLabel: UILabel!
    
    @IBOutlet weak var likesLabel: UILabel!
    
    @IBOutlet weak var commentsLabel: UILabel!
    
    
    /// The kascade key
    var kascadeKey: String?
    
    /// The kascade user
    var kascadeUser: String?
    
    /// The kascade user ARN
    var kascadeUserArn: String?
    
    /// The current logged in user
    var currentUser: String? = KeychainWrapper.standard.string(forKey: "picShipUID")
    
    /// The kascade caption
    var kascadeCaption: String?
    
    /// The kascade user full name
    var kascadeUserFullName: String?
    
    /// The kascade user profile picture file name
    var kascadeUserProfilePicFileName: String?
    
    /// Did the user like the kascade
    var kascadeLiked = false
    
    /// Have the comments been opened?
    var commentsOpened = false
    
    /*init(prefix: String, kascadeKey: String, kascadeCaption: String, kascadeUserFullName: String, kascadeUserProfilePicFileName: String, kascadeUser: String, kascadeUserArn: String) {
        self.prefix = prefix
        self.kascadeKey = kascadeKey
        self.kascadeCaption = kascadeCaption
        self.kascadeUserFullName = kascadeUserFullName
        self.kascadeUserProfilePicFileName = kascadeUserProfilePicFileName
        self.kascadeUser = kascadeUser
        self.kascadeUserArn = kascadeUserArn
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Keep video/camera feature from dimming
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Do any additional setup after loading the view.
        // An AVPlayerLayer is a CALayer instance to which the AVPlayer can
        // direct its visual output. Without it, the user will see nothing.
        //manager = AWSContentManager.default()
        
        /// The player
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        
        /// Set the time interval to one second
        let timeInterval: CMTime = CMTimeMakeWithSeconds(1.0, preferredTimescale: 10)
        
        /// The observer
        timeObserver = avPlayer.addPeriodicTimeObserver(forInterval: timeInterval,queue: DispatchQueue.main) { (elapsedTime: CMTime) -> Void in
            self.observeTime(elapsedTime: elapsedTime)
            } as AnyObject
        
        /// Add the inivisble button
        //view.addSubview(invisibleButton)
        //invisibleButton.addTarget(self, action: #selector(hideShowGUI), for: .touchUpInside)
        
        /// Time remain label
        timeRemainingLabel.textColor = .white
        view.addSubview(timeRemainingLabel)
        
        /// Add the slider
        view.addSubview(seekSlider)
        seekSlider.addTarget(self, action: #selector(sliderBeganTracking),
                             for: .touchDown)
        seekSlider.addTarget(self, action: #selector(sliderEndedTracking),
                             for: [.touchUpInside, .touchUpOutside])
        seekSlider.addTarget(self, action: #selector(sliderValueChanged),
                             for: .valueChanged)
        
        /// Add the loading indicator
        loadingIndicatorView.hidesWhenStopped = true
        view.addSubview(loadingIndicatorView)
        
        /// Who knows
        avPlayer.addObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp", options: NSKeyValueObservingOptions.new, context: nil)
        
        /// Configure and add the cancel button
        //cancelButton = UIButton(frame: CGRect(x: 20.0, y: 30.0, width: 30.0, height: 30.0))
        //cancelButton.setImage(#imageLiteral(resourceName: "cancel"), for: UIControlState())
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        //view.addSubview(cancelButton)
        
        /// Configure and add the report button
        //reportAbuseButton = UIButton(frame: CGRect(x: view.bounds.size.width - 100, y: 30.0, width: 80.0, height: 30.0))
        //reportAbuseButton.setTitle("Report", for: .normal)
        reportAbuseButton.addTarget(self, action: #selector(reportAbuse), for: .touchUpInside)
        //reportAbuseButton.titleLabel?.font = UIFont(name: "Futura", size: 17)
        //view.addSubview(reportAbuseButton)
        
        /// Configure and add the image view
        userImageView.frame = CGRect(x: 20, y: 100.0, width: 30, height: 30.0)
        userImageView.image = #imageLiteral(resourceName: "empy_profile_pic")
        view.addSubview(userImageView)
        //setUserProfilePicture()
        
        /// This creates rounded corners for the image view
        let imageLayer: CALayer?  = self.userImageView.layer
        imageLayer!.borderWidth = 0.5
        imageLayer!.borderColor = UIColor.gray.cgColor
        
        imageLayer!.cornerRadius = userImageView.frame.height / 2
        imageLayer!.masksToBounds = true
        
        /// Configure and add the user label
        userLabel.frame = CGRect(x: 70, y: 100.0, width: view.bounds.size.width - 90.0, height: 30.0)
        userLabel.text = kascadeUserFullName
        userLabel.textColor = UIColor.white
        userLabel.font = UIFont(name: "Avenir", size: 17)
        view.addSubview(userLabel)
        
        /// Configure and add the caption label
        captionLabel.frame = CGRect(x: 20, y: 130.0, width: view.bounds.size.width - 40.0, height: 120.0)
        captionLabel.text = kascadeCaption
        captionLabel.textColor = UIColor.white
        captionLabel.font = UIFont(name: "Avenir", size: 15)
        captionLabel.numberOfLines = 0
        view.addSubview(captionLabel)
        
        /// Configure and add the playback button
        /*playbackButton = UIButton(frame: CGRect(x: 75, y: view.bounds.size.height - 100, width: 30.0, height: 30.0))
        playbackButton.setImage(#imageLiteral(resourceName: "pause").withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
        playbackButton.tintColor = UIColor.white
        view.addSubview(playbackButton)*/
        
        playbackButton.addTarget(self, action: #selector(playbackButtonTapped), for: .touchUpInside)
        
        /// Configure and add the like button
        //likeButton = UIButton(frame: CGRect(x: view.bounds.size.width / 3, y: view.bounds.size.height - 50, width: 30.0, height: 30.0))
        //likeButton.setImage(#imageLiteral(resourceName: "like").withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
        //likeButton.tintColor = UIColor.white
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        //view.addSubview(likeButton)
        
        /// Configure and add the comment button
        //commentButton = UIButton(frame: CGRect(x: (view.bounds.size.width * 2) / 3, y: view.bounds.size.height - 50, width: 30.0, height: 30.0))
        //commentButton.setImage(#imageLiteral(resourceName: "comment").withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
        //commentButton.tintColor = UIColor.white
        //commentButton.addTarget(self, action: #selector(openComments), for: .touchUpInside)
        //view.addSubview(commentButton)
        
        /// Set did load contents to false
        didLoadAllContents = false
        /// Load the content management stuff - this ultimately gets the url
        //loadAndStartStream()
        
        let videoUrl = URL(string: "https://v.cdn.vine.co/r/videos/AA3C120C521177175800441692160_38f2cbd1ffb.1.5.13763579289575020226.mp4")!

        
        let playerItem = AVPlayerItem(url: videoUrl)
        avPlayer.replaceCurrentItem(with: playerItem)
        avPlayer.play()
        
        /// Set like state and number of views
        //updateNumberOfViews()
        //setKascadeLikeState()
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged))
        view.addGestureRecognizer(gesture)
        view.isUserInteractionEnabled = true
        gesture.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /// Keep video/camera feature from dimming
        UIApplication.shared.isIdleTimerDisabled = true
        
        /// Comments stuff
        if commentsOpened {
            commentsOpened = false
        } else {
            loadingIndicatorView.startAnimating()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Layout subviews manually
        avPlayerLayer.frame = view.bounds
        invisibleButton.frame = view.bounds
        let controlsHeight: CGFloat = 30
        let controlsY: CGFloat = view.bounds.size.height - 100
        timeRemainingLabel.frame = CGRect(x: 20, y: controlsY, width: 60, height: controlsHeight)
        seekSlider.frame = CGRect(x: playbackButton.frame.origin.x + playbackButton.bounds.size.width + 10,
                                  y: controlsY, width: view.bounds.size.width - timeRemainingLabel.bounds.size.width - 70, height: controlsHeight)
        loadingIndicatorView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
    }
    
    deinit {
        avPlayer.removeTimeObserver(timeObserver)
        avPlayer.removeObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp")
        //avPlayer = nil
    }
    
    @objc func cancel() {
        avPlayer.pause()
        self.avPlayerLayer.removeFromSuperlayer()
        dismiss(animated: true, completion: nil)
    }
    
    func invisibleButtonTapped(sender: UIButton) {
        /*let playerIsPlaying = avPlayer.rate > 0
         
         if playerIsPlaying {
         avPlayer.pause()
         } else {
         avPlayer.play()
         }*/
    }
    
    /// Playback button tapped - replace ui elements based on interaction
    @objc func playbackButtonTapped(sender: UIButton) {
        let playerIsPlaying = avPlayer.rate > 0
        
        if playerIsPlaying {
            avPlayer.pause()
            
            playbackButton.setImage(#imageLiteral(resourceName: "play").withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
            playbackButton.tintColor = UIColor.white
        } else {
            avPlayer.play()
            
            playbackButton.setImage(#imageLiteral(resourceName: "pause").withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
            playbackButton.tintColor = UIColor.white
            
            if seekSlider.value >= 1 {
                avPlayer.seek(to: CMTimeMakeWithSeconds(0, preferredTimescale: 100)) { (completed: Bool) -> Void in
                    if self.playerRateBeforeSeek > 0 {
                        self.avPlayer.play()
                    }
                }
            }
        }
    }
    
    /// Updates the time label
    private func updateTimeLabel(elapsedTime: Float64, duration: Float64) {
        let timeRemaining: Float64 = CMTimeGetSeconds(avPlayer.currentItem!.duration) - elapsedTime
        timeRemainingLabel.text = String(format: "%02d:%02d", ((lround(timeRemaining) / 60) % 60), lround(timeRemaining) % 60)
    }
    
    /// Observes time
    private func observeTime(elapsedTime: CMTime) {
        let duration = CMTimeGetSeconds(avPlayer.currentItem!.duration)
        
        if duration.isFinite {
            let elapsedTime = CMTimeGetSeconds(elapsedTime)
            updateTimeLabel(elapsedTime: elapsedTime, duration: duration)
            
            let percentage = elapsedTime / duration
            
            seekSlider.setValue(Float(percentage), animated: true)
            
            if percentage >= 1 {
                playbackButton.setImage(#imageLiteral(resourceName: "play").withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
                playbackButton.tintColor = UIColor.white
                
                if !GUIVisible {
                    hideShowGUI()
                }
            }
        }
    }
    
    /// Tracking stuff
    @objc func sliderBeganTracking(slider: UISlider) {
        playerRateBeforeSeek = avPlayer.rate
        avPlayer.pause()
    }
    
    @objc func sliderEndedTracking(slider: UISlider) {
        let videoDuration = CMTimeGetSeconds(avPlayer.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(seekSlider.value)
        updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
        
        avPlayer.seek(to: CMTimeMakeWithSeconds(elapsedTime, preferredTimescale: 100)) { (completed: Bool) -> Void in
            if self.playerRateBeforeSeek > 0 {
                self.avPlayer.play()
            }
        }
    }
    
    @objc func sliderValueChanged(slider: UISlider) {
        let videoDuration = CMTimeGetSeconds(avPlayer.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(seekSlider.value)
        updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
        print("Slider value: \(slider.value)")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if (keyPath == "currentItem.playbackLikelyToKeepUp") {
            if avPlayer.currentItem!.isPlaybackLikelyToKeepUp {
                loadingIndicatorView.stopAnimating()
            } else {
                loadingIndicatorView.startAnimating()
            }
        }
    }
    
    /// This loads the m3u8 and starts stream
    /*fileprivate func loadAndStartStream() {
        /// list the available contents based on the prefix and marker
        manager.listAvailableContents(withPrefix: prefix, marker: marker) {[weak self] (contents: [AWSContent]?, nextMarker: String?, error: Error?) in
            guard let strongSelf = self else { return }
            if let error = error {
                strongSelf.showSimpleAlertWithTitle("Error", message: "Failed to load the list of contents.", cancelButtonTitle: "OK")
                print("Failed to load the list of contents. \(error)")
            }
            if let contents = contents, contents.count > 0 {
                strongSelf.contents = contents
                if let nextMarker = nextMarker, !nextMarker.isEmpty{
                    strongSelf.didLoadAllContents = false
                } else {
                    strongSelf.didLoadAllContents = true
                }
                strongSelf.marker = nextMarker
            }
            
            /// Loop through the contents and find the master m3u8 playlist
            for content in contents! {
                if content.key.contains("m3u8") {
                    content.getRemoteFileURL(completionHandler: { (url, error) in
                        guard let url = url else {
                            print("Error getting URL for file. \(error)")
                            return
                        }
                        
                        do {
                            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                            try AVAudioSession.sharedInstance().setActive(true)
                        } catch {
                            print(error)
                        }
                        
                        // Open Audio and Video files natively in app.
                        let playerItem = AVPlayerItem(url: url)
                        strongSelf.avPlayer.replaceCurrentItem(with: playerItem)
                        strongSelf.avPlayer.play()
                    })
                }
            }
        }
    }*/
    
    /**
     This resize the image
     
     - Parameters:
     - image: The UIImage to be resized.
     - size: The output CGSzie
     
     - Returns: The resized UIImage
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
    
    /// Hide and show the GUI
    @objc func hideShowGUI() {
        if GUIVisible {
            cancelButton.isEnabled = false
            cancelButton.isHidden = true
            playbackButton.isEnabled = false
            playbackButton.isHidden = true
            reportAbuseButton.isEnabled = false
            reportAbuseButton.isHidden = true
            likeButton.isEnabled = false
            likeButton.isHidden = true
            commentButton.isEnabled = false
            commentButton.isHidden = true
            timeRemainingLabel.isEnabled = false
            timeRemainingLabel.isHidden = true
            seekSlider.isEnabled = false
            seekSlider.isHidden = true
            userLabel.isHidden = true
            userImageView.isHidden = true
            captionLabel.isHidden = true
            
            GUIVisible = false
        } else {
            cancelButton.isEnabled = true
            cancelButton.isHidden = false
            playbackButton.isEnabled = true
            playbackButton.isHidden = false
            reportAbuseButton.isEnabled = true
            reportAbuseButton.isHidden = false
            likeButton.isEnabled = true
            likeButton.isHidden = false
            commentButton.isEnabled = true
            commentButton.isHidden = false
            timeRemainingLabel.isEnabled = true
            timeRemainingLabel.isHidden = false
            seekSlider.isEnabled = true
            seekSlider.isHidden = false
            userLabel.isHidden = false
            userImageView.isHidden = false
            captionLabel.isHidden = false
            
            GUIVisible = true
        }
    }
    
    /**
     This responds to a report spreebie tapped event.
     
     - Parameters:
     - sender: The Send report button
     
     - Returns: void.
     */
    @objc func reportAbuse(sender: UIButton) {
        let alert = UIAlertController(title: "Report offensive content", message: "You may report this kascade of you find its content offfensive or inappropriate.  It will then be reviewed by the PicShip team.  Reporting is anonymous. Would you like to continue with your report?", preferredStyle: UIAlertController.Style.alert)
        
        alert.view.tintColor = UIColor(red: 248.0/255.0, green: 119.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { (alert) -> Void in
            self.sendReport()
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    /**
     Sends a report to the backend.
     
     - Parameters:
     - none
     
     - Returns: void.
     */
    func sendReport() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let currentDate = Date()
        let timeStamp = Int(currentDate.timeIntervalSince1970)
        
        if kascadeKey != nil {
            let reportData: Dictionary<String, AnyObject> = [
                "kascade": self.kascadeKey! as AnyObject,
                "creationAt": timeStamp  as AnyObject
            ]
            
            let report = Database.database().reference().child("report").childByAutoId()
            
            report.setValue(reportData, withCompletionBlock: { (error, ref) in
                if error != nil {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    print(error?.localizedDescription)
                } else {
                    self.displayMyAlertMessage("Successful reporting", userMessage: "Your report was received and will be reviewed by the PicShip team.")
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })
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
    
    /// This opens the comments
    /*@objc func openComments() {
        commentsOpened = true
        
        /// Get and open the comment view controller
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let commentsViewController = storyBoard.instantiateViewController(withIdentifier: "commentsViewController") as! CommentsViewController
        commentsViewController.kascadeKey = self.kascadeKey
        commentsViewController.kascadeCaption = self.kascadeCaption
        commentsViewController.kascadeUser = self.kascadeUser
        commentsViewController.kascadeUserArn = self.kascadeUserArn
        self.present(commentsViewController, animated: true, completion: nil)
    }*/
    
    /// Update the number of views
    func updateNumberOfViews() {
        if kascadeKey != nil {
            Database.database().reference().child("kascade").child(kascadeKey!).child("views").runTransactionBlock({ (currentData) -> TransactionResult in
                if var views = currentData.value as? Int {
                    views += 1
                    currentData.value = views
                    
                    return TransactionResult.success(withValue: currentData)
                }
                return TransactionResult.success(withValue: currentData)
            }) { (error, committed, snapshot) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    /// If the like button is tapped, update the user interface elements
    @objc func likeButtonTapped() {
        if !kascadeLiked {
            likeButton.setImage(#imageLiteral(resourceName: "like_tapped").withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
            likeButton.tintColor = UIColor.white
            kascadeLiked = true
            
            updateNumberOfLikes(updateValue: 1)
        } else {
            likeButton.setImage(#imageLiteral(resourceName: "like").withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
            likeButton.tintColor = UIColor.white
            kascadeLiked = false
            
            updateNumberOfLikes(updateValue: -1)
        }
        
        /// Change the like state
        updateKascadeLikeState()
    }
    
    /// Update the number of likes in the backend
    func updateNumberOfLikes(updateValue: Int) {
        if kascadeKey != nil {
            Database.database().reference().child("kascade").child(kascadeKey!).child("likes").runTransactionBlock({ (currentData) -> TransactionResult in
                if var likes = currentData.value as? Int {
                    likes += updateValue
                    currentData.value = likes
                    
                    return TransactionResult.success(withValue: currentData)
                }
                return TransactionResult.success(withValue: currentData)
            }) { (error, committed, snapshot) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    /// Update the like state
    func updateKascadeLikeState() {
        if currentUser != nil {
            let currentDate = Date()
            let timeStamp = Int(currentDate.timeIntervalSince1970)
            
            if kascadeKey != nil {
                let likeData: Dictionary<String, AnyObject> = [
                    "like": kascadeLiked as AnyObject,
                    "modifiedAt": timeStamp  as AnyObject
                ]
                
                let like = Database.database().reference().child("likes").child(currentUser!).child(kascadeKey!)
                
                like.setValue(likeData)
            }
        }
    }
    
    /// Update the like state
    func setKascadeLikeState() {
        if kascadeKey != nil {
            let likeRef = Database.database().reference().child("likes").child(currentUser!).child(kascadeKey!)
            
            likeRef.observeSingleEvent(of: .value, with: { (snapshot) in
                let likeDict = snapshot.value as? Dictionary<String, AnyObject>
                
                if likeDict != nil {
                    let liked = likeDict!["like"] as! Bool
                    
                    if liked {
                        self.likeButton.setImage(#imageLiteral(resourceName: "like_tapped").withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
                        self.likeButton.tintColor = UIColor.white
                        self.kascadeLiked = true
                    } else {
                        self.likeButton.setImage(#imageLiteral(resourceName: "like").withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
                        self.likeButton.tintColor = UIColor.white
                        self.kascadeLiked = false
                    }
                }
            })
        }
    }
    
    /// Set the user profile picture
    /*func setUserProfilePicture() {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
        let documentDirectoryURL = URL(fileURLWithPath: documentDirectory)
        
        if kascadeUserProfilePicFileName != nil {
            if kascadeUserProfilePicFileName != "empty" {
                let fileName = "s-" + kascadeUserProfilePicFileName!
                let downloadSmallFileURL = documentDirectoryURL.appendingPathComponent(fileName)
                
                if FileManager.default.fileExists(atPath: downloadSmallFileURL.path) {
                    self.insertProfilePic(userImageView, fileName: fileName, downloadFileURL: downloadSmallFileURL)
                } else {
                    self.downloadProfilePic(userImageView, fileName: fileName, downloadFileURL: downloadSmallFileURL)
                }
            }
        }
    }*/
    
    /**
     Downloads the profile pic from S3, stores it locally and inserts it into the cell.
     
     - Parameters:
     - cell: The Notifications view cell
     - fileName: The name of the file as it is store on S3
     - downloadULR: The local storage url
     
     - Returns: void.
     */
    /*func downloadProfilePic(_ imageView: UIImageView, fileName: String, downloadFileURL: URL) {
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
                    imageView.alpha = 0
                    let imageLayer: CALayer?  = imageView.layer
                    imageLayer!.cornerRadius = imageView.frame.height / 2
                    //imageLayer!.cornerRadius = 6
                    imageLayer!.masksToBounds = true
                    
                    /// On success, insert the image
                    let image = UIImage(named: downloadFileURL.path)
                    imageView.image = image
                    UIView.animate(withDuration: 0.5, animations: { () -> Void in
                        imageView.alpha = 1
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
    func insertProfilePic(_ imageView: UIImageView, fileName: String, downloadFileURL: URL) {
        DispatchQueue.main.async(execute: { () -> Void in
            if UIImage(named: downloadFileURL.path) != nil {
                imageView.alpha = 0
                let imageLayer: CALayer?  = imageView.layer
                imageLayer!.cornerRadius = imageView.frame.height / 2
                //imageLayer!.cornerRadius = 6
                imageLayer!.masksToBounds = true
                
                /// On success, insert the image
                let image = UIImage(named: downloadFileURL.path)
                imageView.image = image
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    imageView.alpha = 1
                })
            }
        })
    }
    
    /*func shareOnFacebook() {
     if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
     let post = SLComposeViewController(forServiceType: SLServiceTypeFacebook)!
     
     post.add(<#T##url: URL!##URL!#>)
     }
     }*/
    
    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizer.State.began || gestureRecognizer.state == UIGestureRecognizer.State.changed {
            let translation = gestureRecognizer.translation(in: self.view)
            print(gestureRecognizer.view!.center.y)
            if(gestureRecognizer.view!.center.y < 555) {
                gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x, y: gestureRecognizer.view!.center.y + translation.y)
            }else {
                gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x, y: 554)
            }
            
            gestureRecognizer.setTranslation(CGPoint(x: 0,y: 0), in: self.view)
        }
        
    }
}

extension ShipPicViewController {
    fileprivate func showSimpleAlertWithTitle(_ title: String, message: String, cancelButtonTitle cancelTitle: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.view.tintColor = UIColor(red: 248.0/255.0, green: 119.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}
