//
//  ShipPicView.swift
//  PicShip
//
//  Created by Thabo David Klass on 31/05/2019.
//  Copyright © 2019 Open Beacon. All rights reserved.
//

import UIKit
import AVFoundation

class ShipPicView: UIView {
    @IBOutlet var contentView: UIView!
    
    /// Time remaining label
    //let timeRemainingLabel = UILabel()
    @IBOutlet weak var timeRemainingLabel: UILabel!
    
    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet weak var shipPicImageView: UIImageView!
    
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
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var loadingActivityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var viewLabel: UILabel!
    
    @IBOutlet weak var likesLabel: UILabel!
    
    @IBOutlet weak var commentsLabel: UILabel!
    
    @IBOutlet weak var swipeLeftLabel: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    
    
    /// The audio-visual player
    var avPlayer = AVPlayer()
    
    /// The player layer
    var avPlayerLayer: AVPlayerLayer!
    
    /// The invisible button
    //let invisibleButton = UIButton()
    @IBOutlet weak var invisibleButton: UIButton!
    
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
    
    var didLoadAllContents: Bool!
    
    /// The kascade key
    var kascadeKey: String?
    
    /// The kascade user
    var kascadeUser: String?
    
    /// The kascade user ARN
    var kascadeUserArn: String?
    
    /// The current logged in user
    var currentUser: String? = KeychainWrapper.standard.string(forKey: ApplicationConstants.majeshiUserIDKey)
    
    /// The kascade caption
    var kascadeCaption: String?
    
    /// The kascade user full name
    var kascadeUserFullName: String?
    
    /// The kascade user profile picture file name
    var kascadeUserProfilePicFileName: String?
    
    /// Did the user like the kascade
    //var kascadeLiked = false
    var shipPicLiked = false
    
    /// Have the comments been opened?
    var commentsOpened = false
    
    var videoUrlString = ""
    
    weak var parentViewController: ShipPicViewControllerWithScrollView? = nil
    
    var posterUserID = ""
    
    var title = ""
    
    var shipPicID = ""
    
    var mainShipPicKey = ""
    
    var createdAt: Int? = nil
    
    var posterUserName: String? = nil
    
    var posterProfilePictureFileName: String? = nil
    
    var numberOfLikes = 0
    
    var heartColor = UIColor.white
    
    var shouldAnimateSwipeLeftLabel = false
    
    var playerIsPlaying = false
    
    var imageFileURL = ""
    
    var taggedContactUserID: String? = nil
    
    var type = ""
    
