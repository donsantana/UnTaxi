//
//  CCliente.swift
//  Xtaxi
//
//  Created by Done Santana on 14/10/15.
//  Copyright © 2015 Done Santana. All rights reserved.
//

import Foundation

class CCliente{
    var idcliente : String
    var nombre:String
    var numeroTelef:String
    var latitud:Double
    var longitud:Double
    var user : String
    var password : String
    
    
    //Constructor
    init(idcliente: String, nombre:String,numeroTelef:String,latitud:Double,longitud:Double, user:String, password:String){
        self.idcliente = idcliente
        self.nombre=nombre
        self.numeroTelef=numeroTelef
        self.latitud=latitud
        self.longitud=longitud
        self.user = user
        self.password = password
    }

}