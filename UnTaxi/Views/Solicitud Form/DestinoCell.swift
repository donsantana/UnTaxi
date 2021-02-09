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
    self.destinoText.text?.removeAll()
    self.destinoText.setBottomBorder(borderColor: Customization.bottomBorderColor)
  }

}
