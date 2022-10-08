//
//  SolPendSocketExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 8/21/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import UIKit
import MapKit
import SocketIO
import AVFoundation
import ToastViewSwift

extension SolPendController: SocketServiceDelegate{
  //GEOPOSICION DE TAXIS
  func socketResponse(_ controller: SocketService, geocliente result: [String: Any]){
    print("Taxi Geo")
    if globalVariables.solpendientes.count != 0 {
      if (result["idtaxi"] as! Int) == self.solicitudPendiente.taxi.id{
        self.mapView.removeAnnotation(self.taxiAnnotation)
        self.solicitudPendiente.taxi.updateLocation(newLocation: CLLocationCoordinate2DMake(result["lat"] as! Double, result["lng"] as! Double))
        self.taxiAnnotation.coordinate = CLLocationCoordinate2DMake(result["lat"] as! Double, result["lng"] as! Double)
        self.mapView.addAnnotation(self.taxiAnnotation)
        self.mapView.showAnnotations(self.mapView.annotations!, animated: true)
        self.MostrarDetalleSolicitud()
      }
    }
  }
  
  func socketResponse(_ controller: SocketService, serviciocompletado result: [String: Any]){
    print("completada \(result)")
    if globalVariables.solpendientes.count > 0 {
      let solicitudCompletadaIndex = globalVariables.solpendientes.firstIndex{$0.id == result["idsolicitud"] as! Int}!
      if solicitudCompletadaIndex >= 0{
        let solicitudCompletada = globalVariables.solpendientes.remove(at: solicitudCompletadaIndex)
        solicitudCompletada.yapaimporte = result["yapa"] as! Double
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
    let solicitud = globalVariables.solpendientes.first{$0.id == result["idsolicitud"] as! Int}!
    if solicitud != nil{
      let alertaDos = UIAlertController (title: "Su Taxi ha llegado", message: "Su taxi \(solicitud.taxi.marca), color \(solicitud.taxi.color), matrícula \(solicitud.taxi.matricula) ha llegado al punto de recogida. Tiene un período de gracia de 5 min.", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
  func socketResponse(_ controller: SocketService, taximetroiniciado result: [String : Any]) {
    let solicitud = globalVariables.solpendientes.first{$0.id == result["idsolicitud"] as! Int}
    if solicitud != nil {
      let title = solicitud!.tipoServicio == 2 ? "Taximetro Activado" : "Carrera Iniciada"
      let mensaje = solicitud!.tipoServicio == 2 ? "El conductor ha iniciado el Taximetro " : "El conductor ha iniciado la carrera "
      let alertaDos = UIAlertController (title: title, message: "\(mensaje) a las: \(OurDate(stringDate: result["fechacambioestado"] as! String).timeToShow()).", preferredStyle: .alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
  func socketResponse(_ controller: SocketService, cancelarservicio result: [String : Any]) {
    let title = (result["code"] as! Int) == 1 ? "Solicitud Cancelada" : "Error Cancelar"
    let message = (result["code"] as! Int) == 1 ? "Su solicitud fue cancelada con éxito." : result["msg"] as! String

    let alertaDos = UIAlertController (title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
      if (result["code"] as! Int) == 1{
        //self.CancelarSolicitud("Conductor")
        globalVariables.solpendientes.removeAll{$0.id == self.solicitudPendiente.id}
        DispatchQueue.main.async {
          self.goToInicioView()
//          let vc = R.storyboard.main.inicioView()!
//          self.navigationController?.show(vc, sender: nil)
        }
      }
    }))
    self.present(alertaDos, animated: true, completion: nil)

  }
  
  func socketResponse(_ controller: SocketService, serviciocancelado result: [String : Any]) {
    let solicitud = globalVariables.solpendientes.first{$0.id == result["idsolicitud"] as! Int}
    if solicitud != nil{
      let alertaDos = UIAlertController (title: "Estado de Solicitud", message: "Solicitud cancelada por el conductor.", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        
        self.CancelarSolicitud("Conductor")
        
        DispatchQueue.main.async {
          self.goToInicioView()
          let vc = R.storyboard.main.inicioView()!
          self.navigationController?.show(vc, sender: nil)
        }
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
  func socketResponse(_ controller: SocketService, msgVozConductor result: [String : Any]) {
    
    switch AVAudioSession.sharedInstance().recordPermission {
    case AVAudioSession.RecordPermission.granted:self.MensajesBtn.isHidden = false
      self.MensajesBtn.setImage(UIImage(named: "mensajesnew"),for: UIControl.State())
      
      globalVariables.urlConductor = "\(GlobalConstants.urlHost)/\(result["audio"] as! String)"
      if UIApplication.shared.applicationState == .background {
        let localNotification = UILocalNotification()
        localNotification.alertAction = "Mensaje del Conductor"
        localNotification.alertBody = "Mensaje del Conductor. Abra la aplicación para escucharlo."
        localNotification.fireDate = Date(timeIntervalSinceNow: 4)
        UIApplication.shared.scheduleLocalNotification(localNotification)
      }
      globalVariables.SMSVoz.ReproducirVozConductor(globalVariables.urlConductor)
      
    case AVAudioSession.RecordPermission.denied:
      let locationAlert = UIAlertController (title: "Mensaje del Conductor", message: "Ha recibido un mensaje de audio del conductor, para reproducirlo es necesario activar el micrófono de su dispositivo.", preferredStyle: .alert)
      locationAlert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        if #available(iOS 10.0, *) {
          let settingsURL = URL(string: UIApplication.openSettingsURLString)!
          UIApplication.shared.open(settingsURL, options: [:], completionHandler: { success in
            exit(0)
          })
        } else {
          if let url = NSURL(string:UIApplication.openSettingsURLString) {
            UIApplication.shared.openURL(url as URL)
            exit(0)
          }
        }
      }))
      locationAlert.addAction(UIAlertAction(title: "No", style: .default, handler: {alerAction in
    
      }))
      self.present(locationAlert, animated: true, completion: nil)
    case AVAudioSession.RecordPermission.undetermined:
      AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
        if granted {
          
        } else{
          
        }
      })
    default:
      break
    }
  }
	
	func socketResponse(_ controller: SocketService, sosAlert result: [String : Any]) {
		let message = result["msg"] ?? ""
		
		let alertaDos = UIAlertController (title: "Alerta SOS", message: "\(message)", preferredStyle: UIAlertController.Style.alert)
		alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
			self.sosView.isHidden = true
		}))
		self.present(alertaDos, animated: true, completion: nil)
	}
}
