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
