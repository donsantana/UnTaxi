//
//  CarreraPactada.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 7/12/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import Foundation


struct DireccionesPactadas {
  var id: Int
  var dirorigen: String
  var latorigen: Double
  var lngorigen: Double
  var dirdestino: String
  var latdestino: Double
  var lngdestino: Double
  var importeida: Double
  var importeidaregreso: Double
  var idempresa: Int
  
  init(){
    self.id = 0
    self.dirorigen = ""
    self.latorigen = 0.0
    self.lngorigen = 0.0
    self.dirdestino = ""
    self.latdestino = 0.0
    self.lngdestino = 0.0
    self.importeida = 0.0
    self.importeidaregreso = 0.0
    self.idempresa = 0
  }
  
  init(data: [String: Any]){
    self.id = data["idserviciopactado"] as! Int
    self.dirorigen = data["dirorigen"] as! String
    self.latorigen = data["latorigen"] as! Double
    self.lngorigen = data["lngorigen"] as! Double
    self.dirdestino = data["dirdestino"] as! String
    self.latdestino = data["latdestino"] as! Double
    self.lngdestino = data["lngdestino"] as! Double
    self.importeida = data["importeida"] as! Double
    self.importeidaregreso = data["importeidaregreso"] as! Double
    self.idempresa = data["idempresa"] as! Int
  }

}
