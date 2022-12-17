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
//    if globalVariables.solpendientes.count != 0 {
//
//    }
		if (result["idtaxi"] as! Int) == self.solicitudPendiente.taxi.id{
			self.mapView.removeAnnotations(self.taxiAnnotation,pointAnnotationManager: pointAnnotationManager)
			self.solicitudPendiente.taxi.updateLocation(newLocation: CLLocationCoordinate2DMake(result["lat"] as! Double, result["lng"] as! Double))
			self.taxiAnnotation.coordinates = CLLocationCoordinate2DMake(result["lat"] as! Double, result["lng"] as! Double)
			
			//self.mapView.addAnnotation(self.taxiAnnotation, pointAnnotationManager: pointAnnotationManager)
			//self.mapView.showAnnotations(pointAnnotationManager.annotations, animated: true)
			self.MostrarDetalleSolicitud()
		}
  }
  
  func socketResponse(_ controller: SocketService, serviciocompletado result: [String: Any]){
    print("completada \(result)")
    if globalVariables.solpendientes.count > 0 {
      let solicitudCompletadaIndex = globalVariables.solpendientes.firstIndex{$0.id == result["idsolicitud"] as! Int}!
      if solicitudCompletadaIndex >= 0 {
        let solicitudCompletada = globalVariables.solpendientes.remove(at: solicitudCompletadaIndex)
				solicitudCompletada.importe = !(result["importe"] is NSNull) ? result["importe"] as! Double : solicitudCompletada.importe
        solicitudCompletada.yapaimporte = result["yapa"] as! Double
				solicitudCompletada.idestado = 7
        DispatchQueue.main.async {
          let vc = R.storyboard.main.completadaView()!
          vc.solicitud = solicitudCompletada
          self.navigationController?.show(vc, sender: nil)
        }
      }
    }
  }
  
  func socketResponse(_ controller: SocketService, taxiLLego result: [String : Any]) {
		guard let _ = globalVariables.solpendientes.first(where: {$0.id == result["idsolicitud"] as! Int}) else {
			return
		}
		let toast = Toast.text(GlobalStrings.taxiLlegoTitle,subtitle: GlobalStrings.taxiLlegoMessage )
					toast.show()
  }
  
  func socketResponse(_ controller: SocketService, taximetroiniciado result: [String : Any]) {
		if let solicitud = globalVariables.solpendientes.first(where: {$0.id == result["idsolicitud"] as! Int}) {
			
			let mensaje = solicitud.tipoServicio == 2 ? "El conductor ha iniciado el Taxímetro" : "El conductor ha iniciado la carrera"
					let toast = Toast.text("\(mensaje)", subtitle: "\(OurDate(stringDate: result["fechacambioestado"] as! String).timeToShow())")
					toast.show()
    }
  }
  
  func socketResponse(_ controller: SocketService, cancelarservicio result: [String : Any]) {
    let title = (result["code"] as! Int) == 1 ? "Solicitud Cancelada" : "Error Cancelar"
    let message = (result["code"] as! Int) == 1 ? "Su solicitud fue cancelada con éxito." : result["msg"] as! String

    let alertaDos = UIAlertController (title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    alertaDos.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alerAction in
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
      alertaDos.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alerAction in
        
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
      locationAlert.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alerAction in
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
		alertaDos.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alerAction in
			self.sosView.isHidden = true
		}))
		self.present(alertaDos, animated: true, completion: nil)
	}
}
