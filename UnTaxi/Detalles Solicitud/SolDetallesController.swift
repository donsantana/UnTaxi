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

class SolPendController: BaseController, MKMapViewDelegate, UITextViewDelegate,URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
  
  var solicitudPendiente: Solicitud!
  var solicitudIndex: Int!
  var OrigenSolicitud = MKPointAnnotation()
  var TaxiSolicitud = MKPointAnnotation()
  var grabando = false
  var fechahora: String = ""
  var urlSubirVoz = globalVariables.urlSubirVoz
  var apiService = ApiService()
  var responsive = Responsive()
  
  
  //MASK:- VARIABLES INTERFAZ
  //@IBOutlet weak var MapaSolPen: GMSMapView!
  @IBOutlet weak var MapaSolPen: MKMapView!
  @IBOutlet weak var detallesView: UIView!
  @IBOutlet weak var distanciaText: UILabel!
  @IBOutlet weak var valorOferta: UILabel!
  @IBOutlet weak var direccionOrigen: UILabel!
  @IBOutlet weak var direccionDestino: UILabel!
  
  @IBOutlet weak var ComentarioEvalua: UIView!
  
  
  @IBOutlet weak var MensajesBtn: UIButton!
  @IBOutlet weak var LlamarCondBtn: UIButton!
  @IBOutlet weak var SMSVozBtn: UIButton!
  
  
  @IBOutlet weak var showConductorBtn: UIButton!
  @IBOutlet weak var DatosConductor: UIView!
  @IBOutlet weak var reviewConductor: UILabel!
  //datos del conductor a mostrar
  @IBOutlet weak var conductorPreview: UIView!
  @IBOutlet weak var ImagenCond: UIImageView!
  @IBOutlet weak var NombreCond: UILabel!
  @IBOutlet weak var MovilCond: UILabel!
  @IBOutlet weak var MarcaAut: UILabel!
  @IBOutlet weak var ColorAut: UILabel!
  @IBOutlet weak var matriculaAut: UILabel!
  
  @IBOutlet weak var AlertaEsperaView: UIView!
  @IBOutlet weak var MensajeEspera: UITextView!
  
  @IBOutlet weak var valorOfertaIcon: UIImageView!
  @IBOutlet weak var destinoIcon: UIImageView!
  
  @IBOutlet weak var adsBannerView: GADBannerView!
  
  @IBOutlet weak var bannerBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var datosCondHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var detallesVHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var detallesBottomConstraint: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.hideMenuBtn = true
    super.barTitle = ""
    //super.topMenu.bringSubviewToFront(self.formularioSolicitud)
    super.viewDidLoad()
    
    //self.solicitudPendiente = globalVariables.solpendientes[solicitudIndex]
    self.MapaSolPen.delegate = self
    self.OrigenSolicitud.coordinate = self.solicitudPendiente.origenCoord
    self.OrigenSolicitud.title = "origen"
    //self.detallesView.addShadow()
    self.conductorPreview.addShadow()
    self.MostrarDetalleSolicitud()
    print(self.solicitudPendiente.dirDestino)
    
    self.LlamarCondBtn.addShadow()
    
    let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(SolPendController.longTap(_:)))
    longGesture.minimumPressDuration = 0.2
    self.SMSVozBtn.addGestureRecognizer(longGesture)
    
    //ADS BANNER VIEW
    self.adsBannerView.adUnitID = "ca-app-pub-1778988557303127/7963427999"
    self.adsBannerView.rootViewController = self
    self.adsBannerView.load(GADRequest())
    self.adsBannerView.delegate = self
    
    self.detallesVHeightConstraint.constant = responsive.heightFloatPercent(percent: UIScreen.main.bounds.height > 750 ? 23 : 28)
    self.datosCondHeightConstraint.constant = responsive.heightFloatPercent(percent:  UIScreen.main.bounds.height > 750 ? 40 : 52)
    self.detallesBottomConstraint.constant = responsive.heightFloatPercent(percent: 3)
    
    self.bannerBottomConstraint.constant = -(responsive.heightFloatPercent(percent: UIScreen.main.bounds.height > 750 ? 40 : 52) + 15)

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
    
    self.socketEventos()
  }
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    var anotationView = MapaSolPen.dequeueReusableAnnotationView(withIdentifier: "annotationView")
    anotationView = MKAnnotationView(annotation: self.OrigenSolicitud, reuseIdentifier: "annotationView")
    if annotation.title! == "origen"{
      anotationView?.image = UIImage(named: "origen")
    }else{
      anotationView?.image = UIImage(named: "taxi_libre")
    }
    return anotationView
  }
  
  //Dibujar la ruta
  func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
    let renderer = MKPolylineRenderer(overlay: overlay)
    renderer.strokeColor = UIColor.red
    renderer.lineWidth = 4.0
    
    return renderer
  }
  
  
  
  //MASK:- FUNCIONES PROPIAS
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
    if self.solicitudPendiente.taxi.id != 0{
      self.TaxiSolicitud.coordinate = self.solicitudPendiente.taxi.location
      //self.MapaSolPen.addAnnotations([self.OrigenSolicitud, self.TaxiSolicitud])
      self.MapaSolPen.fitAll(in: [self.OrigenSolicitud, self.TaxiSolicitud], andShow: true)
      let temporal = self.solicitudPendiente.DistanciaTaxi()
      self.direccionOrigen.text = solicitudPendiente.dirOrigen
      self.direccionDestino.text = solicitudPendiente.dirDestino
      self.distanciaText.text = "Su taxi está a \(temporal) KM"
      self.valorOferta.text = "$\(String(format: "%.2f",solicitudPendiente.valorOferta))"
      
      self.reviewConductor.text = "\(solicitudPendiente.taxi.conductor.calificacion) (\(solicitudPendiente.taxi.conductor.cantidadcalificaciones))"
      self.NombreCond.text! = "Conductor: \(solicitudPendiente.taxi.conductor.nombreApellido)"
      self.MarcaAut.text! = "\(solicitudPendiente.taxi.marca) -"
      self.ColorAut.text! = "\(solicitudPendiente.taxi.color)"
      self.matriculaAut.text! = "\(solicitudPendiente.taxi.matricula)"
      //self.MovilCond.text! = "Movil: \(datosConductor["movil"] as! String)"
      if solicitudPendiente.taxi.conductor.urlFoto != nil && solicitudPendiente.taxi.conductor.urlFoto != ""{
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
      
      
      self.valorOferta.isHidden = solicitudPendiente.valorOferta == 0.0
      self.valorOfertaIcon.isHidden = solicitudPendiente.valorOferta == 0.0
      self.destinoIcon.isHidden = self.direccionDestino.text!.isEmpty
      
    }else{
      self.MapaSolPen.addAnnotation(self.OrigenSolicitud)
    }
  }
  
  
  //CANCELAR SOLICITUDES
  func MostrarMotivoCancelacion(){
    //["No necesito","Demora el servicio","Tarifa incorrecta","Solo probaba el servicio", "Cancelar"]
    let motivoAlerta = UIAlertController(title: "", message: "Seleccione el motivo de cancelación.", preferredStyle: UIAlertController.Style.actionSheet)
    motivoAlerta.addAction(UIAlertAction(title: "No necesito", style: .default, handler: { action in
      self.CancelarSolicitud("No necesito")
    }))
    motivoAlerta.addAction(UIAlertAction(title: "Demora el servicio", style: .default, handler: { action in
      self.CancelarSolicitud("Demora el servicio")
    }))
    motivoAlerta.addAction(UIAlertAction(title: "Tarifa incorrecta", style: .default, handler: { action in
      self.CancelarSolicitud("Tarifa incorrecta")
    }))
    motivoAlerta.addAction(UIAlertAction(title: "Vehículo en mal estado", style: .default, handler: { action in
      self.CancelarSolicitud("Vehículo en mal estado")
    }))
    motivoAlerta.addAction(UIAlertAction(title: "Solo probaba el servicio", style: .default, handler: { action in
      self.CancelarSolicitud("Solo probaba el servicio")
    }))
    motivoAlerta.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.destructive, handler: { action in
    }))
    
    self.present(motivoAlerta, animated: true, completion: nil)
  }
  
  func CancelarSolicitud(_ motivo: String){
    //#Cancelarsolicitud, id, idTaxi, motivo, "# \n"
    let datos = self.solicitudPendiente.crearTramaCancelar(motivo: motivo)
    globalVariables.solpendientes.removeAll{$0.id == self.solicitudPendiente.id}
    let vc = R.storyboard.main.inicioView()!
    vc.socketEmit("cancelarservicio", datos: datos)
    self.navigationController?.show(vc, sender: nil)
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
//    let datos = "#Transporte," + globalVariables.cliente.idUsuario + "," + self.solicitudPendiente.idTaxi + ",# \n"
//    self.EnviarSocket(datos)
//    MensajeEspera.text = "Procesando..."
//    AlertaEsperaView.isHidden = false
    self.detallesView.removeShadow()
    self.bannerBottomConstraint.constant = -(responsive.heightFloatPercent(percent:  UIScreen.main.bounds.height > 750 ? 40 : 52) + 15)
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
    self.bannerBottomConstraint.constant = -(responsive.heightFloatPercent(percent: UIScreen.main.bounds.height > 750 ? 23 : 28) + 5)
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
