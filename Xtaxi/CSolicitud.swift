//
//  CSolicitud.swift
//  Xtaxi
//
//  Created by Done Santana on 29/1/16.
//  Copyright © 2016 Done Santana. All rights reserved.
//

import Foundation



class CSolicitud {
    var idcliente :String     // = datos[1];
    var idconductor :String   // = datos[2];
    var idtaxi :String        //= datos[3];
    var nombreapellidoscliente :String     //= datos[4];
    var nombreapellidosconductor :String   //= datos[5];
    var codigovehiculo :String              //= datos[6];
    var dirorigen :String                    //= datos[7];
    var referenciaorigen :String //= datos[8];
    var dirdestino :String //= datos[9];
    var disttaxiorigen :String //= datos[10];
    var distorigendestino :String //= datos[11];
    var consumocombustible :String //= datos[12];
    var importe :String //= datos[13];
    var tiempotaxiorigen :String //= datos[14];
    var tiempoorigendestino :String //= datos[15];
    var lattaxi :String //= datos[16];
    var lngtaxi :String //= datos[17];
    var latorigen :String //= datos[18];
    var lngorigen :String //= datos[19];
    var latdestino :String //= datos[20];
    var lngdestino :String //= datos[21];
    var vestuariocliente :String //= datos[22];
    var movilcliente :String //= datos[23];

//Constructor
    init(){
        self.idcliente = ""
        self.idconductor = ""
        self.idtaxi = ""
        self.nombreapellidoscliente = ""
        self.nombreapellidosconductor = ""
        self.codigovehiculo = ""
        self.dirorigen = ""
        self.referenciaorigen = ""
        self.dirdestino = ""
        self.disttaxiorigen = ""
        self.distorigendestino = ""
        self.consumocombustible = ""
        self.importe = ""
        self.tiempotaxiorigen = ""
        self.tiempoorigendestino = ""
        self.lattaxi = ""
        self.lngtaxi = ""
        self.latorigen = ""
        self.lngorigen = ""
        self.latdestino = ""
        self.lngdestino = ""
        self.vestuariocliente = ""
        self.movilcliente = ""
    }
    //agregar datos del cliente
    func DatosCliente(idcliente: String,nombreapellidoscliente :String,movilcliente :String){
        self.idcliente = idcliente
        self.nombreapellidoscliente = nombreapellidoscliente
        self.movilcliente = movilcliente
    }
    //Agregar datos del Conductor
    func DatosTaxiConductor(idconductor: String, nombreapellidosconductor :String, codigovehiculo :String){
        self.idconductor = idconductor
        self.nombreapellidosconductor = nombreapellidosconductor
        self.codigovehiculo = codigovehiculo
        
    }
    //sgregar id y posicion de taxi
    func OtrosDatosTaxi(idtaxi :String,lattaxi :String, lngtaxi :String){
        self.idtaxi = idtaxi
        self.lattaxi = lattaxi
        self.lngtaxi = lngtaxi
    }
    //Agregar datos de la solicitud
    func DatosSolicitud(dirorigen :String, referenciaorigen :String, dirdestino :String, disttaxiorigen :String, distorigendestino :String, consumocombustible :String, importe :String, tiempotaxiorigen :String, tiempoorigendestino :String,   latorigen :String, lngorigen :String, latdestino :String, lngdestino :String, vestuariocliente :String){
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
        self.vestuariocliente = vestuariocliente
    }

}
