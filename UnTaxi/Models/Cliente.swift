//
//  Cliente.swift
//  Xtaxi
//
//  Created by Done Santana on 14/10/15.
//  Copyright © 2015 Done Santana. All rights reserved.
//

import UIKit
import Mapbox

class Cliente{
  var idUsuario: Int!
  var id: Int!
  var user : String!
  var nombreApellidos : String!
  var email: String!
  var idEmpresa: Int!
  var empresa: String!
  var foto: String
  var yapa: Double
  var fotoImage: UIImage!
  var annotation: MGLPointAnnotation!
  
  //Constructor
  init(){
    self.id = 0
    self.user = ""
    self.nombreApellidos = ""
    self.foto = ""
    self.yapa = 0.0
  }
  
  init(idUsuario: Int, id: Int, user: String, nombre: String, email:String, idEmpresa: Int, empresa: String, foto: String, yapa: Double){
    
    self.idUsuario = idUsuario
    self.id = id
    self.user = user
    self.nombreApellidos = nombre
    self.email = email
    self.idEmpresa = idEmpresa
    self.empresa = empresa
    self.foto = foto
    self.yapa = yapa
    self.fotoImage = UIImage(named: "chofer")
  }
  
  init(jsonData: [String: Any]){
    self.idUsuario = jsonData["idusuario"] as? Int
    self.id = jsonData["idcliente"] as? Int
    self.user = jsonData["movil"] as? String
    self.nombreApellidos = jsonData["nombreapellidos"] as? String
    self.email = jsonData["email"] as? String
    self.idEmpresa = jsonData["idempresa"] as? Int
    self.empresa = jsonData["empresa"] as? String
    self.foto = !(jsonData["foto"] is NSNull) ? jsonData["foto"] as! String : ""
    self.yapa = jsonData["yapa"] as! Double
    self.fotoImage = UIImage(named: "chofer")
    self.annotation = MGLPointAnnotation()
    annotation.subtitle = "origen"
    
    let url = URL(string:"\(GlobalConstants.urlHost)/\(self.foto)")
    
    let task = URLSession.shared.dataTask(with: url!) { data, response, error in
      guard let data = data, error == nil else { return }
      DispatchQueue.main.sync() {
        self.fotoImage = UIImage(data: data)
      }
    }
    task.resume()
  }
  
  func getName()->String{
    return self.nombreApellidos.components(separatedBy: " ").first!
  }
  
  func updatePhoto(newPhoto: UIImage){
    self.fotoImage = newPhoto
  }
  
  func cargarPhoto(imageView: UIImageView){
    if self.foto != ""{
      let url = URL(string:"\(GlobalConstants.urlHost)/\(self.foto)")
      
      let task = URLSession.shared.dataTask(with: url!) { data, response, error in
        guard let data = data, error == nil else { return }
        DispatchQueue.main.sync() {
          imageView.contentMode = .scaleAspectFill
          imageView.image = UIImage(data: data)
//          imageView.layer.cornerRadius = imageView.bounds.height/2
//          imageView.clipsToBounds = true
        }
      }
      task.resume()
    }else{
      imageView.image = UIImage(named: "chofer")
    }
  }
  
}
