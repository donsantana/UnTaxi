//
//  CConductor.swift
//  Xtaxi
//
//  Created by Done Santana on 23/1/16.
//  Copyright © 2016 Done Santana. All rights reserved.
//

import Foundation

class CConductor{
    var IdConductor :String
    var NombreApellido :String
    var Telefono :String
    var UrlFoto :String
    
    init(IdConductor :String, Nombre :String, Telefono :String, UrlFoto :String){
        self.IdConductor = IdConductor
        self.NombreApellido = Nombre
        self.Telefono = Telefono
        if UrlFoto != ""{
        self.UrlFoto = UrlFoto
        }
        else{
        self.UrlFoto = "chofer"}
    }
    
    
}