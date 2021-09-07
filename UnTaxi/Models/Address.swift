//
//  Address.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 9/6/21.
//  Copyright © 2021 Done Santana. All rights reserved.
//

import Foundation

struct Coordinates{
  var latitude, longitude: Double
  
  init() {
    latitude = 0.0
    longitude = 0.0
  }
  
  init(json: [String: Any]) throws {
    latitude = (json["coordinates"] as! [Double])[0]
    longitude = (json["coordinates"] as! [Double])[1]
  }
}

struct Address{
  var nombre,numero,calle,ciudad,pais,codigoPostal: String
  var coordenadas: Coordinates!
  
  init(json: [String: Any]) throws {
    let properties = json["properties"] as! [String: Any]
    nombre = properties["name"] != nil ? properties["name"] as! String: ""
    numero = properties["housenumber"] != nil ? properties["housenumber"] as! String: ""
    calle = properties["street"] != nil ? properties["street"] as! String: ""
    ciudad = properties["city"] != nil ? properties["city"] as! String: ""
    pais = properties["country"] != nil ? properties["country"] as! String: ""
    codigoPostal = properties["postcode"] != nil ? properties["postcode"] as! String: ""
    coordenadas = json["geometry"] != nil ? try Coordinates(json: json["geometry"] as! [String: Any]) : Coordinates()
  }
  func fullAddress()->String{
    return "\(nombre) \(calle) \(ciudad)"
  }
}
