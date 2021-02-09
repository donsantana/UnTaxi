//
//  OfertaViewCell.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 7/7/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import UIKit
import CoreLocation

class OfertaViewCell: UITableViewCell {
  @IBOutlet weak var ofertaView: OfertaViewCell!
  @IBOutlet weak var conductorFoto: UIImageView!
  @IBOutlet weak var condNombreApellidos: UILabel!
  @IBOutlet weak var distanciaTiempoText: UILabel!
  @IBOutlet weak var valorText: UILabel!
  @IBOutlet weak var calificacionText: UILabel!
  @IBOutlet weak var marcaModelo: UILabel!
  
  func initContent(oferta: Oferta){
    self.ofertaView.addShadow()
    let origenCoord = globalVariables.solpendientes.first{$0.id == oferta.id}?.origenCoord
    let origenLocation = CLLocation(latitude: Double(origenCoord!.latitude), longitude: Double(origenCoord!.longitude))
    let distance = origenLocation.distance(from: CLLocation(latitude: oferta.location.latitude, longitude: oferta.location.longitude))/1000
    //self.marcaModelo.font = CustomAppFont.normalFont
    //self.condNombreApellidos.normalTextBlueStyle()
    //self.distanciaTiempoText.font = CustomAppFont.normalFont
    //self.valorText.bigTextBlueStyle()
    //self.calificacionText.font = CustomAppFont.smallFont
    
    let url = URL(string:"\(GlobalConstants.urlHost)/\(oferta.urlFoto)")
    
    let task = URLSession.shared.dataTask(with: url!) { data, response, error in
      guard let data = data, error == nil else { return }
      DispatchQueue.main.sync() {
        self.conductorFoto.image = UIImage(data: data)
      }
    }
    task.resume()
    self.marcaModelo.text = "\(oferta.marca)"
    self.condNombreApellidos.text = oferta.nombreConductor
    self.distanciaTiempoText.text = " \(oferta.tiempoLLegada)min - \(String(format: "%.2f",distance))km"
    self.valorText.text = "$\(String(format: "%.2f",oferta.valorOferta))"
    self.calificacionText.text = "\(oferta.calificacion) (\(oferta.totalCalif))"
    
    if distance < 1 {
      self.distanciaTiempoText.backgroundColor = .systemGreen
    }else{
      if distance > 1 && distance < 2{
        self.distanciaTiempoText.backgroundColor = .systemOrange
      }else{
        self.distanciaTiempoText.backgroundColor = .systemRed
      }
    }
  }
}
