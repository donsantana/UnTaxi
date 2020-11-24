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
  var calificacion = 0.0
  var cantidadcalificacion = 0
  var foto = ""
  var importeyapa = 0
  var latdestino = 0.0
  var latorigen = 0.0
  var lngdestino = 0.0
  var lngorigen = 0.0
  var nombreapellidosconductor = ""
  
  //Agregar datos de la solicitud
  init(json: [String: Any]){
    self.id =  json["idsolicitud"] as! Int
    self.fechaHora = OurDate(stringDate: json["fechahora"] as! String)
    self.dirOrigen = json["dirorigen"] as! String
    self.dirDestino = (json["dirdestino"] as! String) != "" ? json["dirdestino"] as! String : "No especificado"
    self.importe = !(json["importe"] is NSNull) ? json["importe"] as! Double : 0.0
    self.tarjeta = json["tarjeta"] as! Bool
    self.yapa =  json["yapa"] as! Bool
    self.matricula = json["matricula"] as! String
    self.pagado = json["pagado"] as! Int
    self.idEstado = json["idestado"] as! Int
  }
  
  func addDetails(details: [String: Any]){
    self.calificacion = details["calificacion"] as! Double
    self.cantidadcalificacion = details["cantidadcalificacion"] as! Int
    self.foto = details["foto"] as! String
    self.importeyapa = details["importeyapa"] as! Int
    self.latdestino = details["latdestino"] as! Double
    self.latorigen = details["latorigen"] as! Double
    self.lngdestino = details["lngdestino"] as! Double
    self.lngorigen = details["lngorigen"] as! Double
    self.nombreapellidosconductor = details["nombreapellidosconductor"] as! String
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

