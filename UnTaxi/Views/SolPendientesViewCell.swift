//
//  SolPendientesViewCell.swift
//  Conaitor
//
//  Created by Donelkys Santana on 12/27/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import UIKit

protocol SolPendientesDelegate: class {
  func cancelRequest(_ controller: SolPendientesViewCell, cancelarSolicitud solicitud: Solicitud)
}

class SolPendientesViewCell: UITableViewCell{
  weak var delegate: SolPendientesDelegate?
  var solicitud: Solicitud?
  
  @IBOutlet weak var solicitudOrigenText: UILabel!
  @IBOutlet weak var solDateText: UILabel!
  @IBOutlet weak var dataView: UIView!
  
  func initContent(solicitud: Solicitud){
    self.solicitud = solicitud
    self.dataView.addShadow()
    self.solicitudOrigenText.text = solicitud.dirOrigen
    self.solDateText.text = solicitud.fechaHora.dateTimeToShow()
  }
  
  @IBAction func cancelarSolicitud(_ sender: Any) {
    self.delegate?.cancelRequest(self, cancelarSolicitud: self.solicitud!)
  }
  
}
