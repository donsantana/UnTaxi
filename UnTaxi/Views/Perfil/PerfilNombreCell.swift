//
//  PerfilNombreCell.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 10/21/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit


class PerfilNombreCell: UITableViewCell, UITextFieldDelegate {
  
  @IBOutlet weak var nombreApellidosText: UITextField!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    nombreApellidosText.delegate = self
  }
  
  //CONTROL DE TECLADO VIRTUAL
  //Funciones para mover los elementos para que no queden detrás del teclado
  func textFieldDidBeginEditing(_ textField: UITextField) {
    textField.text?.removeAll()
  }
  
  func textFieldDidEndEditing(_ textfield: UITextField) {
    textfield.resignFirstResponder()
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
