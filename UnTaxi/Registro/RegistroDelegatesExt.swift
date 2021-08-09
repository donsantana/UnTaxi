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
    textField.textColor = UIColor.black
    textField.text?.removeAll()
    
    if textField.isEqual(countryCodeText){
      picker.isHidden = false
      textField.endEditing(true)
    }
    
    if textField.isEqual(claveText){
      animateViewMoving(true, moveValue: 80, view: self.view)
    }else{
      if textField.isEqual(confirmarClavText) || textField.isEqual(correoText){
        if textField.isEqual(confirmarClavText){
          textField.isSecureTextEntry = true
        }
        textField.tintColor = UIColor.black
        animateViewMoving(true, moveValue: 200, view: self.view)
      }else{
        if textField.isEqual(self.telefonoText){
          textField.textColor = UIColor.black
          //textField.text = ""
          animateViewMoving(true, moveValue: 70, view: self.view)
        }
      }
    }
  }
  
  func textFieldDidEndEditing(_ textfield: UITextField) {
    textfield.text = textfield.text!.replacingOccurrences(of: ",", with: ".")
    if textfield.isEqual(claveText){
      animateViewMoving(false, moveValue: 80, view: self.view)
    }else{
      if textfield.isEqual(confirmarClavText) || textfield.isEqual(correoText){
        if textfield.text != claveText.text && textfield.isEqual(confirmarClavText){
          textfield.textColor = UIColor.red
          textfield.text = "Las claves no coinciden"
          textfield.isSecureTextEntry = false
          crearCuentaBtn.isEnabled = false
        }else{
          crearCuentaBtn.isEnabled = true
        }
        animateViewMoving(false, moveValue: 200, view: self.view)
      }else{
        if textfield.isEqual(telefonoText){
          if textfield.text?.count != 10{
            let alertaDos = UIAlertController (title: "Error", message: "Número de teléfono incorrecto", preferredStyle: .alert)
            alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
              self.telefonoText.becomeFirstResponder()
            }))
            self.present(alertaDos, animated: true, completion: nil)
          }
          animateViewMoving(false, moveValue: 70, view: self.view)
        }
      }
    }
  }
  
  @objc func textFieldDidChange(_ textField: UITextField) {
    
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
    if textField.isEqual(self.correoText){
      self.sendNewUserData()
    }
    return true
  }
}


extension RegistroController: ApiServiceDelegate{
  func apiRequest(_ controller: ApiService, registerUserAPI msg: String) {
    DispatchQueue.main.async {
      let alertaDos = UIAlertController (title: "Registro de usuario", message: msg, preferredStyle: .alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        self.goToLoginView()
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
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
