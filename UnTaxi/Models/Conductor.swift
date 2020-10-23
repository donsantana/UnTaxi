//
//  Conductor.swift
//  Xtaxi
//
//  Created by Done Santana on 23/1/16.
//  Copyright © 2016 Done Santana. All rights reserved.
//

import UIKit

class Conductor{
  var idConductor: Int
  var nombreApellido: String
  var telefono: String
  var urlFoto: String
  var calificacion: Double
  var cantidadcalificaciones: Int
  
  init(){
    self.idConductor = 0
    self.nombreApellido = ""
    self.telefono = ""
    self.urlFoto = ""
    self.calificacion = 0.0
    self.cantidadcalificaciones = 0
    
  }
  init(idConductor: Int, nombre: String, telefono: String, urlFoto: String, calificacion: Double, cantidadcalificaciones: Int){
    self.idConductor = idConductor
    self.nombreApellido = nombre
    self.telefono = telefono
    self.calificacion = calificacion
    self.cantidadcalificaciones = cantidadcalificaciones
    if urlFoto != "null"{
      self.urlFoto = urlFoto
    }
    else{
      self.urlFoto = "chofer"}
  }
  
}
