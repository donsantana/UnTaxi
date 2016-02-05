//
//  CSocket.swift
//  Xtaxi
//
//  Created by Done Santana on 15/10/15.
//  Copyright © 2015 Done Santana. All rights reserved.
//

import Foundation
import Socket_IO_Client_Swift


//Clase CSocket

class CSocket {

    private var socket: SocketIOClient
    var resultado = "Inicial"
   //constructor
    init(){
    self.socket = SocketIOClient(socketURL: "104.171.10.34:5800")
    //self.ControlEventos()
    self.socket.connect()
    
    }
    //Control de eventos desde el servidor
    func ControlEventos(){
        //conexion
        self.socket.on("auth"){data, ack in
           if !data.isEmpty{
            self.resultado = data[0] as! String
            }
           else {
            self.resultado = "hay problemas"
            }
        }
        //Autenticación
        self.socket.on("autenticacion"){data, ack in
        
        }
    }
    //Función conectar
    func Conectar(){
        if self.socket.status.description != "connecting"{
        self.socket.connect()
        }
    }
    //Desconectar
    func Desconectar()->String{
     self.socket.close()
        return self.socket.status.description
    }
    // Resultado
    func Resultado()->String{
      if self.resultado != "Inicial"{
           return self.resultado
        }
        else{
            return "nada"
        }
    
    }

    //Autenticacion
    func Autenticacion (){
        let datos :String = "#LoginPassword,Done,pass,# /n"
        self.socket.emit("data", datos)
        
    }
    //Enviar mensaje
    func EnviarMensaje(){
          self.socket.emit("auth1","Hola")
        
     }
    
    //Dibujar taxis en mapa
    /*func DibujarGeo(datos){
      //dibujar los taxis y la geolocalización del cliente en el mapa
    }*/
    
}