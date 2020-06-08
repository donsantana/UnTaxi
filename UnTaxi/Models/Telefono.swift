//
//  Telefono.swift
//  XTaxi
//
//  Created by Done Santana on 11/8/16.
//  Copyright © 2016 Done Santana. All rights reserved.
//

import Foundation

struct Telefono{
    //#Telefonos,cantidad,numerotelefono1,operadora1,siesmovil1,sitienewassap1,numerotelefono2,operadora2.......,#
    var numero: String
    var operadora: String
    var email: String
    var tienewhatsapp: Bool
    
    init(numero: String,operadora: String,email: String,tienewhatsapp: Bool){
        self.numero = numero
        self.operadora = operadora
        self.email = email
        self.tienewhatsapp = tienewhatsapp
    }
}
