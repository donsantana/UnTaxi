//
//  Perfil3ViewCell.swift
//  UnTaxi
//
//  Created by Done Santana on 10/29/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import UIKit

class Perfil3ViewCell: UITableViewCell, UITextFieldDelegate {
  
  @IBOutlet weak var NombreCampo: UILabel!
  @IBOutlet weak var claveActualText: UITextField!
  @IBOutlet weak var NuevaClaveText: UITextField!
  @IBOutlet weak var ConfirmeClaveText: UITextField!
  @IBOutlet weak var showHideClaveActualBtn: UIButton!
  @IBOutlet weak var showHideNuevaClaveBtn: UIButton!
  @IBOutlet weak var showHideConfirmBtn: UIButton!
  
  var vista = PerfilController()
  
  override func awakeFromNib() {
    super.awakeFromNib()
    NuevaClaveText.delegate = self
    ConfirmeClaveText.delegate = self
    
  }
  
  //CONTROL DE TECLADO VIRTUAL
  //Funciones para mover los elementos para que no queden detrás del teclado
  func textFieldDidBeginEditing(_ textField: UITextField) {
    textField.textColor = UIColor.black
    textField.text?.removeAll()
    textField.isSecureTextEntry = true
  }
  
  func textFieldDidEndEditing(_ textfield: UITextField) {
    textfield.resignFirstResponder()
    if textfield.isEqual(self.ConfirmeClaveText){
      if self.NuevaClaveText.text != self.ConfirmeClaveText.text{
        textfield.textColor = UIColor.red
        textfield.text = "Las Claves Nuevas no coinciden"
        textfield.isSecureTextEntry = false
      }
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField.isEqual(self.ConfirmeClaveText){
      if self.ConfirmeClaveText.text != "Las Claves Nuevas no coinciden"{
        //self.EnviarActualizacion()
      }
    }
    textField.resignFirstResponder()
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
  
  func showHidePassword(textField: UITextField){
    textField.isSecureTextEntry = !textField.isSecureTextEntry
  }
  
  @IBAction func showHideClaveActual(_ sender: Any) {
    self.showHidePassword(textField: self.claveActualText)
    self.showHideClaveActualBtn.setImage(UIImage(named: !self.claveActualText.isSecureTextEntry ? "hideClave" : "showClave"), for: .normal)
  }
  @IBAction func showHideNuevaClave(_ sender: Any) {
    self.showHidePassword(textField: self.NuevaClaveText)
    self.showHideNuevaClaveBtn.setImage(UIImage(named: !self.NuevaClaveText.isSecureTextEntry ? "hideClave" : "showClave"), for: .normal)
  }
  @IBAction func showHideConfirmarClave(_ sender: Any) {
    self.showHidePassword(textField: self.ConfirmeClaveText)
    self.showHideConfirmBtn.setImage(UIImage(named: !self.ConfirmeClaveText.isSecureTextEntry ? "hideClave" : "showClave"), for: .normal)
  }
  
}


