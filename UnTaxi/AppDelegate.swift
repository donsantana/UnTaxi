
//
//  AppDelegate.swift
//  Xtaxi
//
//  Created by Done Santana on 14/10/15.
//  Copyright © 2015 Done Santana. All rights reserved.
//

import UIKit
import CoreLocation
import SocketIO
import AVFoundation
import GoogleMobileAds
//import GooglePlaces
import UserNotifications
//import PaymentezSDK

@UIApplicationMain
 class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate{
  
  var window: UIWindow?
  
  var backgrounTaskIdentifier: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
  var myTimer: Timer?
  var BackgroundSeconds = 0
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    application.isIdleTimerDisabled = true
    
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
      if let error = error {
        print("D'oh: \(error.localizedDescription)")
      } else {
        DispatchQueue.main.async {
          application.unregisterForRemoteNotifications()
          application.registerForRemoteNotifications()
        }
      }
    }
    UNUserNotificationCenter.current().delegate = self
    
    //VISUAL CUSTOMIZATION
    //Navigation Bar
    //UINavigationBar.appearance().barTintColor = .init(CustomAppColor.primaryColor)
    
    // To change colour of tappable items.
   // UINavigationBar.appearance().tintColor = CustomAppColor.textColor
    
    UINavigationBar.appearance().titleTextAttributes = [.foregroundColor : CustomAppColor.textColor,
                                                        .font : UIFont.init(name: "Muli", size: 20.0)!]
    
    // ToolBar
    UIToolbar.appearance().barTintColor = .init(CustomAppColor.primaryColor)
    
    UIToolbar.appearance().tintColor = CustomAppColor.textColor
    
    //TabBar
    //UITabBar.appearance().barTintColor = .init(CustomAppColor.primaryColor)
    //UITabBar.appearance().tintColor = CustomAppColor.textColor
    //UITabBar.appearance().shadowImage = .none
    
    //UILabel.appearance().textColor = CustomAppColor.textColor
    //UILabel.appearance().font = CustomAppFont.normalFont
    
    UITextField.appearance().clearButtonMode = .whileEditing
    //UITextField.appearance().textColor = CustomAppColor.textColor
    //UITextField.appearance().font = CustomAppFont.inputTextFont
    
    //UITextView.appearance().textColor = CustomAppColor.textColor
    //UITextView.appearance().font = CustomAppFont.normalFont
    
    UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: CustomAppColor.buttonsTitleColor], for: .selected)
    UISegmentedControl.appearance().backgroundColor = .white
    
    //UIButton.appearance().titleLabel?.font = CustomAppFont.buttonFont
    
    //GOOGLE ADS CODE
    GADMobileAds.sharedInstance().start(completionHandler: nil)
    // Set the Google Place API's autocomplete UI control
    //GMSPlacesClient.provideAPIKey("AIzaSyDOVTQUV2OeugiuBd3pAVGJbTx2aZ445Ws")
    
    //PaymentezSDKClient.setEnvironment("MERCURIO-EC-CLIENT", secretKey: "8uGTqVeiRBW8oMfAVwHyN51aEsNyM5", testMode: false)
    
    return true
  }
  
  func IsMultitaskingSupported()->Bool{
    return UIDevice.current.isMultitaskingSupported
  }
  
  @objc func TimerMethod(sender: Timer){
    
    let backgroundTimeRemaining = UIApplication.shared.backgroundTimeRemaining
    if backgroundTimeRemaining == .greatestFiniteMagnitude{
      print("Background Time Remaining = Undetermined")
    }else{
      BackgroundSeconds += 1
      print("Background Time Remaining = " + "\(BackgroundSeconds) Secunds")
      
    }
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    //self.MensajeConductor()
    myTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(TimerMethod), userInfo: nil, repeats: true)
    backgrounTaskIdentifier = application.beginBackgroundTask(withName: "task1", expirationHandler: {
      [weak self] in
      if (self?.BackgroundSeconds)! <= 1800 {
        self?.TimerMethod(sender: (self?.myTimer!)!)
      }else{
        globalVariables.socket.emit("data", "#SocketClose,\(globalVariables.cliente.id),# \n")
      }
    })
  }
  
  func endBackgroundTask(){
    if let timer = self.myTimer{
      timer.invalidate()
      self.myTimer = nil
      UIApplication.shared.endBackgroundTask(convertToUIBackgroundTaskIdentifier(self.backgrounTaskIdentifier.rawValue))
      self.backgrounTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    }
    
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    if backgrounTaskIdentifier != UIBackgroundTaskIdentifier.invalid{
      if globalVariables.urlConductor != ""{
        globalVariables.SMSProceso = true
        globalVariables.SMSVoz.ReproducirMusica()
        globalVariables.SMSVoz.ReproducirVozConductor(globalVariables.urlConductor)
      }
      if let timer = self.myTimer{
        timer.invalidate()
        self.myTimer = nil
        BackgroundSeconds = 0
        UIApplication.shared.endBackgroundTask(convertToUIBackgroundTaskIdentifier(self.backgrounTaskIdentifier.rawValue))
        self.backgrounTaskIdentifier = UIBackgroundTaskIdentifier.invalid
      }
    }
    
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.alert, .sound, .badge])
  }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIBackgroundTaskIdentifier(_ input: Int) -> UIBackgroundTaskIdentifier {
  return UIBackgroundTaskIdentifier(rawValue: input)
}
