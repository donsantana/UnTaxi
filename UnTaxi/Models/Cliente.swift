//
//  Cliente.swift
//  Xtaxi
//
//  Created by Done Santana on 14/10/15.
//  Copyright © 2015 Done Santana. All rights reserved.
//

import Foundation

struct Cliente{
  var idUsuario: Int!
  var id: Int!
  var user : String!
  var nombreApellidos : String!
  var email: String!
  var idEmpresa: Int!
  var empresa: String!
  var foto: String
  
  //Constructor
  init(){
    self.id = 0
    self.user = ""
    self.nombreApellidos = ""
    self.foto = ""
  }
  
  init(idUsuario: Int, id: Int, user: String, nombre: String, email:String, idEmpresa: Int, empresa: String, foto: String){
    self.idUsuario = idUsuario
    self.id = id
    self.user = user
    self.nombreApellidos = nombre
    self.email = email
    self.idEmpresa = idEmpresa
    self.empresa = empresa
    self.foto = foto
  }
  
}
