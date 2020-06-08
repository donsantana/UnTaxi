//
//  InicioControllerSocketExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/5/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

extension InicioController{
  func socketEventos(){
    
    //Evento sockect para escuchar
    //TRAMA IN: #LoginPassword,loginok,idusuario,idrol,idcliente,nombreapellidos,cantsolpdte,idsolicitud,idtaxi,cod,fechahora,lattaxi,lngtaxi,latorig,lngorig,latdest,lngdest,telefonoconductor
    if self.appUpdateAvailable(){
      
      let alertaVersion = UIAlertController (title: "Versión de la aplicación", message: "Estimado cliente es necesario que actualice a la última versión de la aplicación disponible en la AppStore. ¿Desea hacerlo en este momento?", preferredStyle: .alert)
      alertaVersion.addAction(UIAlertAction(title: "Si", style: .default, handler: {alerAction in
        
        UIApplication.shared.open(URL(string: GlobalConstants.itunesURL)!)
      }))
      alertaVersion.addAction(UIAlertAction(title: "No", style: .default, handler: {alerAction in
        exit(0)
      }))
      self.present(alertaVersion, animated: true, completion: nil)
    }
    
    //Evento Posicion de taxis
    globalVariables.socket.on("cargarvehiculoscercanos"){data, ack  in
      let result = data[0] as! [String: AnyObject]
      if (result["datos"] as! [Any]).count == 0 {
        let alertaDos = UIAlertController(title: "Solicitud de Taxi", message: "No hay taxis disponibles en este momento, espere unos minutos y vuelva a intentarlo.", preferredStyle: UIAlertController.Style.alert )
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          super.topMenu.isHidden = false
          self.viewDidLoad()
        }))
        self.present(alertaDos, animated: true, completion: nil)
      }else{
        self.formularioSolicitud.isHidden = false
        //self.MostrarTaxi(temporal)
      }
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
      if (result["code"] as! Int) == 1 {
        let newSolicitud = result["datos"] as! [String: Any]
        self.solicitudInProcess.text = String(newSolicitud["idsolicitud"] as! Int)
        self.MensajeEspera.text = "Solicitud creada exitosamente. Buscamos el taxi disponible más cercano a usted. Mientras espera una respuesta puede modificar el valor de su oferta y reenviarla."
        self.AlertaEsperaView.isHidden = false
        self.CancelarSolicitudProceso.isHidden = false
        self.ConfirmaSolicitud(newSolicitud)
        self.newOfertaText.text = String(format: "%.2f", self.ofertaDataCell.valorOferta)
        self.down25.isEnabled = false
      }else{
        print("error de solicitud")
      }
    }
    
    globalVariables.socket.on("cancelarservicio"){data, ack in
      let result = data[0] as! [String: Any]
      if (result["code"] as! Int) == 1 {
        self.Inicio()
      }
    }
    
    globalVariables.socket.on("sinvehiculo"){data, ack in
      let result = data[0] as! [String: Any]
      if (globalVariables.solpendientes.filter{$0.id == (result["idsolicitud"] as! Int)}.count > 0) {
        let alertaDos = UIAlertController (title: "Estado de Solicitud", message: "No se encontó ningún taxi disponible para ejecutar su solicitud. Por favor inténtelo más tarde.", preferredStyle: UIAlertController.Style.alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          self.CancelarSolicitudes(result["idsolicitud"] as! Int, motivo: "")
          self.Inicio()
        }))
        
        self.present(alertaDos, animated: true, completion: nil)
      }
    }
    
    globalVariables.socket.on("solicitudaceptada"){data, ack in
      
      let temporal = data[0] as! [String: Any]
      let solicitud = globalVariables.solpendientes.filter{$0.id == (temporal["idsolicitud"] as! Int)}.first
      
      let newTaxi = Taxi(id: temporal["idtaxi"] as! Int, matricula: temporal["matriculataxi"] as! String, codigo: temporal["codigotaxi"] as! String, marca: temporal["marcataxi"] as! String,color: temporal["colortaxi"] as! String, lat: temporal["lattaxi"] as! Double, long: temporal["lngtaxi"] as! Double, conductor: Conductor(idConductor: temporal["idconductor"] as! Int, nombre: temporal["nombreapellidosconductor"] as! String, telefono:  temporal["telefonoconductor"] as! String, urlFoto: temporal["foto"] as! String, calificacion: temporal["calificacion"] as! Double))

      solicitud!.DatosTaxiConductor(taxi: newTaxi)
      
      let vc = R.storyboard.main.solDetalles()!
      vc.solicitudIndex = globalVariables.solpendientes.firstIndex{$0.id == solicitud?.id}
      self.navigationController?.show(vc, sender: nil)
    }
    
    globalVariables.socket.on("serviciocancelado"){data, ack in
      let temporal = data[0] as! [String: Any]
      
      let alertaDos = UIAlertController (title: "Estado de Solicitud", message: "Solicitud cancelada por el conductor.", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in

        self.CancelarSolicitudes(temporal["idSolicitud"] as! Int, motivo: "Conductor")

        DispatchQueue.main.async {
          let vc = R.storyboard.main.inicioView()!
          self.navigationController?.show(vc, sender: nil)
        }
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
    
    globalVariables.socket.on("ofertadelconductor"){data, ack in
      print(data)
      let temporal = data[0] as! [String: Any]
      
      let array = globalVariables.ofertasList.map{$0.idTaxi}

      if !array.contains(temporal["idsolicitud"] as! Int){
        let newOferta = Oferta(id: temporal["idsolicitud"] as! Int, idTaxi: temporal["idtaxi"] as! Int, codigo: temporal["codigotaxi"] as! String, nombreConductor: temporal["nombreapellidosconductor"] as! String, movilConductor: temporal["movilconductor"] as! String, lat: temporal["lattaxi"] as! Double, lng: temporal["lngtaxi"] as! Double, valorOferta: temporal["valoroferta"] as! Double, tiempoLLegada: temporal["tiempollegada"] as! Int, calificacion: temporal["calificacion"] as! Double, totalCalif: temporal["cantidaddecalificacion"] as! Int, urlFoto: temporal["foto"] as! String, matricula: temporal["matriculataxi"] as! String, marca: temporal["marcataxi"] as! String, color: temporal["colortaxi"] as! String)

        globalVariables.ofertasList.append(newOferta)

        DispatchQueue.main.async {
          let vc = R.storyboard.main.ofertasView()
          self.navigationController?.show(vc!, sender: nil)
        }
      }
    }
    
    globalVariables.socket.on("telefonosdelcallcenter"){data, ack in
      var telefonoList:[Telefono] = []
      let response = data[0] as! [String: Any]
      if response["code"] as! Int == 1{
        let temporal = response["datos"] as! [[String: Any]]
        
        for telefonoData in temporal{
          telefonoList.append(Telefono(numero: telefonoData["telefono2"] as! String, operadora: telefonoData["operadora"] as! String, email: "", tienewhatsapp: (telefonoData["whatsapp"] as! Int) == 1))
        }
        
        globalVariables.TelefonosCallCenter = telefonoList
        print("heree finish")
      }
    }
    
    //ACTIVACION DEL TAXIMETRO
    globalVariables.socket.on("taximetroiniciado"){data, ack in
      
      let response = data[0] as! [String: Any]
      if globalVariables.solpendientes.firstIndex{$0.id == response["idsolicitud"] as! Int}! >= 0 {
        //self.MensajeEspera.text = temporal
        //self.AlertaEsperaView.hidden = false
        let alertaDos = UIAlertController (title: "Taximetro Activado", message: "Estimado Cliente: El conductor ha iniciado el Taximetro a las: \(OurDate(stringDate: response["fechacambioestado"] as! String).timeToShow()).", preferredStyle: .alert)
            alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
              
            }))
            self.present(alertaDos, animated: true, completion: nil)
      }
    }
    
    globalVariables.socket.on("RSO"){data, ack in
      //Trama IN: #Solicitud, ok, idsolicitud, fechahora
      //Trama IN: #Solicitud, error
      self.EnviarTimer(estado: 0, datos: "terminando")
      let temporal = String(describing: data).components(separatedBy: ",")
      print(temporal)
      if temporal[1] == "ok"{
        let alertaDos = UIAlertController (title: "Oferta Actualizada", message: "La oferta ha sido actualizada con éxito y enviada a los conductores disponibles. Esperamos que acepten su nueva oferta.", preferredStyle: UIAlertController.Style.alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          
        }))
        self.present(alertaDos, animated: true, completion: nil)
      }else{
        let alertaDos = UIAlertController (title: "Oferta Cancelada", message: "La oferta ha sido cancelada por el conductor. Por favor", preferredStyle: UIAlertController.Style.alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          self.Inicio()
          if globalVariables.solpendientes.count != 0{
            self.SolPendientesView.isHidden = true
            
          }
        }))
        self.present(alertaDos, animated: true, completion: nil)
      }
    }
    
    //RESPUESTA DE CANCELAR SOLICITUD
