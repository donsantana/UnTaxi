//
//  InicioController.swift
//  UnTaxi
//
//  Created by Done Santana on 2/3/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import SocketIO
import Canvas
import AddressBook
import AVFoundation
import CoreData
import GoogleMobileAds

struct MenuData {
  var imagen: String
  var title: String
}

class InicioController: UIViewController, CLLocationManagerDelegate, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, UIApplicationDelegate, UIGestureRecognizerDelegate {
  var coreLocationManager : CLLocationManager!
  var miposicion = MKPointAnnotation()
  var origenAnotacion = MKPointAnnotation()
  var taxiLocation = MKPointAnnotation()
  var taxi : CTaxi!
  var login = [String]()
  var idusuario : String = ""
  var indexselect = Int()
  var contador = 0
  var centro = CLLocationCoordinate2D()
  var TelefonosCallCenter = [CTelefono]()
  var opcionAnterior : IndexPath!
  var evaluacion: CEvaluacion!
  
  //var SMSVoz = CSMSVoz()
  
  //Reconect Timer
  var timer = Timer()
  //var fechahora: String!
  
  
  
  //Timer de Envio
  var EnviosCount = 0
  var emitTimer = Timer()
  
  var keyboardHeight:CGFloat!
  
  var DireccionesArray = [[String]]()//[["Dir 1", "Ref1"],["Dir2","Ref2"],["Dir3", "Ref3"],["Dir4","Ref4"],["Dir 5", "Ref5"]]//["Dir 1", "Dir2"]
  
  //Menu variables
  var MenuArray = [MenuData(imagen: "solicitud", title: "En proceso"), MenuData(imagen: "operadora", title: "Call center"),MenuData(imagen: "clave", title: "Perfil"),MenuData(imagen: "compartir", title: "Compartir app"), MenuData(imagen: "sesion", title: "Cerrar Sesion"), MenuData(imagen: "salir2", title: "Salir")]
  //variables de interfaz
  
  
  //CONSTRAINTS
  var btnViewTop: NSLayoutConstraint!
  
  @IBOutlet weak var origenIcono: UIImageView!
  @IBOutlet weak var mapaVista: MKMapView!
  @IBOutlet weak var adsBannerView: GADBannerView!
  
  
  
  //@IBOutlet weak var destinoText: UITextField!
  @IBOutlet weak var origenText: UITextField!
  @IBOutlet weak var referenciaText: UITextField!
  @IBOutlet weak var TablaDirecciones: UITableView!
  @IBOutlet weak var RecordarView: UIView!
  @IBOutlet weak var RecordarSwitch: UISwitch!
  @IBOutlet weak var BtnsView: UIView!
  @IBOutlet weak var ContactoView: UIView!
  @IBOutlet weak var NombreContactoText: UITextField!
  @IBOutlet weak var TelefonoContactoText: UITextField!
  
  
  
  @IBOutlet weak var LocationBtn: UIButton!
  @IBOutlet weak var SolicitarBtn: UIButton!
  @IBOutlet weak var formularioSolicitud: UIView!
  @IBOutlet weak var SolicitudView: CSAnimationView!
  
  @IBOutlet weak var EnviarSolBtn: UIButton!
  
  
  //MENU BUTTONS
  @IBOutlet weak var MenuView1: UIView!
  @IBOutlet weak var MenuTable: UITableView!
  @IBOutlet weak var NombreUsuario: UILabel!
  @IBOutlet weak var TransparenciaView: UIVisualEffectView!
  
  
  @IBOutlet weak var SolPendientesView: UIView!
  
  
  
  @IBOutlet weak var AlertaEsperaView: UIView!
  @IBOutlet weak var MensajeEspera: UITextView!
  
  
  //Voucher
  @IBOutlet weak var VoucherView: UIView!
  @IBOutlet weak var VoucherCheck: UISwitch!
  @IBOutlet weak var VoucherEmpresaName: UILabel!
  @IBOutlet weak var destinoText: UITextField!
  
  
  @IBOutlet weak var CancelarSolicitudProceso: UIButton!
  
  
  //CUSTOM CONSTRAINTS
  @IBOutlet weak var textFieldHeight: NSLayoutConstraint!
  @IBOutlet weak var recordarViewBottom: NSLayoutConstraint!
  @IBOutlet weak var origenTextBottom: NSLayoutConstraint!
  @IBOutlet weak var datosSolictudBottom: NSLayoutConstraint!
  @IBOutlet weak var contactoViewTop: NSLayoutConstraint!
  @IBOutlet weak var contactViewHeight: NSLayoutConstraint!
  @IBOutlet weak var voucherViewTop: NSLayoutConstraint!
  
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //LECTURA DEL FICHERO PARA AUTENTICACION
    
