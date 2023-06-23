//
//  InicioSocketExt.swift
//  UnTaxi
//
//  Created by Done Santana on 5/7/23.
//  Copyright © 2023 Done Santana. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import MapboxMaps

extension InicioController: SocketServiceDelegate{
  func socketResponse(_ controller: SocketService, cargarvehiculoscercanos result: [String : Any]) {
//    if (result["datos"] as! [Any]).count == 0 {
//      print(result)
//      let alertaDos = UIAlertController(title: "Solicitud de Taxi", message: "No hay taxis disponibles en este momento, espere unos minutos y vuelva a intentarlo.", preferredStyle: UIAlertController.Style.alert )
//      alertaDos.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alerAction in
//        super.topMenu.isHidden = false
//        self.viewDidLoad()
//      }))
//      self.present(alertaDos, animated: true, completion: nil)
//    } else {
//      self.loadFormularioData()
//    }
    print("taxis cercanos \(result)")
    if (result["datos"] as! [Any]).count > 0 {
      let taxiList = result["datos"] as! [[String: Any]]
      var mapAnnotations: [MyMapAnnotation] = [self.origenAnnotation]
      
      for taxi in taxiList {
        let taxiAnnotation = MyMapAnnotation()
        taxiAnnotation.type = "taxi_libre"
        taxiAnnotation.coordinates = CLLocationCoordinate2D(latitude: taxi["lat"] as! Double,longitude: taxi["lng"] as! Double)
        mapAnnotations.append(taxiAnnotation)
      }
      self.showAnnotations(mapAnnotations)
    }
  }
  
