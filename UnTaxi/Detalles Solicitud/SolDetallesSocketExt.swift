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
    //MASK:- EVENTOS SOCKET
    globalVariables.socket.on("Transporte"){data, ack in
      //"#Taxi,"+nombreconductor+" "+apellidosconductor+","+telefono+","+codigovehiculo+","+gastocombustible+","+marcavehiculo+","+colorvehiculo+","+matriculavehiculo+","+urlfoto+","+idconductor+",# \n";
      let datosConductor = String(describing: data).components(separatedBy: ",")
      print(datosConductor)
      self.NombreCond.text! = "Conductor: \(datosConductor[1])"
      self.MarcaAut.text! = "Marca: \(datosConductor[4])"
      self.ColorAut.text! = "Color: \(datosConductor[5])"
      self.matriculaAut.text! = "Matrícula: \(datosConductor[6])"
      self.MovilCond.text! = "Movil: \(datosConductor[2])"
      if datosConductor[7 ] != "null" && datosConductor[7] != ""{
        let url = URL(string:datosConductor[7])
        
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
      self.AlertaEsperaView.isHidden = true
      self.DatosConductor.isHidden = false
    }
    
    globalVariables.socket.on("V"){data, ack in
      self.MensajesBtn.isHidden = false
      self.MensajesBtn.setImage(UIImage(named: "mensajesnew"),for: UIControl.State())
    }
    
    //GEOPOSICION DE TAXIS
    globalVariables.socket.on("geocliente"){data, ack in
      
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
      print(result)
      let solicitudCompletada = globalVariables.solpendientes.first{$0.id == result["idsolicitud"] as! Int}!
      if globalVariables.solpendientes.count != 0{
        globalVariables.solpendientes.removeAll{$0.id == result["idsolicitud"] as! Int}
        DispatchQueue.main.async {
          let vc = R.storyboard.main.completadaView()!
          vc.id = result["idsolicitud"] as! Int
          vc.idConductor = solicitudCompletada.taxi.conductor.idConductor
          self.navigationController?.show(vc, sender: nil)
        }
      }
    }
    
    //RESPUESTA DE CANCELAR SOLICITUD
//    globalVariables.socket.on("CSO"){data, ack in
//      let vc = R.storyboard.main.inicioView()!
//      vc.EnviarTimer(estado: 0, datos: "Terminado")
//      let temporal = String(describing: data).components(separatedBy: ",")
//      if temporal[1] == "ok"{
////        let alertaDos = UIAlertController (title: "Cancelar Solicitud", message: "Su solicitud fue cancelada.", preferredStyle: UIAlertController.Style.alert)
////        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
////          //self.Inicio()
////          if globalVariables.solpendientes.count != 0{
////            self.SolPendientesView.isHidden = true
////
////          }
//        }))
//        self.present(alertaDos, animated: true, completion: nil)
//      }
//    }
  }
}
