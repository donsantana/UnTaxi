//
//  SolDetallesFunctionsExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 6/18/21.
//  Copyright © 2021 Done Santana. All rights reserved.
//

import Foundation
import SocketIO
import AVFoundation
import GoogleMobileAds
import SideMenu
import Mapbox
import MapboxDirections

extension SolPendController{
  //MASK:- FUNCIONES PROPIAS
  
  func initMapView(){
    mapView.setCenter(self.origenAnnotation.coordinate, zoomLevel: 15, animated: false)
    mapView.styleURL = MGLStyle.lightStyleURL
  }
  
  func drawRoute(from: MGLPointAnnotation, to: MGLPointAnnotation){
    let wp1 = Waypoint(coordinate: from.coordinate, name: from.title)
    let wp2 = Waypoint(coordinate: to.coordinate, name: to.title)
    let options = RouteOptions(waypoints: [wp1, wp2])
    options.includesSteps = true
    options.routeShapeResolution = .full
    options.attributeOptions = [.congestionLevel, .maximumSpeedLimit]
    
    Directions.shared.calculate(options) { (session, result) in
      switch result {
      case let .failure(error):
        print("Error calculating directions: \(error)")
      case let .success(response):
        if let route = response.routes?.first, let leg = route.legs.first {

          let travelTimeFormatter = DateComponentsFormatter()
          travelTimeFormatter.unitsStyle = .short
          let formattedTravelTime = travelTimeFormatter.string(from: route.expectedTravelTime)
          self.distanciaText.text = "SU TAXI ESTÁ A: \(formattedTravelTime ?? "")"
          
//          for step in leg.steps {
//            let direction = step.maneuverDirection?.rawValue ?? "none"
//            print("\(step.instructions) [\(step.maneuverType) \(direction)]")
//          }
          
          if var routeCoordinates = route.shape?.coordinates, routeCoordinates.count > 0 {
            // Convert the route’s coordinates into a polyline.
            let routeLine = MGLPolyline(coordinates: &routeCoordinates, count: UInt(routeCoordinates.count))

            // Add the polyline to the map.
            print("route \(route.distance)")
            if route.distance > 500{
              self.mapView.addAnnotation(routeLine)
            }
          }
        }
      }
    }
  }
  
  @objc func longTap(_ sender : UILongPressGestureRecognizer){
    if sender.state == .ended {
      if !globalVariables.SMSVoz.reproduciendo && globalVariables.grabando{
        self.SMSVozBtn.setImage(UIImage(named: "smsvoz"), for: .normal)
        let dateFormato = DateFormatter()
        dateFormato.dateFormat = "yyMMddhhmmss"
        self.fechahora = dateFormato.string(from: Date())
        let name = "\(self.solicitudPendiente.id)-\(self.solicitudPendiente.taxi.id)-\(fechahora).m4a"
        globalVariables.SMSVoz.TerminarMensaje(name,solicitud: self.solicitudPendiente)
        self.apiService.subirAudioAPIService(solicitud: self.solicitudPendiente, name: name)
        //globalVariables.SMSVoz.SubirAudio(self.solicitudPendiente, name: name)
        //globalVariables.SMSVoz.uploadImageToServerFromApp(solicitud: self.solicitudPendiente, name: name)
        globalVariables.grabando = false
        globalVariables.SMSVoz.ReproducirMusica()
      }
    }else if sender.state == .began {
      if !globalVariables.SMSVoz.reproduciendo{
        self.SMSVozBtn.setImage(UIImage(named: "smsvozRec"), for: .normal)
        globalVariables.SMSVoz.ReproducirMusica()
        globalVariables.SMSVoz.GrabarMensaje()
        globalVariables.grabando = true
      }
    }
  }
  
