//
//  CSolPendiente.swift
//  Xtaxi
//
//  Created by Done Santana on 3/2/16.
//  Copyright © 2016 Done Santana. All rights reserved.
//

import Foundation


class CSolPendiente {
   
    var idSolicitud : String
    var idTaxi : String
    var codigo : String
    var FechaHora : String
    var Latitudtaxi : String
    var Longitudtaxi : String
    var Latitudorigen : String
    var Longitudorigen : String
    var Latituddestino : String
    var Longituddestino : String
    //var Movilchofer : String
    
    init(idSolicitud : String, idTaxi : String, codigo : String, FechaHora : String, Latitudtaxi : String, Longitudtaxi : String, Latitudorigen : String, Longitudorigen : String, Latituddestino : String, Longituddestino : String){
        self.idSolicitud = idSolicitud
        self.idTaxi = idTaxi
        self.codigo = codigo
        self.FechaHora = FechaHora        
        self.Latitudtaxi = Latitudtaxi
        self.Longitudtaxi = Longitudtaxi
        self.Latitudorigen = Latitudorigen
        self.Longitudorigen = Longitudorigen
        self.Latituddestino = Latituddestino
        self.Longituddestino = Longituddestino
        //self.Movilchofer = Movilchofer

    }
}