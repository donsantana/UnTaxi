//
//  SocketService.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 11/27/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import Foundation
import SocketIO

protocol SocketServiceDelegate: class {
  func socketResponse(_ controller: SocketService, startEvent result: [String: Any])
  func socketResponse(_ controller: SocketService, cargarvehiculoscercanos result: [String: Any])
  func socketResponse(_ controller: SocketService, solicitarservicio result: [String: Any])
  func socketResponse(_ controller: SocketService, cancelarservicio result: [String: Any])
  func socketResponse(_ controller: SocketService, sinvehiculo result: [String: Any])
  func socketResponse(_ controller: SocketService, solicitudaceptada result: [String: Any])
  func socketResponse(_ controller: SocketService, serviciocancelado result: [String: Any])
  func socketResponse(_ controller: SocketService, ofertadelconductor result: [String: Any])
  func socketResponse(_ controller: SocketService, aceptaroferta result: [String: Any])
  func socketResponse(_ controller: SocketService, telefonosdelcallcenter result: [[String: Any]])
  func socketResponse(_ controller: SocketService, taximetroiniciado result: [String: Any])
  func socketResponse(_ controller: SocketService, subiroferta result: [String: Any])
  func socketResponse(_ controller: SocketService, msgVozConductor result: [String: Any])
  func socketResponse(_ controller: SocketService, direccionespactadas result: [String: Any])
  func socketResponse(_ controller: SocketService, serviciocompletado result: [String: Any])
  func socketResponse(_ controller: SocketService, taxiLLego result: [String: Any])
  func socketResponse(_ controller: SocketService, geocliente result: [String: Any])
  func socketResponse(_ controller: SocketService, recargaryapa result: [String: Any])
  func socketResponse(_ controller: SocketService, historialdesolicitudes result: [String: Any])
  func socketResponse(_ controller: SocketService, conectionError errorMessage: String)
  func socketResponse(_ controller: SocketService, buscarCliente result: [String: Any])
  func socketResponse(_ controller: SocketService, pasarYapa result: [String: Any])
  func socketResponse(_ controller: SocketService, visualizapublicidad result: [String: Any])
  func socketResponse(_ controller: SocketService, accedeapublicidad result: [String: Any])
  func socketResponse(_ controller: SocketService, detallehistorialdesolicitud result: [String: Any])
  func socketResponse(_ controller: SocketService, actualizaryapa result: [String: Any])
}


final class SocketService{
  
  weak var delegate: SocketServiceDelegate?

  func socketEmit(_ eventName: String, datos: [String: Any]){
    if CConexionInternet.isConnectedToNetwork() == true{
      if globalVariables.socket.status.active{
        print("trama \(datos)")
        globalVariables.socket.emitWithAck(eventName, datos).timingOut(after: 3) {respond in
          if respond[0] as! String == "OK"{
            print(respond)
          }else{
            print("error en socket")
          }
        }
      }else{
        self.delegate?.socketResponse(self, conectionError: "")
      }
    }else{
      self.delegate?.socketResponse(self, conectionError: "")
    }
  }
  
  func offSocketEventos(){
    print("Cerrando eventos")
    globalVariables.socket.off("cargarvehiculoscercanos")
    globalVariables.socket.off("solicitarservicio")
    globalVariables.socket.off("cancelarservicio")
    globalVariables.socket.off("sinvehiculo")
    globalVariables.socket.off("solicitudaceptada")
    globalVariables.socket.off("serviciocancelado")
    globalVariables.socket.off("ofertadelconductor")
    globalVariables.socket.off("telefonosdelcallcenter")
    globalVariables.socket.off("taximetroiniciado")
    globalVariables.socket.off("subiroferta")
    globalVariables.socket.off("U")
    globalVariables.socket.off("voz")
    globalVariables.socket.off("direccionespactadas")
    globalVariables.socket.off("serviciocompletado")
    globalVariables.socket.off("llegue")
    globalVariables.socket.off("geocliente")
    globalVariables.socket.off("aceptaroferta")
    globalVariables.socket.off("historialdesolicitudes")
    globalVariables.socket.off("buscarclientepormovil")
    globalVariables.socket.off("pasaryapa")
    globalVariables.socket.off("visualizapublicidad")
    globalVariables.socket.off("accedeapublicidad")
    globalVariables.socket.off("detallehistorialdesolicitud")
  }
  
  func initLoginEventos(){
    globalVariables.socket.on("start"){data, ack in
      let result = data[0] as! [String: Any]
      print("start \(result["datos"])")
      self.delegate?.socketResponse(self, startEvent: result)
    }
  }
  