//    globalVariables.socket.on("CSO"){data, ack in
//      self.EnviarTimer(estado: 0, datos: "Terminado")
//      let temporal = String(describing: data).components(separatedBy: ",")
//      if temporal[1] == "ok"{
//        let alertaDos = UIAlertController (title: "Cancelar Solicitud", message: "Su solicitud fue cancelada.", preferredStyle: UIAlertController.Style.alert)
//        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
//          self.AlertaEsperaView.isHidden = true
//          self.Inicio()
//          if globalVariables.solpendientes.count != 0{
//            self.SolPendientesView.isHidden = true
//          }
//        }))
//        self.present(alertaDos, animated: true, completion: nil)
//      }
//    }
    
    
    
    //SOLICITUDES SIN RESPUESTA DE TAXIS
//    globalVariables.socket.on("SNA"){data, ack in
//      let temporal = String(describing: data).components(separatedBy: ",")
//      if (globalVariables.solpendientes.filter{String($0.id) == temporal[1]}.count > 0) {
//        let alertaDos = UIAlertController (title: "Estado de Solicitud", message: "No se encontó ningún taxi disponible para ejecutar su solicitud. Por favor inténtelo más tarde.", preferredStyle: UIAlertController.Style.alert)
//        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
//          self.CancelarSolicitudes("")
//        }))
//
//        self.present(alertaDos, animated: true, completion: nil)
//      }
//    }
    

    
    
    //Respuesta de la solicitud enviada
