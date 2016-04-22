//
//  CTarifa.swift
//  Xtaxi
//
//  Created by usuario on 17/4/16.
//  Copyright © 2016 Done Santana. All rights reserved.
//

import Foundation

class CTarifa {
    var horaInicio : Int
    var horaFin : Int
    var valorMinimo : Double
    var tiempoEspera : Double
    var valorKilometro : Double
    var valorArranque : Double
    
    init(horaInicio : String, horaFin : String, valorMinimo : Double, tiempoEspera : Double, valorKilometro : Double, valorArranque : Double){
        var temporal = String(horaInicio).componentsSeparatedByString(":")
        self.horaInicio = Int(temporal[2])!
        self.horaFin = Int(temporal[3])!
        self.valorMinimo = valorMinimo
        self.tiempoEspera = tiempoEspera
        self.valorKilometro = valorKilometro
        self.valorArranque = valorArranque
    }
    
    
}