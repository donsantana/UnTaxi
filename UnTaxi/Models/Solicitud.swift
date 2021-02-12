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

class Solicitud {
//   "SERVICE_TYPE": {
//     "OFERTA": 1,
//     "TAXIMETRO": 2,
//     "HORAS": 3
//   },

  var tramaBase: [String: Any] = [:]
  
  var id = 0
  var tipoServicio = 1
  var cliente = Cliente()
//  var idCliente = 0
//  var user = ""
//  var nombreApellidos = ""
  
  var fechaHora = OurDate(date: Date())
  var dirOrigen = ""
  var origenCoord = CLLocationCoordinate2D()
  var referenciaorigen = ""
  var dirDestino = ""
  var destinoCoord = CLLocationCoordinate2D()
  var distancia = 0.0
  var importe = 0.0
  var yapaimporte = 0.0
  
  var valorOferta = 0.0
  var detalleOferta = ""
  
  var fechaReserva = OurDate(date: Date())
  
  var tarjeta = false
  
  var yapa = false
  
  var taxi = Taxi()
//  var idTaxi = 0
//  var matricula = ""
//  var codTaxi = ""
//  var marca = ""
//  var color = ""
//  var taximarker = CLLocationCoordinate2D()
//
//  var idConductor = 0
//  var nombreApellidosConductor = ""
//  var movil = ""
//  var urlFoto = ""
  
  var useVoucher = "0"
  var otroNombre = ""
  var otroTelefono = ""
  
  
  //Taxi
  //  var idTaxi: String
  //  var matricula :String
  //  var codTaxi :String
  //  var marca :String
  //  var color :String
  //  var taximarker: CLLocationCoordinate2D
  //  //Conductor
  //  var idConductor :String
  //  var nombreApellido :String
  //  var movil :String
  //  var urlFoto :String
  
  
  //  //Constructor
  //  init(){
  //    super.init()
  //    self.idCliente = ""
  //    self.user = ""
  //    self.nombreApellidos = ""
  //
  //    self.id = ""
  //    self.fechaHora = ""
  //    self.dirOrigen = ""
  //    self.origenCoord = CLLocationCoordinate2D()
  //    self.referenciaorigen = ""
  //    self.dirDestino = ""
  //    self.destinoCoord = CLLocationCoordinate2D()
  //    self.distancia = 0.0
  //    self.valorOferta = "0"
  //    self.detalleOferta = ""
  //    self.fechaReserva = Date()
  //
  //    //Taxi
  //    self.idTaxi = ""
  //    self.matricula = ""
  //    self.codTaxi = ""
  //    self.marca = ""
  //    self.color = ""
  //    taximarker = CLLocationCoordinate2D()
  //
  //    self.idConductor = ""
  //    self.nombreApellido = ""
  //    self.movil = ""
  //    self.urlFoto = ""
  //
  //  }
  
  //Agregar datos de la solicitud
  func DatosSolicitud(id: Int, fechaHora: String, dirOrigen: String, referenciaOrigen: String, dirDestino: String, latOrigen: Double, lngOrigen: Double, latDestino: Double, lngDestino: Double, valorOferta: Double, detalleOferta: String, fechaReserva: String, useVoucher: String,tipoServicio: Int, yapa: Bool){
    self.id = id
    self.fechaHora = fechaHora != "" ? OurDate(stringDate: fechaHora) : OurDate(date: Date())
    self.dirOrigen = dirOrigen
    self.referenciaorigen = !referenciaOrigen.isEmpty ? referenciaorigen : "No especificado"
    self.dirDestino = !dirDestino.isEmpty ? dirDestino : "No especificado"
    self.origenCoord = CLLocationCoordinate2D(latitude: latOrigen, longitude: lngOrigen)
    self.destinoCoord = CLLocationCoordinate2D(latitude: latDestino, longitude: lngDestino)
    self.valorOferta = valorOferta
    self.detalleOferta = detalleOferta
    self.useVoucher = useVoucher
    self.tipoServicio = tipoServicio
    self.yapa = yapa
    print("creating")
    if fechaReserva != ""{
      let fechaFormatted = fechaReserva.replacingOccurrences(of: "/", with: "-")
      self.fechaReserva = OurDate(stringDate: fechaFormatted)
    }
    //      self.fechaReserva = //fechaReserva.date
    //    }
  }
  
  //agregar datos para contactar a otro cliente
  func DatosOtroCliente(telefono: String, nombre: String){
    self.otroNombre = nombre
    self.otroTelefono = telefono
  }
  
  //agregar datos del cliente
  func DatosCliente(cliente: Cliente){
    self.cliente = cliente
  }
  //Agregar datos del Conductor
  func DatosTaxiConductor(taxi: Taxi){
    self.taxi = taxi
//    self.idConductor = idconductor
//    self.nombreApellidosConductor = nombreapellidosconductor
//    self.movil = movilconductor
//    self.urlFoto = foto
//    self.idTaxi = idtaxi
//    self.matricula = matricula
//    self.codTaxi = codigovehiculo
//    self.marca = marca
//    self.color = color
//    taximarker = CLLocationCoordinate2D(latitude: lattaxi, longitude: lngtaxi)
  }
  
