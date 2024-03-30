//
//  PicShipContainerViewController.swift
//  PicShip
//
//  Created by Thabo David Klass on 24/05/2019.
//  Copyright © 2019 Open Beacon. All rights reserved.
//

import UIKit

class PicShipContainerViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 1) Create the three views used in the swipe container view
        /*var AVc :AViewController =  AViewController(nibName: "AViewController", bundle: nil);
        var BVc :BViewController =  BViewController(nibName: "BViewController", bundle: nil);
        var CVc :CViewController =  CViewController(nibName: "CViewController", bundle: nil);*/
        
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let shipPicViewController01 = mainStoryboard.instantiateViewController(withIdentifier: "ShipPicViewController") as! ShipPicViewController
        let shipPicViewController02 = mainStoryboard.instantiateViewController(withIdentifier: "ShipPicViewController") as! ShipPicViewController
        let cameraViewController = mainStoryboard.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
        
        // 2) Add in each view to the container view hierarchy
        //    Add them in opposite order since the view hieracrhy is a stack
        self.addChild(shipPicViewController02);
        self.scrollView!.addSubview(shipPicViewController02.view);
        shipPicViewController02.didMove(toParent: self);
        
        self.addChild(shipPicViewController01);
        self.scrollView!.addSubview(shipPicViewController01.view);
        shipPicViewController01.didMove(toParent: self);
        
        self.addChild(cameraViewController);
        self.scrollView!.addSubview(cameraViewController.view);
        cameraViewController.didMove(toParent: self);
        
        
        // 3) Set up the frames of the view controllers to align
        //    with eachother inside the container view
        var adminFrame :CGRect = cameraViewController.view.frame;
        adminFrame.origin.x = adminFrame.width;
        shipPicViewController01.view.frame = adminFrame;
        
        var BFrame :CGRect = shipPicViewController01.view.frame;
        BFrame.origin.x = 2*BFrame.width;
        shipPicViewController02.view.frame = BFrame;
        
        
        // 4) Finally set the size of the scroll view that contains the frames
        var scrollWidth: CGFloat  = 3 * self.view.frame.width
        var scrollHeight: CGFloat  = self.view.frame.size.height
        self.scrollView!.contentSize = CGSize(width: scrollWidth, height: scrollHeight);
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