  func initListenEventos(){
    self.offSocketEventos()
    print("Cargando Eventos")
    //Evento sockect para escuchar
    //TRAMA IN: #LoginPassword,loginok,idusuario,idrol,idcliente,nombreapellidos,cantsolpdte,idsolicitud,idtaxi,cod,fechahora,lattaxi,lngtaxi,latorig,lngorig,latdest,lngdest,telefonoconductor
    
    globalVariables.socket.on("disconnect"){data, ack  in
      let result = data[0] as! [String: AnyObject]
      print("desconectado \(result)")
    }
    
    //Evento Posicion de taxis
    globalVariables.socket.on("cargarvehiculoscercanos"){data, ack  in
      let result = data[0] as! [String: AnyObject]
      self.delegate?.socketResponse(self, cargarvehiculoscercanos: result)
    }
    
    //Respuesta de la solicitud enviada
    globalVariables.socket.on("solicitarservicio"){data, ack in
      //      {
      //        code: 1,
      //        msg: …,
      //        datos: {
      //          idsolicitud: solicitud.idsolicitud,
      //          fechahora: fechahora
      //        }
      //      }
      let result = data[0] as! [String: Any]
      print("result \(result)")
      self.delegate?.socketResponse(self, solicitarservicio: result)
    }
    
    globalVariables.socket.on("cancelarservicio"){data, ack in
      
      let result = data[0] as! [String: Any]
      print("cancelarservicio \(result)")
      self.delegate?.socketResponse(self, cancelarservicio: result)
    }
    
    globalVariables.socket.on("sinvehiculo"){data, ack in
      let result = data[0] as! [String: Any]
      self.delegate?.socketResponse(self, sinvehiculo: result)
    }
    
    globalVariables.socket.on("solicitudaceptada"){data, ack in
      let result = data[0] as! [String: Any]
      print("solicitudaceptada \(result)")
      self.delegate?.socketResponse(self, solicitudaceptada: result)
    }
    
    globalVariables.socket.on("serviciocancelado"){data, ack in
      let result = data[0] as! [String: Any]
      if UIApplication.shared.applicationState == .background {
        let localNotification = UILocalNotification()
        localNotification.alertAction = "Servicio cancelado"
        localNotification.alertBody = "Servicio cancelado por el conductor"
        localNotification.fireDate = Date(timeIntervalSinceNow: 4)
        UIApplication.shared.scheduleLocalNotification(localNotification)
      }
      self.delegate?.socketResponse(self, serviciocancelado: result)
    }
    
    globalVariables.socket.on("ofertadelconductor"){data, ack in
      print("oferta \(data)")
      let result = data[0] as! [String: Any]
      self.delegate?.socketResponse(self, ofertadelconductor: result)
    }

    //ACTIVACION DEL TAXIMETRO
    globalVariables.socket.on("taximetroiniciado"){data, ack in
      let result = data[0] as! [String: Any]
      self.delegate?.socketResponse(self, taximetroiniciado: result)
    }
    
    //UPDATE VALOR DE OFERTA
    globalVariables.socket.on("subiroferta"){data, ack in

      let result = data[0] as! [String: Any]
      print(result)
      self.delegate?.socketResponse(self, subiroferta: result)
    }
    
    globalVariables.socket.on("U"){data, ack in
      let result = data[0] as! [String: Any]
      print("voz \(result)")
      //globalVariables.urlSubirVoz = result[1]
    }
    
    globalVariables.socket.on("voz"){data, ack in
      let result = data[0] as! [String: Any]
      print(result)
      self.delegate?.socketResponse(self, msgVozConductor: result)
    }
    
    globalVariables.socket.on("direccionespactadas"){data, ack in
      globalVariables.direccionesPactadas = []
      let result = data[0] as! [String: Any]
      self.delegate?.socketResponse(self, direccionespactadas: result)
    }
    
    globalVariables.socket.on("serviciocompletado"){data, ack in
      print("Completada")
      let result = data[0] as! [String: Any]
      self.delegate?.socketResponse(self, serviciocompletado: result)
    }
    
    globalVariables.socket.on("llegue"){data, ack in
      print("llegue")
      let result = data[0] as! [String: Any]
      self.delegate?.socketResponse(self, taxiLLego: result)
    }
    
    globalVariables.socket.on("geocliente"){data, ack in
      print("Taxi Geo")
      let result = data[0] as! [String: Any]
      self.delegate?.socketResponse(self, geocliente: result)
    }
    
    globalVariables.socket.on("aceptaroferta"){data, ack in
      print("Aceptada")
      let result = data[0] as! [String: Any]
      self.delegate?.socketResponse(self, aceptaroferta: result)
    }
    
    globalVariables.socket.on("visualizapublicidad"){data, ack in
      let result = data[0] as! [String: Any]
      print("publicidad \(result)")
      self.delegate?.socketResponse(self, visualizapublicidad: result)
    }
    
    globalVariables.socket.on("accedeapublicidad"){data, ack in
      let result = data[0] as! [String: Any]
      print("publicidad \(result)")
      self.delegate?.socketResponse(self, accedeapublicidad: result)
    }
    
    globalVariables.socket.on("actualizaryapa"){data, ack in
      let result = data[0] as! [String: Any]
      print("actualizar Yapa \(result)")
      if globalVariables.cliente.id == result["idcliente"] as! Int{
        globalVariables.cliente.updateYapa(monto: result["yapa"] as! Double)
      }
      self.delegate?.socketResponse(self, actualizaryapa: result)
    }
    
  }
  
