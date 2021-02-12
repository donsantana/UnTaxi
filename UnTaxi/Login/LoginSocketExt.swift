//
//  LoginControllerSocketExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/5/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation


extension LoginController: SocketServiceDelegate{
  func socketResponse(_ controller: SocketService, startEvent result: [String : Any]) {
    print("rwult \(result)")
    switch result["code"] as! Int{
    case 1:
      self.initClientData(datos: result["datos"] as! [String: Any])
      DispatchQueue.main.async {
        self.AutenticandoView.isHidden = true
      }
    default:
      self.initConnectionError(message: result["msg"] as! String)
    }
  }
}

extension LoginController{
  
  func waitSocketConnection(){
//    globalVariables.socket.on("start"){data, ack in
//
//      let result = data[0] as! [String: Any]
//      print("start \(result["datos"])")
//      switch result["code"] as! Int{
//      case 1:
//        self.initClientData(datos: result["datos"] as! [String: Any])
//        DispatchQueue.main.async {
//          self.AutenticandoView.isHidden = true
//        }
//      default:
//        self.initConnectionError(message: result["msg"] as! String)
//      }
//    }
  }
  
  
  func SocketEventos(){
//    globalVariables.socket.on("connect"){data, ack in
//      let read = globalVariables.userDefaults.string(forKey: "loginData") ?? "Vacio"
//      //            let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
//      //            do {
//      //                read = try NSString(contentsOfFile: filePath, encoding: String.Encoding.utf8.rawValue) as String
//      //            }catch {
//      //            }
//      if read != "Vacio"{
//        self.AutenticandoView.isHidden = false
//        self.Login(user:"test", password: "testloginData: read")
//      }
//      else{
//        self.AutenticandoView.isHidden = true
//      }
//
//    }
    
//    globalVariables.socket.on("LoginPassword"){data, ack in
//      self.EnviarTimer(estado: 0, datos: "Terminado")
//      let temporal = String(describing: data).components(separatedBy: ",")
//      switch temporal[1]{
//      case "loginok":
//        //        globalVariables.cliente = Cliente(idUsuario: temporal[2],idcliente: temporal[4], user: self.login[1], nombre: temporal[5],email: temporal[3],empresa: temporal[temporal.count - 2])
//        if temporal[6] != "0"{
//          self.ListSolicitudPendiente(temporal)
//        }
//      case "loginerror":
//        globalVariables.userDefaults.set(nil, forKey: "loginData")
//
//        let alertaDos = UIAlertController (title: "Autenticación", message: "usuario y/o clave incorrectos", preferredStyle: UIAlertController.Style.alert)
//        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
//          self.AutenticandoView.isHidden = true
//          self.usuario.text?.removeAll()
//          self.usuario.text?.removeAll()
//        }))
//        self.present(alertaDos, animated: true, completion: nil)
//      default: print("Problemas de conexion")
//      }
//    }
//
//    globalVariables.socket.on("NR") {data, ack in
//      self.EnviarTimer(estado: 0, datos: "Terminado")
//      let temporal = String(describing: data).components(separatedBy: ",")
//      if temporal[1] == "registrook"{
//        let alertaDos = UIAlertController (title: "Registro de usuario", message: "Registro Realizado con éxito, puede loguearse en la aplicación, ¿Desea ingresar a la Aplicación?", preferredStyle: .alert)
//        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
//          self.RegistroView.isHidden = true
//        }))
//        alertaDos.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: {alerAction in
//          exit(0)
//        }))
//        self.present(alertaDos, animated: true, completion: nil)
//      }
//      else{
//        let alertaDos = UIAlertController (title: "Registro de usuario", message: "Error al registrar el usuario: \(temporal[2])", preferredStyle: UIAlertController.Style.alert)
//        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
//          self.AutenticandoView.isHidden = true
//        }))
//        self.present(alertaDos, animated: true, completion: nil)
//      }
//    }
//
//    //RECUPERAR CLAVES
//    globalVariables.socket.on("Recuperarclave"){data, ack in
//      self.EnviarTimer(estado: 0, datos: "Terminado")
//      let temporal = String(describing: data).components(separatedBy: ",")
//      if temporal[1] == "ok"{
//        let alertaDos = UIAlertController (title: "Recuperación de clave", message: "Su clave ha sido recuperada satisfactoriamente, en este momento ha recibido un correo electronico a la dirección: " + temporal[2], preferredStyle: UIAlertController.Style.alert)
//        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
//        }))
//        self.present(alertaDos, animated: true, completion: nil)
//      }
//    }
  }
}

