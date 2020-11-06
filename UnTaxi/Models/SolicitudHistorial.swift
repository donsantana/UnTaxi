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
  var dirDestino = ""
  var importe = 0.0
  
  var tarjeta = false
  
  var yapa = false
  
  var matricula = ""
  var pagado = 0
  var idEstado = 0
  
  //Agregar datos de la solicitud
  init(json: [String: Any]){
    self.id =  json["idsolicitud"] as! Int
    self.fechaHora = OurDate(stringDate: json["fechahora"] as! String)
    self.dirOrigen = json["dirorigen"] as! String
    self.dirDestino = json["dirdestino"] as! String
    self.importe = json["importe"] as! Double
    self.tarjeta = json["tarjeta"] as! Bool
    self.yapa =  json["yapa"] as! Bool
    self.matricula = json["matricula"] as! String
    self.pagado = json["pagado"] as! Int
    self.idEstado = json["idestado"] as! Int
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