//    globalVariables.socket.on("Solicitud"){data, ack in
//      //Trama IN: #Solicitud, ok, idsolicitud, fechahora
//      //Trama IN: #Solicitud, error
//      //      self.EnviarTimer(estado: 0, datos: "terminando")
//      //      let temporal = String(describing: data).components(separatedBy: ",")
//      //      if temporal[1] == "ok"{
//      //        self.MensajeEspera.text = "Solicitud enviada a todos los taxis cercanos. Esperando respuesta de un conductor."
//      //        self.AlertaEsperaView.isHidden = false
//      //        self.CancelarSolicitudProceso.isHidden = false
//      //        self.ConfirmaSolicitud(temporal)
//      //      }else{
//      //
//      //      }
//    }
//
////    globalVariables.socket.on("Aceptada"){data, ack in
////      self.Inicio()
////      let temporal = String(describing: data).components(separatedBy: ",")
////      print(temporal)
////      //#Aceptada, idsolicitud, idconductor, nombreApellidosConductor, movilConductor, URLfoto, idTaxi, Codvehiculo, matricula, marca, color, latTaxi, lngTaxi
////      if temporal[0] == "#Aceptada" || temporal[0] == "[#Aceptada"{
////        let solicitud = globalVariables.solpendientes.filter{String($0.id) == temporal[1]}.first
////        solicitud!.DatosTaxiConductor(idtaxi: temporal[6], matricula: temporal[8], codigovehiculo: temporal[7], marca: temporal[9],color: temporal[10], lattaxi: Double(temporal[11])!, lngtaxi: Double(temporal[12])!, idconductor: temporal[2], nombreapellidosconductor: temporal[3], movilconductor: temporal[4], foto: temporal[5])
////
////        let vc = R.storyboard.main.solPendientes()!
////        vc.solicitudIndex = globalVariables.solpendientes.firstIndex{$0.id == solicitud?.id}
////        self.navigationController?.show(vc, sender: nil)
////
////      }else{
////        if temporal[0] == "#Cancelada" {
////          //#Cancelada, idsolicitud
////          let alertaDos = UIAlertController (title: "Estado de Solicitud", message: "Ningún vehículo aceptó su solicitud, puede intentarlo más tarde.", preferredStyle: .alert)
////          alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
////          }))
////
////          self.present(alertaDos, animated: true, completion: nil)
////        }
////      }
////    }
//
//
//
  }
}