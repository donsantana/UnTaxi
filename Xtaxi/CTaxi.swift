//
//  CTaxi.swift
//  Xtaxi
//
//  Created by Done Santana on 23/1/16.
//  Copyright © 2016 Done Santana. All rights reserved.
//

import Foundation
class CTaxi{
    var idTaxi: String
    var matricula :String
    var codTaxi :String
    var marcaVehiculo :String
    var modelo: String
    var colorVehiculo :String
    var gastoCombustible :String
    var conductor : CConductor
    
    init(IdTaxi: String, Matricula :String, CodTaxi :String, MarcaVehiculo :String, modelo: String,ColorVehiculo :String, GastoCombustible :String,  Conductor : CConductor){
        self.idTaxi = IdTaxi
        self.matricula = Matricula
        self.codTaxi = CodTaxi
        self.marcaVehiculo = MarcaVehiculo
        self.modelo =  modelo
        self.colorVehiculo = ColorVehiculo
        self.gastoCombustible = GastoCombustible
        self.conductor = Conductor
    }

}