//
//  LoginControllerExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/5/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import UIKit


extension LoginController: UITextFieldDelegate{
  //MARK:- CONTROL DE TECLADO VIRTUAL
  //Funciones para mover los elementos para que no queden detrás del teclado
  func textFieldDidBeginEditing(_ textField: UITextField) {
    RecuperarClaveBtn.isEnabled = false
    var distanceValue = 0
    switch textField {
    case movilClaveRecover:
      distanceValue = 105
    default:
      distanceValue = 80
    }
    animateViewMoving(true, moveValue: CGFloat(distanceValue), view: self.view)
//    textField.textColor = UIColor.black
//    textField.text?.removeAll()
//    if textField.isEqual(clave){
//      animateViewMoving(true, moveValue: 80, view: self.view)
//    }
//    else{
//      if textField.isEqual(movilClaveRecover){
//        textField.text?.removeAll()
//        animateViewMoving(true, moveValue: 105, view: self.view)
//      }
//      else{
//        if textField.isEqual(confirmarClavText) || textField.isEqual(correoText) || textField.isEqual(RecomendadoText){
//          if textField.isEqual(confirmarClavText){
//            textField.isSecureTextEntry = true
//          }
//          textField.tintColor = UIColor.black
//          animateViewMoving(true, moveValue: 200, view: self.view)
//        }else{
//          if textField.isEqual(self.telefonoText){
//            textField.textColor = UIColor.black
//            //textField.text = ""
//            animateViewMoving(true, moveValue: 70, view: self.view)
//          }
//        }
//      }
//    }
  }
  
  func textFieldDidEndEditing(_ textfield: UITextField) {
    var distanceValue = 0
    switch textfield {
    case movilClaveRecover:
      let (valid, message) = textfield.validate(.movilNumber)
      if !valid{
        let alertaDos = UIAlertController (title: "Error en el formulario", message: message, preferredStyle: .alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          self.movilClaveRecover.becomeFirstResponder()
        }))
        self.present(alertaDos, animated: true, completion: nil)
      }else{
        RecuperarClaveBtn.isEnabled = true
      }
      distanceValue = 105
    case codigoText:
      let (valid, message) = textfield.validate(.codigoVerificacion)
      if !valid{
        let alertaDos = UIAlertController (title: "Error en el formulario", message: message, preferredStyle: .alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          self.codigoText.becomeFirstResponder()
        }))
        self.present(alertaDos, animated: true, completion: nil)
      }
      distanceValue = 80
    case newPasswordText:
      let (valid, message) = textfield.validate(.password)
      if !valid{
        let alertaDos = UIAlertController (title: "Error en el formulario", message: message, preferredStyle: .alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          self.newPasswordText.becomeFirstResponder()
        }))
        self.present(alertaDos, animated: true, completion: nil)
      }
      distanceValue = 80
    case newPassConfirmText:
      let (valid, message) = textfield.validate(.password)
      if !valid{
        let alertaDos = UIAlertController (title: "Error en el formulario", message: message, preferredStyle: .alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          self.newPasswordText.becomeFirstResponder()
        }))
        self.present(alertaDos, animated: true, completion: nil)
      }else{
        self.crearNewPasswordBtn.isEnabled = true
      }
      distanceValue = 80
    default:
      distanceValue = 80
    }
    
    animateViewMoving(false, moveValue: CGFloat(distanceValue), view: self.view)
    
//    textfield.text = textfield.text!.replacingOccurrences(of: ",", with: ".")
//    if textfield.isEqual(clave){
//      animateViewMoving(false, moveValue: 80, view: self.view)
//    }else{
//      if textfield.isEqual(movilClaveRecover){
//        if movilClaveRecover.text?.count != 10{
//          textfield.text = "Número de Teléfono Incorrecto"
//        }else{
//          self.RecuperarClaveBtn.isEnabled = true
//        }
//        animateViewMoving(false, moveValue: 105, view: self.view)
//      }
//    }
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
    switch textField {
    case clave:
      self.Login(user: self.usuario.text!, password: self.clave.text!)
    case movilClaveRecover:
      let (valid, message) = textField.validate(.movilNumber)
      if !valid{
        let alertaDos = UIAlertController (title: "Error en el formulario", message: message, preferredStyle: .alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          self.movilClaveRecover.becomeFirstResponder()
        }))
        self.present(alertaDos, animated: true, completion: nil)
      }else{
        sendRecoverClave()
      }
    case codigoText:
      let (valid, message) = textField.validate(.codigoVerificacion)
      if !valid{
        let alertaDos = UIAlertController (title: "Error en el formulario", message: message, preferredStyle: .alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          self.codigoText.becomeFirstResponder()
        }))
        self.present(alertaDos, animated: true, completion: nil)
      }else{
        createNewPassword(codigo: codigoText.text!, newPassword: newPasswordText.text!)
      }
    case newPasswordText:
      let (valid, message) = textField.validate(.password)
      if !valid{
        let alertaDos = UIAlertController (title: "Error en el formulario", message: message, preferredStyle: .alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          self.newPasswordText.becomeFirstResponder()
        }))
        self.present(alertaDos, animated: true, completion: nil)
      }else{
        newPassConfirmText.becomeFirstResponder()
      }
    case newPassConfirmText:
      let (valid, message) = textField.validate(.password)
      if !valid{
        let alertaDos = UIAlertController (title: "Error en el formulario", message: message, preferredStyle: .alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          self.newPassConfirmText.becomeFirstResponder()
        }))
        self.present(alertaDos, animated: true, completion: nil)
      }else{
        createNewPassword(codigo: codigoText.text!, newPassword: newPasswordText.text!)
      }
    default:
    break
  }
    return true
  }
  
  @objc func ocultarTeclado(){
    self.claveRecoverView.endEditing(true)
    self.DatosView.endEditing(true)
    //fself.RegistroView.endEditing(true)
  }
}

extension LoginController: ApiServiceDelegate{
  func apiRequest(_ controller: ApiService, getLoginData data: [String:Any]) {
    print("msg \(data["token"] as! String)")
    globalVariables.userDefaults.set(data["token"] as! String, forKey: "accessToken")
    self.startSocketConnection()
  }

  func apiRequest(_ controller: ApiService, recoverUserClaveAPI success: Bool, msg: String) {
    DispatchQueue.main.async {
      let alertaDos = UIAlertController (title: success ? "Recuperación de clave" : "Error", message: msg, preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        self.waitingView.isHidden = true
        if success{
          self.NewPasswordView.isHidden = false
        }
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
  func apiRequest(_ controller: ApiService, createNewClaveAPI success: Bool, msg: String) {
    DispatchQueue.main.async {
      self.waitingView.isHidden = true
      let alertaDos = UIAlertController (title: success ? "Nueva clave creada" : "Error", message: msg, preferredStyle: .alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        if success{
          self.codigoText.text?.removeAll()
          self.newPasswordText.text?.removeAll()
          self.newPassConfirmText.text?.removeAll()
          self.waitingView.isHidden = true
          self.claveRecoverView.isHidden = true
          globalVariables.userDefaults.setValue(nil, forKey:"nombreUsuario")
        }
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
  func apiRequest(_ controller: ApiService, getLoginError msg: String) {
    DispatchQueue.main.async {
      let alertaDos = UIAlertController (title: "Error de Autenticación", message: msg, preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        self.waitingView.isHidden = true
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
  func apiRequest(_ controller: ApiService, getAPIError msg: String) {
    DispatchQueue.main.async {
      let alertaDos = UIAlertController (title: "Error", message: msg, preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        self.waitingView.isHidden = true
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
}
