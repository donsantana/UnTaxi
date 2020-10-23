//
//  PerfilControllerExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/5/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import Foundation
import UIKit

extension PerfilController: UITableViewDelegate, UITableViewDataSource{
  func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return 3
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    var cell = UITableViewCell()
    switch indexPath.row {
    case 0:
      cell = Bundle.main.loadNibNamed("PerfilNombreCell", owner: self, options: nil)?.first as! PerfilNombreCell
      (cell as! PerfilNombreCell).nombreApellidosText.text = globalVariables.cliente.nombreApellidos
    case 1:
      cell = Bundle.main.loadNibNamed("PerfilViewCell", owner: self, options: nil)?.first as! PerfilViewCell
      (cell as! PerfilViewCell).NuevoValor.text = globalVariables.cliente.user
    case 2:
      cell = Bundle.main.loadNibNamed("Perfil2ViewCell", owner: self, options: nil)?.first as! Perfil2ViewCell
      (cell as! Perfil2ViewCell).NuevoValor.text = globalVariables.cliente.email
      
    default:
      cell = Bundle.main.loadNibNamed("PerfilViewCell", owner: self, options: nil)?.first as! PerfilViewCell
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }
}

extension PerfilController: UITextFieldDelegate{
  //CONTROL DE TECLADO VIRTUAL
  //Funciones para mover los elementos para que no queden detrás del teclado
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if textField.restorationIdentifier != "NuevoTelefono" && textField.restorationIdentifier != "NuevoCorreo"{
      animateViewMoving(true, moveValue: 180, view: self.view)
      textField.textColor = UIColor.black
      textField.text?.removeAll()
    }
  }
  
  func textFieldDidEndEditing(_ textfield: UITextField) {
    if !(textfield.text?.isEmpty)!{
      switch textfield.restorationIdentifier! {
      case "NuevoTelefono":
        self.NuevoTelefonoText = textfield.text!
      case "NuevoCorreo":
        self.NuevoEmailText = textfield.text!
      case "ClaveActual":
        self.ClaveActual = textfield.text!
      case "NuevaClave":
        self.NuevaClaveText = textfield.text!
      case "ConfirmeClave":
        if self.NuevaClaveText != textfield.text{
          textfield.textColor = UIColor.red
          textfield.text = "Las Claves Nuevas no coinciden"
          self.ConfirmeClaveText = "Las Claves Nuevas no coinciden"
          textfield.isSecureTextEntry = false
        }else{
          textfield.isSecureTextEntry = true
          self.ConfirmeClaveText = textfield.text!
        }
      default:
        self.ConfirmeClaveText = textfield.text!
      }
    }
    textfield.resignFirstResponder()
    if textfield.restorationIdentifier != "NuevoTelefono" && textfield.restorationIdentifier != "NuevoCorreo"{
      animateViewMoving(false, moveValue: 180, view: self.view)
    }
    
  }
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.endEditing(true)
    if textField.restorationIdentifier == "ConfirmeClave"{
      if self.ConfirmeClaveText != "Las Claves Nuevas no coinciden"{
        self.EnviarActualizacion()
      }
    }
    
    return true
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
  
  func keyboardNotification(notification: NSNotification){
    if let userInfo = notification.userInfo{
      let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
      let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
      let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
      let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
      let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
      if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
        animateViewMoving(false, moveValue: 180, view: self.view)//self.keyboardHeightLayoutConstraint?.constant = 0.0
      } else {
        animateViewMoving(true, moveValue: 180, view: self.view)//self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
      }
      UIView.animate(withDuration: duration,
                     delay: TimeInterval(0),
                     options: animationCurve,
                     animations: { self.view.layoutIfNeeded() },
                     completion: nil)
    }
    //animateViewMoving(true, moveValue: 135, view: self.view)
  }
}

extension PerfilController: ApiServiceDelegate{
  func apiRequest(_ controller: ApiService, updatedProfileAPI status: Bool) {
    let alertaDos = UIAlertController (title: status ? "Perfil Actualizado" : "Error de Perfil", message: status ? "Su perfil se actualizo con ÉXITO. Los cambios se verán reflejados una vez que vuelva ingresar a la aplicación." : "Se produjo un ERROR al actualizar su perfil. Sus datos continuan sin cambios.", preferredStyle: UIAlertController.Style.alert)
    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
      //        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "Inicio") as! InicioController
      //        self.navigationController?.show(vc, sender: nil)
    }))
    
    self.present(alertaDos, animated: true, completion: nil)
  }
}

