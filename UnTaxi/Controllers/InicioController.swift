//
//  InicioController.swift
//  UnTaxi
//
//  Created by Done Santana on 2/3/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import UIKit
import CoreLocation
import SocketIO
import Canvas
import AddressBook
import AVFoundation
import CoreData
import Mapbox
//import PaymentezSDK

struct MenuData {
  var imagen: String
  var title: String
}

class InicioController: BaseController, CLLocationManagerDelegate, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, UIApplicationDelegate, UIGestureRecognizerDelegate {
  var coreLocationManager : CLLocationManager!
  var origenAnotacion = MGLPointAnnotation()
  var taxiLocation = MGLPointAnnotation()
  var taxi : Taxi!
  var login = [String]()
  var idusuario : String = ""
  var contador = 0
  var opcionAnterior : IndexPath!
  var evaluacion: CEvaluacion!
  var transporteIndex: Int! = -1
  var tipoTransporte: String!
  var isVoucherSelected = false
  var apiService = ApiService()
  var destinoPactadas:[DireccionesPactadas] = []
  
  var origenCell = Bundle.main.loadNibNamed("OrigenCell", owner: self, options: nil)?.first as! OrigenViewCell
  var destinoCell = Bundle.main.loadNibNamed("DestinoCell", owner: self, options: nil)?.first as! DestinoCell
  var ofertaDataCell = Bundle.main.loadNibNamed("OfertaDataCell", owner: self, options: nil)?.first as! OfertaDataViewCell
  var voucherCell = Bundle.main.loadNibNamed("VoucherCell", owner: self, options: nil)?.first as! VoucherViewCell
  var contactoCell = Bundle.main.loadNibNamed("ContactoCell", owner: self, options: nil)?.first as! ContactoViewCell
  var pactadaCell = Bundle.main.loadNibNamed("PactadaCell", owner: self, options: nil)?.first as! PactadaCell
  
  var formularioDataCellList: [UITableViewCell] = []
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
  var menuArray = [[MenuData(imagen: "solicitud", title: "Viajes en proceso"),MenuData(imagen: "historial", title: "Historial de Viajes")],[MenuData(imagen: "callCenter", title: "Operadora"),MenuData(imagen: "terminos", title: "Términos y condiciones"),MenuData(imagen: "compartir", title: "Compartir app")],[MenuData(imagen: "salir2", title: "Salir")]]//,MenuData(imagen: "card", title: "Mis tarjetas")
  
  var ofertaItem = UITabBarItem(title: "Oferta", image: UIImage(named: "tipoOferta"), selectedImage: UIImage(named: "tipoOferta"))
  var taximetroItem = UITabBarItem(title: "Taxímetro", image: UIImage(named: "tipoTaximetro"), selectedImage: UIImage(named: "tipoTaximetro"))
  var horasItem = UITabBarItem(title: "Por Horas", image: UIImage(named: "tipoHoras"), selectedImage: UIImage(named: "tipoHoras"))
  var pactadaItem = UITabBarItem(title: "Pactada", image: UIImage(named: "tipoPactada"), selectedImage: UIImage(named: "tipoPactada"))
  
  //variables de interfaz
  var TelefonoContactoText: UITextField!
  
  var TablaDirecciones = UITableView()
  
  //CONSTRAINTS
  var btnViewTop: NSLayoutConstraint!
  @IBOutlet weak var formularioSolicitudHeight: NSLayoutConstraint!
  
  //MAP
  @IBOutlet weak var mapView: MGLMapView!
  
  
  @IBOutlet weak var origenIcono: UIImageView!

  @IBOutlet weak var headerView: UIView!
  
  @IBOutlet weak var LocationBtn: UIButton!
  @IBOutlet weak var SolicitarBtn: UIButton!
  @IBOutlet weak var formularioSolicitud: UIView!
  @IBOutlet weak var SolicitudView: UIView!

  
  
  //MENU BUTTONS
  @IBOutlet weak var MenuView1: UIView!
  @IBOutlet weak var MenuTable: UITableView!
  @IBOutlet weak var NombreUsuario: UILabel!
  @IBOutlet weak var TransparenciaView: UIVisualEffectView!
  @IBOutlet weak var yapaText: UILabel!
  @IBOutlet weak var userProfilePhoto: UIImageView!
  
  @IBOutlet weak var SolPendientesView: UIView!
  
  @IBOutlet weak var AlertaEsperaView: UIView!
  @IBOutlet weak var MensajeEspera: UITextView!
  @IBOutlet weak var updateOfertaView: UIView!
  @IBOutlet weak var SendOferta: UIButton!
  @IBOutlet weak var newOfertaText: UILabel!
  @IBOutlet weak var up25: UIButton!
  @IBOutlet weak var down25: UIButton!
  @IBOutlet weak var solicitudInProcess: UILabel!
  
