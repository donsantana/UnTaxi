//
//  RegistroDelegatesExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 8/5/21.
//  Copyright © 2021 Done Santana. All rights reserved.
//

import UIKit
import CountryPicker

extension RegistroController: UITextFieldDelegate{
  //MARK:- CONTROL DE TECLADO VIRTUAL
  //Funciones para mover los elementos para que no queden detrás del teclado
  func textFieldDidBeginEditing(_ textField: UITextField) {
    var distanceValue = 0
    switch textField {
    case nombreApText:
      let (valid, message) = telefonoText.validate(.movilNumber)
      if !valid {
				let okAction = UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alertAction in
					self.telefonoText.becomeFirstResponder()
				})
				Alert.showBasic(title: GlobalStrings.formErrorTitle, message: message ?? GlobalStrings.errorGenericoMessage, vc: self, withActions: [okAction])
      }
    case claveText:
      let (valid, message) = nombreApText.validate(.otherText)
      if !valid {
				let okAction = UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alertAction in
					self.nombreApText.becomeFirstResponder()
				})
				Alert.showBasic(title: GlobalStrings.formErrorTitle, message: message ?? GlobalStrings.errorGenericoMessage, vc: self, withActions: [okAction])
      }
      distanceValue = 80
    case confirmarClavText:
      let (valid, message) = claveText.validate(.password)
      if !valid {
				let okAction = UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alertAction in
					self.claveText.becomeFirstResponder()
				})
				Alert.showBasic(title: GlobalStrings.formErrorTitle, message: message ?? GlobalStrings.errorGenericoMessage, vc: self, withActions: [okAction])
      }
      distanceValue = 180
    case correoText:
      let (valid, _) = confirmarClavText.validate(.password)
      if valid && confirmarClavText.text == claveText.text{
        crearCuentaBtn.isEnabled = true
      } else {
				let okAction = UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alertAction in
					self.confirmarClavText.becomeFirstResponder()
				})
				Alert.showBasic(title: GlobalStrings.formErrorTitle, message: GlobalStrings.passNotMatchMessage, vc: self, withActions: [okAction])
      }
      distanceValue = 180
    default:
      break
    }
    
    animateViewMoving(true, moveValue: CGFloat(distanceValue), view: self.view)
  }
  
  func textFieldDidEndEditing(_ textfield: UITextField) {
    //textfield.text = textfield.text!.replacingOccurrences(of: ",", with: ".")
    
    var distanceValue = 0
    switch textfield {
    case telefonoText:
      let (valid, _) = textfield.validate(.movilNumber)
//      if !valid {
//        let alertaDos = UIAlertController (title: "Error en el formulario", message: message, preferredStyle: .alert)
//        alertaDos.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alerAction in
//          self.telefonoText.becomeFirstResponder()
//        }))
//        self.present(alertaDos, animated: true, completion: nil)
//      }
    case nombreApText:
      let (valid, _) = textfield.validate(.otherText)
//      if !valid {
//        let alertaDos = UIAlertController (title: "Error en el formulario", message: message, preferredStyle: .alert)
//        alertaDos.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alerAction in
//          self.nombreApText.becomeFirstResponder()
//        }))
//        self.present(alertaDos, animated: true, completion: nil)
//      }
    case claveText:
      let (valid, _) = textfield.validate(.password)
//      if !valid {
//        let alertaDos = UIAlertController (title: "Error en el formulario", message: message, preferredStyle: .alert)
//        alertaDos.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alerAction in
//          self.claveText.becomeFirstResponder()
//        }))
//        self.present(alertaDos, animated: true, completion: nil)
//      }
      distanceValue = 80
    case confirmarClavText:
//      let (valid, message) = textfield.validate(.password)
//      if valid && textfield.text == claveText.text{
//        crearCuentaBtn.isEnabled = true
//      } else {
//        let alertaDos = UIAlertController (title: "Error en el formulario", message: "Las contraseñas no coinciden.", preferredStyle: .alert)
//        alertaDos.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alerAction in
//          self.confirmarClavText.becomeFirstResponder()
//        }))
//        self.present(alertaDos, animated: true, completion: nil)
//      }
      distanceValue = 180
    case correoText:
      let (valid, message) = textfield.validate(.email)
      print("valid \(valid)")
      if !valid && !textfield.text!.isEmpty {
				let okAction = UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alertAction in
					self.correoText.becomeFirstResponder()
				})
				Alert.showBasic(title: GlobalStrings.formErrorTitle, message: message ?? GlobalStrings.errorGenericoMessage, vc: self, withActions: [okAction])
      }
      distanceValue = 180
    default:
      break
    }
    
    animateViewMoving(false, moveValue: CGFloat(distanceValue), view: self.view)
  }
  
  @objc func textFieldDidChange(_ textField: UITextField) {
    if textField.text!.count > 0{
      crearCuentaBtn.isEnabled = true
    }
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
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.endEditing(true)
    switch textField {
    case telefonoText:
      let (valid, _) = textField.validate(.movilNumber)
      if valid {
        nombreApText.becomeFirstResponder()
      }
    case nombreApText:
      let (valid, _) = textField.validate(.otherText)
      if valid {
        claveText.becomeFirstResponder()
      }
    case claveText:
      // Validate Text Field
      let (valid, _) = textField.validate(.password)
      if valid {
        confirmarClavText.becomeFirstResponder()
      }
    case confirmarClavText:
      let (valid, _) = textField.validate(.password)
      if valid && textField.text == claveText.text{
        correoText.becomeFirstResponder()
      } else {
				let okAction = UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alertAction in
					self.confirmarClavText.becomeFirstResponder()
				})
				Alert.showBasic(title: GlobalStrings.formErrorTitle, message: GlobalStrings.passNotMatchMessage, vc: self, withActions: [okAction])
      }
      break
    case correoText:
      let (valid, message) = textField.validate(.email)
      print("valid \(valid)")
      if !valid && !textField.text!.isEmpty {
				let okAction = UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alertAction in
					self.correoText.becomeFirstResponder()
				})
				Alert.showBasic(title: GlobalStrings.formErrorTitle, message: message ?? GlobalStrings.errorGenericoMessage, vc: self, withActions: [okAction])
      } else {
        self.sendNewUserData()
      }
      break
    default:
      telefonoText.resignFirstResponder()
    }
    return true
  }
  
  // MARK: - Helper Methods

  fileprivate func validateTextField( textField: UITextField) -> (Bool, String?) {
      guard let text = textField.text else {
          return (false, nil)
      }

    switch textField {
    case telefonoText:
			return (textField.text?.count == 10 && textField.text!.isNumeric, GlobalStrings.telefonoNotValidMessage)
    case confirmarClavText:
			return (text == claveText.text, GlobalStrings.passNotMatchMessage)
      
    default:
			return (text.count > 0, GlobalStrings.emptyFieldMessage)
    }
  }
}


