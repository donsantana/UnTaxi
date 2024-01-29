//
//  SplashController.swift
//  UnTaxi
//
//  Created by Done Santana on 8/22/23.
//  Copyright © 2023 Done Santana. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController, AppOpenAdManagerDelegate {
    /// Number of seconds remaining to show the app open ad.
    /// This simulates the time needed to load the app.
    var secondsRemaining: Int = 5
    /// The countdown timer.
    var countdownTimer: Timer?
    /// Text that indicates the number of seconds left to show an app open ad.
    @IBOutlet weak var copyrightLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppOpenAdManager.shared.appOpenAdManagerDelegate = self
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        copyrightLabel.isHidden = GlobalConstants.bundleId != "com.xoait.UnTaxi"
        copyrightLabel.text = "Copyright © \(currentYear). All rights reserved."
        copyrightLabel.textColor = CustomAppColor.launchViewColor
        activityIndicator.color = CustomAppColor.launchViewColor
        startTimer()
    }
    
    @objc func decrementCounter() {
        secondsRemaining -= 1
        if secondsRemaining > 0 {
            AppOpenAdManager.shared.showAdIfAvailable(viewController: self)
        } else {
            countdownTimer?.invalidate()
            //AppOpenAdManager.shared.showAdIfAvailable(viewController: self)
            startMainScreen()
        }
    }
    
    func startTimer() {
        //splashScreenLabel.text = "App is done loading in: \(secondsRemaining)"
        countdownTimer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(SplashViewController.decrementCounter),
            userInfo: nil,
            repeats: true)
    }
    
    func startMainScreen() {
        let mainStoryBoard = UIStoryboard(name: "Login", bundle: nil)
        let vc = mainStoryBoard.instantiateViewController(withIdentifier: "LoginView")
        self.navigationController?.show(vc, sender: self)
        self.dismiss(animated: false)
        
    }
    
    // MARK: AppOpenAdManagerDelegate
    func appOpenAdManagerAdDidComplete(_ appOpenAdManager: AppOpenAdManager) {
        //startMainScreen()
    }
}
