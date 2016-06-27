//
//  CSolicitud.swift
//  Xtaxi
//
//  Created by Done Santana on 29/1/16.
//  Copyright © 2016 Done Santana. All rights reserved.
//

import Foundation
import GoogleMaps


class CSolicitud {
    
    var idSolicitud: String
    var origenCarrera: GMSMarker
    var destinoCarrera: GMSMarker
    var referenciaorigen :String //= datos[8];
    /*var idcliente :String     // = datos[1];
    var nombreapellidoscliente :String     //= datos[4];
    var dirorigen :String                    //= datos[7];
    
    var dirdestino :String //= datos[9];
    var distorigendestino :String //= datos[11];
    var consumocombustible :String //= datos[12];
    var importe :String //= datos[13];
    var tiempoorigendestino :String //= datos[15];
    var latorigen :String //= datos[18];
    var lngorigen :String //= datos[19];
    var latdestino :String //= datos[20];
    var lngdestino :String //= datos[21];
    var movilcliente :String //= datos[23];
    var idconductor :String   // = datos[2];
    var nombreapellidosconductor :String   //= datos[5];
    var movilconductor : String //= datos[24]
    var idtaxi :String        //= datos[3];
    var disttaxiorigen :String //= datos[10];
    var tiempotaxiorigen :String //= datos[14];
    var codigovehiculo :String              //= datos[6];
    var lattaxi :String //= datos[16];
    var lngtaxi :String //= datos[17];
    var fechaHora : String
    var tarifa : Double
    var distancia : Double
    var tiempo : String
    var costo : String*/
    
    var cliente: CCliente
    var taxi : CTaxi //

    

//Constructor
    init(){
        self.idcliente = ""
        self.nombreapellidoscliente = ""
        self.dirorigen = ""
        self.referenciaorigen = ""
        self.dirdestino = ""
        self.distorigendestino = ""
        self.consumocombustible = ""
        self.importe = ""
        self.tiempoorigendestino = ""
        self.latorigen = ""
        self.lngorigen = ""
        self.latdestino = ""
        self.lngdestino = ""
        self.movilcliente = ""
        self.idconductor = ""
        self.nombreapellidosconductor = ""
        self.movilconductor = ""
        self.idtaxi = ""
        self.codigovehiculo = ""
        self.lattaxi = ""
        self.lngtaxi = ""
        self.disttaxiorigen = ""
        self.tiempotaxiorigen = ""
        self.fechaHora = ""
        self.tarifa = 0.0
        self.distancia = 0.0
        self.tiempo = ""
        self.costo = ""
        
        self.origenCarrera = GMSMarker(position: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
        self.origenCarrera.title = "Origen"
        self.origenCarrera.icon = UIImage(named: "origen")
        self.destinoCarrera = GMSMarker(position: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
        self.origenCarrera.title = "Destino"
        self.destinoCarrera.icon = UIImage(named: "destino")

    }
    
    //agregar datos del cliente
    func DatosCliente(idcliente: String,nombreapellidoscliente :String,movilcliente :String){
        self.idcliente = idcliente
        self.nombreapellidoscliente = nombreapellidoscliente
        self.movilcliente = movilcliente
    }
    //Agregar datos del Conductor
    func DatosTaxiConductor(idtaxi :String,lattaxi :String, lngtaxi :String, idconductor: String, nombreapellidosconductor :String, codigovehiculo :String, movilconductor: String){
        self.idconductor = idconductor
        self.nombreapellidosconductor = nombreapellidosconductor
        self.codigovehiculo = codigovehiculo
        self.movilconductor = movilconductor
        self.idtaxi = idtaxi
        self.lattaxi = lattaxi
        self.lngtaxi = lngtaxi
    }
    //sgregar id y posicion de taxi
   /* func OtrosDatosTaxi(idtaxi :String,lattaxi :String, lngtaxi :String){
        self.idtaxi = idtaxi
        self.lattaxi = lattaxi
        self.lngtaxi = lngtaxi
    }*/
    //REGISTRAR FECHA Y HORA
    func RegistrarFechaHora(FechaHora: String, tarifario: [CTarifa]){
        self.FechaHora = FechaHora
        var temporal = String(FechaHora).componentsSeparatedByString(" ")
        temporal = String(temporal[2]).componentsSeparatedByString(":")
        for var tarifatemporal in tarifario{
            if (Int(tarifatemporal.horaInicio) <= Int(temporal[1])) && (Int(temporal[1]) <= Int(tarifatemporal.horaFin)){
                self.tarifa = Double(tarifatemporal.valorKilometro)
            }
        }
    }
    //Agregar datos de la solicitud
    func DatosSolicitud(dirorigen :String, referenciaorigen :String, dirdestino :String, disttaxiorigen :String, distorigendestino :String, consumocombustible :String, importe :String, tiempotaxiorigen :String, tiempoorigendestino :String,   latorigen :String, lngorigen :String, latdestino :String, lngdestino :String){
        self.dirorigen = dirorigen
        self.referenciaorigen = referenciaorigen
        self.dirdestino = dirdestino
        self.disttaxiorigen = disttaxiorigen
        self.distorigendestino = distorigendestino
        self.consumocombustible = consumocombustible
        self.importe = importe
        self.tiempotaxiorigen = tiempotaxiorigen
        self.tiempoorigendestino = tiempoorigendestino
        self.latorigen = latorigen
        self.lngorigen = lngorigen
        self.latdestino = latdestino
        self.lngdestino = lngdestino
    
    }
    //agregar a la solicitud los datos de distancia y tiempo
    func AgregarDistanciaTiempo(datos : [String]){
        self.distancia = Double(datos[0])!
        self.tiempo = datos[1]
    }

    //Calcular el costo de la solicitud
    func CalcularCosto()->String{
        self.Costo = String(distancia * tarifa)
        return self.Costo
    }

}