extension RegistroController: ApiServiceDelegate{
  func apiRequest(_ controller: ApiService, registerUserAPI success: Bool, msg: String) {
		let okAction = UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alertAction in
			if success{
				self.goToLoginView()
			} else {
				self.waitingView.isHidden = true
			}
		})
		Alert.showBasic(title: success ? GlobalStrings.registroUsuarioTitle : GlobalStrings.formErrorTitle, message: msg, vc: self, withActions: [okAction])
  }
    
    func apiRequest(_ controller: ApiService, newRegisterUserAPI success: Bool, statusCode: Int, msg: String) {
        switch statusCode {
        case 201:
            //registration success
            let okAction = UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alertAction in
                self.goToLoginView()
            })
            Alert.showBasic(title: "Éxito", message: msg, vc: self, withActions: [okAction])
        case 404:
            //Codigo de activacion invalido o caducado
            let okAction = UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alertAction in
                self.showCodeVerificationView()
            })
            Alert.showBasic(title: "", message: msg, vc: self, withActions: [okAction])
        case 400:
            //Codigo generenado, revise Whatsapp
            showCodeVerificationView()
        case 409:
            //Usuarion Existente
            let okAction = UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alertAction in
                self.goToLoginView()
            })
            Alert.showBasic(title: "", message: msg, vc: self, withActions: [okAction])
        case 410:
            //Usuarion Existente
            let okAction = UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alertAction in
                self.waitingView.isHidden = true
            })
            Alert.showBasic(title: "", message: msg, vc: self, withActions: [okAction])
        default:
            //General Error
            let okAction = UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alertAction in
                self.waitingView.isHidden = true
            })
            Alert.showBasic(title: "", message: GlobalStrings.errorGenericoMessage, vc: self, withActions: [okAction])
        }
    }
  
  func apiRequest(_ controller: ApiService, getAPIError msg: String) {
		let okAction = UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alertAction in
			self.waitingView.isHidden = true
		})
		Alert.showBasic(title: GlobalStrings.formErrorTitle, message: msg, vc: self, withActions: [okAction])
  }
  
}

extension RegistroController: CountryPickerDelegate{
  // a picker item was selected
  func countryPhoneCodePicker(_ picker: CountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
     //pick up anythink
    countryCodeText.text = phoneCode
    flagImageView.image = flag
    picker.isHidden = true
  }
}
