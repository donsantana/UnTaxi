//
//  RegisterValidationController.swift
//  UnTaxi
//
//  Created by Done Santana on 12/28/23.
//  Copyright © 2023 Done Santana. All rights reserved.
//

import UIKit


class RegisterValidationController: UIViewController {
    var timeToValidateCode = 180
    var registerCodeTimer = Timer()
    let apiService = ApiService()
    var registrationParams: Dictionary<String, String>!
    var parenController:UIViewController!
    var counter = 1
    
    @IBOutlet weak var waitingView: UIVisualEffectView!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var timerText: UILabel!
    @IBOutlet weak var codeText: UITextField!
    @IBOutlet weak var verificarBtn: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        codeText.delegate = self
        apiService.delegate = self
        waitingView.addStandardConfig()
        activityIndicator.color = CustomAppColor.activityIndicatorColor
        titleText.text = GlobalStrings.codeValidationTitle
        descriptionText.text = GlobalStrings.codeValidationMessage
        codeText.placeholder = GlobalStrings.codeValidationPlaceholder
        verificarBtn.addCustomActionBtnsColors()
        startTimer()
    }
    
    func startTimer() {
        registerCodeTimer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updateTimerWatch),
            userInfo: nil,
            repeats: true)
    }
    
    @objc func updateTimerWatch() {
        if timeToValidateCode == 0 {
            self.dismiss(animated: false)
        } else {
            timeToValidateCode -= 1
            timerText.text = String(format: "%02d:%02d",((timeToValidateCode % 3600) / 60),((timeToValidateCode % 3600) % 60))
        }
    }
    
    func validateCode() {
        /*password: string
         movil: string
         nombreapellidos: string
         email: string
         so: string
         version: string
         recomendado: string
         codigo: null / string
         */
        if let codeText = codeText.text {
            registrationParams.updateValue(codeText, forKey: "codigo")
        }
        apiService.newRegisterUserAPI(url: GlobalConstants.registerUrl, params: registrationParams)
    }
    
    func goBackToLogin() {
        dismiss(animated: false)
        guard let parent = (self.parenController as? RegistroController) else {return}
        parent.goToLoginView()

    }
    
    func showMaxIntentAlert() {
        let okAction = UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alertAction in
            self.dismiss(animated: false)
        })
        Alert.showBasic(title: "", message: GlobalStrings.maxIntentMessage, vc: self, withActions: [okAction])
    }
    
    @IBAction func sendValidationCode(_ sender: Any) {
        if counter <= 3 {
            counter += 1
            validateCode()
        } else {
            showMaxIntentAlert()
        }
    }
    
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: false)
    }
}

extension RegisterValidationController: ApiServiceDelegate {
    func apiRequest(_ controller: ApiService, newRegisterUserAPI success: Bool, statusCode: Int, msg: String) {
        DispatchQueue.main.async {
            switch statusCode {
            case 201:
                //registration success
                let okAction = UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alertAction in
                    self.goBackToLogin()
                })
                Alert.showBasic(title: "", message: msg, vc: self, withActions: [okAction])
               
            case 404:
                //Codigo de activacion invalido o caducado
                let okAction = UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alertAction in
                })
                Alert.showBasic(title: "", message: msg, vc: self, withActions: [okAction])
            case 400:
                //Codigo generenado, revise Whatsapp
                let okAction = UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alertAction in
                })
                Alert.showBasic(title: "", message: msg, vc: self, withActions: [okAction])
            case 409:
                //Usuarion Existente
                let okAction = UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alertAction in
                    self.goBackToLogin()
                })
                Alert.showBasic(title: "", message: msg, vc: self, withActions: [okAction])
            default:
                //General Error
                let okAction = UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alertAction in
                    self.goBackToLogin()
                })
                Alert.showBasic(title: "", message: GlobalStrings.errorGenericoMessage, vc: self, withActions: [okAction])
            }
        }
        
    }
}

extension RegisterValidationController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateViewMoving(true, moveValue: 250, view: self.view)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateViewMoving(true, moveValue: -250, view: self.view)
    }
    
    func animateViewMoving (_ up:Bool, moveValue :CGFloat, view : UIView){
      let movementDuration:TimeInterval = 0.3
      let movement:CGFloat = ( up ? -moveValue : moveValue)
      UIView.beginAnimations( "animateView", context: nil)
      UIView.setAnimationBeginsFromCurrentState(true)
      UIView.setAnimationDuration(movementDuration)
      view.frame = view.frame.offsetBy(dx: 0,  dy: movement)
      UIView.commitAnimations()
    }
}
