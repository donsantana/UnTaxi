//
//  HistorialDetailsController.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 11/5/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class HistorialDetailsController: BaseController, MKMapViewDelegate {
  var solicitud: SolicitudHistorial!
  var origenSolicitud = MKPointAnnotation()
  var destinoSolicitud = MKPointAnnotation()

  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var waitingView: UIVisualEffectView!
  
  @IBOutlet weak var reviewConductor: UILabel!
  //datos del conductor a mostrar
  @IBOutlet weak var ImagenCond: UIImageView!
  @IBOutlet weak var NombreCond: UILabel!
  @IBOutlet weak var matriculaAut: UILabel!
  
  @IBOutlet weak var fechaText: UILabel!
  @IBOutlet weak var origenText: UILabel!
  @IBOutlet weak var destinoText: UILabel!
  @IBOutlet weak var importeText: UILabel!
  @IBOutlet weak var statusText: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.viewTopConstraint.constant = super.getTopMenuBottom()
    
    self.mapView.delegate = self
    //self.mapView.centerCoordinate = solicitud.origenCoord
    self.mapView.showsUserLocation = false
    let regionRadius: CLLocationDistance = 1000
    self.loadHistorialSolicitudes()
    
    self.origenSolicitud.title = "origen"
    self.destinoSolicitud.title = "destino"
    
    //self.statusText.font = CustomAppFont.titleFont
    self.fechaText.text = solicitud.fechaHora.dateTimeToShow()
    self.origenText.text = solicitud.dirOrigen
    self.destinoText.text = solicitud.dirDestino
    self.importeText.text = "$\(solicitud.importe)"
    self.statusText.text = solicitud.solicitudStado().uppercased()
    self.matriculaAut.text = solicitud.matricula
    
    globalVariables.socket.on("detallehistorialdesolicitud"){data, ack in
      self.waitingView.isHidden = true
      let result = data[0] as! [String: Any]
      print(result)
      if result["code"] as! Int == 1{
        let temporal = result["datos"] as! [String: Any]
        self.solicitud.addDetails(details: temporal)
        self.reviewConductor.text = "\(temporal["calificacion"] as! Double)(\(temporal["cantidadcalificacion"] as! Int))"

        self.origenSolicitud.coordinate = CLLocationCoordinate2D(latitude: self.solicitud.latorigen, longitude: self.solicitud.lngorigen)
        self.destinoSolicitud.coordinate = CLLocationCoordinate2D(latitude: self.solicitud.latdestino, longitude: self.solicitud.lngdestino)
        
        let coordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: self.solicitud.latorigen, longitude: self.solicitud.lngorigen), latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        
        self.updateMap()
        self.mapView.setRegion(coordinateRegion, animated: true)

        if temporal["foto"] as! String != ""{
          let url = URL(string:"\(GlobalConstants.urlHost)/\(temporal["foto"] as! String)")
          
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
        
        self.NombreCond.text = temporal["nombreapellidosconductor"] as? String

      }
    }
  }
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    var anotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView")
    anotationView = MKAnnotationView(annotation: self.origenSolicitud, reuseIdentifier: "annotationView")
    if annotation.title! == "origen"{
      anotationView?.image = UIImage(named: "origen")
    }else{
      anotationView?.image = UIImage(named: "destinoIcon")
    }
    return anotationView
  }
  
  //Dibujar la ruta
  private func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
    let renderer = MKPolylineRenderer(overlay: overlay)
    renderer.strokeColor = UIColor.red
    renderer.lineWidth = 4.0
    
    return renderer
  }
  
  func updateMap(){
    self.mapView.addAnnotation(self.origenSolicitud)
    if self.solicitud.lngdestino == 0.0{
      self.mapView.addAnnotation(self.destinoSolicitud)
    }
  }
  
  func loadHistorialSolicitudes(){
    let vc = R.storyboard.main.inicioView()!
    vc.socketEmit("detallehistorialdesolicitud", datos: ["idsolicitud": self.solicitud.id])
  }
  
  override func homeBtnAction() {
    let vc = R.storyboard.main.historyView()
    self.navigationController?.show(vc!, sender: nil)
  }

}
