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
    case claveText:
      distanceValue = 80
    case confirmarClavText:
      textField.isSecureTextEntry = true
      distanceValue = 180
    case correoText:
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
      let (valid, message) = textfield.validate(.movilNumber)
      if !valid{
        let alertaDos = UIAlertController (title: "Error en el formulario", message: message, preferredStyle: .alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          self.telefonoText.becomeFirstResponder()
        }))
        self.present(alertaDos, animated: true, completion: nil)
      }
    case claveText:
      distanceValue = 80
    case confirmarClavText:
      let (valid, message) = validateTextField(textField: textfield)
      if valid{
        crearCuentaBtn.isEnabled = true
      }else{
        let alertaDos = UIAlertController (title: "Error en el formulario", message: message, preferredStyle: .alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          self.confirmarClavText.becomeFirstResponder()
        }))
        self.present(alertaDos, animated: true, completion: nil)
      }
      distanceValue = 180
    case correoText:
      let (valid, message) = textfield.validate(.email)
      print("valid \(valid)")
      if !valid{
        let alertaDos = UIAlertController (title: "Error en el formulario", message: message, preferredStyle: .alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          self.correoText.becomeFirstResponder()
        }))
        self.present(alertaDos, animated: true, completion: nil)
      }
      distanceValue = 180
    default:
      break
    }
    
    animateViewMoving(false, moveValue: CGFloat(distanceValue), view: self.view)
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
    print("Return pressed")
    switch textField {
    case telefonoText:
      let (valid, message) = textField.validate(.movilNumber)
      if valid {
        nombreApText.becomeFirstResponder()
      }
    case nombreApText:
      claveText.becomeFirstResponder()
    case claveText:
      // Validate Text Field
      let (valid, message) = validateTextField(textField: textField)
      if valid {
        confirmarClavText.becomeFirstResponder()
      }
    case confirmarClavText:
      let (valid, message) = validateTextField(textField: textField)
      if valid{
        correoText.becomeFirstResponder()
      }
      break
    case correoText:
      let (valid, message) = textField.validate(.email)
      print("valid \(valid)")
      if !valid{
        let alertaDos = UIAlertController (title: "Error en el formulario", message: message, preferredStyle: .alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          self.correoText.becomeFirstResponder()
        }))
        self.present(alertaDos, animated: true, completion: nil)
      }else{
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
      return (textField.text?.count == 10 && textField.text!.isNumeric, "Número de teléfono incorrecto. Por favor verifíquelo")
    case confirmarClavText:
      return (text == claveText.text, "Las claves no coinciden")
      
    default:
      return (text.count > 0, "This field cannot be empty.")
    }

      return (text.count > 0, "This field cannot be empty.")
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
  
  func apiRequest(_ controller: ApiService, getRegisterError msg: String) {
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
