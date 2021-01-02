//
//  YapaPanel.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 12/2/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit

class YapaPanel: UIViewController {
  var socketService = SocketService()
  var keyboardHeight:CGFloat!
  
  @IBOutlet weak var activeCodigoView: UIView!
  @IBOutlet weak var titleText: UILabel!
  @IBOutlet weak var codigoText: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.socketService.initListenEventos()
    self.socketService.delegate = self
    self.codigoText.delegate = self
    self.activeCodigoView.addShadow()
    self.titleText.font = CustomAppFont.subtitleFont
    self.codigoText.font = CustomAppFont.inputTextFont
    self.codigoText.addBorder(color: Customization.buttonActionColor)
    // Do any additional setup after loading the view.
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado))
    //tapGesture.delegate = self
    self.view.addGestureRecognizer(tapGesture)
//    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//    let center = NotificationCenter.default
//    center.addObserver(self, selector: #selector(keyboardWillBeShown(note:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//    center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  @objc func ocultarTeclado(sender: UITapGestureRecognizer){
    //sender.cancelsTouchesInView = false
    self.view.endEditing(true)
  }
  
  //MARK:- CONTROL DE TECLADO VIRTUAL
  @objc func keyboardWillBeShown(note: Notification) {
      let userInfo = note.userInfo
    let keyboardFrame = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
    let contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardFrame.height, right: 0.0)
//      view.contentInset = contentInset
//      view.scrollIndicatorInsets = contentInset
//      view.scrollRectToVisible(textField.frame, animated: true)
  }
  
  @objc func keyboardWillBeHidden(note: Notification) {
      let contentInset = UIEdgeInsets.zero
//      view.contentInset = contentInset
//      view.scrollIndicatorInsets = contentInset
  }
  
  @objc func keyboardWillShow(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
      self.keyboardHeight = keyboardSize.height
    }
  }
  
  @IBAction func recargarYapa(_ sender: Any) {
    socketService.socketEmit("recargaryapa", datos: [
      "idcliente": globalVariables.cliente.id!,
      "codigo": self.codigoText.text!
    ])
  }
  
}

extension YapaPanel: SocketServiceDelegate{
  func socketResponse(_ controller: SocketService, recargaryapa result: [String : Any]) {
    let alertaDos = UIAlertController (title: "Recarga de Yapa", message: result["msg"] as! String, preferredStyle: UIAlertController.Style.alert)
    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
     
    }))
    self.present(alertaDos, animated: true, completion: nil)
  }
}

extension YapaPanel: UITextFieldDelegate{
  //Funciones para mover los elementos para que no queden detrás del teclado
  func textFieldDidBeginEditing(_ textField: UITextField) {
    textField.text?.removeAll()
    animateViewMoving(true, moveValue: 160, view: (self.view)!)
  }
  
  func textFieldDidEndEditing(_ textfield: UITextField) {
    self.animateViewMoving(false, moveValue: 160, view: (self.view)!)
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    socketService.socketEmit("recargaryapa", datos: [
      "idcliente": globalVariables.cliente.id!,
      "codigo": self.codigoText.text!
    ])
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
