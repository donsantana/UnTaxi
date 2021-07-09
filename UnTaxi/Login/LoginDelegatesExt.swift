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
    textField.textColor = UIColor.black
    textField.text?.removeAll()
    if textField.isEqual(claveText) || textField.isEqual(clave){
      animateViewMoving(true, moveValue: 80, view: self.view)
    }
    else{
      if textField.isEqual(movilClaveRecover){
        textField.text?.removeAll()
        animateViewMoving(true, moveValue: 105, view: self.view)
      }
      else{
        if textField.isEqual(confirmarClavText) || textField.isEqual(correoText) || textField.isEqual(RecomendadoText){
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
  }
  
  func textFieldDidEndEditing(_ textfield: UITextField) {
    if !textfield.isEqual(RecomendadoText) && textfield.text!.isEmpty{
      //textfield.text = "Campo requerido"
    }
    textfield.text = textfield.text!.replacingOccurrences(of: ",", with: ".")
    if textfield.isEqual(claveText) || textfield.isEqual(clave){
      animateViewMoving(false, moveValue: 80, view: self.view)
    }else{
      if textfield.isEqual(confirmarClavText) || textfield.isEqual(correoText) || textfield.isEqual(RecomendadoText){
        if textfield.text != claveText.text && textfield.isEqual(confirmarClavText){
          textfield.textColor = UIColor.red
          textfield.text = "Las claves no coinciden"
          textfield.isSecureTextEntry = false
          RegistroBtn.isEnabled = false
        }
        else{
          RegistroBtn.isEnabled = true
        }
        animateViewMoving(false, moveValue: 200, view: self.view)
      }else{
        if textfield.isEqual(telefonoText) || textfield.isEqual(RecomendadoText){
          
          if textfield.text?.count != 10{
            textfield.textColor = UIColor.red
            textfield.text = "Número de Teléfono Incorrecto"
          }
          animateViewMoving(false, moveValue: 70, view: self.view)
        }else{
          if textfield.isEqual(movilClaveRecover){
            if movilClaveRecover.text?.count != 10{
              textfield.text = "Número de Teléfono Incorrecto"
            }else{
              self.RecuperarClaveBtn.isEnabled = true
            }
            animateViewMoving(false, moveValue: 105, view: self.view)
          }
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
    if textField.isEqual(self.clave){
      self.Login(user: self.usuario.text!, password: self.clave.text!)
    }
    return true
  }
  
  @objc func ocultarTeclado(){
    self.claveRecoverView.endEditing(true)
    self.DatosView.endEditing(true)
    self.RegistroView.endEditing(true)
  }
}

extension LoginController: ApiServiceDelegate{
  func apiRequest(_ controller: ApiService, getLoginData data: [String:Any]) {
    print("msg \(data["token"] as! String)")
    globalVariables.userDefaults.set(data["token"] as! String, forKey: "accessToken")
    self.startSocketConnection()
  }
  
  func apiRequest(_ controller: ApiService, registerUserAPI msg: String) {
    DispatchQueue.main.async {
      let alertaDos = UIAlertController (title: "Registro de usuario", message: "Registro Realizado con éxito, puede loguearse en la aplicación.", preferredStyle: .alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        self.RegistroView.isHidden = true
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
  func apiRequest(_ controller: ApiService, recoverUserClaveAPI msg: String) {
    DispatchQueue.main.async {
      let alertaDos = UIAlertController (title: "Recuperación de clave", message: "Su clave ha sido recuperada satisfactoriamente, en este momento ha recibido un correo electronico y/o un SMS.", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        self.NewPasswordView.isHidden = false
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
  func apiRequest(_ controller: ApiService, createNewClaveAPI msg: String) {
    DispatchQueue.main.async {
      let alertaDos = UIAlertController (title: "Nueva clave creada", message: "Su clave ha sido creada satisfactoriamente, en este momento puede usarla para entrar a la aplicación.", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        self.claveRecoverView.isHidden = true
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
  func apiRequest(_ controller: ApiService, getLoginError msg: String) {
    DispatchQueue.main.async {
      let alertaDos = UIAlertController (title: "Error de Autenticación", message: msg, preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        self.AutenticandoView.isHidden = true
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
}
