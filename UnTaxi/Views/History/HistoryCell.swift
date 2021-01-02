//
//  HistoryCell.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 11/3/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {
  @IBOutlet weak var dataView: UIView!
  @IBOutlet weak var fechaText: UILabel!
  @IBOutlet weak var origenText: UILabel!
  @IBOutlet weak var destinoText: UILabel!
  @IBOutlet weak var importeText: UILabel!
  @IBOutlet weak var statusText: UILabel!
  
  func initContent(solicitud: SolicitudHistorial){
    
    self.dataView.addShadow()
    UILabel.appearance().font = CustomAppFont.normalFont
    
    self.fechaText.text = solicitud.fechaHora.dateTimeToShow()
    self.origenText.text = solicitud.dirOrigen
    self.destinoText.text = solicitud.dirDestino
    self.importeText.text = "$\(solicitud.importe)"
    self.statusText.text = solicitud.solicitudStado().uppercased()
  }
}
