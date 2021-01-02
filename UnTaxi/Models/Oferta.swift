//
//  Oferta.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 7/7/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import Foundation
import CoreLocation

struct Oferta {
  //'#OSC,' + idsolicitud + ',' + idtaxi + ',' + codigo + ',' + nombreconductor + ',' + movilconductor + ',' + lat + ',' + lng + ',' + valoroferta + ',' + tiempollegada + ',' + calificacion + ',' + totalcalif + ',' + urlfoto + ',' + matricula + ',' + marca + ',' + color + ',# \n';
  
  var id: Int
  var idTaxi: Int
  var idConductor: Int
  var codigo: String
  var nombreConductor: String
  var movilConductor: String
  var location: CLLocationCoordinate2D
  var valorOferta: Double
  var tiempoLLegada: Int
  var calificacion: Double
  var totalCalif: Int
  var urlFoto: String
  var matricula: String
  var marca :String
  var color :String
  
  init(id: Int, idTaxi: Int,idConductor: Int, codigo: String, nombreConductor: String, movilConductor: String, lat: Double, lng: Double, valorOferta: Double, tiempoLLegada: Int, calificacion: Double, totalCalif: Int,urlFoto: String, matricula :String, marca :String, color :String){
    self.id = id
    self.idTaxi = idTaxi
    self.idConductor = idConductor
    self.codigo = codigo
    self.nombreConductor = nombreConductor
    self.movilConductor = movilConductor
    self.location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
    self.valorOferta = valorOferta
    self.tiempoLLegada = tiempoLLegada
    self.calificacion = calificacion
    self.totalCalif = totalCalif
    self.urlFoto = urlFoto
    self.matricula = matricula
    self.marca = marca
    self.color = color
  }
  
  mutating func updateValorOferta(cantidad: Double) {
    self.valorOferta += cantidad
  }
  
}
