//
//  Tarifario.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 12/12/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import Foundation


class Tarifario {
  var tarifas: [Tarifa] = []
  var precioHoraFuera: Double
  var precioKmFuera: Double
  
  init(json: [String: Any]) {
    let tarifaPorHorarios = json["horarios"] as! [[String: Any]]
    for horarioTarifa in tarifaPorHorarios{
      self.tarifas.append(Tarifa(json: horarioTarifa))
    }
    self.precioHoraFuera = json["precio_hora_fuera"] as! Double
    self.precioKmFuera = json["precio_km_fuera"] as! Double
  }
  
  func valorForDistance(distance: Double)->Double{
    let dateFormatter = DateFormatter()
    var costo : Double!
    dateFormatter.dateFormat = "hh"
    let horaActual = dateFormatter.string(from: Date())
    for var tarifatemporal in tarifas{
      if (Int(tarifatemporal.horaInicio) <= Int(horaActual)!) && (Int(horaActual)! <= Int(tarifatemporal.horaFin)){
        if distance - 10 > 0{
          costo = Double((distance - 10) * tarifatemporal.tresadelantekm) + (7 * tarifatemporal.tresadiezkm) + (3 * tarifatemporal.unoatreskm)
        }else{
          if distance - 3 > 0{
            costo = Double((distance - 3) * tarifatemporal.tresadiezkm) + (3 * tarifatemporal.unoatreskm)
          }else{
            costo = tarifatemporal.valorMinimo
          }
        }
      }
    }
    return costo
  }
}
