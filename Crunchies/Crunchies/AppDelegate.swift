//
//  AppDelegate.swift
//  Crunchies
//
//  Created by JOSH HENDERSHOT on 9/23/14.
//  Copyright (c) 2014 Joshua Hendershot. All rights reserved.
//

import UIKit
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var GVC: GameViewController!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Crashlytics.startWithAPIKey("8ef04d6ce4e7a8d7079296fd9227b7d3e87ec366")
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        if IS_IPHONE5 {
            var storyboard = UIStoryboard(name: "Main", bundle: nil)
            var rootVC = storyboard.instantiateInitialViewController() as GameViewController
            window!.rootViewController = rootVC
        } else if  IS_IPHONE6 {
            var storyboard = UIStoryboard(name: "iPhone6", bundle: nil)
            var rootVC = storyboard.instantiateInitialViewController() as GameViewController
            window!.rootViewController = rootVC
        } else {
            var storyboard = UIStoryboard(name: "iPhone6Plus", bundle: nil)
            var rootVC = storyboard.instantiateInitialViewController() as GameViewController
            window!.rootViewController = rootVC
            println("iPhone6Plus")
        }
        window!.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

