//
//  RegistroFunctionsExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 8/5/21.
//  Copyright © 2021 Done Santana. All rights reserved.
//

import UIKit

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
                    ApiService.shared.newRegisterUserAPI(url: GlobalConstants.registerUrl, params: [
                        "password": claveText.text!,
                        "movil": telefonoText.text!,
                        "nombreapellidos": nombreApText.text!,
                        "email": correoText.text!,
                        "so": "IOS",
                        "version": GlobalConstants.appVersion,
                        "recomendado": ""]) { result in
                            self.registerResultProcesor(result: result)
                        }
                } else {
                    ApiService.shared.registerUserAPI(url: GlobalConstants.registerUrl, params: [
                        "password": claveText.text!,
                        "movil": telefonoText.text!,
                        "nombreapellidos": nombreApText.text!,
                        "email": correoText.text!,
                        "so": "IOS",
                        "version": GlobalConstants.appVersion,
                        "recomendado": ""]) { result in
                            var errorMessage = ""
                            switch result {
                            case .success(let message):
                                self.showRegistrationMessage(message: message, success: true)
                            case .failure(let error):
                                switch error {
                                case .invalidResponse(message: let message):
                                    errorMessage = message
                                case .serverError(message: let message):
                                    errorMessage = message
                                default:
                                    errorMessage = error.localizedDescription
                                }
                                self.showRegistrationMessage(message: errorMessage, success: false)
                            }
                            
                        }
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
    
    internal func registerResultProcesor(result: Result<Dictionary<String, AnyObject>, APIError>) {
        switch result {
        case .success(let result):
            let message = result["msg"] as? String ?? GlobalStrings.errorGenericoMessage
            switch result["statusCode"] as! Int {
            case 201:
                //registration success
                let okAction = UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alertAction in
                    self.goToLoginView()
                })
                Alert.showBasic(title: "Éxito", message: message, vc: self, withActions: [okAction])
            case 404:
                //Codigo de activacion invalido o caducado
                let okAction = UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alertAction in
                    self.showCodeVerificationView()
                })
                Alert.showBasic(title: "", message: message, vc: self, withActions: [okAction])
            case 400:
                //Codigo generenado, revise Whatsapp
                showCodeVerificationView()
            case 409:
                //Usuarion Existente
                let okAction = UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alertAction in
                    self.goToLoginView()
                })
                Alert.showBasic(title: "", message: message, vc: self, withActions: [okAction])
            case 410:
                //Usuarion Existente
                let okAction = UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alertAction in
                    self.waitingView.isHidden = true
                })
                Alert.showBasic(title: "", message: message, vc: self, withActions: [okAction])
            default:
                //General Error
                let okAction = UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alertAction in
                    self.waitingView.isHidden = true
                })
                Alert.showBasic(title: "", message: GlobalStrings.errorGenericoMessage, vc: self, withActions: [okAction])
            }
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
    func showRegistrationMessage(message: String, success: Bool) {
        let okAction = UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: { alertAction in
            self.goToLoginView(success)
        })
        Alert.showBasic(title: success ? GlobalStrings.registroUsuarioTitle : GlobalStrings.formErrorTitle, message: message, vc: self, withActions: [okAction])
    }
  
    func goToLoginView(_ success: Bool = true) {
        DispatchQueue.main.async {
            if success {
                guard let viewcontrollers = self.navigationController?.viewControllers else {
                    return
                }
                viewcontrollers.forEach({ (vc) in
                    if let inventoryListVC = vc as? LoginController {
                        self.navigationController!.popToViewController(inventoryListVC, animated: true)
                    }
                })
            } else {
                self.waitingView.isHidden = true
            }
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
