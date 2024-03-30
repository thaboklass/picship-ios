//
//  ApplicationConstants.swift
//  Spreebie
//
//  Created by Thabo David Klass on 03/06/2017.
//  Copyright © 2017 Spreebie, Inc. All rights reserved.
//

import Foundation

struct ApplicationConstants {
    /// The Majeshi AWS identity pool ID
    static var majeshiIdentityPoolID: String = "us-east-1:31e0331f-aaa0-4877-98fb-9c1380d1ab63"
    
    /// The Majeshi S3 bucket
    static var majeshiS3Bucket: String = "majeshi-userfiles-mobilehub-1247101272"
    
    /// The Majeshi SNS platform application ARN
    //static var majeshiSNSPlatformApplicationArn: String = "arn:aws:sns:us-east-1:203525439813:app/APNS_SANDBOX/PicShipSNSDevelopment"
    static var majeshiSNSPlatformApplicationArn: String = "arn:aws:sns:us-east-1:203525439813:app/APNS/PicShipSNSProduction"
    
    /// The Majeshi APNS type
    //static var majeshiAPNSType: String = "APNS_SANDBOX"
    static var majeshiAPNSType: String = "APNS"
    
    // The Majeshi In-App Purchases ID
    static var picShipInAppPurchasesID: String = "PicShip900MegsFor30Days"
    
    /// The URL to the Majeshi terms
    static var majeshiTermsURL: String = "http://openbeacon.biz/picship-terms-of-service/"
    
    /// The URL to the Majeshi contact us
    static var majeshiContactUSURL: String = "http://openbeacon.biz/contact-us/"
    
    /// The URL to the Majeshi privacy policy
    static var majeshiPrivacyPolicyURL: String = "http://openbeacon.biz/picship-privacy-policy/"
    
    /// The URL to the Majeshi landing page
    static var majeshiLandingPageURL: String = "http://openbeacon.biz/picship/"
    
    /// The database empty value string
    static var dbEmptyValue: String = "empty"
    
    /// The profile picture download error message
    static var profilePictureDownloadErrorMessage: String = "Could not load image."
    
    /// The Majeshi user ID key value
    static var majeshiUserIDKey: String = "picShipUID"
    
    /// The login button text
    static var majeshiLoginButtonValue: String = "Login"
    
    /// Majeshi user just logged out value
    static var majeshiUserJustLoggedOutValue: String = "picShipJustLoggedOut"
    
    /// Majeshi application's small "no" value
    static var majeshiSmallNoValue: String = "no"
    
    /// Majeshi application's small "yes" value
    static var majeshiSmallYesValue: String = "yes"
    
    /// Majeshi user just logged in value
    static var majeshiUserJustLoggedInValue: String = "picShipsJustLoggedIn"
    
    /// Has the view controller segued
    static var hasASeguedHappenedInTheHomePage: Bool = false
    
    /// The tabbar index before the camera was opened
    static var indexBeforeCameraWasOpened = 0
    
    /// Just moved back from the date picker
    static var justMovedBackFromDatePicker: Bool = false
    
    static var shipPicEditingJustHappened: Bool = false
    
    static var shipPicEditingJustHappenedForBackTableVC: Bool = false
    
    static var justMovedBackFromSignOut: Bool = false
    
    static var profilePictureUpdated: Bool = false
}
