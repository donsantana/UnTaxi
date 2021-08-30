//
//  SolicitudOferta.swift
//  Xtaxi
//
//  Created by Done Santana on 29/1/16.
//  Copyright © 2016 Done Santana. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
import MapKit

class SolicitudHistorial {
  
//   "SERVICE_TYPE": {
//     "OFERTA": 1,
//     "TAXIMETRO": 2,
//     "HORAS": 3
//   },

  var id = 0
  
  var fechaHora = OurDate(date: Date())
  var dirOrigen = ""
  var dirDestino = "No especificado"
  var importe = 0.0
  
  var tarjeta = false
  
  var yapa = false
  
  var matricula = ""
  var pagado = 0
  var idEstado = 0
  //Details
  var evaluacion = 0
  var calificacion = 0.0
  var cantidadcalificacion = 0
  var foto = ""
  var importeyapa = 0.0
  var latdestino = 0.0
  var latorigen = 0.0
  var lngdestino = 0.0
  var lngorigen = 0.0
  var nombreapellidosconductor = ""
  
  //Agregar datos de la solicitud
  init(jsonData: [String: Any]){
    self.id =  !(jsonData["idsolicitud"] is NSNull) ? jsonData["idsolicitud"] as! Int : 0
    self.fechaHora = !(jsonData["fechahora"] is NSNull) ? OurDate(stringDate: jsonData["fechahora"] as! String) : OurDate(date: Date())
    self.dirOrigen = !(jsonData["dirorigen"] is NSNull) ? jsonData["dirorigen"] as! String : ""
    self.dirDestino = !(jsonData["dirdestino"] is NSNull) ? (jsonData["dirdestino"] as! String) : "No especificado"
    self.importe = !(jsonData["importe"] is NSNull) ? jsonData["importe"] as! Double : 0.0
    self.tarjeta = !(jsonData["tarjeta"] is NSNull) ? jsonData["tarjeta"] as! Bool : false
    self.yapa =  !(jsonData["yapa"] is NSNull) ? jsonData["yapa"] as! Bool : false
    self.matricula = !(jsonData["matricula"] is NSNull) ? jsonData["matricula"] as! String : ""
    self.pagado = !(jsonData["pagado"] is NSNull) ? jsonData["pagado"] as! Int : 0
    self.idEstado = !(jsonData["idestado"] is NSNull) ? jsonData["idestado"] as! Int : 0
  }
  
  func addDetails(jsonDetails: [String: Any]){
    self.calificacion = !(jsonDetails["calificacion"] is NSNull) ? jsonDetails["calificacion"] as! Double : 0.0
    self.cantidadcalificacion = !(jsonDetails["idestado"] is NSNull) ? jsonDetails["cantidadcalificacion"] as! Int : 0
    self.foto = !(jsonDetails["foto"] is NSNull) ? jsonDetails["foto"] as! String : ""
    self.importeyapa = !(jsonDetails["importeyapa"] is NSNull) ? jsonDetails["importeyapa"] as! Double : 0.0
    self.latorigen = !(jsonDetails["latorigen"] is NSNull) ? jsonDetails["latorigen"] as! Double : 0.0
    self.lngorigen = !(jsonDetails["lngorigen"] is NSNull) ? jsonDetails["lngorigen"] as! Double : 0.0
    self.latdestino = !(jsonDetails["latdestino"] is NSNull) ? jsonDetails["latdestino"] as! Double : 0.0
    self.lngdestino = !(jsonDetails["lngdestino"] is NSNull) ? jsonDetails["lngdestino"] as! Double : 0.0
    self.nombreapellidosconductor = !(jsonDetails["nombreapellidosconductor"] is NSNull) ? jsonDetails["nombreapellidosconductor"] as! String : ""
  }
  
  func solicitudStado()->String{
    switch self.idEstado {
    case 5: return "Ejecutada"
    case 4: return "Rechazada"
    case 6: return "Cancelada"
    case 7: return "Completada"
    case 8: return "Abortad"
    case 2: return "Asignada"
    case 3: return "Aceptada"
    case 10: return "Ofertad"
    default:
      return ""
    }
  }
}