  //REGISTRAR FECHA Y HORA
  func RegistrarFechaHora(Id: Int, FechaHora: String){ //, tarifario: [CTarifa]
    self.id = Id
    self.fechaHora = OurDate(stringDate: FechaHora)
  }
  
  func DistanciaTaxi()->String{
    let ruta = CRuta(origen: self.origenCoord, taxi: self.taxi.location)
    return ruta.CalcularDistancia()
  }
  
//  func getFechaISO() -> String {
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//    return dateFormatter.string(from: self.fechaReserva)
//  }
//  //
//  func showFecha()->String{
//    let formatter = DateFormatter()
//    formatter.dateFormat = "MMMM dd HH:mm:ss"
//    formatter.dateStyle = .medium
//    formatter.timeStyle = .short
//    return formatter.string(from: self.fechaReserva)
//  }
  
  func updateValorOferta(newValor: String)->[String: Any]{
    self.valorOferta = (newValor as NSString).doubleValue
    
    return [
      "idsolicitud": self.id,
      "importe": self.valorOferta
    ]
  }
  
  func crearTramaTaximetro()->[String: Any]{

    if self.useVoucher != "0"{
      return [
        "dirdestino": self.dirDestino,
        "latdestino": self.destinoCoord.latitude,
        "lngdestino": self.destinoCoord.longitude,
      ]
    }else{
      return [:]
    }
  }
  
  func crearTrama() -> [String:Any]{
    //    idcliente: 28138,
    //    tiposervicio: 2,
    //    dirorigen: 'Aqui',
    //    referenciaorigen: 'Frenta a la biblioteca',
    //    dirdestino: 'Alla',
    //    distorigendestino: 3,
    //    latorigen: -2.0001,
    //    lngorigen: -79.0001,
    //    latdestino: -2.0002,
    //    lngdestino: -79.0002,
    //    so: 2,
    //    idempresa: 311,
    //    empresa: 'FANTASTIC',
    //    detalleoferta: null,
    //    fechareserva: '2020-03-25 00:00:00',
    //    importe: 0,
    //    idtipovehiculo: 1,
    //    tipovehiculo: 'Taxi',
    //    tarjeta: true
    self.tramaBase = [
      "idcliente": self.cliente.id!,
      "tiposervicio": self.tipoServicio,
      "dirorigen": self.dirOrigen,
      "referenciaorigen": self.referenciaorigen,
      "latorigen": self.origenCoord.latitude,
      "lngorigen": self.origenCoord.longitude,
      "so": 2,
      "idempresa": self.cliente.idEmpresa ?? 0,
      "empresa": self.cliente.empresa ?? "",
      "idtipovehiculo": 1,
      "tipovehiculo": "Taxi",
      "tarjeta": self.tarjeta,
      "yapa": self.yapa,
      "dirdestino": self.dirDestino,
      "latdestino": self.destinoCoord.latitude,
      "lngdestino": self.destinoCoord.longitude,
      "importe": self.valorOferta,
      "detalleoferta": self.detalleOferta
    ]
    
    if self.otroTelefono != ""{
      tramaBase["idcliente"] = globalVariables.cliente.id!
      tramaBase["nombreapellidos"] = self.otroNombre
      tramaBase["movilcliente"] = self.otroTelefono
    }
    
//    if self.tipoServicio == 1{
//      tramaBase["importe"] = self.valorOferta
//      tramaBase["detalleoferta"] = self.detalleOferta
//    }
    print("trama \(tramaBase)")
    return tramaBase
  }
  
  //  func crearTrama(voucher: String) -> String{
  //    if self.valorOferta != "0"{
  //    return "#SO,\(self.idCliente),\(self.nombreApellidos),\(self.user),\(self.dirOrigen),\(self.referenciaorigen),\(self.dirDestino),\(self.origenCoord.latitude),\(self.origenCoord.longitude),\(self.destinoCoord.latitude),\(self.destinoCoord.longitude),\(self.distancia),\(self.valorOferta),\(voucher),\(self.detalleOferta),\(self.getFechaISO()),1,# \n"
  //    }else{
  //      return "#Solicitud,\(self.idCliente),\(self.nombreApellidos),\(self.user),\(self.dirOrigen),\(self.referenciaorigen),\(self.dirDestino),\(String(self.origenCoord.latitude)),\(String(self.origenCoord.longitude)),0.0,0.0,\(String(self.distancia)),\(self.importe),\(voucher),# \n"
  //    }
  //  }
  
  func crearTramaCancelar(motivo: String) -> [String:Any] {
    return [
      "idsolicitud": self.id,
      "motivocancelacion": motivo
    ]
  }
  
  func isAceptada()->Bool{
    return self.taxi.location.latitude != 0.0
  }
  
}
