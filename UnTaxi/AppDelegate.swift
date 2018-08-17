
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

struct myvariables {
    static var socket: SocketIOClient!
    static var cliente : CCliente!
    static var solicitudesproceso: Bool = false
    static var taximetroActive: Bool = false
    static var solpendientes = [CSolicitud]()
    static var grabando = false
    static var SMSProceso = false
    static var UrlSubirVoz:String!
    static var SMSVoz = CSMSVoz()
    static var urlconductor = ""
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{

    var window: UIWindow?
    
    var backgrounTaskIdentifier: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    var myTimer: Timer?
    var BackgroundSeconds = 0
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
        application.isIdleTimerDisabled = true
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
        
        //LEER SI EXISTE EL FICHERO DEL LOGIN
        
        return true
    }
    
    @objc func TimerMethod(sender: Timer){
        let backgroundTimeRemaining = UIApplication.shared.backgroundTimeRemaining
        if backgroundTimeRemaining == Double.greatestFiniteMagnitude{
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
        if myvariables.solicitudesproceso{
            let localNotification = UILocalNotification()
            localNotification.alertAction = "Regresar a la aplicación"
            localNotification.alertBody = "Debe mantener la aplicación abierta si desea comunicarse con el conductor."
            localNotification.fireDate = Date(timeIntervalSinceNow: 0)
            UIApplication.shared.scheduleLocalNotification(localNotification)
        }
        myTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self,selector: #selector(TimerMethod), userInfo: nil, repeats: true)
        backgrounTaskIdentifier = application.beginBackgroundTask(withName: "task1", expirationHandler: {
            [weak self] in
            self!.endBackgroundTask()
        })
    }

    func endBackgroundTask(){
        if let timer = self.myTimer{
            timer.invalidate()
            self.myTimer = nil
            UIApplication.shared.endBackgroundTask(self.backgrounTaskIdentifier)
            self.backgrounTaskIdentifier = UIBackgroundTaskInvalid
        }
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        if backgrounTaskIdentifier != UIBackgroundTaskInvalid{
            endBackgroundTask()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
    }
}

