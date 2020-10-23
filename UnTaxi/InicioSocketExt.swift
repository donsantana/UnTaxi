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
    self.offSocketEventos()
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
      print("result \(result)")
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
        print("error de solicitud \(data)")
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
      print(temporal)
      print("solicitudes en aceptada: \(globalVariables.solpendientes.count)")
      
      let newTaxi = Taxi(id: temporal["idtaxi"] as! Int, matricula: temporal["matriculataxi"] as! String, codigo: temporal["codigotaxi"] as! String, marca: temporal["marcataxi"] as! String,color: temporal["colortaxi"] as! String, lat: temporal["lattaxi"] as! Double, long: temporal["lngtaxi"] as! Double, conductor: Conductor(idConductor: temporal["idconductor"] as! Int, nombre: temporal["nombreapellidosconductor"] as! String, telefono:  temporal["telefonoconductor"] as! String, urlFoto: temporal["foto"] as! String, calificacion: temporal["calificacion"] as! Double))

      globalVariables.solpendientes.first{$0.id == (temporal["idsolicitud"] as! Int)}!.DatosTaxiConductor(taxi: newTaxi)
      //solicitud!.DatosTaxiConductor(taxi: newTaxi)
      print("solicitudes despues de aceptada: \(globalVariables.solpendientes.count)")
      DispatchQueue.main.async {
        let vc = R.storyboard.main.solDetalles()!
        vc.solicitudPendiente = globalVariables.solpendientes.first{$0.id == (temporal["idsolicitud"] as! Int)}
        self.navigationController?.show(vc, sender: nil)
      }
    }
    
    globalVariables.socket.on("serviciocancelado"){data, ack in
      let temporal = data[0] as! [String: Any]
      
      let alertaDos = UIAlertController (title: "Estado de Solicitud", message: "Solicitud cancelada por el conductor.", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in

        self.CancelarSolicitudes(temporal["idsolicitud"] as! Int, motivo: "Conductor")

        DispatchQueue.main.async {
          let vc = R.storyboard.main.inicioView()!
          self.navigationController?.show(vc, sender: nil)
        }
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
    
    globalVariables.socket.on("ofertadelconductor"){data, ack in
      print("oferta \(data)")
      let temporal = data[0] as! [String: Any]
      let array = globalVariables.ofertasList.map{$0.idTaxi}
      if !array.contains(temporal["idsolicitud"] as! Int){
        let newOferta = Oferta(id: temporal["idsolicitud"] as! Int, idTaxi: temporal["idtaxi"] as! Int, idConductor: temporal["idconductor"] as! Int, codigo: temporal["codigotaxi"] as! String, nombreConductor: temporal["nombreapellidosconductor"] as! String, movilConductor: temporal["telefonoconductor"] as! String, lat: temporal["lattaxi"] as! Double, lng: temporal["lngtaxi"] as! Double, valorOferta: temporal["valoroferta"] as! Double, tiempoLLegada: temporal["tiempollegada"] as! Int, calificacion: temporal["calificacion"] as! Double, totalCalif: temporal["cantidaddecalificacion"] as! Int, urlFoto: temporal["foto"] as! String, matricula: temporal["matriculataxi"] as! String, marca: temporal["marcataxi"] as! String, color: temporal["colortaxi"] as! String)

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
      }
    }
    
    //ACTIVACION DEL TAXIMETRO
    globalVariables.socket.on("taximetroiniciado"){data, ack in
      
      let response = data[0] as! [String: Any]
      let solicitud = globalVariables.solpendientes.first{$0.id == response["idsolicitud"] as! Int}!
      if solicitud != nil {
        //self.MensajeEspera.text = temporal
        //self.AlertaEsperaView.hidden = false
        let title = solicitud.tipoServicio == 2 ? "Taximetro Activado" : "Carrera Iniciada"
        let mensaje = solicitud.tipoServicio == 2 ? "El conductor ha iniciado el Taximetro " : "El conductor ha iniciado la carrera "
        let alertaDos = UIAlertController (title: title, message: "\(mensaje) a las: \(OurDate(stringDate: response["fechacambioestado"] as! String).timeToShow()).", preferredStyle: .alert)
            alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
              
            }))
            self.present(alertaDos, animated: true, completion: nil)
      }
    }
    
    //UPDATE VALOR DE OFERTA
    globalVariables.socket.on("subiroferta"){data, ack in

      let temporal = data[0] as! [String: Any]
      print(temporal)
      if temporal["code"] as! Int == 1{
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
    
    globalVariables.socket.on("U"){data, ack in
      let temporal = data[0] as! [String: Any]
      print("voz \(temporal)")
      //globalVariables.urlSubirVoz = temporal[1]
    }
    
    globalVariables.socket.on("voz"){data, ack in
      let temporal = data[0] as! [String: Any]
      print(temporal)
      globalVariables.urlConductor = "\(GlobalConstants.urlHost)/\(temporal["audio"] as! String)"
      if UIApplication.shared.applicationState == .background {
        let localNotification = UILocalNotification()
        localNotification.alertAction = "Mensaje del Conductor"
        localNotification.alertBody = "Mensaje del Conductor. Abra la aplicación para escucharlo."
        localNotification.fireDate = Date(timeIntervalSinceNow: 4)
        UIApplication.shared.scheduleLocalNotification(localNotification)
        //                if !myvariables.grabando{
        //
        //                    //myvariables.SMSVoz.ReproducirMusica()
        //                    myvariables.SMSVoz.ReproducirVozConductor(myvariables.urlconductor)
        //                }
      }
      //            else{
      //                if  !myvariables.SMSProceso{
      //                    myvariables.SMSProceso = true
      //                    myvariables.SMSVoz.ReproducirMusica()
      //                    myvariables.SMSVoz.ReproducirVozConductor(myvariables.urlconductor)
      //                }else{
      //                    let session = AVAudioSession.sharedInstance()
      //                }
      //
      //            }

      globalVariables.SMSVoz.ReproducirVozConductor(globalVariables.urlConductor)
    }
    //
    globalVariables.socket.on("direccionespactadas"){data, ack in
      globalVariables.direccionesPactadas = []
      let temporal = data[0] as! [String: Any]
      print("pactadas \(temporal["datos"])")
      if temporal["code"] as! Int == 1{
        let pactadasList = temporal["datos"] as! [[String: Any]]
        for direccionPactada in pactadasList{
          globalVariables.direccionesPactadas.append(DireccionesPactadas(data: direccionPactada))
        }
      }
      self.addressPicker.reloadAllComponents()
      self.destinoAddressPicker.reloadAllComponents()
      //myvariables.UrlSubirVoz = temporal[1]
      
    }
    
    globalVariables.socket.on("serviciocompletado"){data, ack in
      
      let result = data[0] as! [String: Any]
      print("solicitudes en completadas: \(globalVariables.solpendientes.count)")
      if globalVariables.solpendientes.count > 0 {
        let solicitudCompletadaIndex = globalVariables.solpendientes.firstIndex{$0.id == result["idsolicitud"] as! Int}!
        if solicitudCompletadaIndex >= 0{
          let solicitudCompletada = globalVariables.solpendientes.remove(at: solicitudCompletadaIndex)
          DispatchQueue.main.async {
            let vc = R.storyboard.main.completadaView()!
            vc.id = solicitudCompletada.id
            vc.idConductor = solicitudCompletada.taxi.conductor.idConductor
            self.navigationController?.show(vc, sender: nil)
          }
        }
      }
    }
    
    globalVariables.socket.on("llegue"){data, ack in
      let result = data[0] as! [String: Any]
      print(result["idsolicitud"])
      let solicitudIndex = globalVariables.solpendientes.firstIndex{$0.id == result["idsolicitud"] as! Int}!
      let solicitud = globalVariables.solpendientes[solicitudIndex]
      if solicitudIndex >= 0{
        let alertaDos = UIAlertController (title: "Su Taxi ha llegado", message: "Su taxi \(solicitud.taxi.marca), color \(solicitud.taxi.color), matrícula \(solicitud.taxi.matricula) ha llegado al punto de recogida.", preferredStyle: UIAlertController.Style.alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          
        }))
        self.present(alertaDos, animated: true, completion: nil)
      }
    }
  }
}
