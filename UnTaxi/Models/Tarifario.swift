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
  
  init(jsonData: [String: Any]) {
    let tarifaPorHorarios = jsonData["horarios"] as! [[String: Any]]
    for horarioTarifa in tarifaPorHorarios{
      self.tarifas.append(Tarifa(jsonData: horarioTarifa))
    }
    self.precioHoraFuera = !(jsonData["precio_hora_fuera"] is NSNull) ? jsonData["precio_hora_fuera"] as! Double : 0.0
    self.precioKmFuera = !(jsonData["precio_km_fuera"] is NSNull) ? jsonData["precio_km_fuera"] as! Double : 0.0
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
