//
//  AppConfig.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 7/9/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import Foundation

struct AppConfig {
  
  var oferta: Bool            //para cliente
  var taximetro: Bool       //para cliente
  var horas: Bool             //para cliente
  var cardpay: Bool         //para cliente
  var advertising: Bool    //para cliente y conductor
  var pactadas: Bool
  
  init() {
    oferta = false
    taximetro = false
    horas = false
    cardpay = false
    advertising = false
    pactadas = false
  }
  
  init(config: [String: Any]) {
    oferta = config["oferta"] as! Bool
    taximetro = config["taximetro"] as! Bool
    horas = config["horas"] as! Bool
    cardpay = config["cardpay"] as! Bool
    advertising = config["advertising"] as! Bool
    pactadas = config["pactadas"] as! Bool
  }
}
