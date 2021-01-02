//
//  ContactoViewCell.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/28/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import UIKit

class ContactoViewCell: UITableViewCell {
  @IBOutlet weak var contactoNameText: UITextField!
  @IBOutlet weak var telefonoText: UITextField!
  @IBOutlet weak var contactarSwitch: UISwitch!
  @IBOutlet weak var contactDataVIew: UIView!
  
  
  @IBAction func showContactView(_ sender: Any) {
    self.contactDataVIew.isHidden = !self.contactarSwitch.isOn
  }
  
}
