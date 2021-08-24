//
//  ContactoViewCell.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/28/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import UIKit
import PhoneNumberKit

protocol ContactoCellDelegate: AnyObject{
  func otherContactSelected(_ controller: ContactoViewCell, otherContactSelected isSelected: Bool)
}

class ContactoViewCell: UITableViewCell {
  weak var delegate: ContactoCellDelegate?
  
  let phoneNumberKit = PhoneNumberKit()
  
  @IBOutlet weak var contactoNameText: UITextField!
  @IBOutlet weak var telefonoText: UITextField!
  @IBOutlet weak var contactarSwitch: UISwitch!
  @IBOutlet weak var contactDataVIew: UIView!
  
  func clearContacto(){
    self.contactarSwitch.isOn = false
    self.contactDataVIew.isHidden = true
    self.contactoNameText.text?.removeAll()
    self.telefonoText.text?.removeAll()
  }
  
  @IBAction func showContactView(_ sender: Any) {
    self.telefonoText.placeholder = "Teléfono"
    self.contactDataVIew.isHidden = !self.contactarSwitch.isOn
    self.delegate?.otherContactSelected(self, otherContactSelected: self.contactarSwitch.isOn)
  }
  
  func isValidPhone()->Bool{
    return self.phoneNumberKit.isValidPhoneNumber(self.telefonoText.text!)
  }
  
}

