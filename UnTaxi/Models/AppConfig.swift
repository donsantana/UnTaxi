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
  var recargas: Bool
  var reserva: Bool
  var sms: Bool
  var tiemposolicitud: Int
  var yapa: Bool
  var uso_yapa: Double
  
  init() {
    oferta = false
    taximetro = false
    horas = false
    cardpay = false
    advertising = false
    pactadas = false
    recargas = false
    reserva = false
    sms = false
    tiemposolicitud = 90
    yapa = false
    uso_yapa = 0.0
  }
  
  init(config: [String: Any]) {
    print(config["oferta"])
    oferta = (config["oferta"] != nil)
    taximetro = (config["taximetro"] != nil)
    horas = (config["horas"] != nil)
    cardpay = (config["cardpay"] != nil)
    advertising = (config["advertising"] != nil)
    pactadas = (config["pactadas"] != nil)
    recargas = (config["recargas"] != nil)
    reserva = (config["reserva"] != nil)
    sms = (config["sms"] != nil)
    tiemposolicitud = config["tiemposolicitud"] as! Int
    yapa = (config["yapa"] != nil)
    uso_yapa = config["uso_yapa"] as! Double
    
  }
}