    /*init(userID: String) {
     posterUserID = userID
     
     //super.init(nibName: nil, bundle: nil)
     }*/
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    func commonInit() {
        Bundle.main.loadNibNamed("ShipPicView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        //loadingIndicatorView.startAnimating()
        loadingActivityIndicatorView.startAnimating()
        
        print("The poster ID is: \(posterUserID)")
        
        /// Keep video/camera feature from dimming
        UIApplication.shared.isIdleTimerDisabled = true
        
        seekSlider.setValue(0, animated: false)
        
        // Do any additional setup after loading the view.
        // An AVPlayerLayer is a CALayer instance to which the AVPlayer can
        // direct its visual output. Without it, the user will see nothing.
        //manager = AWSContentManager.default()
        
        /// The player
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        /*avPlayerLayer.frame = videoView.frame
         videoView.layer.addSublayer(avPlayerLayer)*/
        
        avPlayerLayer.frame = videoView.bounds
        videoView.layer.insertSublayer(avPlayerLayer, at: 0)
        
        /// Set the time interval to one second
        let timeInterval: CMTime = CMTimeMakeWithSeconds(1.0, preferredTimescale: 10)
        
        /// The observer
        timeObserver = avPlayer.addPeriodicTimeObserver(forInterval: timeInterval,queue: DispatchQueue.main) { (elapsedTime: CMTime) -> Void in
            self.observeTime(elapsedTime: elapsedTime)
            } as AnyObject
        
        /// Add the inivisble button
        //invisibleButton.frame = videoView.bounds
        //videoView.addSubview(invisibleButton)
        invisibleButton.addTarget(self, action: #selector(hideShowGUI), for: .touchUpInside)
        
        /// Time remain label
        timeRemainingLabel.textColor = .white
        //view.addSubview(timeRemainingLabel)
        
        /// Add the slider
        //view.addSubview(seekSlider)
        seekSlider.addTarget(self, action: #selector(sliderBeganTracking),
                             for: .touchDown)
        seekSlider.addTarget(self, action: #selector(sliderEndedTracking),
                             for: [.touchUpInside, .touchUpOutside])
        seekSlider.addTarget(self, action: #selector(sliderValueChanged),
                             for: .valueChanged)
        
        /// Add the loading indicator
        //loadingIndicatorView.hidesWhenStopped = true
        loadingActivityIndicatorView.hidesWhenStopped = true
        //view.addSubview(loadingIndicatorView)
        
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
        
        let reportAbuseButtonLayer: CALayer?  = reportAbuseButton.layer
        reportAbuseButtonLayer!.cornerRadius = reportAbuseButton.frame.height / 6
        reportAbuseButtonLayer!.masksToBounds = true
        
        reportAbuseButton.addTarget(self, action: #selector(reportAbuse), for: .touchUpInside)
        //reportAbuseButton.titleLabel?.font = UIFont(name: "Futura", size: 17)
        //view.addSubview(reportAbuseButton)
        
        let orangish = UIColor(red: 248.0/255.0, green: 119.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        
        let editButtonLayer: CALayer?  = editButton.layer
        editButtonLayer!.cornerRadius = editButton.frame.height / 6
        //editButtonLayer!.borderWidth = 1.0
        //editButtonLayer!.borderColor = orangish.cgColor
        editButtonLayer!.masksToBounds = true
        
        editButton.alpha = 0.9
        
        /// Configure and add the image view
        userImageView.frame = CGRect(x: 20, y: 100.0, width: 30, height: 30.0)
        userImageView.image = #imageLiteral(resourceName: "empy_profile_pic")
        //view.addSubview(userImageView)
        //setUserProfilePicture()
        
        /// This creates rounded corners for the image view
        let imageLayer: CALayer?  = userImageView.layer
        imageLayer!.borderWidth = 0.5
        imageLayer!.borderColor = UIColor.gray.cgColor
        
        imageLayer!.cornerRadius = userImageView.frame.height / 2
        imageLayer!.masksToBounds = true
        
        /// Configure and add the user label
        /*userLabel.frame = CGRect(x: 70, y: 100.0, width: view.bounds.size.width - 90.0, height: 30.0)
         userLabel.text = kascadeUserFullName
         userLabel.textColor = UIColor.white
         userLabel.font = UIFont(name: "Futura", size: 17)
         //view.addSubview(userLabel)*/
        
        /// Configure and add the caption label
        /*captionLabel.frame = CGRect(x: 20, y: 130.0, width: view.bounds.size.width - 40.0, height: 120.0)
         captionLabel.text = kascadeCaption
         captionLabel.textColor = UIColor.white
         captionLabel.font = UIFont(name: "Futura", size: 15)
         captionLabel.numberOfLines = 0
         //view.addSubview(captionLabel)*/
        
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
        commentButton.addTarget(self, action: #selector(openComments), for: .touchUpInside)
        //view.addSubview(commentButton)
        
        /// Set did load contents to false
        didLoadAllContents = false
        /// Load the content management stuff - this ultimately gets the url
        //loadAndStartStream()
        
        swipeLeftLabel.alpha = 0
        
        /// Set like state and number of views
        //updateNumberOfViews()
        //setShipPicLikeState()
        print("Run this shit")
        print("Inside the subview - the mainShipPicKey is: \(mainShipPicKey)")
        
        //setPoserData()
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        print("Video Finished")
        avPlayer.seek(to: .zero)
    }
    
    func startPlayback() {
        print("Inside the subview - the mainShipPicKey is: \(mainShipPicKey)")
        let videoUrl = URL(string: videoUrlString)!
        
        
        let playerItem = AVPlayerItem(url: videoUrl)
        avPlayer.replaceCurrentItem(with: playerItem)
        //avPlayer.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
        
        playerIsPlaying = avPlayer.rate > 0
        
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
    
    func loadShipPicImage() {
        print("Inside the subview - the mainShipPicKey is: \(mainShipPicKey)")
        print("Ïnside loadShipPicImage() 01")
        seekSlider.isEnabled = false
        seekSlider.isHidden = true
        
        playbackButton.isEnabled = false
        playbackButton.isHidden = true
        
        loadingActivityIndicatorView.stopAnimating()
        loadingActivityIndicatorView.isHidden = true
        
        
        if imageFileURL != ""{
            print("Ïnside loadShipPicImage() 02")
            /// Get a reference to the image using the URL
            let ref = Storage.storage().reference(forURL: self.imageFileURL)
            
            /// Get the image data
            ref.getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print(ApplicationConstants.profilePictureDownloadErrorMessage)
                } else {
                    if let imageData = data {
                        if let image = UIImage(data: imageData) {
                            self.shipPicImageView.alpha = 0
                            
                            self.shipPicImageView.image = image
                            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                                self.shipPicImageView.alpha = 1
                                
                                if self.shouldAnimateSwipeLeftLabel {
                                    self.animateSwipeLeftLabel()
                                }
                            })
                        }
                    }
                }
            })
        }
    }
    
    /*override func viewWillAppear(_ animated: Bool) {
     super.viewWillAppear(animated)
     /// Keep video/camera feature from dimming
     UIApplication.shared.isIdleTimerDisabled = true
     
     /// Comments stuff
     if commentsOpened {
     commentsOpened = false
     } else {
     loadingIndicatorView.startAnimating()
     }
     }*/
    
    /*override func viewWillLayoutSubviews() {
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
     }*/
    
    deinit {
        /*/avPlayer.removeTimeObserver(timeObserver)
         avPlayer.removeObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp")*/
        //avPlayer = nil
    }
    
    @objc func cancel() {
        avPlayer.pause()
        self.avPlayerLayer.removeFromSuperlayer()
        parentViewController!.dismiss(animated: true, completion: nil)
    }
    
    /*func invisibleButtonTapped(sender: UIButton) {
     let playerIsPlaying = avPlayer.rate > 0
     
     if playerIsPlaying {
     avPlayer.pause()
     } else {
     avPlayer.play()
     }
     }*/
    
    /// Playback button tapped - replace ui elements based on interaction
    @objc func playbackButtonTapped(sender: UIButton) {
        playerIsPlaying = avPlayer.rate > 0
        
        if playerIsPlaying {
            print("Inside the true situation")
            avPlayer.pause()
            
            playbackButton.setImage(#imageLiteral(resourceName: "play").withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
            playbackButton.tintColor = UIColor.white
        } else {
            print("Inside the false situation")
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
                
                //playerIsPlaying = false
                
                if shouldAnimateSwipeLeftLabel {
                    animateSwipeLeftLabel()
                }
                
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
                //loadingIndicatorView.stopAnimating()
                loadingActivityIndicatorView.stopAnimating()
                //animateSwipeLeftLabel()
            } else {
                //loadingIndicatorView.startAnimating()
                loadingActivityIndicatorView.startAnimating()
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
        print("hideShowGUI() tapped")
        if GUIVisible {
            cancelButton.isEnabled = false
            //cancelButton.isHidden = true
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.cancelButton.alpha = 0
            })
            
            playbackButton.isEnabled = false
            //playbackButton.isHidden = true
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.playbackButton.alpha = 0
            })
            
            reportAbuseButton.isEnabled = false
            //reportAbuseButton.isHidden = true
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.reportAbuseButton.alpha = 0
            })
            
            likeButton.isEnabled = false
            //likeButton.isHidden = true
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.likeButton.alpha = 0
            })
            
            commentButton.isEnabled = false
            //commentButton.isHidden = true
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.commentButton.alpha = 0
            })
            
            timeRemainingLabel.isEnabled = false
            //timeRemainingLabel.isHidden = true
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.timeRemainingLabel.alpha = 0
            })
            
            seekSlider.isEnabled = false
            //seekSlider.isHidden = true
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.seekSlider.alpha = 0
            })
            
            //userLabel.isHidden = true
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.userLabel.alpha = 0
            })
            
            //userImageView.isHidden = true
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.userImageView.alpha = 0
            })
            
            //captionLabel.isHidden = true
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.captionLabel.alpha = 0
            })
            
            //dateLabel.isHidden = true
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.dateLabel.alpha = 0
            })
            
            //viewLabel.isHidden = true
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.viewLabel.alpha = 0
            })
            
            //likesLabel.isHidden = true
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.likesLabel.alpha = 0
            })
            
            //commentsLabel.isHidden = true
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.commentsLabel.alpha = 0
            })
            
            editButton.isEnabled = false
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.editButton.alpha = 0
            })
            
            
            GUIVisible = false
        } else {
            cancelButton.isEnabled = true
            //cancelButton.isHidden = false
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.cancelButton.alpha = 1
            })
            
            playbackButton.isEnabled = true
            //playbackButton.isHidden = false
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.playbackButton.alpha = 1
            })
            
            reportAbuseButton.isEnabled = true
            //reportAbuseButton.isHidden = false
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.reportAbuseButton.alpha = 1
            })
            
            likeButton.isEnabled = true
            //likeButton.isHidden = false
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.likeButton.alpha = 1
            })
            
            commentButton.isEnabled = true
            //commentButton.isHidden = false
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.commentButton.alpha = 1
            })
            
            timeRemainingLabel.isEnabled = true
            //timeRemainingLabel.isHidden = false
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.timeRemainingLabel.alpha = 1
            })
            
            seekSlider.isEnabled = true
            //seekSlider.isHidden = false
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.seekSlider.alpha = 1
            })
            
            //userLabel.isHidden = false
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.userLabel.alpha = 1
            })
            
            //userImageView.isHidden = false
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.userImageView.alpha = 1
            })
            
            //captionLabel.isHidden = false
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.captionLabel.alpha = 1
            })
            
            //dateLabel.isHidden = false
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.dateLabel.alpha = 1
            })
            
            //viewLabel.isHidden = false
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.viewLabel.alpha = 1
            })
            
            //likesLabel.isHidden = false
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.likesLabel.alpha = 1
            })
            
            //commentsLabel.isHidden = false
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.commentsLabel.alpha = 1
            })
            
            editButton.isEnabled = true
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.editButton.alpha = 1
            })
            
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
        parentViewController!.present(alert, animated: true, completion: nil)
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
        
        if shipPicID != "" {
            /*let reportData: Dictionary<String, AnyObject> = [
             "kascade": self.kascadeKey! as AnyObject,
             "creationAt": timeStamp  as AnyObject
             ]
             
             let report = Database.database().reference().child("report").childByAutoId()
             
             report.setValue(reportData, withCompletionBlock: { (error, ref) in
             if error != nil {
             UIApplication.shared.isNetworkActivityIndicatorVisible = false
             print(error?.localizedDescription)
             } else {
             self.displayMyAlertMessage("Successful reporting", userMessage: "Your report was received and will be reviewed by the Kascada team.")
             
             UIApplication.shared.isNetworkActivityIndicatorVisible = false
             }
             })*/
            
            let dBase = Firestore.firestore()
            
            let currentDate = Date()
            let timeStamp = Int(currentDate.timeIntervalSince1970)
            
            let picShipMetaData: Dictionary<String, AnyObject> = [
                "picShipMetaID": shipPicID as AnyObject,
                "seen": false as AnyObject
            ]
            
            dBase.collection("reports").document("\(timeStamp)-\(self.currentUser!)").setData(picShipMetaData, completion: { (error) in
                if let error = error {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    print(error.localizedDescription)
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
        /*let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertController.Style.alert)
         let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
         myAlert.addAction(okAction)
         
         self.present(myAlert, animated: true, completion: nil)*/
    }
    
    /// This opens the comments
    @objc func openComments() {
        commentsOpened = true
        
        /// Get and open the comment view controller
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let commentsViewController = storyBoard.instantiateViewController(withIdentifier: "commentsViewController") as! CommentsViewController
        commentsViewController.shipPicID = self.shipPicID
        commentsViewController.shipPicCaption = self.title
        commentsViewController.picShipUser = self.posterUserID
        //commentsViewController.kascadeUserArn = self.kascadeUserArn
        parentViewController!.present(commentsViewController, animated: true, completion: nil)
    }
    
    /// Update the number of views
    func updateNumberOfViews() {
        if shipPicID != "" {
            /*Database.database().reference().child("kascade").child(kascadeKey!).child("views").runTransactionBlock({ (currentData) -> TransactionResult in
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
             }*/
            
            
            let dBase = Firestore.firestore()
            
            let shipPicRef = dBase.collection("picShipMeta").document(shipPicID)
            
            dBase.runTransaction({ (transaction, errorPointer) -> Any? in
                let shipPicDocument: DocumentSnapshot
                do {
                    try shipPicDocument = transaction.getDocument(shipPicRef)
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }
                
                guard let oldViews = shipPicDocument.data()?["views"] as? Int else {
                    let error = NSError(
                        domain: "AppErrorDomain",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(shipPicDocument)"
                        ]
                    )
                    errorPointer?.pointee = error
                    return nil
                }
                
                // Note: this could be done without a transaction
                //       by updating the population using FieldValue.increment()
                transaction.updateData(["views": oldViews + 1], forDocument: shipPicRef)
                
                let views = oldViews + 1
                
                if views == 0 {
                    self.viewLabel.text = "No views"
                } else if views == 1 {
                    self.viewLabel.text = "1 view"
                } else {
                    self.viewLabel.text = "\(views) views"
                }
                
                return nil
            }) { (object, error) in
                if let error = error {
                    print("Transaction failed: \(error)")
                } else {
                    print("Transaction successfully committed!")
                }
            }
        }
    }
    
    /// If the like button is tapped, update the user interface elements
    @objc func likeButtonTapped() {
        let orangish = UIColor(red: 248.0/255.0, green: 119.0/255.0, blue: 19.0/255.0, alpha: 1.0)
        
        if !shipPicLiked {
            likeButton.setImage(#imageLiteral(resourceName: "like_tapped").withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
            likeButton.tintColor = orangish
            shipPicLiked = true
            
            updateNumberOfLikes(updateValue: 1)
            handleTap()
        } else {
            likeButton.setImage(#imageLiteral(resourceName: "like").withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
            likeButton.tintColor = orangish
            shipPicLiked = false
            
            updateNumberOfLikes(updateValue: -1)
        }
        
        /// Change the like state
        updateShipPicLikeState()
    }
    
    /// Update the number of likes in the backend
    func updateNumberOfLikes(updateValue: Int) {
        if shipPicID != "" {
            /*Database.database().reference().child("kascade").child(kascadeKey!).child("likes").runTransactionBlock({ (currentData) -> TransactionResult in
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
             }*/
            
            let dBase = Firestore.firestore()
            
            let shipPicRef = dBase.collection("picShipMeta").document(shipPicID)
            
            dBase.runTransaction({ (transaction, errorPointer) -> Any? in
                let shipPicDocument: DocumentSnapshot
                do {
                    try shipPicDocument = transaction.getDocument(shipPicRef)
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }
                
                guard let oldLikes = shipPicDocument.data()?["likes"] as? Int else {
                    let error = NSError(
                        domain: "AppErrorDomain",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(shipPicDocument)"
                        ]
                    )
                    errorPointer?.pointee = error
                    return nil
                }
                
                // Note: this could be done without a transaction
                //       by updating the population using FieldValue.increment()
                transaction.updateData(["likes": oldLikes + updateValue], forDocument: shipPicRef)
                return nil
            }) { (object, error) in
                if let error = error {
                    print("Transaction failed: \(error)")
                } else {
                    self.numberOfLikes = self.numberOfLikes + updateValue
                    
                    if self.numberOfLikes == 0 {
                        self.likesLabel.text = "No likes"
                    } else if self.numberOfLikes == 1 {
                        self.likesLabel.text = "1 like"
                    } else {
                        self.likesLabel.text = "\(self.numberOfLikes) likes"
                    }
                    
                    print("Transaction successfully committed!")
                }
            }
        }
    }
    
    /// Update the like state
    func updateShipPicLikeState() {
        if currentUser != nil {
            let currentDate = Date()
            let timeStamp = Int(currentDate.timeIntervalSince1970)
            
            if shipPicID != "" {
                let likeData: Dictionary<String, AnyObject> = [
                    "like": shipPicLiked as AnyObject,
                    "modifiedAt": timeStamp  as AnyObject
                ]
                
                /*let like = Database.database().reference().child("likes").child(currentUser!).child(kascadeKey!)
                 
                 like.setValue(likeData)*/
                
                if currentUser != nil {
                    let dBase = Firestore.firestore()
                    
                    let likesRef = dBase.collection("likes").document(currentUser!).collection(shipPicID).document("likeData")
                    likesRef.setData(likeData)
                    //commentRef.setData(likeData)
                    /*commentRef.collection("comments").addDocument(data: commentData) {  (error) in
                     if let error = error {
                     print("\(error.localizedDescription)")
                     UIApplication.shared.isNetworkActivityIndicatorVisible = false
                     
                     self.displayMajeshiGenericAlert("Error", userMessage: "There was an error posting your comment. Please try again.")
                     } else {*/
                }
            }
        }
    }
    
    /// Update the like state
    func setShipPicLikeState() {
        if shipPicID != "" {
            /*let likeRef = Database.database().reference().child("likes").child(currentUser!).child(kascadeKey!)
             
             likeRef.observeSingleEvent(of: .value, with: { (snapshot) in
             let likeDict = snapshot.value as? Dictionary<String, AnyObject>
             
             if likeDict != nil {
             let liked = likeDict!["like"] as! Bool
             
             if liked {
             self.likeButton.setImage(#imageLiteral(resourceName: "like_tapped").withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
             self.likeButton.tintColor = UIColor.white
             self.shipPicLiked = true
             } else {
             self.likeButton.setImage(#imageLiteral(resourceName: "like").withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
             self.likeButton.tintColor = UIColor.white
             self.shipPicLiked = false
             }
             }
             })*/
            
            let orangish = UIColor(red: 248.0/255.0, green: 119.0/255.0, blue: 19.0/255.0, alpha: 1.0)
            
            let dBase = Firestore.firestore()
            
            let likesRef = dBase.collection("likes").document(currentUser!).collection(shipPicID).document("likeData")
            likesRef.getDocument { (documentSnapshot, error) in
                if let document = documentSnapshot, (documentSnapshot?.exists)! {
                    if let likeDict = document.data() {
                        /// Check for nil again
                        let liked = likeDict["like"] as! Bool
                        
                        if liked {
                            self.likeButton.setImage(#imageLiteral(resourceName: "like_tapped").withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
                            self.likeButton.tintColor = orangish
                            self.shipPicLiked = true
                        } else {
                            self.likeButton.setImage(#imageLiteral(resourceName: "like").withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
                            self.likeButton.tintColor = orangish
                            self.shipPicLiked = false
                        }
                    }
                }
            }
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
    
    func setPoserData() {
        if numberOfLikes == 0 {
            likesLabel.text = "No likes"
        } else if numberOfLikes == 1 {
            likesLabel.text = "1 like"
        } else {
            likesLabel.text = "\(numberOfLikes) likes"
        }
        
        if createdAt != nil {
            dateLabel.text = convertTimeStampToDate(timeStamp: createdAt!) + " - [\(type)]"
        } else {
            print("createdAt is nil")
        }
        
        if title != "" {
            self.captionLabel.text = title
        }
        
        countComments()
        setShipPicLikeState()
        
        print("inside setPoserData() 01")
        /// Check for nil
        if posterUserID != "" {
            print("inside setPoserData() 02")
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            // Get firestore dBase
            let dBase = Firestore.firestore()
            
            let userRef = dBase.collection("users").document(posterUserID)
            
            userRef.getDocument { (document, error) in
                print("inside setPoserData() 03")
                if let document = document, document.exists {
                    print("inside setPoserData() 04")
                    if let userDict = document.data() {
                        print("inside setPoserData() 05")
                        /// Check for nil again
                        if let fullName = userDict["fullName"] as? String, let profilePictureFileName = userDict["profilePictureFileName"] as? String {
                            print("inside setPoserData() 06")
                            
                            print(fullName)
                            print(profilePictureFileName)
                            
                            /// Set the text data
                            self.userLabel.text = fullName
                            self.posterUserName = fullName
                            
                            /// Set the profile picture data
                            if profilePictureFileName != ApplicationConstants.dbEmptyValue {
                                self.posterProfilePictureFileName = profilePictureFileName
                                
                                let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
                                let documentDirectoryURL = URL(fileURLWithPath: documentDirectory)
                                
                                if self.currentUser != nil {
                                    /*let fileName = self.currentUser! + ".jpg"
                                     let downloadFileURL = documentDirectoryURL.appendingPathComponent(fileName)
                                     
                                     /// Download or insert inmage into the cell if it already exists locally
                                     if FileManager.default.fileExists(atPath: downloadFileURL.path) {
                                     self.insertMajeshiImage(self.profilePictureImageView, downloadFileURL: downloadFileURL)
                                     } else {*/
                                    //self.setProfilePic(fileNameToSaveAs: "empty")
                                    //}
                                }
                            }
                            
                            /*if let school = userDict["school"] as? String {
                             self.schoolLabel.text = school
                             self.currentUserSchool = school
                             }
                             
                             if let role = userDict["role"] as? String {
                             self.currentUserRole = role
                             
                             if role == "student" {
                             if let roleDetails = userDict["roleDetails"] as? String {
                             self.roleLabel.text = roleDetails
                             self.currentUserRoleDetails = roleDetails
                             }
                             } else {
                             if let roleDetails = userDict["roleDetails"] as? String {
                             self.roleLabel.text = roleDetails
                             self.currentUserRoleDetails = roleDetails
                             }
                             }
                             }*/
                            
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        }
                    }
                } else {
                    print("Error: \(String(describing: error?.localizedDescription))")
                }
            }
        }
    }
    
    /**
     Downloads the profile pic.
     
     - Parameters:
     - imageView: The profile pic image view
     - fileName: The name of the file as it is store on S3
     - downloadULR: The local storage url
     
     - Returns: void.
     */
    func setProfilePic(fileNameToSaveAs: String) {
        /// When signing up, the user image is stored as "empty"
        if posterProfilePictureFileName != ApplicationConstants.dbEmptyValue && posterProfilePictureFileName != nil {
            /// Get a reference to the image using the URL
            let ref = Storage.storage().reference(forURL: self.posterProfilePictureFileName!)
            print("posterProfilePictureFileName: \(self.posterProfilePictureFileName!)")
            
            /// Get the image data
            ref.getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print(ApplicationConstants.profilePictureDownloadErrorMessage)
                } else {
                    if let imageData = data {
                        if let image = UIImage(data: imageData) {
                            self.userImageView.alpha = 0
                            let imageLayer: CALayer?  = self.userImageView.layer
                            imageLayer!.cornerRadius = self.userImageView.frame.height / 2
                            imageLayer!.masksToBounds = true
                            
                            self.userImageView.image = image
                            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                                self.userImageView.alpha = 1
                            })
                            
                            /// Store the image on the phone
                            if fileNameToSaveAs != "empty" {
                                
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
                            }
                        }
                    }
                }
            })
        }
    }
    
    /**
     Convert the time stamp to a readable date
     
     - Parameters:
     - timeStamp: The timestamp as an int
     
     - Returns: void.
     */
    func convertTimeStampToDate(timeStamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timeStamp))
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        let localDate = dateFormatter.string(from: date)
        
        return localDate
    }
    
    func countComments() {
        if shipPicID != "" {
            let dBase = Firestore.firestore()
            
            let commentRef = dBase.collection("comment").document(shipPicID).collection("comments")
            
            commentRef.getDocuments { (querySnapshot, error) in
                if error == nil {
                    if let queryDocumentSnapshot = querySnapshot?.documents {
                        /*if queryDocumentSnapshot.count == 0 {
                         UIApplication.shared.isNetworkActivityIndicatorVisible = false
                         } else {
                         /// The kascade has comments
                         self.kascadeHasComments = true
                         }*/
                        
                        if queryDocumentSnapshot.count == 0 {
                            self.commentsLabel.text = "No comments"
                        } else if queryDocumentSnapshot.count == 1 {
                            self.commentsLabel.text = "\(queryDocumentSnapshot.count) comment"
                        } else {
                            self.commentsLabel.text = "\(queryDocumentSnapshot.count) comments"
                        }
                    }
                }
            }
        }
    }
    
    func handleTap() {
        let orangish = UIColor(red: 248.0/255.0, green: 119.0/255.0, blue: 19.0/255.0, alpha: 1.0)
        let greenish = UIColor(red: 112.0/255.0, green: 214.0/255.0, blue: 210.0/255.0, alpha: 1.0)
        
        var number = 0
        
        (0...20).forEach { (_) in
            if number % 2 == 0 {
                heartColor = orangish
            } else {
                heartColor = greenish
            }
            
            generateAnimatedViews()
            
            number = number + 1
        }
    }
    
    fileprivate func generateAnimatedViews() {
        let heart = UIImage(named: "like_tapped")
        
        let templateHeart = heart!.withRenderingMode(.alwaysTemplate)
        //myImageView.image = templateImage
        //myImageView.tintColor = UIColor.orangeColor()
        
        //let image = drand48() > 0.5 ? #imageLiteral(resourceName: "thumbs_up") : #imageLiteral(resourceName: "heart")
        let imageView = UIImageView(image: templateHeart)
        let dimension = 20 + drand48() * 10
        imageView.frame = CGRect(x: 0, y: 0, width: dimension, height: dimension)
        imageView.tintColor = heartColor
        imageView.alpha = 0.7
        
        let animation = CAKeyframeAnimation(keyPath: "position")
        
        animation.path = customPath().cgPath
        animation.duration = 2 + drand48() * 3
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        
        imageView.layer.add(animation, forKey: nil)
        self.addSubview(imageView)
    }
    
    func animateSwipeLeftLabel() {
        UIView.animate(withDuration: 4.0, animations: { () -> Void in
            self.swipeLeftLabel.alpha = 1
            
            UIView.animate(withDuration: 4.0, animations: { () -> Void in
                self.swipeLeftLabel.alpha = 0
                
                self.shouldAnimateSwipeLeftLabel = false
            })
        })
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Edit Your ShipPic", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        actionSheet.view.tintColor = UIColor(red: 248.0/255.0, green: 119.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        
        actionSheet.addAction(UIAlertAction(title: "Edit ShipPic", style: UIAlertAction.Style.default, handler: { (alert: UIAlertAction) -> Void in
            self.parentViewController?.performSegue(withIdentifier: "openDetailsFromSingleShipPic", sender: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Delete ShipPic", style: UIAlertAction.Style.default, handler: { (alert: UIAlertAction) -> Void in
            /*imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
             imagePicker.allowsEditing = false
             self.present(imagePicker, animated: true, completion: nil)*/
            if self.currentUser != nil && self.mainShipPicKey != "" {
                print("The mainShipPicKey is: \(self.mainShipPicKey)")
                print("The shipPicID is: \(self.shipPicID)")
                
                let alert = UIAlertController(title: "Delete ShipPic", message: "Are you sure you want to delete your ShipPic?", preferredStyle: UIAlertController.Style.alert)
                alert.view.tintColor = UIColor(red: 248.0/255.0, green: 119.0/255.0, blue: 20.0/255.0, alpha: 1.0)
                
                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { (alert) -> Void in
                    self.loadingActivityIndicatorView.startAnimating()
                    
                    let dBase = Firestore.firestore()
                    dBase.collection("picShip").document(self.currentUser!).collection("picShips").document(self.mainShipPicKey).delete(completion: { (error) in
                        if error == nil {
                            print("inside picShip")
                            
                            if self.taggedContactUserID != nil {
                                print("inside taggedContactUserID")
                                dBase.collection("tagged").document(self.taggedContactUserID!).collection("picShips").whereField("picShipID", isEqualTo: self.mainShipPicKey).getDocuments(completion: { (snapshot, error) in
                                    if let querySnapshot = snapshot?.documents {
                                        for data in querySnapshot {
                                            let documentID = data.documentID
                                            
                                            dBase.collection("tagged").document(self.taggedContactUserID!).collection("picShips").document(documentID).delete()
                                            
                                            dBase.collection("picShipMeta").document(self.shipPicID).delete(completion: { (error) in
                                                ApplicationConstants.shipPicEditingJustHappened = true
                                                ApplicationConstants.shipPicEditingJustHappenedForBackTableVC = true
                                                
                                                self.loadingActivityIndicatorView.stopAnimating()
                                                self.parentViewController?.dismiss(animated: true, completion: nil)
                                            })
                                        }
                                    }
                                })
                            } else {
                                print("outside picShipMeta")
                                dBase.collection("picShipMeta").document(self.shipPicID).delete(completion: { (error) in
                                    ApplicationConstants.shipPicEditingJustHappened = true
                                    ApplicationConstants.shipPicEditingJustHappenedForBackTableVC = true
                                    
                                    print("inside picShipMeta")
                                    
                                    self.loadingActivityIndicatorView.stopAnimating()
                                    self.parentViewController?.dismiss(animated: true, completion: nil)
                                })
                            }
                        } else {
                            self.loadingActivityIndicatorView.stopAnimating()
                            self.displayMyAlertMessage("Error", userMessage: "There was an error deleting your ShipPic. Please try again.")
                        }
                    })
                }))
                alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: nil))
                
                // show the alert
                self.parentViewController!.present(alert, animated: true, completion: nil)
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        
        parentViewController!.present(actionSheet, animated: true, completion: nil)
    }
    
    func setTaggedUser() {
        if shipPicID != "" {
            let dBase = Firestore.firestore()
            
            let picShipRef = dBase.collection("picShipMeta").document(shipPicID)
            
            picShipRef.getDocument { (documentSnapshot, error) in
                if error == nil {
                    if let picShipMetaDict = documentSnapshot?.data() {
                        if let contactUserID = picShipMetaDict["contactUserID"] as? String {
                            if contactUserID != "empty" {
                                self.taggedContactUserID = contactUserID
                                
                                print("The tagged user ID is: \(self.taggedContactUserID!)")
                            }
                        }
                    }
                }
            }
        }
    }
}

func customPath() -> UIBezierPath {
    let path = UIBezierPath()
    
    path.move(to: CGPoint(x: 0, y: 200))
    
    let endPoint = CGPoint(x: 400, y: 200)
    
    let randomYShift = 200 + drand48() * 300
    let cp1 = CGPoint(x: 100, y: 100 - randomYShift)
    let cp2 = CGPoint(x: 200, y: 300 + randomYShift)
    
    path.addCurve(to: endPoint, controlPoint1: cp1, controlPoint2: cp2)
    return path
}

class CurvedView: UIView {
    
    override func draw(_ rect: CGRect) {
        //do some fancy curve drawing
        let path = customPath()
        path.lineWidth = 3
        path.stroke()
    }
    
}
