//
//  SolPendSocketExt.swift
//  MovilClub
//
//  Created by Donelkys Santana on 8/21/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import UIKit
import MapKit
import SocketIO

extension SolPendController{
  func socketEventos(){
    self.offSocketEventos()
    //MASK:- EVENTOS SOCKET
    globalVariables.socket.on("cargardatosdevehiculo"){data, ack in
      
      let temporal = data[0] as! [String: Any]
      if temporal["code"] as! Int == 1{
        let datosConductor = temporal["datos"] as! [String: Any]
        print(datosConductor)
        self.reviewConductor.text = "\(datosConductor["calificacion"] as! Double) (\(datosConductor["cantidadcalificacion"] as! Int))"
        self.NombreCond.text! = "Conductor: \(datosConductor["conductor"] as! String)"
        self.MarcaAut.text! = "\(datosConductor["marca"] as! String) -"
        self.ColorAut.text! = "\(datosConductor["color"] as! String)"
        self.matriculaAut.text! = "\(datosConductor["matricula"] as! String)"
        //self.MovilCond.text! = "Movil: \(datosConductor["movil"] as! String)"
        if datosConductor["urlfoto"] != nil && datosConductor["urlfoto"] as! String != ""{
          let url = URL(string:"\(GlobalConstants.urlHost)/\(datosConductor["urlfoto"] as! String)")
          
          let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.sync() {
              self.ImagenCond.image = UIImage(data: data)
            }
          }
          task.resume()
        }else{
          self.ImagenCond.image = UIImage(named: "chofer")
        }
        self.DatosConductor.isHidden = false
      }else{
        let alertaDos = UIAlertController (title: "Datos del vehículo", message: temporal["msg"] as! String, preferredStyle: UIAlertController.Style.alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          
        }))
        self.present(alertaDos, animated: true, completion: nil)
      }
    }
    
    globalVariables.socket.on("voz"){data, ack in
      
      let temporal = data[0] as! [String: Any]
      print(temporal)
      
      self.MensajesBtn.isHidden = false
      self.MensajesBtn.setImage(UIImage(named: "mensajesnew"),for: UIControl.State())
      
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
    
    //GEOPOSICION DE TAXIS
    globalVariables.socket.on("geocliente"){data, ack in
      print("Taxi Geo")
      let temporal = data[0] as! [String: Any]
      
      if globalVariables.solpendientes.count != 0 {
        if (temporal["idtaxi"] as! Int) == self.solicitudPendiente.taxi.id{
          self.MapaSolPen.removeAnnotation(self.TaxiSolicitud)
          self.solicitudPendiente.taxi.updateLocation(newLocation: CLLocationCoordinate2DMake(temporal["lat"] as! Double, temporal["lng"] as! Double))
          self.TaxiSolicitud.coordinate = CLLocationCoordinate2DMake(temporal["lat"] as! Double, temporal["lng"] as! Double)
          self.MapaSolPen.addAnnotation(self.TaxiSolicitud)
          self.MapaSolPen.showAnnotations(self.MapaSolPen.annotations, animated: true)
          self.MostrarDetalleSolicitud()
        }
      }
    }
    
    globalVariables.socket.on("serviciocompletado"){data, ack in
      
//      idtaxi: data.idtaxi,
//      idsolicitud: data.idsolicitud,
//      distancia: data.distancia,
//      importe: data.importe,
//      tiempodeespera: data.tiempodeespera
      
      let result = data[0] as! [String: Any]
      print("completadas: \(result["importe"] != nil)")
      if globalVariables.solpendientes.count > 0 {
        let solicitudCompletadaIndex = globalVariables.solpendientes.firstIndex{$0.id == result["idsolicitud"] as! Int}!
        if solicitudCompletadaIndex >= 0{
          let solicitudCompletada = globalVariables.solpendientes.remove(at: solicitudCompletadaIndex)
          print(solicitudCompletada.valorOferta)
          DispatchQueue.main.async {
            let vc = R.storyboard.main.completadaView()!
            vc.solicitud = solicitudCompletada
            vc.importe = !(result["importe"] is NSNull) ? result["importe"] as! Double : solicitudCompletada.valorOferta
            self.navigationController?.show(vc, sender: nil)
          }
        }
      }
    }
  }
}