  //FUNCIÓN ENVIAR AL SOCKET
  func EnviarSocket(_ datos: String){
    if CConexionInternet.isConnectedToNetwork() == true{
      if globalVariables.socket.status.active{
        print(datos)
        globalVariables.socket.emit("data",datos)
      }else{
        let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor intentar otra vez.", preferredStyle: UIAlertController.Style.alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          exit(0)
        }))
        self.present(alertaDos, animated: true, completion: nil)
      }
    }else{
      self.ErrorConexion()
    }
  }
  
  func ErrorConexion(){
    let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor revise su conexión a Internet.", preferredStyle: UIAlertController.Style.alert)
    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
      exit(0)
    }))
    
    self.present(alertaDos, animated: true, completion: nil)
  }
  
  func MostrarDetalleSolicitud(){
    var annotationsToShow = [self.origenAnnotation]
    if self.solicitudPendiente.taxi.id != 0{
      self.taxiAnnotation.coordinate = self.solicitudPendiente.taxi.location
      self.taxiAnnotation.subtitle = "taxi_libre"
      annotationsToShow.append(taxiAnnotation)
      //self.MapaSolPen.addAnnotations([self.origenAnnotation, self.taxiAnnotation])
      
      let temporal = self.solicitudPendiente.DistanciaTaxi()
      self.direccionOrigen.text = solicitudPendiente.dirOrigen
      self.direccionDestino.text = solicitudPendiente.dirDestino
      self.distanciaText.text = "SU TAXI ESTÁ A \(temporal) KM"
      self.valorOferta.text = !(solicitudPendiente.valorOferta == 0.0) ? "$\(String(format: "%.2f",solicitudPendiente.valorOferta)), Efectivo" : "Importe \(self.solicitudPendiente.tipoServicio == 2 ? "del Taxímetro" : "por Horas")"
      
      self.reviewConductor.text = "\(solicitudPendiente.taxi.conductor.calificacion) (\(solicitudPendiente.taxi.conductor.cantidadcalificaciones))"
      self.NombreCond.text! = "\(solicitudPendiente.taxi.conductor.nombreApellido)"
      self.MarcaAut.text! = "\(solicitudPendiente.taxi.marca) - \(solicitudPendiente.taxi.color)"
      self.matriculaAut.text! = "\(solicitudPendiente.taxi.matricula)"
      if solicitudPendiente.taxi.conductor.urlFoto != ""{
        let url = URL(string:"\(GlobalConstants.urlHost)/\(solicitudPendiente.taxi.conductor.urlFoto)")
        
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
      
      self.detallesView.isHidden = false
      self.SMSVozBtn.setImage(UIImage(named:"smsvoz"),for: UIControl.State())
      
    }else{
      //self.MapaSolPen.addAnnotations(self.origenAnnotation)
    }
  
    if self.destinoAnnotation.coordinate.latitude != 0.0{
      annotationsToShow.append(self.destinoAnnotation)
    }
    
    self.showAnnotation(annotationsToShow)
    self.drawRoute(from: self.origenAnnotation, to: self.taxiAnnotation)
    self.waitingView.isHidden = true
    //self.mapView.addAnnotations(annotationsToShow)
    //self.MapaSolPen.fitAll(in: annotationsToShow, andShow: true)
  }
  
  
  //CANCELAR SOLICITUDES
  func MostrarMotivoCancelacion(){
    let motivoAlerta = UIAlertController(title: "¿Por qué cancela el viaje?", message: "", preferredStyle: .actionSheet)
    
    let titleAttributes = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 20)!, NSAttributedString.Key.foregroundColor: UIColor.black]
    let titleString = NSAttributedString(string: "¿Por qué cancela el viaje?", attributes: titleAttributes)
    motivoAlerta.setValue(titleString, forKey: "attributedTitle")
    
    for i in 0...Customization.motivosCancelacion.count - 1{
      if i == Customization.motivosCancelacion.count - 1{
        motivoAlerta.addAction(UIAlertAction(title: Customization.motivosCancelacion[i], style: .default, handler: { action in
          let ac = UIAlertController(title: Customization.motivosCancelacion[i], message: nil, preferredStyle: .alert)
          ac.addTextField()
          
          let submitAction = UIAlertAction(title: "Enviar", style: .default) { [unowned ac] _ in
            if !ac.textFields![0].text!.isEmpty{
              self.CancelarSolicitud(ac.textFields![0].text!)
            }
          }
          
          ac.addAction(submitAction)
          self.present(ac, animated: true)
        }))
      }else{
        motivoAlerta.addAction(UIAlertAction(title: Customization.motivosCancelacion[i], style: .default, handler: { action in
          self.CancelarSolicitud(Customization.motivosCancelacion[i])
        }))
      }
    }
    motivoAlerta.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { action in
    }))
    self.present(motivoAlerta, animated: true, completion: nil)
  }
  
  func CancelarSolicitud(_ motivo: String){
    //#Cancelarsolicitud, id, idTaxi, motivo, "# \n"
    let datos = self.solicitudPendiente.crearTramaCancelar(motivo: motivo)
    socketService.socketEmit("cancelarservicio", datos: datos)
  }
  
  func offSocketEventos(){
    globalVariables.socket.off("cargardatosdevehiculo")
    globalVariables.socket.off("voz")
    globalVariables.socket.off("geocliente")
    globalVariables.socket.off("serviciocompletado")
  }
  
  func openWhatsApp(number : String){
    var fullMob = number
    fullMob = fullMob.replacingOccurrences(of: " ", with: "")
    fullMob = fullMob.replacingOccurrences(of: "+", with: "")
    fullMob = fullMob.replacingOccurrences(of: "-", with: "")
    let urlWhats = "whatsapp://send?phone=\(fullMob)"
    
    if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
      if let whatsappURL = NSURL(string: urlString) {
        if UIApplication.shared.canOpenURL(whatsappURL as URL) {
          UIApplication.shared.open(whatsappURL as URL, options: [:], completionHandler: { (Bool) in
          })
        } else {
          let alertaCompartir = UIAlertController (title: "Whatsapp Error", message: "La aplicaión de whatsapp no está instalada en su dispositivo", preferredStyle: UIAlertController.Style.alert)
          alertaCompartir.addAction(UIAlertAction(title: "Cerrar", style: .default, handler: {alerAction in
            
          }))
          self.present(alertaCompartir, animated: true, completion: nil)
        }
      }
    }
  }
  
  func mostrarAdvertenciaCancelacion(){
    let alertaDos = UIAlertController (title: "Aviso Importante", message: "Estimado usuario, la cancelación frecuente del servicio puede ser motivo de un bloqueo temporal de la aplicación.", preferredStyle: .alert)
    
    let titleAttributes = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 20)!, NSAttributedString.Key.foregroundColor: UIColor.red]
    let titleString = NSAttributedString(string: "Aviso Importante", attributes: titleAttributes)
    alertaDos.setValue(titleString, forKey: "attributedTitle")
    
    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { [self]alerAction in
      self.MostrarMotivoCancelacion()
    }))
    
    self.present(alertaDos, animated: true, completion: nil)
  }
  
  @objc func goToPublicidad(){
    globalVariables.publicidadService?.goToPublicidad()
  }
}
