//
//  DestinoCell.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/16/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit

protocol DestinoCellDelegate: class {
  func destinoCell(_ controller: DestinoCell, openSearchPanel result: Bool)
}

final class DestinoCell: UITableViewCell {
  @IBOutlet weak var destinoText: UITextField!
  @IBOutlet weak var showSearchBtn: UIButton!
  
  weak var delegate: DestinoCellDelegate?
  
  func initContent(){
    self.destinoText.text?.removeAll()
    self.destinoText.setBottomBorder(borderColor: Customization.bottomBorderColor)
  }
  
  @IBAction func openSearchPanel(_ sender: Any) {
    self.destinoText.resignFirstResponder()
    self.delegate?.destinoCell(self, openSearchPanel: true)
  }
  
}
