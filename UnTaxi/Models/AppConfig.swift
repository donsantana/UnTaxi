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
  
//  init(config: [String: Any]) {
//    print("config \(config["oferta"])")
//      oferta = !(config["oferta"] is NSNull) ? (config["oferta"] as! Bool) : false
//      taximetro = !(config["taximetro"] is NSNull) ? (config["taximetro"] as! Bool) : false
//      horas = !(config["horas"] is NSNull) ? (config["horas"] as! Bool) : false
//      cardpay = !(config["cardpay"] is NSNull) ? (config["cardpay"] as! Bool) : false
//      advertising = !(config["advertising"] is NSNull) ? (config["advertising"] as! Bool) : false
//      pactadas = !(config["pactadas"] is NSNull) ? (config["pactadas"] as! Bool) : false
//      recargas = !(config["recargas"] is NSNull) ? (config["recargas"] as! Bool) : false
//      reserva = !(config["reserva"] is NSNull) ? (config["reserva"] as! Bool) : false
//      sms = !(config["sms"] is NSNull) ? (config["sms"] as! Bool) : false
//      tiemposolicitud = !(config["tiemposolicitud"] == nil) ? config["tiemposolicitud"] as! Int : 90
//      yapa = !(config["yapa"] is NSNull) ? (config["yapa"] as! Bool) : false
//    uso_yapa = !(config["uso_yapa"] is NSNull) ? (config["uso_yapa"] as! Double) : 0.0
//
//  }
  
  //Produccion
  init(config: [String: Any]) {
		oferta = !(config["oferta"] is NSNull) ? (config["oferta"] is NSString) ? ((config["oferta"] as! NSString) == "true") : (config["oferta"] as! Bool) : false
		taximetro = !(config["taximetro"] is NSNull) ? (config["taximetro"] is NSString) ? ((config["taximetro"] as! NSString) == "true") : (config["taximetro"] as! Bool) : false
		horas = !(config["horas"] is NSNull) ? (config["horas"] is NSString) ? ((config["horas"] as! NSString) == "true") : (config["horas"] as! Bool) : false
		cardpay = !(config["cardpay"] is NSNull) ? (config["cardpay"] is NSString) ? ((config["cardpay"] as? NSString) == "true") : (config["cardpay"] as! Bool) : false
		advertising = !(config["advertising"] is NSNull) ? (config["advertising"] is NSString) ? ((config["advertising"] as! NSString) == "true") : (config["advertising"] as! Bool) : false
		pactadas = !(config["pactadas"] is NSNull) ? (config["pactadas"] is NSString) ? ((config["pactadas"] as! NSString) == "true") : (config["pactadas"] as! Bool) : false
		recargas = !(config["recargas"] is NSNull) ? (config["recargas"] is NSString) ? ((config["recargas"] as! NSString) == "true") : (config["recargas"] as! Bool) : false
		reserva = !(config["reserva"] is NSNull) ? (config["reserva"] is NSString) ? ((config["reserva"] as! NSString) == "true") : (config["reserva"] as! Bool) : false
		sms = !(config["sms"] is NSNull) ? (config["sms"] is NSString) ? ((config["sms"] as! NSString) == "true") : (config["sms"] as! Bool) : false
		tiemposolicitud = !(config["tiemposolicitud"] == nil) ? config["tiemposolicitud"] as! Int : 0
		yapa = !(config["yapa"] is NSNull) ? ((config["yapa"] as! Int) == 1) : (config["yapa"] as! Bool)
		uso_yapa = !(config["uso_yapa"] is NSNull) ? (config["uso_yapa"] as! Double) : 0.0
//    if GlobalConstants.enviroment == "dev"{
//      oferta = !(config["oferta"] is NSNull) ? (config["oferta"] as! Bool) : false
//      taximetro = !(config["taximetro"] is NSNull) ? (config["taximetro"] as! Bool) : false
//      horas = !(config["horas"] is NSNull) ? (config["horas"] as! Bool) : false
//      cardpay = !(config["cardpay"] is NSNull) ? (config["cardpay"] as! Bool) : false
//      advertising = !(config["advertising"] is NSNull) ? (config["advertising"] as! Bool) : false
//      pactadas = !(config["pactadas"] is NSNull) ? (config["pactadas"] as! Bool) : false
//      recargas = !(config["recargas"] is NSNull) ? (config["recargas"] as! Bool) : false
//      reserva = !(config["reserva"] is NSNull) ? (config["reserva"] as! Bool) : false
//      sms = !(config["sms"] is NSNull) ? (config["sms"] as! Bool) : false
//      tiemposolicitud = !(config["tiemposolicitud"] == nil) ? config["tiemposolicitud"] as! Int : 90
//      yapa = !(config["yapa"] is NSNull) ? (config["yapa"] as! Bool) : false
//      uso_yapa = !(config["uso_yapa"] is NSNull) ? (config["uso_yapa"] as! Double) : 0.0
//    } else {
//
//    }
  }
}