    mapaVista.delegate = self
    coreLocationManager = CLLocationManager()
    coreLocationManager.delegate = self
    self.referenciaText.delegate = self
    self.NombreContactoText.delegate = self
    self.TelefonoContactoText.delegate = self
    self.origenText.delegate = self
    self.destinoText.delegate = self
    
    //        //ADS BANNER VIEW
    //        self.adsBannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
    //        self.adsBannerView.rootViewController = self
    //        self.adsBannerView.load(GADRequest())
    //        self.adsBannerView.delegate = self
    
    //solicitud de autorización para acceder a la localización del usuario
    self.NombreUsuario.text = globalVariables.cliente.nombreApellidos
    
    self.MenuTable.delegate = self
    self.MenuView1.layer.borderColor = UIColor.lightGray.cgColor
    self.MenuView1.layer.borderWidth = 0.3
    self.MenuView1.layer.masksToBounds = false
    self.NombreContactoText.setBottomBorder(borderColor: UIColor.gray)
    self.TelefonoContactoText.setBottomBorder(borderColor: UIColor.gray)
    
    //self.MenuView1.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
    
    coreLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    coreLocationManager.startUpdatingLocation()  //Iniciar servicios de actualiación de localización del usuario
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado))
    tapGesture.delegate = self
    self.SolicitudView.addGestureRecognizer(tapGesture)
    
    let MenuTapGesture = UITapGestureRecognizer(target: self, action: #selector(ocultarMenu))
    self.TransparenciaView.addGestureRecognizer(MenuTapGesture)
    
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    //Calculate the custom constraints
    var spaceBetween = CGFloat(20)
    if UIScreen.main.bounds.height < 736{
      self.textFieldHeight.constant = 40
      spaceBetween = 10
    }else{
      self.textFieldHeight.constant = 45
    }
    
    //self.recordarViewBottom.constant = -spaceBetween
    //self.origenTextBottom.constant = -spaceBetween
    self.datosSolictudBottom.constant = -spaceBetween
    self.contactoViewTop.constant = spaceBetween
    self.voucherViewTop.constant = spaceBetween
    
    if let tempLocation = self.coreLocationManager.location?.coordinate{
      self.origenAnotacion.coordinate = (coreLocationManager.location?.coordinate)!
      self.origenAnotacion.title = "origen"
    }else{
      coreLocationManager.requestWhenInUseAuthorization()
      self.origenAnotacion.coordinate = (CLLocationCoordinate2D(latitude: -2.173714, longitude: -79.921601))
    }
    
    let span = MKCoordinateSpan.init(latitudeDelta: 0.005, longitudeDelta: 0.005)
    let region = MKCoordinateRegion(center: self.origenAnotacion.coordinate, span: span)
    self.mapaVista.setRegion(region, animated: true)
    
    if globalVariables.socket.status.active{
      let ColaHilos = OperationQueue()
      let Hilos : BlockOperation = BlockOperation (block: {
        self.SocketEventos()
        self.timer.invalidate()
        let url = "#U,# \n"
        self.EnviarSocket(url)
        let telefonos = "#Telefonos,# \n"
        self.EnviarSocket(telefonos)
        let datos = "OT"
        self.EnviarSocket(datos)
      })
      ColaHilos.addOperation(Hilos)
    }else{
      self.Reconect()
    }
    
    //self.referenciaText.enablesReturnKeyAutomatically = false
    //self.origenText.delegate = self
    self.TablaDirecciones.delegate = self
    
    self.origenText.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    
    //PEDIR PERMISO PARA EL MICROPHONO
    switch AVAudioSession.sharedInstance().recordPermission {
    case AVAudioSession.RecordPermission.granted:
      print("Permission granted")
    case AVAudioSession.RecordPermission.denied:
      print("Pemission denied")
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
  
  override func viewDidAppear(_ animated: Bool){
    self.NombreContactoText.setBottomBorder(borderColor: UIColor.black)
    self.TelefonoContactoText.setBottomBorder(borderColor: UIColor.black)
    self.btnViewTop = NSLayoutConstraint(item: self.BtnsView, attribute: .top, relatedBy: .equal, toItem: self.origenText, attribute: .bottom, multiplier: 1, constant: 0)
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    self.miposicion.coordinate = (locations.last?.coordinate)!
    self.SolicitarBtn.isHidden = false
  }
  

  //MARK:- BOTONES GRAFICOS ACCIONES
  @IBAction func MostrarMenu(_ sender: Any) {
    self.MenuView1.isHidden = !self.MenuView1.isHidden
    self.MenuView1.startCanvasAnimation()
    self.TransparenciaView.isHidden = self.MenuView1.isHidden
    //self.Inicio()
    self.TransparenciaView.startCanvasAnimation()
    
  }
  @IBAction func SalirApp(_ sender: Any) {
    let fileAudio = FileManager()
    let AudioPath = NSHomeDirectory() + "/Library/Caches/Audio"
    do {
      try fileAudio.removeItem(atPath: AudioPath)
    }catch{
    }
    let datos = "#SocketClose," + globalVariables.cliente.idCliente + ",# \n"
    EnviarSocket(datos)
    exit(3)
  }
  
  @IBAction func RelocateBtn(_ sender: Any) {
    let span = MKCoordinateSpan.init(latitudeDelta: 0.005, longitudeDelta: 0.005)
    let region = MKCoordinateRegion(center: self.origenAnotacion.coordinate, span: span)
    self.mapaVista.setRegion(region, animated: true)
    
  }
  //SOLICITAR BUTTON
  @IBAction func Solicitar(_ sender: AnyObject) {
    //TRAMA OUT: #Posicion,idCliente,latorig,lngorig
    self.origenAnotacion.coordinate = self.miposicion.coordinate
    let datos = "#Posicion," + globalVariables.cliente.idCliente + "," + "\(self.origenAnotacion.coordinate.latitude)," + "\(self.origenAnotacion.coordinate.longitude)," + "# \n"
    EnviarSocket(datos)
    
  }
  
  //Voucher check
  @IBAction func SwicthVoucher(_ sender: Any) {
//    if self.VoucherCheck.isOn{
//      self.destinoText.isHidden = false
//      self.destinoText.becomeFirstResponder()
//    }else{
//      self.destinoText.isHidden = true
//      self.destinoText.resignFirstResponder()
//    }
  }
  
  //Aceptar y Enviar solicitud desde formulario solicitud
  @IBAction func AceptarSolicitud(_ sender: AnyObject) {
    
    if self.destinoText.text!.isEmpty{
      let alertaDos = UIAlertController (title: "Dirección de Destino", message: "La dirección de destino es un campo requerido para que su carrera sea aceptada.", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        self.destinoText.becomeFirstResponder()
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }else{
      if !(self.origenText.text?.isEmpty)! {
        var voucher = "0"
        let origen = self.cleanTextField(textfield: self.origenText)
        
        let referencia = self.cleanTextField(textfield: self.referenciaText)
        
        let destino = self.cleanTextField(textfield: self.destinoText)
        
        let nombreContactar = self.NombreContactoText.text!.isEmpty ? globalVariables.cliente.nombreApellidos : self.cleanTextField(textfield: self.NombreContactoText)
        
        let telefonoContactar = self.TelefonoContactoText.text!.isEmpty ? globalVariables.cliente.user : self.cleanTextField(textfield: self.TelefonoContactoText)
        
        let clienteSolicitud = self.NombreContactoText.text!.isEmpty ? globalVariables.cliente : CCliente(idUsuario: globalVariables.cliente.idUsuario, idcliente: globalVariables.cliente.idCliente, user: telefonoContactar!, nombre: nombreContactar!, email: globalVariables.cliente.email, empresa: globalVariables.cliente.empresa,foto: "<null>")
        
        mapaVista.removeAnnotations(mapaVista.annotations)
        let nuevaSolicitud = Solicitud()
        
        nuevaSolicitud.DatosCliente(cliente: clienteSolicitud!)
        
//        nuevaSolicitud.DatosSolicitud(idSolicitud: origen, fechaHora: referencia, dirOrigen: destino,referenciaOrigen: Double(origenAnotacion.coordinate.latitude), dirDestino: Double(origenAnotacion.coordinate.longitude), latOrigen: "0", lngOrigen: "0",latDestino: "")
        
        if self.VoucherView.isHidden == false && self.VoucherCheck.isOn{
          voucher = "1"
        }
        
        if self.RecordarView.isHidden == false && self.RecordarSwitch.isOn{
          let newFavorita = [self.origenText.text, referenciaText.text]
          self.GuardarFavorita(newFavorita: newFavorita as! [String])
        }
        
        self.CrearSolicitud(nuevaSolicitud,voucher: voucher)
        DibujarIconos([self.origenAnotacion])
        view.endEditing(true)
      }else{
        
      }
    }
    //        if !(self.NombreContactoText.text?.isEmpty)! && (self.TelefonoContactoText.text?.isEmpty)!{
    //            let alertaDos = UIAlertController (title: "Contactar a otra persona", message: "Debe teclear el número de teléfono de la persona que el conductor debe contactar.", preferredStyle: .alert)
    //            alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
    //
    //            }))
    //            self.present(alertaDos, animated: true, completion: nil)
    //        }else{
    //            if (!(self.origenText.text?.isEmpty)! && self.TelefonoContactoText.text != "Escriba el nombre del contacto" && self.TelefonoContactoText.text != "Número de teléfono incorrecto"){
    //                var voucher = "0"
    //                var recordar = "0"
    //                var origen = self.origenText.text!.uppercased()
    //                origen = origen.replacingOccurrences(of: "Ñ", with: "N",options: .regularExpression, range: nil)
    //                origen = origen.replacingOccurrences(of: "[,.]", with: "-",options: .regularExpression, range: nil)
    //                origen = origen.replacingOccurrences(of: "[\n]", with: " ",options: .regularExpression, range: nil)
    //                origen = origen.replacingOccurrences(of: "[#]", with: "No",options: .regularExpression, range: nil)
    //                origen = origen.folding(options: .diacriticInsensitive, locale: .current)
    //
    //                self.referenciaText.endEditing(true)
    //                var referencia = self.referenciaText.text!.uppercased()
    //                referencia = referencia.replacingOccurrences(of: "Ñ", with: "N",options: .regularExpression, range: nil)
    //                referencia = referencia.replacingOccurrences(of: "[,.]", with: "-",options: .regularExpression, range: nil)
    //                referencia = referencia.replacingOccurrences(of: "[\n]", with: " ",options: .regularExpression, range: nil)
    //                referencia = referencia.replacingOccurrences(of: "[#]", with: "No",options: .regularExpression, range: nil)
    //                referencia = referencia.folding(options: .diacriticInsensitive, locale: .current)
    //
    //                mapaVista.removeAnnotations(self.mapaVista.annotations)
    //                let nuevaSolicitud = Solicitud()
    //                if !(NombreContactoText.text?.isEmpty)!{
    //                    nuevaSolicitud.DatosOtroCliente(clienteId: globalVariables.cliente.idCliente, telefono: self.TelefonoContactoText.text!, nombre: self.NombreContactoText.text!)
    //                }else{
    //                    nuevaSolicitud.DatosCliente(cliente: globalVariables.cliente)
    //                }
    //                nuevaSolicitud.DatosSolicitud(dirorigen: origen, referenciaorigen: referencia, dirdestino: "null", latorigen: String(Double(origenAnotacion.coordinate.latitude)), lngorigen: String(Double(origenAnotacion.coordinate.longitude)), latdestino: "0.0", lngdestino: "0.0",FechaHora: "null")
    //                if self.VoucherView.isHidden == false && self.VoucherCheck.isOn{
    //                    voucher = "1"
    //                }
    //                if self.RecordarView.isHidden == false && self.RecordarSwitch.isOn{
    //                    let newFavorita = [self.origenText.text, referenciaText.text]
    //                    self.GuardarFavorita(newFavorita: newFavorita as! [String])
    //                }
    //                self.CrearSolicitud(nuevaSolicitud,voucher: voucher)
    //                self.RecordarView.isHidden = true
    //                //self.CancelarSolicitudProceso.isHidden = false
    //            }else{
    //
    //            }
    //        }
  }
  
  //Boton para Cancelar Carrera
  @IBAction func CancelarSol(_ sender: UIButton) {
    self.formularioSolicitud.isHidden = true
    self.referenciaText.endEditing(true)
    self.Inicio()
    self.origenText.text?.removeAll()
    self.RecordarView.isHidden = true
    self.RecordarSwitch.isOn = false
    self.referenciaText.text?.removeAll()
    self.SolicitarBtn.isHidden = false
  }
  
  // CANCELAR LA SOL MIENTRAS SE ESPERA LA FONFIRMACI'ON DEL TAXI
  @IBAction func CancelarProcesoSolicitud(_ sender: AnyObject) {
    MostrarMotivoCancelacion()
  }
  
  @IBAction func MostrarTelefonosCC(_ sender: AnyObject) {
    self.SolPendientesView.isHidden = true
    DispatchQueue.main.async {
      let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "CallCenter") as! CallCenterController
      vc.telefonosCallCenter = self.TelefonosCallCenter
      self.navigationController?.show(vc, sender: nil)
    }
    
  }
  
  @IBAction func MostrarSolPendientes(_ sender: AnyObject) {
    if globalVariables.solpendientes.count > 0{
      DispatchQueue.main.async {
        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "ListaSolPdtes") as! SolicitudesTableController
        vc.solicitudesMostrar = globalVariables.solpendientes
        self.navigationController?.show(vc, sender: nil)
      }
    }else{
      self.SolPendientesView.isHidden = !self.SolPendientesView.isHidden
    }
  }
  
  @IBAction func MapaMenu(_ sender: AnyObject) {
    Inicio()
  }
  
}




