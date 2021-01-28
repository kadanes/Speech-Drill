//
//  AppDelegate.swift
//  TOEFL Speaking
//
//  Created by Parth Tamane on 31/07/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let locationManager: CLLocationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let userDefaults = UserDefaults.standard
        
        let topicNumber  = userDefaults.integer(forKey: "topicNumber")
        if (topicNumber == 0) {
            userDefaults.set(1, forKey: "topicNumber")
        }
        
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        
        userDefaults.setValue(nil, forKey: userLocationCodeKey)
        locationManager.delegate = self
        
        if #available(iOS 13.0, *) {
            self.window?.overrideUserInterfaceStyle = UIUserInterfaceStyle.dark
        }
        
        //        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //        let mainVC = storyboard.instantiateViewController(withIdentifier: "MainVC") as! MainVC
        
        let sideNav = SideNavigationController()
        let sideNavigationController = SlidingNavigationController.init(rootViewController: sideNav)
        self.window?.rootViewController = sideNavigationController
        
        // For iOS 10 display notification (sent via APNS)
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        application.registerForRemoteNotifications()
        InstanceID.instanceID().getID { (token, error) in
            print("Token: ", token)
            Messaging.messaging().subscribe(toTopic: speechDrillDiscussionsFCMTopicName)
        }
        
        
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        removeLocationFromFirebase()
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        storeLocationInFirebase(locationManager: locationManager)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        let uuid = UIDevice.current.identifierForVendor!.uuidString
        userLocationReference.child(uuid).onDisconnectSetValue(nil)
        print("Making uuid ", uuid, "ofline")
    }
    
    open func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
}

//MARK:- Location manager

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Storing location on change")
        
        if CLLocationManager.authorizationStatus() ==  CLAuthorizationStatus.notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        storeLocationInFirebase(locationManager: locationManager)
    }
}

//MARK:- Notification Helper

extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func application(_ application: UIApplication,
                 didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken as Data
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        // Print full message.
        print("User Info: ")
        print(userInfo)
//        sideNav?.calledFromVCIndex = 1
//        sideNav?.shouldAutoNavigateToChild = true
    }

    // This method will be called when app received push notifications in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    { completionHandler([UNNotificationPresentationOptions.alert,UNNotificationPresentationOptions.sound,UNNotificationPresentationOptions.badge])
    }

    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("received remote notification")
    }
    
}
