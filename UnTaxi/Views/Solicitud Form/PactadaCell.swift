//
//  DestinoPactadaCell.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 7/12/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import Foundation
import UIKit

class PactadaCell: UITableViewCell {
  var solicitudPactada = DireccionesPactadas()
  var importe: Double = 0.0
  
  @IBOutlet weak var idaVueltaSwitch: UISegmentedControl!
  @IBOutlet weak var precioText: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.idaVueltaSwitch.customColor()
  }
  
  func initContent(solicitudPactada: DireccionesPactadas){
    self.solicitudPactada = solicitudPactada
    self.importe = self.idaVueltaSwitch.selectedSegmentIndex == 0 ? self.solicitudPactada.importeida :   self.solicitudPactada.importeidaregreso
    
    self.precioText.text = "$\(String(format: "%.0f", self.importe))"
  }
  
  @IBAction func onValueChanged(_ sender: Any) {
    self.importe = self.idaVueltaSwitch.selectedSegmentIndex == 0 ? self.solicitudPactada.importeida :   self.solicitudPactada.importeidaregreso
    
    self.precioText.text = "$\(String(format: "%.0f", self.importe))"
  }
  
}
