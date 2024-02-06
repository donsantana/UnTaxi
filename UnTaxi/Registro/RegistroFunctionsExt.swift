//
//  RegistroFunctionsExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 8/5/21.
//  Copyright © 2021 Done Santana. All rights reserved.
//

import UIKit
import CountryPicker

extension RegistroController{
  
  @objc func ocultarTeclado(){
    self.view.endEditing(true)
  }
  
  func sendNewUserData(){
    
		let (valid, message) = confirmarClavText.validate(.password)
		if valid && confirmarClavText.text == claveText.text {
			let (valid, message) = correoText.validate(.email)
			if !correoText.text!.isEmpty && valid {
				waitingView.isHidden = false
				view.endEditing(true)
                if GlobalConstants.registerValidationIsAnable {
                    apiService.newRegisterUserAPI(url: GlobalConstants.registerUrl, params: [
                        "password": claveText.text!,
                        "movil": telefonoText.text!,
                        "nombreapellidos": nombreApText.text!,
                        "email": correoText.text!,
                        "so": "IOS",
                        "version": GlobalConstants.appVersion,
                        "recomendado": ""])
                } else {
                    apiService.registerUserAPI(url: GlobalConstants.registerUrl, params: [
                        "password": claveText.text!,
                        "movil": telefonoText.text!,
                        "nombreapellidos": nombreApText.text!,
                        "email": correoText.text!,
                        "so": "IOS",
                        "version": GlobalConstants.appVersion,
                        "recomendado": ""])
                }
			} else {
				let okAction = UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alerAction in
					self.correoText.becomeFirstResponder()
				})
				Alert.showBasic(title: GlobalStrings.formErrorTitle, message: message ?? GlobalStrings.errorGenericoMessage, vc: self, withActions: [okAction])
			}
		} else {
			let okAction = UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alerAction in
				self.confirmarClavText.becomeFirstResponder()
			})
			Alert.showBasic(title: GlobalStrings.formErrorTitle, message: GlobalStrings.passNotMatchMessage, vc: self, withActions: [okAction])
		}
	}
  
    func goToLoginView() {
        DispatchQueue.main.async {
            guard let viewcontrollers = self.navigationController?.viewControllers else {
                return
            }
            viewcontrollers.forEach({ (vc) in
                if let inventoryListVC = vc as? LoginController {
                    self.navigationController!.popToViewController(inventoryListVC, animated: true)
                }
            })
        }
    }
    
    func cleanAllTexfields() {
        nombreApText.text?.removeAll()
        claveText.text?.removeAll()
        confirmarClavText.text?.removeAll()
        correoText.text?.removeAll()
        telefonoText.text?.removeAll()
    }
    
    func showCodeVerificationView() {
        //Init timer max 3 min
        DispatchQueue.main.async {
            self.waitingView.isHidden = true
            let mainStoryBoard = UIStoryboard(name: "Login", bundle: nil)
            let vc = mainStoryBoard.instantiateViewController(withIdentifier: "verificationView") as! RegisterValidationController
            vc.registrationParams = [
                "password": self.claveText.text!,
                "movil": self.telefonoText.text!,
                "nombreapellidos": self.nombreApText.text!,
                "email": self.correoText.text!,
                "so": "IOS",
                "recomendado": ""]
            vc.parenController = self
            self.cleanAllTexfields()
            self.present(vc, animated: true)
        }
    }
    
}
