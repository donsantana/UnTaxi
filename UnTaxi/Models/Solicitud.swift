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
    var pagado = 0
    var idestado = 0
    
    //var valorOferta = 0.0
    var detalleOferta = ""
    
    var fechaReserva = OurDate(date: Date())
    
    var tarjeta = false
    
    var yapa = false
    
    var taxi = Taxi()
    
    var useVoucher = "0"
    var otroNombre = ""
    var otroTelefono = ""
    //
    init(id: Int, fechaHora: String, dirOrigen: String, referenciaOrigen: String, dirDestino: String, latOrigen: Double, lngOrigen: Double, latDestino: Double, lngDestino: Double, importe: Double, detalleOferta: String, fechaReserva: String, useVoucher: String,tipoServicio: Int, yapa: Bool, tarjeta: Bool) {
        self.id = id
        self.fechaHora = fechaHora != "" ? OurDate(stringDate: fechaHora) : OurDate(date: Date())
        self.dirOrigen = dirOrigen
        self.referenciaorigen = !referenciaOrigen.isEmpty ? referenciaorigen : "No especificado"
        self.dirDestino = !dirDestino.isEmpty ? dirDestino : "No especificado"
        self.origenCoord = CLLocationCoordinate2D(latitude: latOrigen, longitude: lngOrigen)
        self.destinoCoord = CLLocationCoordinate2D(latitude: latDestino, longitude: lngDestino)
        self.importe = importe
        self.detalleOferta = detalleOferta
        self.useVoucher = useVoucher
        self.tipoServicio = tipoServicio
        self.yapa = yapa
        self.tarjeta = tarjeta
        if fechaReserva != ""{
            let fechaFormatted = fechaReserva.replacingOccurrences(of: "/", with: "-")
            self.fechaReserva = OurDate(stringDate: fechaFormatted)
        }
    }
    
    init(jsonData: [String: Any]) {
        self.id = !(jsonData["idsolicitud"] is NSNull) ? jsonData["idsolicitud"] as! Int : 0
        self.fechaHora = !(jsonData["fechahora"] is NSNull) ? OurDate(stringDate:jsonData["fechahora"] as? String) : OurDate(date: Date())
        self.dirOrigen = !(jsonData["dirorigen"] is NSNull) ? jsonData["dirorigen"] as! String : ""
        self.referenciaorigen = !(jsonData["referenciaorigen"] is NSNull) ? jsonData["referenciaorigen"] as! String : ""
        self.dirDestino = !(jsonData["dirdestino"] is NSNull) ? jsonData["dirdestino"] as! String : ""
        self.origenCoord = CLLocationCoordinate2D(latitude: !(jsonData["latorigen"] is NSNull) ? jsonData["latorigen"] as! Double : 0.0, longitude: !(jsonData["lngorigen"] is NSNull) ? jsonData["lngorigen"] as! Double : 0.0)
        self.destinoCoord = CLLocationCoordinate2D(latitude: !(jsonData["latdestino"] is NSNull) ? jsonData["latdestino"] as! Double : 0.0, longitude: !(jsonData["lngdestino"] is NSNull) ? jsonData["lngdestino"] as! Double : 0.0)
        self.importe = !(jsonData["importe"] is NSNull) ? jsonData["importe"] as! Double : 0.0
        self.detalleOferta = !(jsonData["detalleoferta"] is NSNull) ? jsonData["detalleoferta"] as! String : ""
        self.useVoucher = !(jsonData["idempresa"] is NSNull) ? (jsonData["idempresa"] as! Int != 0) ? "1" : "0" : "0"
        self.tipoServicio = !(jsonData["tiposervicio"] is NSNull) ? jsonData["tiposervicio"] as! Int : 0
        self.yapa = !(jsonData["yapa"] is NSNull) ? jsonData["yapa"] as! Bool : false
        self.fechaReserva = !(jsonData["fechareserva"] is NSNull) ? OurDate(stringDate:jsonData["fechareserva"] as? String) : OurDate(date: Date())
        self.taxi = !(jsonData["taxi"] is NSNull) ? Taxi(jsonData: jsonData["taxi"] as! [String: Any]) : Taxi()
        self.idestado = !(jsonData["idestado"] is NSNull) ? jsonData["idestado"] as! Int : 0
        self.pagado = !(jsonData["pagado"] is NSNull) ? jsonData["pagado"] as! Int : 0
        self.tarjeta = !(jsonData["tarjeta"] is NSNull) ? jsonData["tarjeta"] as! Bool : false
    }
    
    //Agregar datos de la solicitud
    func DatosSolicitud(id: Int, fechaHora: String, dirOrigen: String, referenciaOrigen: String, dirDestino: String, latOrigen: Double, lngOrigen: Double, latDestino: Double, lngDestino: Double, importe: Double, detalleOferta: String, fechaReserva: String, useVoucher: String,tipoServicio: Int, yapa: Bool){
        self.id = id
        self.fechaHora = fechaHora != "" ? OurDate(stringDate: fechaHora) : OurDate(date: Date())
        self.dirOrigen = dirOrigen
        self.referenciaorigen = !referenciaOrigen.isEmpty ? referenciaorigen : "No especificado"
        self.dirDestino = !dirDestino.isEmpty ? dirDestino : "No especificado"
        self.origenCoord = CLLocationCoordinate2D(latitude: latOrigen, longitude: lngOrigen)
        self.destinoCoord = CLLocationCoordinate2D(latitude: latDestino, longitude: lngDestino)
        self.importe = importe
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
    
    func updateValorOferta(newValor: String)->[String: Any]{
        self.importe = (newValor.dropFirst() as NSString).doubleValue
        
        return [
            "idsolicitud": self.id,
            "importe": self.importe
        ]
    }
    
    func crearTramaTaximetro()->[String: Any]{
        
        if self.useVoucher != "0"{
            return [
                "dirdestino": self.dirDestino,
                "latdestino": self.destinoCoord.latitude,
                "lngdestino": self.destinoCoord.longitude,
            ]
        } else {
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
            "idempresa": self.useVoucher == "1" ? self.cliente.idEmpresa! : 0,
            "empresa": self.useVoucher == "1" ? self.cliente.empresa! : "",
            "idtipovehiculo": 1,
            "tipovehiculo": "Taxi",
            "tarjeta": self.tarjeta,
            "yapa": self.yapa,
            "dirdestino": self.dirDestino,
            "latdestino": self.destinoCoord.latitude,
            "lngdestino": self.destinoCoord.longitude,
            "importe": self.importe,
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
    
    func crearTramaCancelar(motivo: String) -> [String:Any] {
        return [
            "idsolicitud": self.id,
            "motivocancelacion": motivo
        ]
    }
    
    func isAceptada()->Bool {
        return self.taxi.location.latitude != 0.0
    }
    
    func isPendientePago()->Bool {
        return idestado == 7 && pagado == 0 && tarjeta
    }
    
    func tipodePago() {
        
    }
    
}
