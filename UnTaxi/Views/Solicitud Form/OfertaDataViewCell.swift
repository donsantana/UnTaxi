//
//  OfertaViewCell.swift
//  Conaitor
//
//  Created by Donelkys Santana on 12/4/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import UIKit
import CurrencyTextField


class OfertaDataViewCell: UITableViewCell {
  var valueData: [Double] = []
  var valorOferta: Double = 0.0

  @IBOutlet weak var valorOfertaText: CurrencyTextField!

  func initContent(){
    self.valorOfertaText.setBottomBorder(borderColor: Customization.bottomBorderColor)
    //self.valorOfertaText.font = CustomAppFont.titleFont
    //self.valorOfertaText.text = "$\(String(format: "%.2f", globalVariables.tarifario.valorForDistance(distance: 0.0)))"
  }
}
 
