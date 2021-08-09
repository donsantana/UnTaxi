//
//  Taxi.swift
//  Xtaxi
//
//  Created by Done Santana on 23/1/16.
//  Copyright © 2016 Done Santana. All rights reserved.
//

import Foundation
import CoreLocation

class Taxi{
  var id: Int
  var matricula: String
  var codigo: String
  var marca: String
  var color: String
  var location: CLLocationCoordinate2D
  
  var conductor: Conductor
  
  init(){
    self.id = 0
    self.matricula = ""
    self.codigo = ""
    self.marca = ""
    self.color = ""
    //self.conductor = Conductor()
    self.location = CLLocationCoordinate2D()
    
    self.conductor = Conductor()
  }
  
  init(jsonData: [String: Any]){
    self.id = !(jsonData["idtaxi"] is NSNull) ? jsonData["idtaxi"] as! Int : 0
    self.matricula = !(jsonData["matriculataxi"] is NSNull) ? jsonData["matriculataxi"] as! String : ""
    self.codigo = !(jsonData["codigotaxi"] is NSNull) ? jsonData["codigotaxi"] as! String : ""
    self.marca = !(jsonData["marcataxi"] is NSNull) ? jsonData["marcataxi"] as! String : ""
    self.color = !(jsonData["colortaxi"] is NSNull) ? jsonData["colortaxi"] as! String : ""
    self.location = CLLocationCoordinate2D(latitude: !(jsonData["lattaxi"] is NSNull) ? jsonData["lattaxi"] as! Double : 0.0, longitude: !(jsonData["lngtaxi"] is NSNull) ? jsonData["lngtaxi"] as! Double : 0.0)
    
    self.conductor = Conductor(idConductor: !(jsonData["idconductor"] is NSNull) ? jsonData["idconductor"] as! Int : 0, nombre: !(jsonData["nombreapellidosconductor"] is NSNull) ? jsonData["nombreapellidosconductor"] as! String : "", telefono: !(jsonData["telefonoconductor"] is NSNull) ? jsonData["telefonoconductor"] as! String : "", urlFoto: !(jsonData["foto"] is NSNull) ? jsonData["foto"] as! String : "", calificacion: !(jsonData["calificacion"] is NSNull) ? jsonData["calificacion"] as! Double : 0.0, cantidadcalificaciones: !(jsonData["cantidadcalificacion"] is NSNull) ? jsonData["cantidadcalificacion"] as! Int : 0)
  }
  
  init(id: Int, matricula: String, codigo: String, marca: String, color: String, lat: Double, long: Double, conductor: Conductor){
    self.id = id
    self.matricula = matricula
    self.codigo = codigo
    self.marca = marca
    self.color = color
    self.location = CLLocationCoordinate2D(latitude: lat, longitude: long)
    //Datos de Conductor
    self.conductor = conductor
  }
  
  func updateLocation(newLocation: CLLocationCoordinate2D){
    self.location = newLocation
  }
  
}
