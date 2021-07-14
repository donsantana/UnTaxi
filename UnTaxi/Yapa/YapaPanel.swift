//
//  YapaPanel.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 12/2/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit
import FloatingPanel
import PhoneNumberKit

class YapaPanel: UIViewController {
  let phoneNumberKit = PhoneNumberKit()
  var actionType = 1
  var socketService = SocketService()
  var contactService = ContactService()
  var keyboardHeight:CGFloat!
  var activeTextField: UITextField!
  var idReceptorYapa = 0
  let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado))
  
  @IBOutlet weak var activeCodigoView: UIView!
  @IBOutlet weak var titleText: UILabel!
  @IBOutlet weak var codigoText: UITextField!
  @IBOutlet weak var sendYapaView: UIView!
  @IBOutlet weak var movilNumberText: UITextField!
  @IBOutlet weak var nombreText: UILabel!
  @IBOutlet weak var montoText: UITextField!
  @IBOutlet weak var sendYapaBtn: UIButton!
  @IBOutlet weak var contactosView: UIView!
  @IBOutlet weak var contactsTable: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.socketService.delegate = self
    self.codigoText.delegate = self
    self.contactsTable.delegate = self
    self.movilNumberText.delegate = self
    self.montoText.delegate = self
    self.activeCodigoView.addShadow()
//    self.titleText.font = CustomAppFont.subtitleFont
//    self.codigoText.font = CustomAppFont.inputTextFont
    self.codigoText.addBorder(color: CustomAppColor.buttonActionColor)
    self.movilNumberText.addBorder(color: CustomAppColor.buttonActionColor)
    self.montoText.addBorder(color: CustomAppColor.buttonActionColor)
    
    self.movilNumberText.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    
    self.sendYapaView.isHidden = (actionType == 1)
    // Do any additional setup after loading the view.
    
    //tapGesture.delegate = self
    self.activeCodigoView.addGestureRecognizer(tapGesture)
    self.sendYapaView.addGestureRecognizer(tapGesture)
    
    self.movilNumberText.placeholder = Locale.current.regionCode != nil ? self.phoneNumberKit.getFormattedExampleNumber(forCountry: Locale.current.regionCode!.description,withPrefix: false) : "Número de teléfono"
    
    self.socketService.initYapaEvents()
    
//    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//
//    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  @objc func textFieldDidChange(_ textField: UITextField) {
    if textField.text?.digitString.count == 10{
      self.isCliente()
    }
  }
  
  
  @objc func ocultarTeclado(sender: UITapGestureRecognizer){
    //sender.cancelsTouchesInView = false
    self.view.endEditing(true)
  }
  
  func isCliente(){
    print("este user: \(self.movilNumberText.text!.digitString)")
    socketService.socketEmit("buscarclientepormovil", datos: [
      "idcliente": globalVariables.cliente.id!,
      "movil": self.movilNumberText.text!.digitString
    ])
  }
  
  //MARK:- CONTROL DE TECLADO VIRTUAL
 
