/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implements the view controller for the camera interface.
*/

import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, KVNCameraViewControllerDelegate, UISearchBarDelegate, UserSearchViewControllerDelegate {
    
    // MARK: View Controller Life Cycle
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var publicShipPicsButton: UIButton!
    @IBOutlet weak var createShipPicButton: UIButton!
    @IBOutlet weak var mainSearchBar: UISearchBar!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    
    /// The current user
    var currentUser: String? = KeychainWrapper.standard.string(forKey: ApplicationConstants.majeshiUserIDKey)
    
    /// The URL of the created video
    var newVideoURL: URL? = nil
    
    var newImage: UIImage? = nil
    
    /// The filename - unique
    var fileName: String? = nil
    
    /// Tokenized filename without extension
    var fileNameWithoutExtension: String? = nil
    
    /// Screenshot file name
    var screenshotFileName: String? = nil
    
    /// The local URL of the picture
    var uploadScreenshotURL = URL(string: "")
    
    var videoScreenshot: UIImage? = nil
    
    //var pcdvc: PicShipDetailsViewController? = nil
    
    /// Moved forward and selected contact
    var movedForwardAndSelectedContact = false
    
    var searchedUserID: String? = nil
    
    weak var spvcwsv: ShipPicViewControllerWithScrollView? = nil
    
    var userFiles = [String]()
    
    var userFilesTotalSize: Int64 = 0
    
    /// The space allocated for the folder
    var spaceAllocated: Int64 = 100 * 1024 * 1024
    
    /// Has the space been exceeed
    var spaceAllocatedExceeded = false
    
    /// The duration of the subscription = 30 days
    let subscriptionDuration: Int = 43200
    
    /// The tooltip restrictors
    var peersTooltipHasBeenShow = false
    var foldersTooltipHasBeenShow = false
    var buddiesTooltipHasBeenShow = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //KeychainWrapper.standard.removeObject(forKey: ApplicationConstants.majeshiUserIDKey)
        
        //KeychainWrapper.standard.set("QxEvV7wx9yPtGdiw9vBcCjn4Ok63", forKey: ApplicationConstants.majeshiUserIDKey)
        
        createShipPicButton.isEnabled = false
        //createShipPicButton.titleLabel?.text = "Wait..."
        
        //getMyShipPics()
        
        mainSearchBar.delegate = self
        
        captureModeControl.isEnabled = false
        captureModeControl.isHidden = true
        
        cameraButton.isEnabled = false
        cameraButton.isHidden = true
        
        cameraUnavailableLabel.isEnabled = false
        cameraUnavailableLabel.isHidden = true
        
        photoButton.isEnabled = false
        photoButton.isHidden = true
        
        livePhotoModeButton.isEnabled = false
        livePhotoModeButton.isHidden = true
        
        depthDataDeliveryButton.isEnabled = false
        depthDataDeliveryButton.isHidden = true
        
        portraitEffectsMatteDeliveryButton.isEnabled = false
        portraitEffectsMatteDeliveryButton.isHidden = true
        
        capturingLivePhotoLabel.isEnabled = false
        capturingLivePhotoLabel.isHidden = true
        
        recordButton.isEnabled = false
        recordButton.isHidden = true
        
        resumeButton.isEnabled = false
        resumeButton.isHidden = true
        
        let loginButtonLayer: CALayer?  = loginButton.layer
        loginButtonLayer!.cornerRadius = 4
        loginButtonLayer!.masksToBounds = true
        
        let publicShipPicsButtonLayer: CALayer?  = self.publicShipPicsButton.layer
        publicShipPicsButtonLayer!.borderWidth = 1.0
        publicShipPicsButtonLayer!.borderColor = UIColor.white.cgColor
        
        publicShipPicsButtonLayer!.cornerRadius = publicShipPicsButton.frame.height / 2
        publicShipPicsButtonLayer!.masksToBounds = true
        
        let createShipPicButtonLayer: CALayer?  = self.createShipPicButton.layer
        createShipPicButtonLayer!.borderWidth = 1.0
        createShipPicButtonLayer!.borderColor = UIColor.white.cgColor
        
        createShipPicButtonLayer!.cornerRadius = createShipPicButton.frame.height / 2
        createShipPicButtonLayer!.masksToBounds = true
        
        mainSearchBar.keyboardAppearance = .dark
        
        if let textfield = mainSearchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = UIColor.white
            //textfield.backgroundColor = UIColor.yellow
        }
        
        self.tabBarController?.tabBar.isHidden = true
        
        // Disable UI. Enable the UI later, if and only if the session starts running.
        cameraButton.isEnabled = false
        recordButton.isEnabled = false
        photoButton.isEnabled = false
        livePhotoModeButton.isEnabled = false
        depthDataDeliveryButton.isEnabled = false
        portraitEffectsMatteDeliveryButton.isEnabled = false
        captureModeControl.isEnabled = false
        
        // Set up the video preview view.
        previewView.session = session
        /*
         Check video authorization status. Video access is required and audio
         access is optional. If the user denies audio access, AVCam won't
         record audio during movie recording.
         */
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // The user has previously granted access to the camera.
            break
            
        case .notDetermined:
            /*
             The user has not yet been presented with the option to grant
             video access. We suspend the session queue to delay session
             setup until the access request has completed.
             
             Note that audio access will be implicitly requested when we
             create an AVCaptureDeviceInput for audio during session setup.
             */
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
            
        default:
            // The user has previously denied access.
            setupResult = .notAuthorized
        }
        
        /*
         Setup the capture session.
         In general, it is not safe to mutate an AVCaptureSession or any of its
         inputs, outputs, or connections from multiple threads at the same time.
         
         Don't perform these tasks on the main queue because
         AVCaptureSession.startRunning() is a blocking call, which can
         take a long time. We dispatch session setup to the sessionQueue, so
         that the main queue isn't blocked, which keeps the UI responsive.
         */
        sessionQueue.async {
            self.configureSession()
        }
        
        if currentUser == nil {
            /// Time the opening of the onboarder
            Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.timedSegueToOnboarder), userInfo: nil, repeats: false)
        } else {
            print("The current user ID is: \(currentUser!)")
            loginButton.setTitle("ShipPics", for: UIControl.State())
        }
        
        // Gesture Recognizer
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        
        self.view.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeLeft)
        
        let testingVerification = true
        if (testingVerification) {
            let base64Sig = "MEUCICQr3MsZxEYgbyE989lgdEQVxP/pq3yIbxr5vkQYlbfzAiEAwF4uJOr6YE36sUjFAZPcf9LaXph2E08338pUIfmtXRA=";
            let client_id = "5a24ce13014fdd16a9d4757e";
            
            let verified = KanvasSDK.initialize(withClientID: client_id, signature: base64Sig)
        }
        
        if currentUser == nil {
            publicShipPicsButton.isEnabled = false
            chatButton.isEnabled = false
            profileButton.isEnabled = false
        } else {
            publicShipPicsButton.isEnabled = true
            chatButton.isEnabled = true
            profileButton.isEnabled = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
        
        ApplicationConstants.justMovedBackFromDatePicker = false
        
        ApplicationConstants.justMovedBackFromSignOut = false
        
        createShipPicButton.titleLabel?.text = "Wait..."
        
        //pcdvc = nil
        spvcwsv = nil
        
        userFiles.removeAll()
        
        userFilesTotalSize = 0
        
        print("viewWillAppear")
        
        
        currentUser = KeychainWrapper.standard.string(forKey: ApplicationConstants.majeshiUserIDKey)
        
        if currentUser != nil {
            let showPopups = KeychainWrapper.standard.string(forKey: "picShipShowPopups")
            
            if showPopups != nil {
                if showPopups == ApplicationConstants.majeshiSmallNoValue {
                    peersTooltipHasBeenShow = true
                    foldersTooltipHasBeenShow = true
                    buddiesTooltipHasBeenShow = true
                }
            }
            
            loginButton.setTitle("ShipPics", for: UIControl.State())
        } else {
            /// Time the opening of the onboarder
            Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.timedSegueToOnboarder), userInfo: nil, repeats: false)
            
            loginButton.setTitle("Login", for: UIControl.State())
        }
        
        getMyShipPics()
        
        sessionQueue.async {
            switch self.setupResult {
            case .success:
                // Only setup observers and start the session running if setup succeeded.
                self.addObservers()
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
                
            case .notAuthorized:
                DispatchQueue.main.async {
                    let changePrivacySetting = "AVCam doesn't have permission to use the camera, please change privacy settings"
                    let message = NSLocalizedString(changePrivacySetting, comment: "Alert message when the user has denied access to the camera")
                    let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                    
                    alertController.view.tintColor = UIColor(red: 248.0/255.0, green: 119.0/255.0, blue: 20.0/255.0, alpha: 1.0)
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                            style: .cancel,
                                                            handler: nil))
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"),
                                                            style: .`default`,
                                                            handler: { _ in
                                                                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
                                                                                          options: [:],
                                                                                          completionHandler: nil)
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                
            case .configurationFailed:
                DispatchQueue.main.async {
                    let alertMsg = "Alert message when something goes wrong during capture session configuration"
                    let message = NSLocalizedString("Unable to capture media", comment: alertMsg)
                    let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                    
                    alertController.view.tintColor = UIColor(red: 248.0/255.0, green: 119.0/255.0, blue: 20.0/255.0, alpha: 1.0)
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                            style: .cancel,
                                                            handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
        if newVideoURL != nil {
            
        }
        
        if movedForwardAndSelectedContact {
            performSegue(withIdentifier: "openProfileFromUserSearch", sender: nil)
        }
        
        if currentUser == nil {
            publicShipPicsButton.isEnabled = false
            chatButton.isEnabled = false
            profileButton.isEnabled = false
        } else {
            publicShipPicsButton.isEnabled = true
            chatButton.isEnabled = true
            profileButton.isEnabled = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        sessionQueue.async {
            if self.setupResult == .success {
                self.session.stopRunning()
                self.isSessionRunning = self.session.isRunning
                self.removeObservers()
            }
        }
        
        super.viewWillDisappear(animated)
    }
    
    override var shouldAutorotate: Bool {
        // Disable autorotation of the interface when recording is in progress.
        if let movieFileOutput = movieFileOutput {
            return !movieFileOutput.isRecording
        }
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if let videoPreviewLayerConnection = previewView.videoPreviewLayer.connection {
            let deviceOrientation = UIDevice.current.orientation
            guard let newVideoOrientation = AVCaptureVideoOrientation(deviceOrientation: deviceOrientation),
                deviceOrientation.isPortrait || deviceOrientation.isLandscape else {
                    return
            }
            
            videoPreviewLayerConnection.videoOrientation = newVideoOrientation
        }
    }
    
    // MARK: Session Management
    
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    private let session = AVCaptureSession()
    private var isSessionRunning = false
    
    private let sessionQueue = DispatchQueue(label: "session queue") // Communicate with the session and other session objects on this queue.
    
    private var setupResult: SessionSetupResult = .success
    
    @objc dynamic var videoDeviceInput: AVCaptureDeviceInput!
    
    @IBOutlet private weak var previewView: PreviewView!
    
    // Call this on the session queue.
    /// - Tag: ConfigureSession
    private func configureSession() {
        if setupResult != .success {
            return
        }
        
        session.beginConfiguration()
        
        /*
         We do not create an AVCaptureMovieFileOutput when setting up the session because
         Live Photo is not supported when AVCaptureMovieFileOutput is added to the session.
         */
        session.sessionPreset = .high
        
        // Add video input.
        do {
            var defaultVideoDevice: AVCaptureDevice?
            
            // Choose the back dual camera if available, otherwise default to a wide angle camera.
            
            if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
                defaultVideoDevice = dualCameraDevice
            } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                // If a rear dual camera is not available, default to the rear wide angle camera.
                defaultVideoDevice = backCameraDevice
            } else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                // In the event that the rear wide angle camera isn't available, default to the front wide angle camera.
                defaultVideoDevice = frontCameraDevice
            }
            guard let videoDevice = defaultVideoDevice else {
                print("Default video device is unavailable.")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                
                DispatchQueue.main.async {
                    /*
                     Dispatch video streaming to the main queue because AVCaptureVideoPreviewLayer is the backing layer for PreviewView.
                     You can manipulate UIView only on the main thread.
                     Note: As an exception to the above rule, it is not necessary to serialize video orientation changes
                     on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                     
                     Use the status bar orientation as the initial video orientation. Subsequent orientation changes are
                     handled by CameraViewController.viewWillTransition(to:with:).
                     */
                    let statusBarOrientation = UIApplication.shared.statusBarOrientation
                    var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
                    if statusBarOrientation != .unknown {
                        if let videoOrientation = AVCaptureVideoOrientation(interfaceOrientation: statusBarOrientation) {
                            initialVideoOrientation = videoOrientation
                        }
                    }
                    
                    self.previewView.videoPreviewLayer.connection?.videoOrientation = initialVideoOrientation
                }
            } else {
                print("Couldn't add video device input to the session.")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        } catch {
            print("Couldn't create video device input: \(error)")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        // Add audio input.
        do {
            let audioDevice = AVCaptureDevice.default(for: .audio)
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice!)
            
            if session.canAddInput(audioDeviceInput) {
                session.addInput(audioDeviceInput)
            } else {
                print("Could not add audio device input to the session")
            }
        } catch {
            print("Could not create audio device input: \(error)")
        }
        
        // Add photo output.
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            
            photoOutput.isHighResolutionCaptureEnabled = true
            photoOutput.isLivePhotoCaptureEnabled = photoOutput.isLivePhotoCaptureSupported
            photoOutput.isDepthDataDeliveryEnabled = photoOutput.isDepthDataDeliverySupported
            photoOutput.isPortraitEffectsMatteDeliveryEnabled = photoOutput.isPortraitEffectsMatteDeliverySupported
            livePhotoMode = photoOutput.isLivePhotoCaptureSupported ? .on : .off
            depthDataDeliveryMode = photoOutput.isDepthDataDeliverySupported ? .on : .off
            portraitEffectsMatteDeliveryMode = photoOutput.isPortraitEffectsMatteDeliverySupported ? .on : .off
            
        } else {
            print("Could not add photo output to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
    }
    
    @IBAction private func resumeInterruptedSession(_ resumeButton: UIButton) {
        sessionQueue.async {
            /*
             The session might fail to start running, e.g., if a phone or FaceTime call is still
             using audio or video. A failure to start the session running will be communicated via
             a session runtime error notification. To avoid repeatedly failing to start the session
             running, we only try to restart the session running in the session runtime error handler
             if we aren't trying to resume the session running.
             */
            self.session.startRunning()
            self.isSessionRunning = self.session.isRunning
            if !self.session.isRunning {
                DispatchQueue.main.async {
                    let message = NSLocalizedString("Unable to resume", comment: "Alert message when unable to resume the session running")
                    let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                    
                    alertController.view.tintColor = UIColor(red: 248.0/255.0, green: 119.0/255.0, blue: 20.0/255.0, alpha: 1.0)
                    
                    let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    self.resumeButton.isHidden = true
                }
            }
        }
    }
    
    private enum CaptureMode: Int {
        case photo = 0
        case movie = 1
    }
    
    @IBOutlet private weak var captureModeControl: UISegmentedControl!
    
    /// - Tag: EnableDisableModes
    @IBAction private func toggleCaptureMode(_ captureModeControl: UISegmentedControl) {
        captureModeControl.isEnabled = false
        
        if captureModeControl.selectedSegmentIndex == CaptureMode.photo.rawValue {
            recordButton.isEnabled = false
            
            sessionQueue.async {
                // Remove the AVCaptureMovieFileOutput from the session since it doesn't support capture of Live Photos.
                self.session.beginConfiguration()
                
                if self.movieFileOutput != nil {
                    self.session.removeOutput(self.movieFileOutput!)
                }
                
                self.session.sessionPreset = .photo
                
                DispatchQueue.main.async {
                    captureModeControl.isEnabled = true
                }
                
                self.movieFileOutput = nil
                
                if self.photoOutput.isLivePhotoCaptureSupported {
                    self.photoOutput.isLivePhotoCaptureEnabled = true
                    
                    DispatchQueue.main.async {
                        self.livePhotoModeButton.isEnabled = true
                        self.livePhotoModeButton.isHidden = false
                    }
                }
                if self.photoOutput.isDepthDataDeliverySupported {
                    self.photoOutput.isDepthDataDeliveryEnabled = true
                    
                    DispatchQueue.main.async {
                        self.depthDataDeliveryButton.isHidden = false
                        self.depthDataDeliveryButton.isEnabled = true
                    }
                }
                
                if self.photoOutput.isPortraitEffectsMatteDeliverySupported {
                    self.photoOutput.isPortraitEffectsMatteDeliveryEnabled = true
                    
                    DispatchQueue.main.async {
                        self.portraitEffectsMatteDeliveryButton.isHidden = false
                        self.portraitEffectsMatteDeliveryButton.isEnabled = true
                    }
                }
                self.session.commitConfiguration()
            }
        } else if captureModeControl.selectedSegmentIndex == CaptureMode.movie.rawValue {
            livePhotoModeButton.isHidden = true
            depthDataDeliveryButton.isHidden = true
            portraitEffectsMatteDeliveryButton.isHidden = true
            
            sessionQueue.async {
                let movieFileOutput = AVCaptureMovieFileOutput()
                
                if self.session.canAddOutput(movieFileOutput) {
                    self.session.beginConfiguration()
                    self.session.addOutput(movieFileOutput)
                    self.session.sessionPreset = .high
                    if let connection = movieFileOutput.connection(with: .video) {
                        if connection.isVideoStabilizationSupported {
                            connection.preferredVideoStabilizationMode = .auto
                        }
                    }
                    self.session.commitConfiguration()
                    
                    DispatchQueue.main.async {
                        captureModeControl.isEnabled = true
                    }
                    
                    self.movieFileOutput = movieFileOutput
                    
                    DispatchQueue.main.async {
                        self.recordButton.isEnabled = true
                    }
                }
            }
        }
    }
    
    
    
    // MARK: Device Configuration
    
    @IBOutlet private weak var cameraButton: UIButton!
    
    @IBOutlet private weak var cameraUnavailableLabel: UILabel!
    
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera],
                                                                               mediaType: .video, position: .unspecified)
    
    /// - Tag: ChangeCamera
    @IBAction private func changeCamera(_ cameraButton: UIButton) {
        cameraButton.isEnabled = false
        recordButton.isEnabled = false
        photoButton.isEnabled = false
        livePhotoModeButton.isEnabled = false
        captureModeControl.isEnabled = false
        
        sessionQueue.async {
            let currentVideoDevice = self.videoDeviceInput.device
            let currentPosition = currentVideoDevice.position
            
            let preferredPosition: AVCaptureDevice.Position
            let preferredDeviceType: AVCaptureDevice.DeviceType
            
            switch currentPosition {
            case .unspecified, .front:
                preferredPosition = .back
                preferredDeviceType = .builtInDualCamera
                
            case .back:
                preferredPosition = .front
                preferredDeviceType = .builtInTrueDepthCamera
            }
            let devices = self.videoDeviceDiscoverySession.devices
            var newVideoDevice: AVCaptureDevice? = nil
            
            // First, seek a device with both the preferred position and device type. Otherwise, seek a device with only the preferred position.
            if let device = devices.first(where: { $0.position == preferredPosition && $0.deviceType == preferredDeviceType }) {
                newVideoDevice = device
            } else if let device = devices.first(where: { $0.position == preferredPosition }) {
                newVideoDevice = device
            }
            
            if let videoDevice = newVideoDevice {
                do {
                    let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                    
                    self.session.beginConfiguration()
                    
                    // Remove the existing device input first, since the system doesn't support simultaneous use of the rear and front cameras.
                    self.session.removeInput(self.videoDeviceInput)
                    
                    if self.session.canAddInput(videoDeviceInput) {
                        NotificationCenter.default.removeObserver(self, name: .AVCaptureDeviceSubjectAreaDidChange, object: currentVideoDevice)
                        NotificationCenter.default.addObserver(self, selector: #selector(self.subjectAreaDidChange), name: .AVCaptureDeviceSubjectAreaDidChange, object: videoDeviceInput.device)
                        
                        self.session.addInput(videoDeviceInput)
                        self.videoDeviceInput = videoDeviceInput
                    } else {
                        self.session.addInput(self.videoDeviceInput)
                    }
                    if let connection = self.movieFileOutput?.connection(with: .video) {
                        if connection.isVideoStabilizationSupported {
                            connection.preferredVideoStabilizationMode = .auto
                        }
                    }
                    
                    /*
                     Set Live Photo capture and depth data delivery if it is supported. When changing cameras, the
                     `livePhotoCaptureEnabled and depthDataDeliveryEnabled` properties of the AVCapturePhotoOutput gets set to NO when
                     a video device is disconnected from the session. After the new video device is
                     added to the session, re-enable them on the AVCapturePhotoOutput if it is supported.
                     */
                    self.photoOutput.isLivePhotoCaptureEnabled = self.photoOutput.isLivePhotoCaptureSupported
                    self.photoOutput.isDepthDataDeliveryEnabled = self.photoOutput.isDepthDataDeliverySupported
                    self.photoOutput.isPortraitEffectsMatteDeliveryEnabled = self.photoOutput.isPortraitEffectsMatteDeliverySupported
                    
                    self.session.commitConfiguration()
                } catch {
                    print("Error occurred while creating video device input: \(error)")
                }
            }
            
            DispatchQueue.main.async {
                self.cameraButton.isEnabled = true
                self.recordButton.isEnabled = self.movieFileOutput != nil
                self.photoButton.isEnabled = true
                self.livePhotoModeButton.isEnabled = true
                self.captureModeControl.isEnabled = true
                self.depthDataDeliveryButton.isEnabled = self.photoOutput.isDepthDataDeliveryEnabled
                self.depthDataDeliveryButton.isHidden = !self.photoOutput.isDepthDataDeliverySupported
                self.portraitEffectsMatteDeliveryButton.isEnabled = self.photoOutput.isPortraitEffectsMatteDeliveryEnabled
                self.portraitEffectsMatteDeliveryButton.isHidden = !self.photoOutput.isPortraitEffectsMatteDeliverySupported
            }
        }
    }
    
    @IBAction private func focusAndExposeTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let devicePoint = previewView.videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: gestureRecognizer.location(in: gestureRecognizer.view))
        focus(with: .autoFocus, exposureMode: .autoExpose, at: devicePoint, monitorSubjectAreaChange: true)
    }
    
    private func focus(with focusMode: AVCaptureDevice.FocusMode,
                       exposureMode: AVCaptureDevice.ExposureMode,
                       at devicePoint: CGPoint,
                       monitorSubjectAreaChange: Bool) {
        
        sessionQueue.async {
            let device = self.videoDeviceInput.device
            do {
                try device.lockForConfiguration()
                
                /*
                 Setting (focus/exposure)PointOfInterest alone does not initiate a (focus/exposure) operation.
                 Call set(Focus/Exposure)Mode() to apply the new point of interest.
                 */
                if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                    device.focusPointOfInterest = devicePoint
                    device.focusMode = focusMode
                }
                
                if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                    device.exposurePointOfInterest = devicePoint
                    device.exposureMode = exposureMode
                }
                
                device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                device.unlockForConfiguration()
            } catch {
                print("Could not lock device for configuration: \(error)")
            }
        }
    }
    
    // MARK: Capturing Photos
    
    private let photoOutput = AVCapturePhotoOutput()
    
    private var inProgressPhotoCaptureDelegates = [Int64: PhotoCaptureProcessor]()
    
    @IBOutlet private weak var photoButton: UIButton!
    
    /// - Tag: CapturePhoto
    @IBAction private func capturePhoto(_ photoButton: UIButton) {
        /*
         Retrieve the video preview layer's video orientation on the main queue before
         entering the session queue. We do this to ensure UI elements are accessed on
         the main thread and session configuration is done on the session queue.
         */
        let videoPreviewLayerOrientation = previewView.videoPreviewLayer.connection?.videoOrientation
        
        sessionQueue.async {
            if let photoOutputConnection = self.photoOutput.connection(with: .video) {
                photoOutputConnection.videoOrientation = videoPreviewLayerOrientation!
            }
            var photoSettings = AVCapturePhotoSettings()
            
            // Capture HEIF photos when supported. Enable auto-flash and high-resolution photos.
            if  self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
                photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
            }
            
            if self.videoDeviceInput.device.isFlashAvailable {
                photoSettings.flashMode = .auto
            }
            
            photoSettings.isHighResolutionPhotoEnabled = true
            if !photoSettings.__availablePreviewPhotoPixelFormatTypes.isEmpty {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoSettings.__availablePreviewPhotoPixelFormatTypes.first!]
            }
            if self.livePhotoMode == .on && self.photoOutput.isLivePhotoCaptureSupported { // Live Photo capture is not supported in movie mode.
                let livePhotoMovieFileName = NSUUID().uuidString
                let livePhotoMovieFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((livePhotoMovieFileName as NSString).appendingPathExtension("mov")!)
                photoSettings.livePhotoMovieFileURL = URL(fileURLWithPath: livePhotoMovieFilePath)
            }
            
            photoSettings.isDepthDataDeliveryEnabled = (self.depthDataDeliveryMode == .on
                && self.photoOutput.isDepthDataDeliveryEnabled)
            
            photoSettings.isPortraitEffectsMatteDeliveryEnabled = (self.portraitEffectsMatteDeliveryMode == .on
                && self.photoOutput.isPortraitEffectsMatteDeliveryEnabled)
            
            let photoCaptureProcessor = PhotoCaptureProcessor(with: photoSettings, willCapturePhotoAnimation: {
                // Flash the screen to signal that AVCam took a photo.
                DispatchQueue.main.async {
                    self.previewView.videoPreviewLayer.opacity = 0
                    UIView.animate(withDuration: 0.25) {
                        self.previewView.videoPreviewLayer.opacity = 1
                    }
                }
            }, livePhotoCaptureHandler: { capturing in
                self.sessionQueue.async {
                    if capturing {
                        self.inProgressLivePhotoCapturesCount += 1
                    } else {
                        self.inProgressLivePhotoCapturesCount -= 1
                    }
                    
                    let inProgressLivePhotoCapturesCount = self.inProgressLivePhotoCapturesCount
                    DispatchQueue.main.async {
                        if inProgressLivePhotoCapturesCount > 0 {
                            self.capturingLivePhotoLabel.isHidden = false
                        } else if inProgressLivePhotoCapturesCount == 0 {
                            self.capturingLivePhotoLabel.isHidden = true
                        } else {
                            print("Error: In progress Live Photo capture count is less than 0.")
                        }
                    }
                }
            }, completionHandler: { photoCaptureProcessor in
                // When the capture is complete, remove a reference to the photo capture delegate so it can be deallocated.
                self.sessionQueue.async {
                    self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = nil
                }
            }
            )
            
            // The photo output keeps a weak reference to the photo capture delegate and stores it in an array to maintain a strong reference.
            self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = photoCaptureProcessor
            self.photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureProcessor)
        }
    }
    
    private enum LivePhotoMode {
        case on
        case off
    }
    
    private enum DepthDataDeliveryMode {
        case on
        case off
    }
    
    private enum PortraitEffectsMatteDeliveryMode {
        case on
        case off
    }
    
    private var livePhotoMode: LivePhotoMode = .off
    
    @IBOutlet private weak var livePhotoModeButton: UIButton!
    
    @IBAction private func toggleLivePhotoMode(_ livePhotoModeButton: UIButton) {
        sessionQueue.async {
            self.livePhotoMode = (self.livePhotoMode == .on) ? .off : .on
            let livePhotoMode = self.livePhotoMode
            
            DispatchQueue.main.async {
                if livePhotoMode == .on {
                    self.livePhotoModeButton.setImage(#imageLiteral(resourceName: "LivePhotoON"), for: [])
                } else {
                    self.livePhotoModeButton.setImage(#imageLiteral(resourceName: "LivePhotoOFF"), for: [])
                }
            }
        }
    }
    
    private var depthDataDeliveryMode: DepthDataDeliveryMode = .off
    
    @IBOutlet private weak var depthDataDeliveryButton: UIButton!
    
    @IBAction func toggleDepthDataDeliveryMode(_ depthDataDeliveryButton: UIButton) {
        sessionQueue.async {
            self.depthDataDeliveryMode = (self.depthDataDeliveryMode == .on) ? .off : .on
            let depthDataDeliveryMode = self.depthDataDeliveryMode
            if depthDataDeliveryMode == .off {
                self.portraitEffectsMatteDeliveryMode = .off
            }
            
            DispatchQueue.main.async {
                if depthDataDeliveryMode == .on {
                    self.depthDataDeliveryButton.setImage(#imageLiteral(resourceName: "DepthON"), for: [])
                } else {
                    self.depthDataDeliveryButton.setImage(#imageLiteral(resourceName: "DepthOFF"), for: [])
                    self.portraitEffectsMatteDeliveryButton.setImage(#imageLiteral(resourceName: "PortraitMatteOFF"), for: [])
                }
            }
        }
    }
    
    private var portraitEffectsMatteDeliveryMode: PortraitEffectsMatteDeliveryMode = .off
    
    @IBOutlet private weak var portraitEffectsMatteDeliveryButton: UIButton!
    
    @IBAction func togglePortraitEffectsMatteDeliveryMode(_ portraitEffectsMatteDeliveryButton: UIButton) {
        sessionQueue.async {
            if self.portraitEffectsMatteDeliveryMode == .on {
                self.portraitEffectsMatteDeliveryMode = .off
            } else {
                self.portraitEffectsMatteDeliveryMode = (self.depthDataDeliveryMode == .off) ? .off : .on
            }
            let portraitEffectsMatteDeliveryMode = self.portraitEffectsMatteDeliveryMode
            
            DispatchQueue.main.async {
                if portraitEffectsMatteDeliveryMode == .on {
                    self.portraitEffectsMatteDeliveryButton.setImage(#imageLiteral(resourceName: "PortraitMatteON"), for: [])
                } else {
                    self.portraitEffectsMatteDeliveryButton.setImage(#imageLiteral(resourceName: "PortraitMatteOFF"), for: [])
                }
            }
        }
    }
    
    private var inProgressLivePhotoCapturesCount = 0
    
    @IBOutlet var capturingLivePhotoLabel: UILabel!
    
    // MARK: Recording Movies
    
    private var movieFileOutput: AVCaptureMovieFileOutput?
    
    private var backgroundRecordingID: UIBackgroundTaskIdentifier?
    
    @IBOutlet private weak var recordButton: UIButton!
    
    @IBOutlet private weak var resumeButton: UIButton!
    
    @IBAction private func toggleMovieRecording(_ recordButton: UIButton) {
        guard let movieFileOutput = self.movieFileOutput else {
            return
        }
        
        /*
         Disable the Camera button until recording finishes, and disable
         the Record button until recording starts or finishes.
         
         See the AVCaptureFileOutputRecordingDelegate methods.
         */
        cameraButton.isEnabled = false
        recordButton.isEnabled = false
        captureModeControl.isEnabled = false
        
        let videoPreviewLayerOrientation = previewView.videoPreviewLayer.connection?.videoOrientation
        
        sessionQueue.async {
            if !movieFileOutput.isRecording {
                if UIDevice.current.isMultitaskingSupported {
                    self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                }
                
                // Update the orientation on the movie file output video connection before recording.
                let movieFileOutputConnection = movieFileOutput.connection(with: .video)
                movieFileOutputConnection?.videoOrientation = videoPreviewLayerOrientation!
                
                let availableVideoCodecTypes = movieFileOutput.availableVideoCodecTypes
                
                if availableVideoCodecTypes.contains(.hevc) {
                    movieFileOutput.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.hevc], for: movieFileOutputConnection!)
                }
                
                // Start recording video to a temporary file.
                let outputFileName = NSUUID().uuidString
                let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
                movieFileOutput.startRecording(to: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
            } else {
                movieFileOutput.stopRecording()
            }
        }
    }
    
    /// - Tag: DidStartRecording
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        // Enable the Record button to let the user stop recording.
        DispatchQueue.main.async {
            self.recordButton.isEnabled = true
            self.recordButton.setImage(#imageLiteral(resourceName: "CaptureStop"), for: [])
        }
    }
    
    /// - Tag: DidFinishRecording
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        // Note: Since we use a unique file path for each recording, a new recording won't overwrite a recording mid-save.
        func cleanup() {
            let path = outputFileURL.path
            if FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch {
                    print("Could not remove file at url: \(outputFileURL)")
                }
            }
            
            if let currentBackgroundRecordingID = backgroundRecordingID {
                backgroundRecordingID = UIBackgroundTaskIdentifier.invalid
                
                if currentBackgroundRecordingID != UIBackgroundTaskIdentifier.invalid {
                    UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
                }
            }
        }
        
        var success = true
        
        if error != nil {
            print("Movie file finishing error: \(String(describing: error))")
            success = (((error! as NSError).userInfo[AVErrorRecordingSuccessfullyFinishedKey] as AnyObject).boolValue)!
        }
        
        if success {
            // Check authorization status.
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    // Save the movie file to the photo library and cleanup.
                    PHPhotoLibrary.shared().performChanges({
                        let options = PHAssetResourceCreationOptions()
                        options.shouldMoveFile = true
                        let creationRequest = PHAssetCreationRequest.forAsset()
                        creationRequest.addResource(with: .video, fileURL: outputFileURL, options: options)
                    }, completionHandler: { success, error in
                        if !success {
                            print("AVCam couldn't save the movie to your photo library: \(String(describing: error))")
                        }
                        cleanup()
                    }
                    )
                } else {
                    cleanup()
                }
            }
        } else {
            cleanup()
        }
        
        // Enable the Camera and Record buttons to let the user switch camera and start another recording.
        DispatchQueue.main.async {
            // Only enable the ability to change camera if the device has more than one camera.
            self.cameraButton.isEnabled = self.videoDeviceDiscoverySession.uniqueDevicePositionsCount > 1
            self.recordButton.isEnabled = true
            self.captureModeControl.isEnabled = true
            self.recordButton.setImage(#imageLiteral(resourceName: "CaptureVideo"), for: [])
        }
    }
    
    // MARK: KVO and Notifications
    
    private var keyValueObservations = [NSKeyValueObservation]()
    /// - Tag: ObserveInterruption
    private func addObservers() {
        let keyValueObservation = session.observe(\.isRunning, options: .new) { _, change in
            guard let isSessionRunning = change.newValue else { return }
            let isLivePhotoCaptureSupported = self.photoOutput.isLivePhotoCaptureSupported
            let isLivePhotoCaptureEnabled = self.photoOutput.isLivePhotoCaptureEnabled
            let isDepthDeliveryDataSupported = self.photoOutput.isDepthDataDeliverySupported
            let isDepthDeliveryDataEnabled = self.photoOutput.isDepthDataDeliveryEnabled
            let isPortraitEffectsMatteSupported = self.photoOutput.isPortraitEffectsMatteDeliverySupported
            let isPortraitEffectsMatteEnabled = self.photoOutput.isPortraitEffectsMatteDeliveryEnabled
            
            DispatchQueue.main.async {
                // Only enable the ability to change camera if the device has more than one camera.
                self.cameraButton.isEnabled = isSessionRunning && self.videoDeviceDiscoverySession.uniqueDevicePositionsCount > 1
                self.recordButton.isEnabled = isSessionRunning && self.movieFileOutput != nil
                self.photoButton.isEnabled = isSessionRunning
                self.captureModeControl.isEnabled = isSessionRunning
                self.livePhotoModeButton.isEnabled = isSessionRunning && isLivePhotoCaptureEnabled
                self.livePhotoModeButton.isHidden = !(isSessionRunning && isLivePhotoCaptureSupported)
                self.depthDataDeliveryButton.isEnabled = isSessionRunning && isDepthDeliveryDataEnabled
                self.depthDataDeliveryButton.isHidden = !(isSessionRunning && isDepthDeliveryDataSupported)
                self.portraitEffectsMatteDeliveryButton.isEnabled = isSessionRunning && isPortraitEffectsMatteEnabled
                self.portraitEffectsMatteDeliveryButton.isHidden = !(isSessionRunning && isPortraitEffectsMatteSupported)
            }
        }
        keyValueObservations.append(keyValueObservation)
        
        let systemPressureStateObservation = observe(\.videoDeviceInput.device.systemPressureState, options: .new) { _, change in
            guard let systemPressureState = change.newValue else { return }
            self.setRecommendedFrameRateRangeForPressureState(systemPressureState: systemPressureState)
        }
        keyValueObservations.append(systemPressureStateObservation)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(subjectAreaDidChange),
                                               name: .AVCaptureDeviceSubjectAreaDidChange,
                                               object: videoDeviceInput.device)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionRuntimeError),
                                               name: .AVCaptureSessionRuntimeError,
                                               object: session)
        
        /*
         A session can only run when the app is full screen. It will be interrupted
         in a multi-app layout, introduced in iOS 9, see also the documentation of
         AVCaptureSessionInterruptionReason. Add observers to handle these session
         interruptions and show a preview is paused message. See the documentation
         of AVCaptureSessionWasInterruptedNotification for other interruption reasons.
         */
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionWasInterrupted),
                                               name: .AVCaptureSessionWasInterrupted,
                                               object: session)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionInterruptionEnded),
                                               name: .AVCaptureSessionInterruptionEnded,
                                               object: session)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
        
        for keyValueObservation in keyValueObservations {
            keyValueObservation.invalidate()
        }
        keyValueObservations.removeAll()
    }
    
    @objc
    func subjectAreaDidChange(notification: NSNotification) {
        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        focus(with: .continuousAutoFocus, exposureMode: .continuousAutoExposure, at: devicePoint, monitorSubjectAreaChange: false)
    }
    
    /// - Tag: HandleRuntimeError
    @objc
    func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
        
        print("Capture session runtime error: \(error)")
        // If media services were reset, and the last start succeeded, restart the session.
        if error.code == .mediaServicesWereReset {
            sessionQueue.async {
                if self.isSessionRunning {
                    self.session.startRunning()
                    self.isSessionRunning = self.session.isRunning
                } else {
                    DispatchQueue.main.async {
                        self.resumeButton.isHidden = false
                    }
                }
            }
        } else {
            resumeButton.isHidden = false
        }
    }
    
    /// - Tag: HandleSystemPressure
    private func setRecommendedFrameRateRangeForPressureState(systemPressureState: AVCaptureDevice.SystemPressureState) {
        /*
         The frame rates used here are for demonstrative purposes only for this app.
         Your frame rate throttling may be different depending on your app's camera configuration.
         */
        let pressureLevel = systemPressureState.level
        if pressureLevel == .serious || pressureLevel == .critical {
            if self.movieFileOutput == nil || self.movieFileOutput?.isRecording == false {
                do {
                    try self.videoDeviceInput.device.lockForConfiguration()
                    print("WARNING: Reached elevated system pressure level: \(pressureLevel). Throttling frame rate.")
                    self.videoDeviceInput.device.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: 20 )
                    self.videoDeviceInput.device.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: 15 )
                    self.videoDeviceInput.device.unlockForConfiguration()
                } catch {
                    print("Could not lock device for configuration: \(error)")
                }
            }
        } else if pressureLevel == .shutdown {
            print("Session stopped running due to shutdown system pressure level.")
        }
    }
    
    /// - Tag: HandleInterruption
    @objc
    func sessionWasInterrupted(notification: NSNotification) {
        /*
         In some scenarios we want to enable the user to resume the session running.
         For example, if music playback is initiated via control center while
         using AVCam, then the user can let AVCam resume
         the session running, which will stop music playback. Note that stopping
         music playback in control center will not automatically resume the session
         running. Also note that it is not always possible to resume, see `resumeInterruptedSession(_:)`.
         */
        if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
            let reasonIntegerValue = userInfoValue.integerValue,
            let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) {
            print("Capture session was interrupted with reason \(reason)")
            
            var showResumeButton = false
            if reason == .audioDeviceInUseByAnotherClient || reason == .videoDeviceInUseByAnotherClient {
                showResumeButton = true
            } else if reason == .videoDeviceNotAvailableWithMultipleForegroundApps {
                // Fade-in a label to inform the user that the camera is unavailable.
                cameraUnavailableLabel.alpha = 0
                cameraUnavailableLabel.isHidden = false
                UIView.animate(withDuration: 0.25) {
                    self.cameraUnavailableLabel.alpha = 1
                }
            } else if reason == .videoDeviceNotAvailableDueToSystemPressure {
                print("Session stopped running due to shutdown system pressure level.")
            }
            if showResumeButton {
                // Fade-in a button to enable the user to try to resume the session running.
                resumeButton.alpha = 0
                resumeButton.isHidden = false
                UIView.animate(withDuration: 0.25) {
                    self.resumeButton.alpha = 1
                }
            }
        }
    }
    
    @objc
    func sessionInterruptionEnded(notification: NSNotification) {
        print("Capture session interruption ended")
        
        if !resumeButton.isHidden {
            UIView.animate(withDuration: 0.25,
                           animations: {
                            self.resumeButton.alpha = 0
            }, completion: { _ in
                self.resumeButton.isHidden = true
            })
        }
        if !cameraUnavailableLabel.isHidden {
            UIView.animate(withDuration: 0.25,
                           animations: {
                            self.cameraUnavailableLabel.alpha = 0
            }, completion: { _ in
                self.cameraUnavailableLabel.isHidden = true
            }
            )
        }
    }
    
    @IBAction func closeCameraButtonTapped(_ sender: Any) {
        self.tabBarController?.tabBar.isHidden = false
        
        print("The index is: \(ApplicationConstants.indexBeforeCameraWasOpened)")
        
        let parentTabBarController = self.tabBarController
        parentTabBarController?.selectedIndex = ApplicationConstants.indexBeforeCameraWasOpened
    }
    
    // MARK: - Helpers
    //// Open the login/signup page
    @objc func timedSegueToOnboarder() {
        self.performSegue(withIdentifier: "openLoginFromCamera", sender: nil)
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        //userComesFromLogin = true
        
        if loginButton.titleLabel?.text == ApplicationConstants.majeshiLoginButtonValue {
            self.performSegue(withIdentifier: "openLoginFromCamera", sender: nil)
        } else {
            //pickContact()
            self.performSegue(withIdentifier: "openShipsFromCamera", sender: nil)
        }
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        print("Swipe happened!")
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            print("Swipe happened 1!")
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.right:
                print("Swipe happened! 3a")
                //right view controller
                //let newViewController = ShipPicViewController()
                //self.navigationController?.pushViewController(newViewController, animated: true)
            case UISwipeGestureRecognizer.Direction.left:
                print("Swipe happened! 3b")
                //left view controller
                //let newViewController = ShipPicViewController()
                //self.navigationController?.pushViewController(newViewController, animated: true)
            default:
                break
            }
        }
    }
    
    func cameraViewController(_ cameraViewController: KVNCameraViewController!, didFinishWith image: UIImage!) {
        self.dismiss(animated: true, completion: nil)
        
        newImage = image
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        redoThisShit()
        
        if image != nil {
            newVideoURL = nil
            
            if currentUser != nil {
                /// create file names
                self.fileNameWithoutExtension = UUID().uuidString
                
                performSegue(withIdentifier: "openPicShipDetails", sender: nil)
                
                /*let alert = UIAlertController(title: "Title?", message: "Would you like to give your kascade a title?", preferredStyle: UIAlertControllerStyle.alert)
                 
                 // add the actions (buttons)
                 alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (alert) -> Void in
                 
                 self.sendKascadeButton.isHidden = false
                 self.sendKascadeButton.isEnabled = true
                 self.kascadeTitleTextField.isHidden = false
                 }))
                 alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: { (alert) -> Void in
                 
                 self.uploadKascade()
                 }))
                 
                 // show the alert
                 self.present(alert, animated: true, completion: nil)*/
            } else {
                let alert = UIAlertController(title: "Login required", message: "To upload the kascade you just created, you need to be logged in.", preferredStyle: UIAlertController.Style.alert)
                
                alert.view.tintColor = UIColor(red: 248.0/255.0, green: 119.0/255.0, blue: 20.0/255.0, alpha: 1.0)
                
                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "Login", style: UIAlertAction.Style.default, handler: { (alert) -> Void in
                    //self.openLoginPage()
                    
                    //self.didOpenLoginPage = true
                    self.performSegue(withIdentifier: "openLoginFromCamera", sender: nil)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { (alert) -> Void in
                    
                    self.newVideoURL = nil
                }))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func cameraViewController(_ cameraViewController: KVNCameraViewController!, didFinishWithVideo fileURL: URL!) {
        newVideoURL = fileURL
        self.dismiss(animated: true, completion: nil)
        
        UISaveVideoAtPathToSavedPhotosAlbum(fileURL.path, nil, nil, nil)
        
        redoThisShit()
        
        if newVideoURL != nil {
            newImage = nil
            
            if currentUser != nil {
                /// create file names
                self.fileNameWithoutExtension = UUID().uuidString
                
                videoScreenshot = self.getThumbnailFrom(path: self.newVideoURL!)
                self.saveScreenshotToDevice(image: videoScreenshot!)
                
                performSegue(withIdentifier: "openPicShipDetails", sender: nil)
                
                /*let alert = UIAlertController(title: "Title?", message: "Would you like to give your kascade a title?", preferredStyle: UIAlertControllerStyle.alert)
                 
                 // add the actions (buttons)
                 alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (alert) -> Void in
                 
                 self.sendKascadeButton.isHidden = false
                 self.sendKascadeButton.isEnabled = true
                 self.kascadeTitleTextField.isHidden = false
                 }))
                 alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: { (alert) -> Void in
                 
                 self.uploadKascade()
                 }))
                 
                 // show the alert
                 self.present(alert, animated: true, completion: nil)*/
            } else {
                let alert = UIAlertController(title: "Login required", message: "To upload the kascade you just created, you need to be logged in.", preferredStyle: UIAlertController.Style.alert)
                
                alert.view.tintColor = UIColor(red: 248.0/255.0, green: 119.0/255.0, blue: 20.0/255.0, alpha: 1.0)
                
                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "Login", style: UIAlertAction.Style.default, handler: { (alert) -> Void in
                    //self.openLoginPage()
                    
                    //self.didOpenLoginPage = true
                    self.performSegue(withIdentifier: "openLoginFromCamera", sender: nil)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { (alert) -> Void in
                    
                    self.newVideoURL = nil
                }))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func cameraViewController(_ cameraViewController: KVNCameraViewController!, didFinishWithGifURL fileURL: URL!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func cameraViewController(_ cameraViewController: KVNCameraViewController!, willDismiss sender: Any!) {
        self.dismiss(animated: true, completion: nil)
        
        redoThisShit()
    }
    
    func presentCompose(sender: Any?) {
        let viewController: KVNCameraViewController = KVNCameraViewController.verified()
        
        viewController.settings.maxVideoDuration = 60
        viewController.settings.enableGifMode = false
        viewController.settings.enableCameraMode = true
        viewController.settings.enableAssetPicker = false
        
        viewController.settings.enableStopMotion = true
        viewController.settings.enableVideoMode = true
        
        viewController.settings.defaultCameraMode = kCameraSettingModeVideo
        
        viewController.delegate = self
        self.present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func createNewShipPic(_ sender: Any) {
        if spaceAllocatedExceeded {
            self.displayMajeshiGenericAlert("Space Exceeded!", userMessage: "Oops! You have you exceeded you PicShip storage limit. Please go to you profile and tap the '+ Space' button to get extra space.")
        } else {
            self.presentCompose(sender: nil)
        }
    }
    
    func redoThisShit() {
        recordButton.isEnabled = false
        
        sessionQueue.async {
            // Remove the AVCaptureMovieFileOutput from the session since it doesn't support capture of Live Photos.
            self.session.beginConfiguration()
            
            if self.movieFileOutput != nil {
                self.session.removeOutput(self.movieFileOutput!)
            }
            
            self.session.sessionPreset = .photo
            
            DispatchQueue.main.async {
                self.captureModeControl.isEnabled = true
            }
            
            self.movieFileOutput = nil
            
            if self.photoOutput.isLivePhotoCaptureSupported {
                self.photoOutput.isLivePhotoCaptureEnabled = true
                
                DispatchQueue.main.async {
                    self.livePhotoModeButton.isEnabled = true
                    self.livePhotoModeButton.isHidden = false
                }
            }
            if self.photoOutput.isDepthDataDeliverySupported {
                self.photoOutput.isDepthDataDeliveryEnabled = true
                
                DispatchQueue.main.async {
                    self.depthDataDeliveryButton.isHidden = false
                    self.depthDataDeliveryButton.isEnabled = true
                }
            }
            
            if self.photoOutput.isPortraitEffectsMatteDeliverySupported {
                self.photoOutput.isPortraitEffectsMatteDeliveryEnabled = true
                
                DispatchQueue.main.async {
                    self.portraitEffectsMatteDeliveryButton.isHidden = false
                    self.portraitEffectsMatteDeliveryButton.isEnabled = true
                }
            }
            self.session.commitConfiguration()
        }
        
        livePhotoModeButton.isHidden = true
        depthDataDeliveryButton.isHidden = true
        portraitEffectsMatteDeliveryButton.isHidden = true
        
        sessionQueue.async {
            let movieFileOutput = AVCaptureMovieFileOutput()
            
            if self.session.canAddOutput(movieFileOutput) {
                self.session.beginConfiguration()
                self.session.addOutput(movieFileOutput)
                self.session.sessionPreset = .high
                if let connection = movieFileOutput.connection(with: .video) {
                    if connection.isVideoStabilizationSupported {
                        connection.preferredVideoStabilizationMode = .auto
                    }
                }
                self.session.commitConfiguration()
                
                DispatchQueue.main.async {
                    self.captureModeControl.isEnabled = true
                }
                
                self.movieFileOutput = movieFileOutput
                
                DispatchQueue.main.async {
                    self.recordButton.isEnabled = true
                }
            }
        }
    }
    
    /**
     Create a screenshot from a video url.
     
     - Parameters:
     - path: the video url
     
     - Returns: void.
     */
    func getThumbnailFrom(path: URL) -> UIImage? {
        do {
            print("Inside getThumbnailFrom")
            let asset = AVURLAsset(url: path , options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
    /**
     Save a screenshot to the device
     
     - Parameters:
     - image: the image to be saved
     
     - Returns: void.
     */
    func saveScreenshotToDevice(image: UIImage) {
        print("Inside saveScreenshotToDevice")
        
        /// The directory of the documents folder
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
        
        /// The URL of the documents folder
        let documentDirectoryURL = URL(fileURLWithPath: documentDirectory)
        
        /// Assign the imahe a unique name
        screenshotFileName = fileNameWithoutExtension! + ".jpg"
        
        /// The local URL of the profile pic
        let localURL = documentDirectoryURL.appendingPathComponent(screenshotFileName!)
        
        /// The local paths of the URLs
        let localPath = localURL.path
        
        /// Write the image data to file
        //let data = UIImageJPEGRepresentation(image, 0.0)
        let data = image.jpegData(compressionQuality: 0.0)
        
        try? data!.write(to: URL(fileURLWithPath: localPath), options: [.atomic])
        
        /// The location of the profile pic
        uploadScreenshotURL = URL(fileURLWithPath: localPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /// Has a segue just happened
        ApplicationConstants.hasASeguedHappenedInTheHomePage = true
        
        /*if (segue.identifier == "OpenUserFolder") {
         weak var ufvc = segue.destination as? UserFilesViewController
         
         ufvc?.folderOwner = selectedFolderOwner
         ufvc?.ownerFirstName = selectedFolderOwnerFirstName
         }*/
        
        if (segue.identifier == "openPicShipDetails") {
            print("inside the segue identifier openPicShipDetails")
            let navigationController = segue.destination as! UINavigationController
            let pcdvc = navigationController.viewControllers[0] as! PicShipDetailsViewController
            
            //let navigationController = window?.rootViewController as! UINavigationController
            //let firstVC = navigationController.viewControllers[0] as! NameOfFirstViewController
            
            if videoScreenshot == nil {
                print("videoScreenshot is nil")
            } else {
                print("videoScreenshot is not nil")
            }
            
            if newVideoURL == nil {
                pcdvc.shipPicImage = newImage
            } else {
                pcdvc.shipPicImage = videoScreenshot
            }
            pcdvc.shipPicURL = newVideoURL
        }
        
        
        if (segue.identifier == "openShipPicsScrollViewFromCamera") {
            spvcwsv = segue.destination as? ShipPicViewControllerWithScrollView
        }
        
        if (segue.identifier == "openUserSearchFromCamera") {
            print("inside the segue identifier openPicShipDetails")
            let navigationController = segue.destination as! UINavigationController
            let usvc = navigationController.viewControllers[0] as! UserSearchViewController
            
            if mainSearchBar.text != "" {
                usvc.searchedUserName = mainSearchBar.text
                
                usvc.userDataDelegate = self
            }
        }
        
        if (segue.identifier == "openProfileFromUserSearch") {
            let navigationController = segue.destination as! UINavigationController
            let upvc = navigationController.viewControllers[0] as! UserProfileViewController
            
            if searchedUserID != nil {
                upvc.searchedUserID = searchedUserID
            }
            
            movedForwardAndSelectedContact = false
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        //
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //searchActive = false
        searchBar.endEditing(true)
        //self.revealViewController()!.revealToggle(nil)
        if searchBar.text != "" {
            if currentUser != nil {
                performSegue(withIdentifier: "openUserSearchFromCamera", sender: nil)
            } else {
                self.displayMajeshiGenericAlert("Please log in", userMessage: "To perform a search, you have be logged in. Please log in.")
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func setUserData(userID: String?, hasMoveForwardAndChanged: Bool) {
        print("setMessageData called")
        self.searchedUserID = userID
        self.movedForwardAndSelectedContact = hasMoveForwardAndChanged
    }
    
    func getMyShipPics() {
        if currentUser != nil {
            print("Inside getPublicShipPics() 01")
            let dBase = Firestore.firestore()
            
            let picShipRef = dBase.collection("picShip").document(currentUser!).collection("picShips")
            
            picShipRef.order(by: "createdAt", descending: true).getDocuments { (querySnapshot, error) in
                print(querySnapshot)
                print("querySnapshot count: \(querySnapshot?.count)")
                querySnapshot?.count
                print("Inside getPublicShipPics() 02")
                if error == nil {
                    print("Inside getPublicShipPics() 04")
                    if let queryDocumentSnapshot = querySnapshot?.documents {
                        print(queryDocumentSnapshot)
                        print("Inside getPublicShipPics() 05")
                        print("The number of documents is: \(queryDocumentSnapshot.count)")
                        
                        for data in queryDocumentSnapshot {
                            print(data)
                            print("Inside getPublicShipPics() 06")
                            let mainKey = data.documentID
                            
                            let picShipMetaDict = data.data()
                            if let videoFileURL = picShipMetaDict["videoFileURL"] as? String, let imageFileURL = picShipMetaDict["imageFileURL"] as? String, let title = picShipMetaDict["title"] as? String, let createdAt = picShipMetaDict["createdAt"] as? Int, let dueAt = picShipMetaDict["dueAt"] as? Int, let isVideo = picShipMetaDict["isVideo"] as? Bool, let isPublic = picShipMetaDict["isPublic"] as? Bool {
                                
                                if isVideo {
                                    self.userFiles.append(videoFileURL)
                                } else {
                                    self.userFiles.append(imageFileURL)
                                }
                            }
                        }
                        
                        self.updateSpaceAllocation()
                    } else {
                        self.updateSpaceAllocation()
                    }
                } else {
                    print("Inside getPublicShipPics() 03")
                    print("Error: \(error?.localizedDescription)")
                }
            }
        }
    }
    
    func updateSpaceAllocation() {
        /// Check for nil
        if currentUser != nil {
            let dBase = Firestore.firestore()
            let subscriptionRef = dBase.collection("subscriptions").document(currentUser!).collection("PicShip900MegsFor30Days")
            
            subscriptionRef.getDocuments { (querySnapshot, error) in
                if error == nil {
                    if let queryDocumentSnapshot = querySnapshot?.documents {
                        for data in queryDocumentSnapshot {
                            let subscriptionDict = data.data()
                            
                            if let creationAtTimeStamp = subscriptionDict["creationAt"] as? Int {
                                let currentDate = Date()
                                let creationAt = Date(timeIntervalSince1970: TimeInterval(creationAtTimeStamp))
                                
                                let minuteDifference: Double = currentDate.timeIntervalSince(creationAt) / 60.0
                                let minuteDifferenceInt = Int(minuteDifference)
                                
                                let timeLeftOnSubscription: Int = self.subscriptionDuration - minuteDifferenceInt
                                
                                if timeLeftOnSubscription > 0 {
                                    self.spaceAllocated = 1024 * 1024 * 1024;
                                    
                                    //self.getTotalFileSize()
                                } else {
                                    self.spaceAllocated = 100 * 1024 * 1024;
                                    
                                    //self.getTotalFileSize()
                                }
                                
                                if timeLeftOnSubscription > 0 {
                                    break
                                }
                            }
                        }
                        
                        self.getTotalFileSize()
                    } else {
                        self.getTotalFileSize()
                    }
                }
            }
        }
    }
    
    func getTotalFileSize() {
        userFilesTotalSize = 0
        
        var count = 0
        for userFile in userFiles {
            print("Ïnside getTotalFileSize 01")
            /// Get a reference to the image using the URL
            let ref = Storage.storage().reference(forURL: userFile)
            
            ref.getMetadata { (metaData, error) in
                if error != nil {
                    // Do nothing
                    print(error)
                } else {
                    print("Ïnside getTotalFileSize 03")
                    print((metaData?.name)! + ": \(String(describing: metaData?.size))")
                    
                    self.userFilesTotalSize = self.userFilesTotalSize + metaData!.size
                    
                    count = count + 1
                    
                    if count == self.userFiles.count {
                        print("The total file size is: \(self.userFilesTotalSize)")
                        
                        if self.userFilesTotalSize > self.spaceAllocated {
                            self.spaceAllocatedExceeded = true
                        }
                        
                        self.createShipPicButton.titleLabel?.text = "Create"
                        self.createShipPicButton.isEnabled = true
                        
                        if !self.peersTooltipHasBeenShow {
                            AMTooltipView(message: "The 'Create' button is how you create your 'ShipPics'. Through this button, you can create pictures or videos that will help you remember or commemorate scheduled events. PLEASE NOTE: only contacts stored with a country code can be searched or tagged on PicShip. For example, +1 555 555-1234 - only a contact stored like this on your phone can be found.",
                                          focusView: self.createShipPicButton, //pass view you want show tooltip over it
                                target: self)
                            
                            self.peersTooltipHasBeenShow = true
                        }
                    }
                }
            }
        }
        
        if userFiles.count < 1 {
            if self.userFilesTotalSize > self.spaceAllocated {
                self.spaceAllocatedExceeded = true
            }
            
            self.createShipPicButton.titleLabel?.text = "Create"
            createShipPicButton.isEnabled = true
            
            if !self.peersTooltipHasBeenShow {
                AMTooltipView(message: "The 'Create' button is how you create your 'ShipPics'. Through this button, you can create pictures or videos that will help you remember or commemorate scheduled events. PLEASE NOTE: only contacts stored with a country code can be searched or tagged on PicShip. For example, +1 555 555-1234 - only a contact stored like this on your phone can be found.",
                              focusView: self.createShipPicButton, //pass view you want show tooltip over it
                    target: self)
                
                self.peersTooltipHasBeenShow = true
            }
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
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion: nil)
    }
}

extension AVCaptureVideoOrientation {
    init?(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeRight
        case .landscapeRight: self = .landscapeLeft
        default: return nil
        }
    }
    
    init?(interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeLeft
        case .landscapeRight: self = .landscapeRight
        default: return nil
        }
    }
}

extension AVCaptureDevice.DiscoverySession {
    var uniqueDevicePositionsCount: Int {
        var uniqueDevicePositions: [AVCaptureDevice.Position] = []
        
        for device in devices {
            if !uniqueDevicePositions.contains(device.position) {
                uniqueDevicePositions.append(device.position)
            }
        }
        
        return uniqueDevicePositions.count
    }
}
