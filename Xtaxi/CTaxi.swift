//
//  CTaxi.swift
//  Xtaxi
//
//  Created by Done Santana on 23/1/16.
//  Copyright © 2016 Done Santana. All rights reserved.
//

import Foundation
class CTaxi{
    var Matricula :String
    var CodTaxi :String
    var MarcaVehiculo :String
    var ColorVehiculo :String
    var GastoCombustible :String
    var Conductor : CConductor
    
    init(Matricula :String, CodTaxi :String, MarcaVehiculo :String, ColorVehiculo :String, GastoCombustible :String,  Conductor : CConductor){
        self.Matricula = Matricula
        self.CodTaxi = CodTaxi
        self.MarcaVehiculo = MarcaVehiculo
        self.ColorVehiculo = ColorVehiculo
        self.GastoCombustible = GastoCombustible
        self.Conductor = Conductor
    }

}