//
//  GameResetViewController.swift
//  Crunchies
//
//  Created by JOSH HENDERSHOT on 9/29/14.
//  Copyright (c) 2014 Joshua Hendershot. All rights reserved.
//

import UIKit

class GameResetViewController: UIViewController{
    var resetNormal = UIButton(frame: CGRectMake(50, 200, 290, 100))
    var resetElfin = UIButton(frame: CGRectMake(50, 350, 290, 100))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if IS_IPHONE5 {
            resetNormal.frame = CGRectMake(20, 200, 290, 100)
            resetElfin.frame = CGRectMake(20, 350, 290, 100)
            var backgroundView = UIImageView(frame: self.view.frame)
            backgroundView.image = UIImage(named: "Backgroundthing2")
            view.addSubview(backgroundView)
        }
        var backgroundView = UIImageView(frame: self.view.frame)
        backgroundView.image = UIImage(named: "Backgroundthing2")
        view.addSubview(backgroundView)
//        view.backgroundColor = UIColor(patternImage: UIImage(named: "Backgroundthing2"))
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(animated: Bool) {
        UIView.animateWithDuration(0.7, delay: 5.0, options: .CurveEaseOut, animations: {
            self.resetNormal.backgroundColor = UIColor(patternImage: UIImage(named: "Normal"))
            self.resetNormal.layer.cornerRadius = 15
            self.resetNormal.layer.borderWidth = 5
            self.resetNormal.layer.borderColor = UIColor.whiteColor().CGColor

            self.resetElfin.backgroundColor = UIColor(patternImage: UIImage(named: "NoElfinWay"))
            self.resetElfin.layer.cornerRadius = 15
            self.resetElfin.layer.borderWidth = 5
            self.resetElfin.layer.borderColor = UIColor(red: 0.984, green: 0.153, blue: 0.165, alpha: 1.0).CGColor
            
            }, completion: { finished in
                self.resetNormal.addTarget(self, action: Selector("resetGameNormal2"), forControlEvents: .TouchUpInside)
                self.resetElfin.addTarget(self, action: Selector("resetGameElfin2"), forControlEvents: .TouchUpInside)
                self.view.addSubview(self.resetNormal)
                self.view.addSubview(self.resetElfin)
        })
    }
    
    func resetGameElfin2() {
        var nc = NSNotificationCenter.defaultCenter()
        nc.postNotificationName("newGameElfin", object: nil)
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    
    func resetGameNormal2() {
        var nc = NSNotificationCenter.defaultCenter()
        nc.postNotificationName("newGame", object: nil)
//        performSegueWithIdentifier("back", sender: self)
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    
    
}
