//
//  Tarifa.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 12/12/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import Foundation

class Tarifa {
  var horaInicio : Int
  var horaFin : Int
  var valorMinimo : Double
  var tiempoEspera : Double
  var valorArranque : Double
  var unoatreskm: Double
  var tresadiezkm: Double
  var tresadelantekm: Double //diez en adelante
  
  init(json: [String: Any]){
    self.horaInicio = json["hora_inicio"] as! Int
    self.horaFin = json["hora_fin"] as! Int
    self.valorMinimo = json["minima"] as! Double
    self.tiempoEspera = json["tiempo_espera"] as! Double
    self.valorArranque = json["arranque"] as! Double
    self.unoatreskm = json["unoatreskm"] as! Double
    self.tresadiezkm = json["tresadiezkm"] as! Double
    self.tresadelantekm = json["tresadelantekm"] as! Double
  }
  
}