//  @objc func keyboardWillShow(notification: NSNotification) {
//    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//      print("y \(activeTextField.frame.origin.y) \(keyboardSize.height)")
//      if activeTextField.frame.origin.y > keyboardSize.height{
//        print("TextField oculto")
//        self.view.frame.origin.y = -keyboardSize.height
//        self.keyboardHeight = keyboardSize.height
//      }else{
//        print("TextField ok")
//      }
////      if self.navigationController?.isNavigationBarHidden == false {
////        print("moviendo panel")
//////        self.openMapBtn.frame = CGRect(x: 0, y: Responsive().heightFloatPercent(percent: 80) - keyboardSize.height, width: self.view.bounds.width - 40, height: 40)
////      }else{
////        self.view.frame.origin.y = -keyboardSize.height
////        self.keyboardHeight = keyboardSize.height
////      }
//    }
//  }
//
//  @objc func keyboardWillHide(notification: NSNotification) {
//    if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
//      self.view.frame.origin.y = 0
////      if self.navigationController?.isNavigationBarHidden == false {
//////        self.openMapBtn.frame = CGRect(x: 0, y: Responsive().heightFloatPercent(percent: 80), width: self.view.bounds.width - 40, height: 40)
////      }else{
////        self.view.frame.origin.y = 0
////      }
//    }
//
//  }
  
  @objc
     dynamic func keyboardWillShow(
         _ notification: NSNotification
     ) {
         animateWithKeyboard(notification: notification) {
             (keyboardFrame) in
             let constant = -keyboardFrame.height
             self.view.frame.origin.y = constant
         }
     }
     
     @objc
     dynamic func keyboardWillHide(_ notification: NSNotification) {
         animateWithKeyboard(notification: notification) {
             (keyboardFrame) in
          self.view.frame.origin.y = 20
         }
     }
  
  func animateWithKeyboard(
    notification: NSNotification,
    animations: ((_ keyboardFrame: CGRect) -> Void)?
  ) {
    // Extract the duration of the keyboard animation
    let durationKey = UIResponder.keyboardAnimationDurationUserInfoKey
    let duration = notification.userInfo![durationKey] as! Double
    
    // Extract the final frame of the keyboard
    let frameKey = UIResponder.keyboardFrameEndUserInfoKey
    let keyboardFrameValue = notification.userInfo![frameKey] as! NSValue
    
    // Extract the curve of the iOS keyboard animation
    let curveKey = UIResponder.keyboardAnimationCurveUserInfoKey
    let curveValue = notification.userInfo![curveKey] as! Int
    let curve = UIView.AnimationCurve(rawValue: curveValue)!
    
    // Create a property animator to manage the animation
    let animator = UIViewPropertyAnimator(
      duration: duration,
      curve: curve
    ) {
      // Perform the necessary animation layout updates
      animations?(keyboardFrameValue.cgRectValue)
      
      // Required to trigger NSLayoutConstraint changes
      // to animate
      self.view?.layoutIfNeeded()
    }
    
    // Start the animation
    animator.startAnimation()
  }
  
  func cleanTextField(textfield: UITextField)->String{
    var cleanedTextField = textfield.text?.uppercased()
    cleanedTextField = cleanedTextField!.replacingOccurrences(of: "[() -]", with: "",options: .regularExpression, range: nil)
  
    return cleanedTextField!.folding(options: .diacriticInsensitive, locale: .current)
  }
  
  @IBAction func recargarYapa(_ sender: Any) {
    socketService.socketEmit("recargaryapa", datos: [
      "idcliente": globalVariables.cliente.id!,
      "codigo": self.codigoText.text!
    ])
  }
  
  @IBAction func searchContacts(_ sender: Any) {
    //self.isCliente()
    self.sendYapaBtn.isEnabled = false
    self.nombreText.text?.removeAll()
    self.sendYapaView.removeGestureRecognizer(tapGesture)
    self.contactosView.isHidden = false
  }
  
  @IBAction func sendYapa(_ sender: Any) {
    self.view.endEditing(true)
    print("Yapa value \((self.montoText.text!.digitsAndPeriods as NSString).doubleValue)-\(globalVariables.cliente.yapa)")
    if (self.montoText.text!.digitsAndPeriods as NSString).doubleValue <= globalVariables.cliente.yapa{
    socketService.socketEmit("pasaryapa", datos: [
      "idclientenew": self.idReceptorYapa,
      "idclienteold": globalVariables.cliente.id!,
      "yapa": self.montoText.text!.digitsAndPeriods
    ])
    }else{
      let alertaDos = UIAlertController (title: "Pasar de Yapa", message: "Solo puede pasar una cantidad menor o igual a su YAPA acumulada.", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        self.montoText.text = "$\(globalVariables.cliente.yapa)"
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
  @IBAction func closeContactView(_ sender: Any) {
    self.sendYapaView.addGestureRecognizer(tapGesture)
    self.contactosView.isHidden = true
  }
  
}

extension YapaPanel: SocketServiceDelegate{
  func socketResponse(_ controller: SocketService, recargaryapa result: [String : Any]) {
    let alertaDos = UIAlertController (title: "Recarga de Yapa", message: result["msg"] as! String, preferredStyle: UIAlertController.Style.alert)
    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
      
    }))
    self.present(alertaDos, animated: true, completion: nil)
  }
  
  func socketResponse(_ controller: SocketService, buscarCliente result: [String : Any]) {
    if (result["code"] as! Int) == 1{
      print("user \(result["datos"])")
      let datos = result["datos"] as! [String: Any]
      self.idReceptorYapa = datos["idcliente"] as! Int
      self.nombreText.text = "Nombre: \(datos["nombreapellidos"] as! String)"
      self.montoText.text = "$\(globalVariables.cliente.yapa)"
      self.sendYapaBtn.isEnabled = true
    }else{
      let alertaDos = UIAlertController (title: "Pasar de Yapa", message: result["msg"] as! String, preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        self.nombreText.text = ""
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
    
  }
  
  func socketResponse(_ controller: SocketService, pasarYapa result: [String : Any]) {
    if (result["code"] as! Int) == 1{
      let alertaDos = UIAlertController (title: "Pasar de Yapa", message: result["msg"] as! String, preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        globalVariables.cliente.yapa -= Double(self.montoText.text!.digitsAndPeriods)!
        
        (self.parent as! FloatingPanelController).removeFromParent()
        (self.parent as! FloatingPanelController).move(to: .hidden, animated: true)
        
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
}

extension YapaPanel: UITextFieldDelegate{
  //Funciones para mover los elementos para que no queden detrás del teclado
  func textFieldDidBeginEditing(_ textField: UITextField) {
    self.activeTextField = textField
    (self.parent as! FloatingPanelController).move(to: .full, animated: true)
    textField.text?.removeAll()
    //animateViewMoving(true, moveValue: 150, view: (self.view)!)
  }
  
  func textFieldDidEndEditing(_ textfield: UITextField) {
    self.activeTextField = nil
    (self.parent as! FloatingPanelController).move(to: .half, animated: true)
    //self.animateViewMoving(false, moveValue: 150, view: (self.view)!)
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

extension YapaPanel: FloatingPanelControllerDelegate{
  func floatingPanelDidMove(_ fpc: FloatingPanelController) {
    print(fpc.state)
  }
}
