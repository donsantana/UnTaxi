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
  var socketService = SocketService()
  var regionRadius: CLLocationDistance = 1000
  var idConductor = 0
  
  let inicioVC = InicioController()

  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var waitingView: UIVisualEffectView!
  
  @IBOutlet weak var reviewConductor: UILabel!
  //datos del conductor a mostrar
  @IBOutlet weak var ImagenCond: UIImageView!
  @IBOutlet weak var NombreCond: UILabel!
  @IBOutlet weak var matriculaAut: UILabel!
  
  @IBOutlet weak var origenIcon: UIImageView!
  @IBOutlet weak var starImag: UIImageView!
  @IBOutlet weak var fechaText: UILabel!
  @IBOutlet weak var origenText: UILabel!
  @IBOutlet weak var destinoText: UILabel!
  @IBOutlet weak var importeText: UILabel!
  @IBOutlet weak var statusText: UILabel!
  @IBOutlet weak var evaluarBtn: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.viewTopConstraint.constant = super.getTopMenuBottom()
    
    self.mapView.delegate = self
    self.socketService.delegate = self
    self.mapView.showsUserLocation = false
    
    self.origenSolicitud.title = "origen"
    self.destinoSolicitud.title = "destino"
    
    //self.statusText.font = CustomAppFont.titleFont
    self.fechaText.text = solicitud.fechaHora.dateTimeToShow()
    self.origenText.text = solicitud.dirOrigen
    self.destinoText.text = solicitud.dirDestino
    self.importeText.text = "$\(solicitud.importe)"
    self.statusText.text = solicitud.solicitudStado().uppercased()
    self.matriculaAut.text = solicitud.matricula
    waitingView.addStandardConfig()
    origenIcon.addCustomTintColor(customColor: CustomAppColor.buttonActionColor)
    starImag.addCustomTintColor(customColor: CustomAppColor.buttonActionColor)
    evaluarBtn.addCustomActionBtnsColors()
    self.loadHistorialSolicitudes()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    self.loadHistorialSolicitudes()
  }
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    var anotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView")
    anotationView = MKAnnotationView(annotation: self.origenSolicitud, reuseIdentifier: "annotationView")
    if annotation.title! == "origen"{
      anotationView?.image = UIImage(named: "origen")
    }else{
      anotationView?.image = UIImage(named: "destino")
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
    if self.solicitud.lngdestino != 0.0{
      self.mapView.showAnnotations([self.origenSolicitud,self.destinoSolicitud], animated: true)
    }else{
      self.mapView.showAnnotations([self.origenSolicitud], animated: true)
    }
  }
  
  func loadHistorialSolicitudes(){
    self.socketService.socketEmit("detallehistorialdesolicitud", datos: ["idsolicitud": self.solicitud.id])
    self.socketService.initHistorialDetallesEvents()
  }
  
  override func homeBtnAction() {
    let viewcontrollers = self.navigationController?.viewControllers
    viewcontrollers?.forEach({ (vc) in
      if  let inventoryListVC = vc as? HistorialController {
        self.navigationController!.popToViewController(inventoryListVC, animated: true)
      }
    })
  }
  
  @IBAction func evaluarConductor(_ sender: Any) {
    let tempSolicitud = Solicitud(id: self.solicitud.id, fechaHora: "", dirOrigen: self.solicitud.dirOrigen, referenciaOrigen: "", dirDestino: self.solicitud.dirDestino, latOrigen: self.solicitud.latorigen, lngOrigen: self.solicitud.lngorigen, latDestino: self.solicitud.latdestino, lngDestino: self.solicitud.lngdestino, valorOferta: self.solicitud.importe, detalleOferta: "", fechaReserva: "", useVoucher: "", tipoServicio: 0, yapa: self.solicitud.yapa)
    
    let vc = R.storyboard.main.completadaView()!
    vc.solicitud = tempSolicitud
    vc.importe = solicitud.importe
    vc.idConductor = self.idConductor
    
    self.navigationController?.show(vc, sender: self)
    
//    let viewcontrollers = self.navigationController?.viewControllers
//    print("cantidad de viewcontrollers \(viewcontrollers?.count)")
//
//    let tempSolicitud = Solicitud()
//    tempSolicitud.DatosSolicitud(id: self.solicitud.id, fechaHora: "", dirOrigen: self.solicitud.dirOrigen, referenciaOrigen: "", dirDestino: self.solicitud.dirDestino, latOrigen: self.solicitud.latorigen, lngOrigen: self.solicitud.lngorigen, latDestino: self.solicitud.latdestino, lngDestino: self.solicitud.lngdestino, valorOferta: self.solicitud.importe, detalleOferta: "", fechaReserva: "", useVoucher: "", tipoServicio: 0, yapa: self.solicitud.yapa)
//    let vc = R.storyboard.main.completadaView()!
//    vc.solicitud = tempSolicitud
//    vc.importe = solicitud.importe
//    vc.idConductor = self.idConductor
//
//    self.navigationController?.show(vc, sender: self)
  }
  
}

extension HistorialDetailsController: SocketServiceDelegate{
  
  func socketResponse(_ controller: SocketService, detallehistorialdesolicitud result: [String : Any]) {

    self.waitingView.isHidden = true
    if result["code"] as! Int == 1{
      let datos = result["datos"] as! [String: Any]
      print("Details result \(datos)")
      self.solicitud.addDetails(jsonDetails: datos)
      if !(datos["idconductor"] is NSNull) && datos["idconductor"] != nil{
        self.idConductor = datos["idconductor"] as! Int
        self.reviewConductor.text = "\(datos["calificacion"] as! Double)(\(datos["cantidadcalificacion"] as! Int))"
        evaluarBtn.isHidden = !(datos["evaluacion"] is NSNull) || self.solicitud.idEstado != 7
        
        if datos["foto"] as! String != ""{
          let url = URL(string:"\(GlobalConstants.urlHost)/\(datos["foto"] as! String)")
          
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
        
        self.NombreCond.text = datos["nombreapellidosconductor"] as? String
      }
      self.origenSolicitud.coordinate = CLLocationCoordinate2D(latitude: self.solicitud.latorigen, longitude: self.solicitud.lngorigen)
      self.destinoSolicitud.coordinate = CLLocationCoordinate2D(latitude: self.solicitud.latdestino, longitude: self.solicitud.lngdestino)
      
      self.updateMap()
    }
  }
}