  func initYapaEvents() {
    globalVariables.socket.on("recargaryapa"){data, ack in
      print("Yapa recargada")
      let result = data[0] as! [String: Any]
      self.delegate?.socketResponse(self, recargaryapa: result)
    }
    
    globalVariables.socket.on("buscarclientepormovil"){data, ack in
      let result = data[0] as! [String: Any]
      print("cliente \(result)")
      self.delegate?.socketResponse(self, buscarCliente: result)
    }
    
    globalVariables.socket.on("pasaryapa"){data, ack in
      let result = data[0] as! [String: Any]
      print("cliente \(result)")
      self.delegate?.socketResponse(self, pasarYapa: result)
    }
  }
  
  func initCallcenterEvents(){
    globalVariables.socket.off("telefonosdelcallcenter")
    globalVariables.socket.on("telefonosdelcallcenter"){data, ack in
      let response = data[0] as! [String: Any]
      if response["code"] as! Int == 1{
        let result = response["datos"] as! [[String: Any]]
        self.delegate?.socketResponse(self, telefonosdelcallcenter: result)
      }
    }
  }
  
  func initHistorialEvents(){
    globalVariables.socket.off("historialdesolicitudes")
    globalVariables.socket.on("historialdesolicitudes"){data, ack in
      let result = data[0] as! [String: Any]
      print("historialdesolicitudes \(result)")
      self.delegate?.socketResponse(self, historialdesolicitudes: result)
    }
  }
  
  func initHistorialDetallesEvents(){
    globalVariables.socket.off("detallehistorialdesolicitud")
    globalVariables.socket.on("detallehistorialdesolicitud"){data, ack in
      let result = data[0] as! [String: Any]
      print("detallesHistorial \(result)")
      self.delegate?.socketResponse(self, detallehistorialdesolicitud: result)
    }
  }
}

extension SocketServiceDelegate{
  func socketResponse(_ controller: SocketService, startEvent result: [String: Any]){}
  func socketResponse(_ controller: SocketService, cargarvehiculoscercanos result: [String: Any]){}
  func socketResponse(_ controller: SocketService, solicitarservicio result: [String: Any]){}
  func socketResponse(_ controller: SocketService, cancelarservicio result: [String: Any]){}
  func socketResponse(_ controller: SocketService, sinvehiculo result: [String: Any]){}
  func socketResponse(_ controller: SocketService, solicitudaceptada result: [String: Any]){}
  func socketResponse(_ controller: SocketService, serviciocancelado result: [String: Any]){}
  func socketResponse(_ controller: SocketService, ofertadelconductor result: [String: Any]){}
  func socketResponse(_ controller: SocketService, aceptaroferta result: [String: Any]){}
  func socketResponse(_ controller: SocketService, telefonosdelcallcenter result: [[String: Any]]){}
  func socketResponse(_ controller: SocketService, taximetroiniciado result: [String: Any]){}
  func socketResponse(_ controller: SocketService, subiroferta result: [String: Any]){}
  func socketResponse(_ controller: SocketService, msgVozConductor result: [String: Any]){}
  func socketResponse(_ controller: SocketService, direccionespactadas result: [String: Any]){}
  func socketResponse(_ controller: SocketService, serviciocompletado result: [String: Any]){}
  func socketResponse(_ controller: SocketService, taxiLLego result: [String: Any]){}
  func socketResponse(_ controller: SocketService, geocliente result: [String: Any]){}
  func socketResponse(_ controller: SocketService, recargaryapa result: [String: Any]){}
  func socketResponse(_ controller: SocketService, historialdesolicitudes result: [String: Any]){}
  func socketResponse(_ controller: SocketService, conectionError errorMessage: String){}
  func socketResponse(_ controller: SocketService, buscarCliente result: [String: Any]){}
  func socketResponse(_ controller: SocketService, pasarYapa result: [String: Any]){}
  func socketResponse(_ controller: SocketService, visualizapublicidad result: [String: Any]){}
  func socketResponse(_ controller: SocketService, accedeapublicidad result: [String: Any]){}
  func socketResponse(_ controller: SocketService, detallehistorialdesolicitud result: [String: Any]){}
  func socketResponse(_ controller: SocketService, actualizaryapa result: [String: Any]){}
}
