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
  
  init(jsonData: [String: Any]){
    self.horaInicio = !(jsonData["hora_inicio"] is NSNull) ? jsonData["hora_inicio"] as! Int : 0
    self.horaFin = !(jsonData["hora_fin"] is NSNull) ? jsonData["hora_fin"] as! Int : 0
    self.valorMinimo = !(jsonData["minima"] is NSNull) ? jsonData["minima"] as! Double : 0.0
    self.tiempoEspera = !(jsonData["tiempo_espera"] is NSNull) ? jsonData["tiempo_espera"] as! Double : 0.0
    self.valorArranque = !(jsonData["arranque"] is NSNull) ? jsonData["arranque"] as! Double : 0.0
    self.unoatreskm = !(jsonData["unoatreskm"] is NSNull) ? jsonData["unoatreskm"] as! Double : 0.0
    self.tresadiezkm = !(jsonData["tresadiezkm"] is NSNull) ? jsonData["tresadiezkm"] as! Double : 0.0
    self.tresadelantekm = !(jsonData["tresadelantekm"] is NSNull) ? jsonData["tresadelantekm"] as! Double : 0.0
  }
  
}
