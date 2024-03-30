//
//  SpreebieTabBarController.swift
//  Spreebie
//
//  Created by Thabo David Klass on 10/12/15.
//  Copyright (c) 2015 Open Beacon. All rights reserved.
//

import UIKit

class PicShipTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        // Do any additional setup after loading the view.
        
        /// Get the navigation controller of the Products page
        let navigationController = self.viewControllers![1] as! UINavigationController // or whatever tab index you're trying to access
        
        /// Get the Products page from the navigation controller
        let ppvc = navigationController.viewControllers[0] as! ProductsPageViewController
        
        /// Set the patriarch view controller in the Products page as self
        /// This is used during login
        ppvc.patriarch = self
        
        /// Get the navigation controller of the Settings page
        let navigationController4 = self.viewControllers![4] as! UINavigationController
        
        /// Get the Settings page from the navigation controller
        let sstvc = navigationController4.viewControllers[0] as! SpreebieSettingsTableViewController
        
        /// Set the patriarch view controller in the Settings page as self
        /// This is used during logout
        sstvc.patriarch = self*/
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*let lar = LoginAndRegistration()
        
        let isUserLoggedIn = UserDefaults.standard.bool(forKey: "isUserLoggedInPicShip")
            
        /// Disable tabs that require a user to be logged in
        if !isUserLoggedIn {
            lar.disableTabsThatReguireLogin(self)
        }*/
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let indexOfTab = tabBar.items?.index(of: item)
        print("pressed tabBar: \(String(describing: indexOfTab))")
        if (indexOfTab! != 2) {
            ApplicationConstants.indexBeforeCameraWasOpened = indexOfTab!
        }
    }
}
