//
//  SolPendController.swift
//  UnTaxi
//
//  Created by Done Santana on 28/2/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import UIKit
import MapKit
import SocketIO
import AVFoundation
import GoogleMobileAds
import SideMenu
import Mapbox
import MapboxDirections

class SolPendController: BaseController, MKMapViewDelegate, UITextViewDelegate,URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
  var socketService = SocketService()
  var solicitudPendiente: Solicitud!
  var solicitudIndex: Int!
  var origenAnnotation = MGLPointAnnotation()
  var destinoAnnotation = MGLPointAnnotation()
  var taxiAnnotation = MGLPointAnnotation()
  var grabando = false
  var fechahora: String = ""
  var urlSubirVoz = globalVariables.urlSubirVoz
  var apiService = ApiService()
  var responsive = Responsive()
  var sideMenu: SideMenuNavigationController!
  
  
  //MASK:- VARIABLES INTERFAZ
  @IBOutlet weak var mapView: MGLMapView!
  @IBOutlet weak var detallesView: UIView!
  @IBOutlet weak var distanciaText: UILabel!
  @IBOutlet weak var valorOferta: UILabel!
  @IBOutlet weak var direccionOrigen: UILabel!
  @IBOutlet weak var direccionDestino: UILabel!
  
  @IBOutlet weak var ComentarioEvalua: UIView!
  
  
  @IBOutlet weak var cancelarBtn: UIButton!
  @IBOutlet weak var MensajesBtn: UIButton!
  @IBOutlet weak var LlamarCondBtn: UIButton!
  @IBOutlet weak var whatsappBtn: UIButton!
  @IBOutlet weak var SMSVozBtn: UIButton!
  
  @IBOutlet weak var showConductorBtn: UIButton!
  @IBOutlet weak var DatosConductor: UIView!
  @IBOutlet weak var reviewConductor: UILabel!
  //datos del conductor a mostrar
  @IBOutlet weak var conductorPreview: UIView!
  @IBOutlet weak var ImagenCond: UIImageView!
  @IBOutlet weak var NombreCond: UILabel!
  @IBOutlet weak var MarcaAut: UILabel!
  @IBOutlet weak var matriculaAut: UILabel!
  
  @IBOutlet weak var valorOfertaIcon: UIImageView!
  @IBOutlet weak var destinoIcon: UIImageView!
  
  @IBOutlet weak var adsBannerView: GADBannerView!
  
  @IBOutlet weak var bannerBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var datosCondHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var detallesVHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var detallesBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var waitingView: UIVisualEffectView!
  @IBOutlet weak var cancelarBtnLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var llamarBtnLoadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var whatsappLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var radioBtnLoadingConstraint: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.hideMenuBtn = false
    super.hideCloseBtn = false
    super.barTitle = ""
    //super.topMenu.bringSubviewToFront(self.formularioSolicitud)
    super.viewDidLoad()
    
    self.sideMenu = self.addSideMenu()
    
    self.mapView.delegate = self
    self.mapView.automaticallyAdjustsContentInset = true
    
    self.socketService.delegate = self
    self.socketService.initListenEventos()
    
    self.origenAnnotation.coordinate = self.solicitudPendiente.origenCoord
    self.origenAnnotation.subtitle = "origen"
    self.initMapView()
    if self.solicitudPendiente.destinoCoord.latitude != 0.0{
      self.destinoAnnotation.coordinate = self.solicitudPendiente.destinoCoord
      self.destinoAnnotation.subtitle = "destino"
    }
    
    //self.detallesView.addShadow()
    self.conductorPreview.addShadow()
    self.MostrarDetalleSolicitud()
    self.matriculaAut.titleBlueStyle()
    self.distanciaText.titleBlueStyle()
    self.reviewConductor.font = CustomAppFont.smallFont
    self.valorOferta.titleBlueStyle()
    self.LlamarCondBtn.addShadow()
    
    let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(SolPendController.longTap(_:)))
    longGesture.minimumPressDuration = 0.2
    self.SMSVozBtn.addGestureRecognizer(longGesture)
    
    //ADS BANNER VIEW
    self.adsBannerView.adUnitID = "ca-app-pub-1778988557303127/7963427999"
    self.adsBannerView.rootViewController = self
    self.adsBannerView.load(GADRequest())
    self.adsBannerView.delegate = self
    let distanceBtwBtns = responsive.distanceBtwElement(elementWidth: 60, elementCount: 4)
    self.cancelarBtnLeadingConstraint.constant = distanceBtwBtns
    self.llamarBtnLoadingConstraint.constant = distanceBtwBtns
    self.whatsappLeadingConstraint.constant = distanceBtwBtns
    self.radioBtnLoadingConstraint.constant = distanceBtwBtns
    
    self.detallesVHeightConstraint.constant = responsive.heightFloatPercent(percent: globalVariables.isBigIphone ? 20 : 24)
    self.datosCondHeightConstraint.constant = responsive.heightFloatPercent(percent:  globalVariables.isBigIphone ? 33 : 40)
    self.detallesBottomConstraint.constant = responsive.heightFloatPercent(percent: 3)
    
    self.bannerBottomConstraint.constant = -(responsive.heightFloatPercent(percent: globalVariables.isBigIphone ? 33 : 40) + 15)
    
    if globalVariables.urlConductor != ""{
      self.MensajesBtn.isHidden = false
      self.MensajesBtn.setImage(UIImage(named: "mensajesnew"),for: UIControl.State())
    }
    
    //PEDIR PERMISO PARA EL MICROPHONO
    switch AVAudioSession.sharedInstance().recordPermission {
    case AVAudioSession.RecordPermission.granted:
      print("Permission granted")
    case AVAudioSession.RecordPermission.denied:
      let locationAlert = UIAlertController (title: "Error de Micrófono", message: "Estimado cliente es necesario que active el micrófono de su dispositivo.", preferredStyle: .alert)
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
        exit(0)
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
      self.taxiAnnotation.title = "taxi_libre"
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
    
    self.showAnnotation(annotationsToShow, isPOI: true)
    self.drawRoute(from: self.origenAnnotation, to: self.taxiAnnotation)
    self.waitingView.isHidden = true
    //self.mapView.addAnnotations(annotationsToShow)
    //self.MapaSolPen.fitAll(in: annotationsToShow, andShow: true)
  }
  
  
  //CANCELAR SOLICITUDES
  func MostrarMotivoCancelacion(){
    //["No necesito","Demora el servicio","Tarifa incorrecta","Solo probaba el servicio", "Cancelar"]
    let motivoAlerta = UIAlertController(title: "¿Por qué cancela el viaje?", message: "", preferredStyle: UIAlertController.Style.actionSheet)
    //    motivoAlerta.addAction(UIAlertAction(title: "No necesito", style: .default, handler: { action in
    //      self.CancelarSolicitud("No necesito")
    //    }))
    motivoAlerta.addAction(UIAlertAction(title: "Mucho tiempo de espera", style: .default, handler: { action in
      self.CancelarSolicitud("Mucho tiempo de espera")
    }))
    motivoAlerta.addAction(UIAlertAction(title: "El taxi no se mueve", style: .default, handler: { action in
      self.CancelarSolicitud("El taxi no se mueve")
    }))
    motivoAlerta.addAction(UIAlertAction(title: "El conductor se fue a una dirección equivocada", style: .default, handler: { action in
      self.CancelarSolicitud("El conductor se fue a una dirección equivocada")
    }))
    motivoAlerta.addAction(UIAlertAction(title: "Ubicación incorrecta", style: .default, handler: { action in
      self.CancelarSolicitud("Ubicación incorrecta")
    }))
    motivoAlerta.addAction(UIAlertAction(title: "Otro", style: .default, handler: { action in
      let ac = UIAlertController(title: "Entre el motivo", message: nil, preferredStyle: .alert)
      ac.addTextField()
      
      let submitAction = UIAlertAction(title: "Enviar", style: .default) { [unowned ac] _ in
        if !ac.textFields![0].text!.isEmpty{
          self.CancelarSolicitud(ac.textFields![0].text!)
        }
      }
      
      ac.addAction(submitAction)
      
      self.present(ac, animated: true)
    }))
    motivoAlerta.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { action in
    }))
    
    self.present(motivoAlerta, animated: true, completion: nil)
  }
  
  func CancelarSolicitud(_ motivo: String){
    //#Cancelarsolicitud, id, idTaxi, motivo, "# \n"
    let datos = self.solicitudPendiente.crearTramaCancelar(motivo: motivo)
    globalVariables.solpendientes.removeAll{$0.id == self.solicitudPendiente.id}
    //let vc = R.storyboard.main.inicioView()!
    socketService.socketEmit("cancelarservicio", datos: datos)
    //self.navigationController?.show(vc, sender: nil)
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
  
  override func homeBtnAction() {
    present(sideMenu!, animated: true)
  }
  
  override func closeBtnAction() {
    let panicoViewController = storyboard?.instantiateViewController(withIdentifier: "panicoChildVC") as! PanicoController
    self.addChild(panicoViewController)
    self.view.addSubview(panicoViewController.view)
  }
  
  //MASK:- ACCIONES DE BOTONES
  //LLAMAR CONDUCTOR
  @IBAction func LLamarConductor(_ sender: AnyObject) {
    if let url = URL(string: "tel://\(self.solicitudPendiente.taxi.conductor.telefono)") {
      UIApplication.shared.open(url)
    }
  }
  @IBAction func ReproducirMensajesCond(_ sender: AnyObject) {
    if globalVariables.urlConductor != ""{
      globalVariables.SMSVoz.ReproducirVozConductor(globalVariables.urlConductor)
    }
  }
  
  //MARK:- BOTNES ACTION
  @IBAction func DatosConductor(_ sender: AnyObject) {
    self.detallesView.removeShadow()
    self.bannerBottomConstraint.constant = -(responsive.heightFloatPercent(percent:  UIScreen.main.bounds.height > 750 ? 33 : 40) + 15)
    //self.btnViewTop = NSLayoutConstraint(item: self.BtnsView, attribute: .top, relatedBy: .equal, toItem: self.origenCell.origenText, attribute: .bottom, multiplier: 1, constant: 0)
    self.showConductorBtn.isHidden = true
    self.DatosConductor.isHidden = false
    //    let datos = [
    //      "idtaxi": self.solicitudPendiente.taxi.id
    //    ]
    //    let vc = R.storyboard.main.inicioView()!
    //    vc.socketEmit("cargardatosdevehiculo", datos: datos)
  }
  
  @IBAction func AceptarCond(_ sender: UIButton) {
    
    self.openWhatsApp(number: self.solicitudPendiente.taxi.conductor.telefono)
    
    //    let alertaCompartir = UIAlertController (title: "Viaje seguro", message: "Para un viaje más seguro, puede compartir los datos de conductor con un amigo a familiar. ¿Desea compartir?", preferredStyle: UIAlertController.Style.alert)
    //    alertaCompartir.addAction(UIAlertAction(title: "Si", style: .default, handler: {alerAction in
    //
    //      let datosAuto = self.MarcaAut.text! + ", " + self.ColorAut.text! + ", " + self.matriculaAut.text!
    //      let datosConductor = self.NombreCond.text! + ", " + self.MovilCond.text! + ", " +  datosAuto
    //      let objectsToShare = [datosConductor]
    //      let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
    //      self.DatosConductor.isHidden = true
    //      self.present(activityVC, animated: true, completion: nil)
    //
    //    }))
    //    alertaCompartir.addAction(UIAlertAction(title: "No", style: .default, handler: {alerAction in
    //      self.DatosConductor.isHidden = true
    //    }))
    //    self.present(alertaCompartir, animated: true, completion: nil)
  }
  
  
  @IBAction func CancelarProcesoSolicitud(_ sender: AnyObject) {
    MostrarMotivoCancelacion()
  }
  
  @IBAction func cerrarDatosConductor(_ sender: Any) {
    self.detallesView.addShadow()
    self.bannerBottomConstraint.constant = -(responsive.heightFloatPercent(percent: UIScreen.main.bounds.height > 750 ? 20 : 24) + 5)
    self.showConductorBtn.isHidden = false
    self.DatosConductor.isHidden = true
  }
}

extension SolPendController: GADBannerViewDelegate{
  
  func adViewDidReceiveAd(_ bannerView: GADBannerView) {
    print("get the ads")
  }
  
  func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
    print("Error receiving the ads \(error.description)")
  }
}