  func socketResponse(_ controller: SocketService, solicitarservicio result: [String : Any]) {
    print("solicitarservicio \(result)")
    if (result["code"] as! Int) == 1 {
      let newSolicitud = result["datos"] as! [String: Any]
      self.ConfirmaSolicitud(newSolicitud)
    } else {
            
            let alertaDos = UIAlertController (title: "", message: result["msg"] as! String, preferredStyle: UIAlertController.Style.alert)
            alertaDos.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alerAction in
                DispatchQueue.main.async {
                    self.waitingView.isHidden = true
                }
            }))
            
            self.present(alertaDos, animated: true, completion: nil)
      print("error de solicitud \(result["msg"])")
    }
    
  }
  
  func socketResponse(_ controller: SocketService, cancelarservicio result: [String : Any]) {
    let title = (result["code"] as! Int) == 1 ? "Solicitud Cancelada" : "Error Cancelar"
    let message = (result["code"] as! Int) == 1 ? "Su solicitud fue cancelada con éxito." : result["msg"] as! String

    let alertaDos = UIAlertController (title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    alertaDos.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alerAction in
      if (result["code"] as! Int) == 1{
        globalVariables.ofertasList.removeAll()
        DispatchQueue.main.async {
          self.Inicio()
        }
      }
    }))
    self.present(alertaDos, animated: true, completion: nil)
  }
  
  func socketResponse(_ controller: SocketService, sinvehiculo result: [String : Any]) {
    let solicitud = globalVariables.solpendientes.first{$0.id == result["idsolicitud"] as! Int}
    if (solicitud != nil) {
      let alertaDos = UIAlertController (title: "Estado de Solicitud", message: "No se encontó ningún taxi disponible para ejecutar su solicitud. Por favor inténtelo más tarde.", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alerAction in
        self.CancelarSolicitud("",solicitud: solicitud!)
        self.Inicio()
      }))
      
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
  func socketResponse(_ controller: SocketService, solicitudaceptada result: [String : Any]) {
    let newTaxi = Taxi(id: result["idtaxi"] as! Int, matricula: result["matriculataxi"] as! String, codigo: result["codigotaxi"] as! String, marca: result["marcataxi"] as! String,color: result["colortaxi"] as! String, lat: result["lattaxi"] as! Double, long: result["lngtaxi"] as! Double, conductor: Conductor(idConductor: result["idconductor"] as! Int, nombre: result["nombreapellidosconductor"] as! String, telefono:  result["telefonoconductor"] as! String, urlFoto: result["foto"] as! String, calificacion: result["calificacion"] as! Double, cantidadcalificaciones: result["cantidadcalificacion"] as! Int))
    
    globalVariables.solpendientes.first{$0.id == (result["idsolicitud"] as! Int)}!.DatosTaxiConductor(taxi: newTaxi)
    
    DispatchQueue.main.async {
      let vc = R.storyboard.main.solDetalles()!
      vc.solicitudPendiente = globalVariables.solpendientes.first{$0.id == (result["idsolicitud"] as! Int)}
      self.navigationController?.show(vc, sender: nil)
    }
  }
  
  func socketResponse(_ controller: SocketService, serviciocancelado result: [String : Any]) {
    let solicitud = globalVariables.solpendientes.first{$0.id == result["idsolicitud"] as! Int}
    if solicitud != nil{
      let alertaDos = UIAlertController (title: "Estado de Solicitud", message: "Solicitud cancelada por el conductor.", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alerAction in
        
        self.CancelarSolicitud("Conductor",solicitud: solicitud!)
        
        DispatchQueue.main.async {
          self.goToInicioView()
        }
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
  func socketResponse(_ controller: SocketService, ofertadelconductor result: [String : Any]) {
    let array = globalVariables.ofertasList.map{$0.id}
    if !array.contains(result["idsolicitud"] as! Int){
      let newOferta = Oferta(id: result["idsolicitud"] as! Int, idTaxi: result["idtaxi"] as! Int, idConductor: result["idconductor"] as! Int, codigo: result["codigotaxi"] as! String, nombreConductor: result["nombreapellidosconductor"] as! String, movilConductor: result["telefonoconductor"] as! String, lat: result["lattaxi"] as! Double, lng: result["lngtaxi"] as! Double, valorOferta: result["valoroferta"] as! Double, tiempoLLegada: result["tiempollegada"] as! Int, calificacion: result["calificacion"] as! Double, totalCalif: result["cantidadcalificacion"] as! Int, urlFoto: result["foto"] as! String, matricula: result["matriculataxi"] as! String, marca: result["marcataxi"] as! String, color: result["colortaxi"] as! String)

      globalVariables.ofertasList.append(newOferta)

        if let solpendiente = globalVariables.solpendientes.first(where: {$0.id == newOferta.id}) {
            DispatchQueue.main.async {
              let vc = R.storyboard.main.ofertasView()!
              vc.solicitud = solpendiente
              self.navigationController?.show(vc, sender: nil)
            }
        }
      
    }
  }
  
  func socketResponse(_ controller: SocketService, taximetroiniciado result: [String : Any]) {
    let solicitud = globalVariables.solpendientes.first{$0.id == result["idsolicitud"] as! Int}
    if solicitud != nil {
      //self.MensajeEspera.text = result
      //self.AlertaEsperaView.hidden = false
      let title = solicitud!.tipoServicio == 2 ? "Taximetro Activado" : "Carrera Iniciada"
      let mensaje = solicitud!.tipoServicio == 2 ? "El conductor ha iniciado el Taximetro " : "El conductor ha iniciado la carrera "
      let alertaDos = UIAlertController (title: title, message: "\(mensaje) a las: \(OurDate(stringDate: result["fechacambioestado"] as! String).timeToShow()).", preferredStyle: .alert)
      alertaDos.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alerAction in
        
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
  func socketResponse(_ controller: SocketService, subiroferta result: [String : Any]) {
    if result["code"] as! Int == 1{
      let alertaDos = UIAlertController (title: "Oferta Actualizada", message: "La oferta ha sido actualizada con éxito y enviada a los conductores disponibles. Esperamos que acepten su nueva oferta.", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alerAction in
        
      }))
      self.present(alertaDos, animated: true, completion: nil)
    } else {
      let alertaDos = UIAlertController (title: "Oferta Cancelada", message: "La oferta ha sido cancelada por el conductor. Por favor", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alerAction in
        if globalVariables.solpendientes.count != 0{
          self.Inicio()
        }
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
  func socketResponse(_ controller: SocketService, msgVozConductor result: [String : Any]) {
    globalVariables.urlConductor = "\(GlobalConstants.urlHost)/\(result["audio"] as! String)"
    if UIApplication.shared.applicationState == .background {
      let localNotification = UILocalNotification()
      localNotification.alertAction = "Mensaje del Conductor"
      localNotification.alertBody = "Mensaje del Conductor. Abra la aplicación para escucharlo."
      localNotification.fireDate = Date(timeIntervalSinceNow: 4)
      UIApplication.shared.scheduleLocalNotification(localNotification)
    }
    globalVariables.SMSVoz.ReproducirVozConductor(globalVariables.urlConductor)
  }
  
  func socketResponse(_ controller: SocketService, direccionespactadas result: [String : Any]) {
    if result["code"] as! Int == 1{
      let pactadasList = result["datos"] as! [[String: Any]]
      print(pactadasList)
      for direccionPactada in pactadasList{
        globalVariables.direccionesPactadas.append(DireccionesPactadas(data: direccionPactada))
      }
    }
    self.addressPicker.reloadAllComponents()
    self.destinoAddressPicker.reloadAllComponents()
  }
  
  func socketResponse(_ controller: SocketService, serviciocompletado result: [String : Any]) {
    if globalVariables.solpendientes.count > 0 {
      let solicitudCompletadaIndex = globalVariables.solpendientes.firstIndex{$0.id == result["idsolicitud"] as! Int}!
      if solicitudCompletadaIndex >= 0{
        let solicitudCompletada = globalVariables.solpendientes.remove(at: solicitudCompletadaIndex)
        print(solicitudCompletada.importe)
        DispatchQueue.main.async {
          let vc = R.storyboard.main.completadaView()!
          vc.solicitud = solicitudCompletada
          vc.importe = !(result["importe"] is NSNull) ? result["importe"] as! Double : solicitudCompletada.importe
          self.navigationController?.show(vc, sender: nil)
        }
      }
    }
  }
  
  func socketResponse(_ controller: SocketService, taxiLLego result: [String : Any]) {
    let solicitudIndex = globalVariables.solpendientes.firstIndex{$0.id == result["idsolicitud"] as! Int}!
    let solicitud = globalVariables.solpendientes[solicitudIndex]
    if solicitudIndex >= 0{
      let alertaDos = UIAlertController (title: "Su Taxi ha llegado", message: "Su taxi \(solicitud.taxi.marca), color \(solicitud.taxi.color), matrícula \(solicitud.taxi.matricula) ha llegado al punto de recogida.", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alerAction in
        
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
  
  func socketResponse(_ controller: SocketService, conectionError errorMessage: String) {
    let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor intentar otra vez.", preferredStyle: UIAlertController.Style.alert)
    alertaDos.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alerAction in
      exit(0)
    }))
    self.present(alertaDos, animated: true, completion: nil)
  }
  
    
    func socketResponse(_ controller: SocketService, cardAddedSucceed result: Bool) {
        let alertaDos = UIAlertController (title: result ? nil : "Error", message: result ? "La tarejta se registró con éxito." : "El registro de la tarjeta falló. Por favor intentelo otra vez.", preferredStyle: UIAlertController.Style.alert)
        alertaDos.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: { [self] alerAction in
            if result {
                tarjetasView.isHidden = true
            } else {
                tarjetasView.isHidden = true
                pagoCell.resetToEfectivo()
            }
        }))
        self.present(alertaDos, animated: true, completion: nil)
        super.hideMenuBar(isHidden: false)
    }
    
    func socketResponse(_ controller: SocketService, cardExist result: Bool) {
        let alertaDos = UIAlertController (title: "Error", message: "La tarjeta fue registrada anteriormente. Por favor verífique en su lista de Tarjetas registradas.", preferredStyle: UIAlertController.Style.alert)
        alertaDos.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: { [self] alerAction in
            tarjetasView.isHidden = true
            pagoCell.resetToEfectivo()
        }))
        self.present(alertaDos, animated: true, completion: nil)
    }
    
    func socketResponse(_ controller: SocketService, pagoConTarjeta result: [String : Any]) {
        let code = result["code"] as? Int
        let message = result["msg"] as? String
        let alertaDos = UIAlertController (title: code == 1 ? nil : "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alertaDos.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: { alerAction in

        }))
        self.present(alertaDos, animated: true, completion: nil)
    }
}
