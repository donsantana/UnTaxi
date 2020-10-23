//
//  InicioControllerExtension.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 2/16/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit
import GoogleMobileAds
//import PaymentezSDK


extension InicioController: UITextFieldDelegate{
  //Funciones para mover los elementos para que no queden detrás del teclado
  func textFieldDidBeginEditing(_ textField: UITextField) {
    textField.text?.removeAll()
    
    if self.tipoSolicitudSwitch.selectedSegmentIndex == 3{
      textField.resignFirstResponder()
      if textField.isEqual(self.origenCell.origenText){
        self.destinoCell.destinoText.text?.removeAll()
        self.addressView.isHidden = false
        self.origenCell.origenText.text = globalVariables.direccionesPactadas[0].dirorigen
        self.destinoPactadas = globalVariables.direccionesPactadas.filter{$0.dirorigen == globalVariables.direccionesPactadas[0].dirorigen}
        self.destinoAddressPicker.reloadAllComponents()
      }else{
        if textField.isEqual(self.destinoCell.destinoText) && self.tipoSolicitudSwitch.selectedSegmentIndex == 3{
          self.destinoAddressView.isHidden = false
          self.destinoCell.destinoText.text = globalVariables.direccionesPactadas[0].dirdestino
          self.pactadaCell.initContent(solicitudPactada: globalVariables.direccionesPactadas[0])
          //self.pactadaCell.precioText.text = "$\(self.destinoPactadas[0].importeida)"
        }
      }
    }else{
      if textField.isEqual(self.contactoCell.contactoNameText) || textField.isEqual(self.TelefonoContactoText){
        if textField.isEqual(self.TelefonoContactoText){
          self.TelefonoContactoText.textColor = UIColor.black
          if (self.contactoCell.contactoNameText.text?.isEmpty)! || !self.SoloLetras(name: self.contactoCell.contactoNameText.text!){
            
            let alertaDos = UIAlertController (title: "Contactar a otra persona", message: "Debe teclear el nombre de la persona que el conductor debe contactar.", preferredStyle: .alert)
            alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
              self.contactoCell.contactoNameText.becomeFirstResponder()
            }))
            self.present(alertaDos, animated: true, completion: nil)
          }
        }
        self.animateViewMoving(true, moveValue: 140, view: view)
      }else{
        if !(self.origenCell.origenText.text?.isEmpty)!{
          //textField.text?.removeAll()
          //animateViewMoving(true, moveValue: 130, view: self.view)
        }else{
          if !textField.isEqual(self.origenCell.origenText){
            self.view.resignFirstResponder()
            let alertaDos = UIAlertController (title: "Dirección de Origen", message: "Debe teclear la dirección de recogida para orientar al conductor.", preferredStyle: .alert)
            alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
              self.origenCell.origenText.becomeFirstResponder()
            }))
            
            self.present(alertaDos, animated: true, completion: nil)
          }
        }
      }
      
    }
    animateViewMoving(true, moveValue: 130, view: self.view)
  }
  
  func textFieldDidEndEditing(_ textfield: UITextField) {
    if textfield.isEqual(self.contactoCell.contactoNameText) || textfield.isEqual(self.TelefonoContactoText){
      if textfield.isEqual(self.TelefonoContactoText) && textfield.text?.count != 10 && textfield.text?.count != 9 && !((self.contactoCell.contactoNameText.text?.isEmpty)!){
        textfield.textColor = UIColor.red
        textfield.text = "Número de teléfono incorrecto"
      }
      self.animateViewMoving(false, moveValue: 140, view: view)
    }else{
      //            if textfield.isEqual(self.origenCell.referenciaText) || textfield.isEqual(self.origenCell.destinoText){
      //                self.animateViewMoving(false, moveValue: 130, view: view)
      //            }
    }
    self.animateViewMoving(false, moveValue: 130, view: view)
  }
  
  //    @objc func textFieldDidChange(_ textField: UITextField) {
  //        if textField.text?.lengthOfBytes(using: .utf8) == 0{
  ////            self.TablaDirecciones.isHidden = false
  ////            self.RecordarView.isHidden = true
  //        }else{
  //            if self.DireccionesArray.count < 5 && textField.text?.lengthOfBytes(using: .utf8) == 1 {
  //                //self.RecordarView.isHidden = false
  //                //NSLayoutConstraint(item: self.RecordarView, attribute: .bottom, relatedBy: .equal, toItem: self.origenCell.referenciaText, attribute: .top, multiplier: 1, constant: -10).isActive = true
  //                //NSLayoutConstraint(item: self.origenCell.origenText, attribute: .bottom, relatedBy: .equal, toItem: self.origenCell.referenciaText, attribute: .top, multiplier: 1, constant: -(self.RecordarView.bounds.height + 20)).isActive = true
  //            }
  //            //self.TablaDirecciones.isHidden = true
  //        }
  //        //self.EnviarSolBtn.isEnabled = true
  //    }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.view.endEditing(true)
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

extension InicioController: VoucherCellDelegate{
  func voucherSwitch(_ controller: VoucherViewCell, voucherSelected isSelected: Bool) {
    self.isVoucherSelected = isSelected
    self.loadFormularioData()
  }
}

extension InicioController: ApiServiceDelegate{
  func apiRequest(_ controller: ApiService, getCardsList data: [[String : Any]]) {
    var cardList: [Card] = []
    for cardData in data{
      cardList.append(Card(data: cardData))
    }
    globalVariables.cardList = cardList
  }
}

//MARK:- PICKER DELEGATE FUNCTIONS

extension InicioController: UIPickerViewDelegate, UIPickerViewDataSource{
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    if pickerView.isEqual(self.addressPicker){
      return globalVariables.direccionesPactadas.count
    }else{
      return self.destinoPactadas.count
    }
    
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    if pickerView.isEqual(self.addressPicker){
      return globalVariables.direccionesPactadas[row].dirorigen
    }else{
      return self.destinoPactadas[row].dirdestino
    }
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    if pickerView.isEqual(self.addressPicker){
      self.origenCell.origenText.text = globalVariables.direccionesPactadas[row].dirorigen
      self.destinoPactadas = globalVariables.direccionesPactadas.filter{$0.dirorigen == globalVariables.direccionesPactadas[row].dirorigen}
      if self.destinoPactadas.count > 1{
        self.destinoAddressPicker.reloadAllComponents()
        self.destinoCell.destinoText.isUserInteractionEnabled = true
      }else{
        self.destinoCell.destinoText.text = globalVariables.direccionesPactadas[row].dirdestino
        self.destinoCell.destinoText.isUserInteractionEnabled = false
        self.pactadaCell.precioText.text = "$\(globalVariables.direccionesPactadas[row].importeida)"
      }
    }else{
      self.destinoCell.destinoText.text = self.destinoPactadas[row].dirdestino
      self.pactadaCell.initContent(solicitudPactada: globalVariables.direccionesPactadas[row])
      //self.pactadaCell.precioText.text = "$\(self.destinoPactadas[row].importeida)"
    }
  }
}



