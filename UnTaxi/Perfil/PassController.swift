//
//  ChangePasswordView.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 10/22/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit

class PassController: BaseController, UIGestureRecognizerDelegate {
  var apiService = ApiService()
  
  @IBOutlet weak var claveActualText: UITextField!
  @IBOutlet weak var NuevaClaveText: UITextField!
  @IBOutlet weak var ConfirmeClaveText: UITextField!
  @IBOutlet weak var showHideClaveActualBtn: UIButton!
  @IBOutlet weak var showHideNuevaClaveBtn: UIButton!
  @IBOutlet weak var showHideConfirmBtn: UIButton!
  @IBOutlet weak var waitingView: UIVisualEffectView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.apiService.delegate = self
    self.claveActualText.delegate = self
    self.NuevaClaveText.delegate = self
    self.ConfirmeClaveText.delegate = self
    //UILabel.appearance().font = CustomAppFont.titleFont
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado))
    tapGesture.delegate = self
    self.view.addGestureRecognizer(tapGesture)
  }
  
  func sendUpdatePassword(){
    self.waitingView.isHidden = false
    self.apiService.changeClaveAPI(params: ["user": String(globalVariables.cliente.user), "password": self.claveActualText.text!, "newpassword": self.NuevaClaveText.text!])
  }
  
  @objc func ocultarTeclado(sender: UITapGestureRecognizer){
    self.view.endEditing(true)
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
  
  @IBAction func updatePassword(_ sender: Any) {
    if self.NuevaClaveText.text == self.ConfirmeClaveText.text{
      self.sendUpdatePassword()
    }
    self.ConfirmeClaveText.resignFirstResponder()
  }
}

extension PassController: UITextFieldDelegate{
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
      if self.NuevaClaveText.text == self.ConfirmeClaveText.text{
        self.sendUpdatePassword()
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
}

extension PassController: ApiServiceDelegate{
  func apiRequest(_ controller: ApiService, changeClaveAPI msg: String){
    DispatchQueue.main.async {
      self.waitingView.isHidden = true
    }
    let alertaDos = UIAlertController (title: "Cambio de clave", message: msg, preferredStyle: UIAlertController.Style.alert)
    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
      let vc = R.storyboard.main.inicioView()
      self.navigationController?.show(vc!, sender: nil)
    }))
    self.present(alertaDos, animated: true, completion: nil)
  }
}
