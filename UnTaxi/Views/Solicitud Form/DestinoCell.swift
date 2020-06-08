//
//  DestinoCell.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/16/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit

class DestinoCell: UITableViewCell {
  @IBOutlet weak var destinoText: UITextField!
  
  func initContent(){
    self.destinoText.delegate = self
    
    self.destinoText.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
  }
  
  @objc func textFieldDidChange(_ textField: UITextField) {
  //    if !textField.text!.isEmpty{
  //      GMSPlacesClient.shared().autocompleteQuery(textField.text!, bounds: nil, filter: filter, callback: {(result, error) in
  //        if error == nil && result != nil{
  //          self.arrayAddress = result!
  //        }else{
  //          print("here \(error.debugDescription)")
  //        }
  //      })
  //    }else{
  //      self.arrayAddress = [GMSAutocompletePrediction]()
  //    }
  //    self.origenAddressView.isHidden = self.arrayAddress.count == 0 || !textField.isEqual(self.origenText)
  //    self.destinoAddressView.isHidden = self.arrayAddress.count == 0 || !textField.isEqual(self.destinoText)
    }
}

extension DestinoCell: UITextFieldDelegate{
  func textFieldDidBeginEditing(_ textField: UITextField) {
    textField.text?.removeAll()
  }
}
