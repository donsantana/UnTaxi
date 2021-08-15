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
  
  init(jsonData:[String: Any]){
    self.id = !(jsonData["idsolicitud"] is NSNull) ? jsonData["idsolicitud"] as! Int : 0
    self.idTaxi = !(jsonData["idtaxi"] is NSNull) ? jsonData["idtaxi"] as! Int : 0
    self.idConductor = !(jsonData["idconductor"] is NSNull) ? jsonData["idconductor"] as! Int : 0
    self.codigo = !(jsonData["codigotaxi"] is NSNull) ? jsonData["codigotaxi"] as! String : ""
    self.nombreConductor = !(jsonData["nombreapellidosconductor"] is NSNull) ? jsonData["nombreapellidosconductor"] as! String : ""
    self.movilConductor = !(jsonData["telefonoconductor"] is NSNull) ? jsonData["telefonoconductor"] as! String : ""
    self.location = CLLocationCoordinate2D(latitude: !(jsonData["lattaxi"] is NSNull) ? jsonData["lattaxi"] as! Double : 0.0, longitude: !(jsonData["lngtaxi"] is NSNull) ? jsonData["lngtaxi"] as! Double : 0.0)
    self.valorOferta = !(jsonData["valoroferta"] is NSNull) ? jsonData["valoroferta"] as! Double : 0.0
    self.tiempoLLegada = !(jsonData["tiempollegada"] is NSNull) ? jsonData["tiempollegada"] as! Int : 0
    self.calificacion = !(jsonData["calificacion"] is NSNull) ? jsonData["calificacion"] as! Double : 0.0
    self.totalCalif = !(jsonData["cantidadcalificacion"] is NSNull) ? jsonData["cantidadcalificacion"] as! Int : 0
    self.urlFoto = !(jsonData["foto"] is NSNull) ? jsonData["foto"] as! String : ""
    self.matricula = !(jsonData["matriculataxi"] is NSNull) ? jsonData["matriculataxi"] as! String : ""
    self.marca = !(jsonData["marcataxi"] is NSNull) ? jsonData["marcataxi"] as! String : ""
    self.color = !(jsonData["colortaxi"] is NSNull) ? jsonData["colortaxi"] as! String : ""
  }
  
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