  @IBOutlet weak var CancelarSolicitudProceso: UIButton!
  
  @IBOutlet weak var solicitudFormTable: UITableView!
  
  @IBOutlet weak var addressView: UIView!
  @IBOutlet weak var addressPicker: UIPickerView!
  
  @IBOutlet weak var destinoAddressView: UIView!
  @IBOutlet weak var destinoAddressPicker: UIPickerView!
  
  @IBOutlet weak var menuHeaderHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var menuCenterDistance: NSLayoutConstraint!
  @IBOutlet weak var yapaTextHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var tabBar: UITabBar!
  
  @IBOutlet weak var llamar911Btn: UIButton!
  @IBOutlet weak var panicoView: UIView!
  
  
  override func viewDidLoad() {
    super.hideMenuBtn = false
    super.hideCloseBtn = false
    super.barTitle = Customization.nameShowed
    super.topMenu.bringSubviewToFront(self.formularioSolicitud)
    super.viewDidLoad()
    
    self.tabBar.delegate = self
    self.tabBar.layer.borderColor = UIColor.clear.cgColor
    self.tabBar.clipsToBounds = true
    mapView.delegate = self
    mapView.automaticallyAdjustsContentInset = true
    coreLocationManager = CLLocationManager()
    coreLocationManager.delegate = self
    self.contactoCell.contactoNameText.delegate = self
    self.contactoCell.telefonoText.delegate = self
    self.origenCell.origenText.delegate = self
    self.destinoCell.destinoText.delegate = self
    self.voucherCell.delegate = self
    self.voucherCell.referenciaText.delegate = self
    self.apiService.delegate = self
    
    self.addressPicker.delegate = self
    self.destinoAddressPicker.delegate = self
    
    self.navigationItem.title = Customization.nameShowed
    //solicitud de autorización para acceder a la localización del usuario
    self.NombreUsuario.text = "¡Hola, \(globalVariables.cliente.nombreApellidos.uppercased())!"
    self.NombreUsuario.textColor = Customization.textColor
    self.NombreUsuario.font = AppFont.subtitleFont
    globalVariables.cliente.cargarPhoto(imageView: self.userProfilePhoto)

    self.MenuTable.delegate = self
    self.MenuView1.layer.borderColor = UIColor.lightGray.cgColor
    self.MenuView1.layer.borderWidth = 0.3
    self.MenuView1.layer.masksToBounds = false
    self.menuHeaderHeightConstraint.constant = Responsive().heightFloatPercent(percent: 28)
    self.menuCenterDistance.constant = Responsive().heightFloatPercent(percent: 2)
    self.yapaTextHeightConstraint.constant = Responsive().heightFloatPercent(percent: 6)
    self.yapaText.addBorder(color: Customization.buttonActionColor)
    self.yapaText.font = AppFont.titleFont
    
    self.updateOfertaView.addShadow()
    self.AlertaEsperaView.addShadow()
    self.SolicitarBtn.addShadow()
    self.SolicitudView.addShadow()
    self.SendOferta.addShadow()
    self.LocationBtn.addShadow()
    self.llamar911Btn.addShadow()
    self.newOfertaText.addBorder(color: Customization.buttonActionColor)
    self.MensajeEspera.centerVertically()
    self.TransparenciaView.standardConfig()
    //    self.contactoCell.contactoNameText.setBottomBorder(borderColor: UIColor.lightGray)
    //    self.TelefonoContactoText.setBottomBorder(borderColor: UIColor.lightGray)
    
    //self.SolicitudView.addShadow()
    
    //MANTENER EL COLOR DE LOS ICONOS
    
    coreLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    coreLocationManager.startUpdatingLocation()  //Iniciar servicios de actualiación de localización del usuario
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado))
    tapGesture.delegate = self
    self.solicitudFormTable.addGestureRecognizer(tapGesture)
    
    let MenuTapGesture = UITapGestureRecognizer(target: self, action: #selector(ocultarMenu))
    self.TransparenciaView.addGestureRecognizer(MenuTapGesture)
    
    //INITIALIZING INTERFACES VARIABLES
    self.TelefonoContactoText = self.contactoCell.telefonoText
    self.voucherCell.initContent(isCorporativo: false)
    
    self.origenAnotacion.title = "origen"
    
    if let tempLocation = self.coreLocationManager.location?.coordinate{
      self.origenAnotacion.coordinate = tempLocation
    }else{
      self.origenAnotacion.coordinate = (CLLocationCoordinate2D(latitude: -2.173714, longitude: -79.921601))
      coreLocationManager.requestWhenInUseAuthorization()
    }
    self.initMapView()
    self.origenCell.initContent()
    self.destinoCell.initContent()
    self.origenCell.origenText.addTarget(self, action: #selector(textViewDidChange(_:)), for: .editingChanged)
    
    if globalVariables.appConfig.pactadas && globalVariables.cliente.idEmpresa != 0{
//      if self.tipoSolicitudSwitch.numberOfSegments == 3{
//        self.tipoSolicitudSwitch.insertSegment(withTitle: "Pactada", at: 3, animated: false)
//      }
      self.tabBar.setItems([self.ofertaItem, self.taximetroItem, self.horasItem, self.pactadaItem],animated: true)
//      if self.tabBar.items?.count == 3{
//
//      }
      
      self.socketEmit("direccionespactadas", datos: [
      "idempresa": globalVariables.cliente.idEmpresa!
      ] as [String: Any])
    }else{
      self.tabBar.setItems([self.ofertaItem, self.taximetroItem, self.horasItem],animated: true)
    }
  
    for item in self.tabBar.items!{
      if let image = item.image
      {
        item.image = image.withRenderingMode( .alwaysOriginal)
        item.selectedImage = item.selectedImage?.withRenderingMode(.alwaysOriginal)
      }
    }
    self.tabBar.selectedItem = self.tabBar.items![0] as UITabBarItem
    self.tabBar.selectionIndicatorImage = UIImage().createSelectionIndicator(color: Customization.buttonActionColor, size: CGSize(width: tabBar.frame.width/CGFloat(tabBar.items!.count), height: tabBar.frame.height), lineWidth: 2.0)
    self.addEnvirSolictudBtn()
    
    globalVariables.socket.on("disconnect"){data, ack in
      self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.Reconect), userInfo: nil, repeats: true)
    }
    
    //PEDIR PERMISO PARA MICROPHONE
    switch AVAudioSession.sharedInstance().recordPermission {
    case AVAudioSession.RecordPermission.granted:
      print("Permission granted")
    case AVAudioSession.RecordPermission.denied:
      print("Pemission denied")
      let locationAlert = UIAlertController (title: "Error de Micrófono", message: "Es necesario que active el micrófono de su dispositivo.", preferredStyle: .alert)
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
    
//    globalVariables.socket.on("connect"){data, ack in
//      let ColaHilos = OperationQueue()
//      let Hilos : BlockOperation = BlockOperation ( block: {
//        self.socketEventos()
//        self.timer.invalidate()
//      })
//      ColaHilos.addOperation(Hilos)
//      var read = "Vacio"
//      //var vista = ""
//      let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
//      do {
//        read = try NSString(contentsOfFile: filePath, encoding: String.Encoding.utf8.rawValue) as String
//      }catch {
//
//      }
//    }
    
    self.socketEventos()
    self.loadFormularioData()
    self.loadCallCenter()
    
    //self.apiService.listCardsAPIService()
    
  }
  
  override func viewDidAppear(_ animated: Bool){
    self.contactoCell.contactoNameText.setBottomBorder(borderColor: UIColor.black)
    self.contactoCell.telefonoText.setBottomBorder(borderColor: UIColor.black)
    //self.btnViewTop = NSLayoutConstraint(item: self.BtnsView, attribute: .top, relatedBy: .equal, toItem: self.origenCell.origenText, attribute: .bottom, multiplier: 1, constant: 0)
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    self.origenAnotacion.coordinate = (locations.last?.coordinate)!
    self.SolicitarBtn.isHidden = false
  }
  
 override func homeBtnAction(){
   self.MenuView1.isHidden = !self.MenuView1.isHidden
   self.MenuView1.startCanvasAnimation()
   self.TransparenciaView.isHidden = self.MenuView1.isHidden
   self.TransparenciaView.startCanvasAnimation()
   super.topMenu.isHidden = true
 }
  
  override func closeBtnAction() {
    self.panicoView.isHidden = false
    super.hideShowMenuBar(isHidden: true)
  }
 
  
  //MARK:- BOTONES GRAFICOS ACCIONES
  
  @IBAction func RelocateBtn(_ sender: Any) {
    self.origenAnotacion.coordinate = (self.coreLocationManager.location?.coordinate)!
    self.initMapView()
  }
  
  //SOLICITAR BUTTON
  @IBAction func Solicitar(_ sender: AnyObject) {
    //TRAMA OUT: #Posicion,idCliente,latorig,lngorig
    self.direccionDeCoordenada(mapView.centerCoordinate, directionText: self.origenCell.origenText)
    super.topMenu.isHidden = true
    self.addEnvirSolictudBtn()
    
    let data = [
      "idcliente": globalVariables.cliente.id!,
      "latitud": self.origenAnotacion.coordinate.latitude,
      "longitud": self.origenAnotacion.coordinate.longitude
      ] as [String: Any]
    
    self.socketEmit("cargarvehiculoscercanos", datos: data)
  }
  
  //Boton para Cancelar Carrera
  @IBAction func CancelarSol(_ sender: UIButton) {
    self.formularioSolicitud.isHidden = true
    self.voucherCell.referenciaText.endEditing(true)
    self.Inicio()
    self.origenCell.origenText.text?.removeAll()
    //    self.RecordarView.isHidden = true
    //    self.RecordarSwitch.isOn = false
    self.voucherCell.referenciaText.text?.removeAll()
    self.SolicitarBtn.isHidden = false
  }
  
  // CANCELAR LA SOL MIENTRAS SE ESPERA LA FONFIRMACI'ON DEL TAXI
  @IBAction func CancelarProcesoSolicitud(_ sender: AnyObject) {
    MostrarMotivoCancelacion(solicitud: globalVariables.solpendientes.last!)
  }
  
  @IBAction func cancelarSolicitudOferta(_ sender: Any) {
    MostrarMotivoCancelacion(solicitud: globalVariables.solpendientes.last!)
  }
  
  //  @IBAction func MostrarTelefonosCC(_ sender: AnyObject) {
  //    self.SolPendientesView.isHidden = true
  //    DispatchQueue.main.async {
  //      let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "CallCenter") as! CallCenterController
  //      vc.telefonosCallCenter = globalVariables.TelefonosCallCenter
  //      self.navigationController?.show(vc, sender: nil)
  //    }
  //  }
  //
  //  @IBAction func MostrarSolPendientes(_ sender: AnyObject) {
  //    if globalVariables.solpendientes.count > 0{
  //      DispatchQueue.main.async {
  //        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "ListaSolPdtes") as! SolicitudesTableController
  //        vc.solicitudesMostrar = globalVariables.solpendientes
  //        self.navigationController?.show(vc, sender: nil)
  //      }
  //    }else{
  //      self.SolPendientesView.isHidden = !self.SolPendientesView.isHidden
  //    }
  //  }
  //
  //  @IBAction func MapaMenu(_ sender: AnyObject) {
  //    Inicio()
  //  }
  
  @IBAction func closeSolicitudForm(_ sender: Any) {
    Inicio()
  }
  
  @IBAction func downOferta(_ sender: Any) {
    self.updateOfertaValue(value: -0.25)
    self.down25.isEnabled = Double(self.newOfertaText!.text!.dropFirst())! > Double(self.ofertaDataCell.valorOfertaText.text!.dropFirst())!
  }
  
  @IBAction func upOferta(_ sender: Any) {
    self.down25.isEnabled = true
    self.updateOfertaValue(value: +0.25)
  }
  @IBAction func enviarNuevoValorOferta(_ sender: Any) {
    //#RSO.id,idcliente,nuevovaloroferta,#
//    let datos = "#RSO,\(self.solicitudInProcess.text!),\(globalVariables.cliente.idCliente!),\(self.newOfertaText.text!),# \n"
//    print(datos)
//    self.EnviarSocket(datos)
    self.socketEmit("subiroferta", datos: globalVariables.solpendientes.first{$0.id == Int(self.solicitudInProcess.text!)}!.updateValorOferta(newValor: self.newOfertaText.text!))
  }
  
  @IBAction func tipoSolicitudSwitchChanged(_ sender: Any) {
//    self.updateOfertaView.isHidden =
//      !(self.tabBar.selectedItem == 0)
//    self.loadFormularioData()
  }
  
  @IBAction func showProfile(_ sender: Any) {
    let vc = R.storyboard.main.perfil()!
    self.navigationController?.show(vc, sender: nil)
  }
  
  @IBAction func hideAddressView(_ sender: Any) {
    self.addressView.isHidden = true
  }
  
  @IBAction func hideDestinoAddressView(_ sender: Any) {
    self.destinoAddressView.isHidden = true
  }
  
  @IBAction func takeOrigenAddress(_ sender: Any) {
    self.addressView.isHidden = true
  }
  
  @IBAction func takeDestinoAddress(_ sender: Any) {
    self.destinoAddressView.isHidden = true
  }
  
//  @IBAction func cerrarSesion(_ sender: Any) {
//    globalVariables.userDefaults.set(nil, forKey: "accessToken")
//    self.CloseAPP()
//  }
//
//  @IBAction func cerrarApp(_ sender: Any) {
//    self.CloseAPP()
//  }
  
  @IBAction func closePanicoView(_ sender: Any) {
    self.panicoView.isHidden = true
    super.hideShowMenuBar(isHidden: false)
  }
  
  @IBAction func llamar911(_ sender: Any) {
    if let url = URL(string: "tel://911") {
      UIApplication.shared.open(url)
    }
  }
  
  
}




