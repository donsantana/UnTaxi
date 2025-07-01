//
//  Address.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 9/6/21.
//  Copyright © 2021 Done Santana. All rights reserved.
//

import Foundation
import CoreLocation

struct Coordinates: Decodable {
    var latitude, longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case latitude = "latitud"
        case longitude = "longitud"
    }
    
    init() {
        latitude = 0.0
        longitude = 0.0
    }
    
    init(json: [String: Any]) throws {
        latitude = (json["coordinates"] as! [Double])[1]
        longitude = (json["coordinates"] as! [Double])[0]
    }
    
}

struct Address {
  var nombre,numero,calle,localidad,distrito,ciudad,pais,codigoPostal: String
  var coordenadas: Coordinates!
  
  init(json: [String: Any]) throws {
    let properties = json["properties"] as! [String: Any]
    nombre = properties["name"] != nil ? properties["name"] as! String: ""
    numero = properties["housenumber"] != nil ? properties["housenumber"] as! String: ""
    calle = properties["street"] != nil ? properties["street"] as! String: ""
    localidad = properties["locality"] != nil ? properties["locality"] as! String: ""
    distrito = properties["district"] != nil ? properties["district"] as! String: ""
    ciudad = properties["city"] != nil ? properties["city"] as! String: ""
    pais = properties["country"] != nil ? properties["country"] as! String: ""
    codigoPostal = properties["postcode"] != nil ? properties["postcode"] as! String: ""
    coordenadas = json["geometry"] != nil ? try Coordinates(json: json["geometry"] as! [String: Any]) : Coordinates()
  }
    
    init(description: String,placeId: String) {
        nombre = description
        numero = placeId
        calle = ""
        localidad = ""
        distrito = ""
        ciudad = ""
        pais = ""
        codigoPostal = ""
        coordenadas = Coordinates()
    }
  
  func fullAddress()->String{
    return "\(calle) \(localidad) \(distrito) \(ciudad)"
  }
  
  func getCoordinates()->CLLocationCoordinate2D{
    print("\(coordenadas.latitude) - \(coordenadas.longitude)")
    return CLLocationCoordinate2D(latitude: coordenadas.latitude, longitude: coordenadas.longitude)
  }
}

struct AddressOptionItem: Decodable {
    var description: String
    var place_id: String
}

struct AddressOptionsList: Decodable {
    var list: [AddressOptionItem]
}
