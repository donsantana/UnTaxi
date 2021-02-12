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
import MapboxSearch
import MapboxSearchUI
import MapboxGeocoder
import FloatingPanel
import SideMenu
//import PaymentezSDK

struct MenuData {
  var imagen: String
  var title: String
}

class InicioController: BaseController, CLLocationManagerDelegate, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, UIApplicationDelegate, UIGestureRecognizerDelegate {
  var socketService = SocketService()
  var coreLocationManager : CLLocationManager!
  var origenAnnotation = MGLPointAnnotation()
  var destinoAnnotation = MGLPointAnnotation()
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
  var pagoCell = Bundle.main.loadNibNamed("PagoCell", owner: self, options: nil)?.first as! PagoViewCell
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
  var sideMenu: SideMenuNavigationController?
  
  var menuArray = [[MenuData(imagen: "solicitud", title: "Viajes en proceso"),MenuData(imagen: "historial", title: "Historial de Viajes")],[MenuData(imagen: "callCenter", title: "Operadora"),MenuData(imagen: "terminos", title: "Términos y condiciones"),MenuData(imagen: "compartir", title: "Compartir app")],[MenuData(imagen: "salir2", title: "Salir")]]//,MenuData(imagen: "card", title: "Mis tarjetas")
  
  var ofertaItem = UITabBarItem(title: "", image: UIImage(named: "tipoOferta"), selectedImage: UIImage(named: "tipoOfertaSelected"))
  var taximetroItem = UITabBarItem(title: "", image: UIImage(named: "tipoTaximetro"), selectedImage: UIImage(named: "tipoTaximetroSelected"))
  var horasItem = UITabBarItem(title: "", image: UIImage(named: "tipoHoras"), selectedImage: UIImage(named: "tipoHorasSelected"))
  var pactadaItem = UITabBarItem(title: "", image: UIImage(named: "tipoPactada"), selectedImage: UIImage(named: "tipoPactadaSelected"))
  
  //variables de interfaz
  
  var TablaDirecciones = UITableView()
  
  let geocoder = Geocoder.shared
  
  let openMapBtn = UIButton(type: UIButton.ButtonType.system)
  
  var searchingAddress = "origen"

  //CONSTRAINTS
  var btnViewTop: NSLayoutConstraint!
  @IBOutlet weak var formularioSolicitudHeight: NSLayoutConstraint!
  @IBOutlet weak var formularioSolicitudBottomConstraint: NSLayoutConstraint!
  
  //MAP
  let searchEngine = SearchEngine()
  var searchController: MapboxSearchController!
  var panelController: MapboxPanelController!
  
  var solicitudPanel = FloatingPanelController()
  var nuevaSolicitud: Solicitud?
  
  @IBOutlet weak var mapView: MGLMapView!
  
  @IBOutlet weak var locationIcono: UIImageView!

  @IBOutlet weak var LocationBtn: UIButton!
  @IBOutlet weak var SolicitudView: UIView!
  
  
  
  //MENU BUTTONS
  @IBOutlet weak var TransparenciaView: UIVisualEffectView!
  
  @IBOutlet weak var solicitudFormTable: UITableView!
  
  @IBOutlet weak var addressView: UIView!
  @IBOutlet weak var addressPicker: UIPickerView!
  
  @IBOutlet weak var destinoAddressView: UIView!
  @IBOutlet weak var destinoAddressPicker: UIPickerView!
  
  
  @IBOutlet weak var tabBar: UITabBar!

  @IBOutlet weak var panicoView: UIView!
  
  @IBOutlet weak var mapBottomConstraint: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.hideMenuBtn = false
    super.hideCloseBtn = false
    super.viewDidLoad()
    
    self.solicitudFormTable.rowHeight = UITableView.automaticDimension
    self.checkForNewVersions()
    self.socketService.delegate = self
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
    self.pagoCell.delegate = self
    self.pagoCell.referenciaText.delegate = self
    self.apiService.delegate = self
    self.addressPicker.delegate = self
    self.destinoAddressPicker.delegate = self
    self.origenAnnotation.subtitle = "origen"
    self.destinoAnnotation.subtitle = "destino"
    
    //MARK:- MENU INITIALIZATION
    self.sideMenu = self.addSideMenu()
  
    self.SolicitudView.addShadow()

    self.LocationBtn.addShadow()

    self.TransparenciaView.standardConfig()
    
    //MARK:- MAPBOX SEARCH ADDRESS BAR
    self.searchController = MapboxSearchController()
    
    self.panelController = MapboxPanelController(rootViewController: self.searchController)
    func currentLocation() -> CLLocationCoordinate2D? { mapboxSFOfficeCoordinate }
    let mapboxSFOfficeCoordinate = CLLocationCoordinate2D(latitude: 37.7911551, longitude: -122.3966103)
    
    searchController.delegate = self
    
    //searchEngine.delegate = self
    
    //MARK:- PANEL DEFINITION
    //letsolicitudPanel = FloatingPanelController()
    self.solicitudPanel.delegate = self
    guard let contentPanel = storyboard?.instantiateViewController(withIdentifier: "SolicitudPanel") as? SolicitudPanel else{
      return
    }
    
    self.solicitudPanel.set(contentViewController: contentPanel)
    //solicitudPanel.addPanel(toParent: self)
    
    coreLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    coreLocationManager.startUpdatingLocation()  //Iniciar servicios de actualiación de localización del usuario
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado))
    tapGesture.delegate = self
    self.solicitudFormTable.addGestureRecognizer(tapGesture)
    
    let mapTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideSearchPanel))
    mapTapGesture.delegate = self
    self.mapView.addGestureRecognizer(mapTapGesture)
    
    //INITIALIZING INTERFACES VARIABLES
    self.pagoCell.initContent(isCorporativo: true)
    
    if let tempLocation = self.coreLocationManager.location?.coordinate{
      globalVariables.cliente.annotation.coordinate = tempLocation
      self.origenAnnotation.coordinate = tempLocation
      coreLocationManager.stopUpdatingLocation()
      self.initMapView()
    }else{
      globalVariables.cliente.annotation.coordinate = (CLLocationCoordinate2D(latitude: -2.173714, longitude: -79.921601))
      coreLocationManager.requestWhenInUseAuthorization()
    }
    
    self.origenCell.initContent()
    self.destinoCell.initContent()
    self.origenCell.origenText.addTarget(self, action: #selector(textViewDidChange(_:)), for: .editingChanged)

    //self.tabBar.selectionIndicatorImage = UIImage().createSelectionIndicator(color: Customization.buttonActionColor, size: CGSize(width: tabBar.frame.width/CGFloat(tabBar.items!.count), height: tabBar.frame.height), lineWidth: 2.0)
    
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

    self.socketService.initListenEventos()
    self.initTipoSolicitudBar()
    //self.loadFormularioData()
    
    //self.apiService.listCardsAPIService()

  }
  
  override func viewDidAppear(_ animated: Bool){
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    self.contactoCell.contactoNameText.setBottomBorder(borderColor: UIColor.black)
    self.contactoCell.telefonoText.setBottomBorder(borderColor: UIColor.black)
    //self.btnViewTop = NSLayoutConstraint(item: self.BtnsView, attribute: .top, relatedBy: .equal, toItem: self.origenCell.origenText, attribute: .bottom, multiplier: 1, constant: 0)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    self.navigationController?.setNavigationBarHidden(true, animated: false)
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    globalVariables.cliente.annotation.coordinate = (locations.last?.coordinate)!
    //self.origenAnnotation.coordinate = (locations.last?.coordinate)!
    //self.initMapView()
  }
  
 override func homeBtnAction(){
  present(sideMenu!, animated: true)
 }
  
  override func closeBtnAction() {
    var panicoViewController = storyboard?.instantiateViewController(withIdentifier: "panicoChildVC") as! PanicoController
    self.addChild(panicoViewController)
    self.view.addSubview(panicoViewController.view)
  }
 
  
  //MARK:- BOTONES GRAFICOS ACCIONES
  
  @IBAction func RelocateBtn(_ sender: Any) {
    self.initMapView()
  }
  
  //SOLICITAR BUTTON
  @IBAction func Solicitar(_ sender: AnyObject) {
    //TRAMA OUT: #Posicion,idCliente,latorig,lngorig
//    self.loadFormularioData()
//    let data = [
//      "idcliente": globalVariables.cliente.id!,
//      "latitud": self.origenAnnotation.coordinate.latitude,
//      "longitud": self.origenAnnotation.coordinate.longitude
//      ] as [String: Any]
//    socketService.socketEmit("cargarvehiculoscercanos", datos: data)
  }
  
  //Boton para Cancelar Carrera
  @IBAction func CancelarSol(_ sender: UIButton) {
    self.SolicitudView.isHidden = true
    self.pagoCell.referenciaText.endEditing(true)
    self.Inicio()
    self.origenCell.origenText.text?.removeAll()
    //    self.RecordarView.isHidden = true
    //    self.RecordarSwitch.isOn = false
    self.pagoCell.referenciaText.text?.removeAll()
  }
  
  @IBAction func closeSolicitudForm(_ sender: Any) {
    Inicio()
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
  
  @IBAction func closeView(_ sender: Any) {
    if self.searchingAddress == "origen" {
      self.origenAnnotation.updateAnnotation(newCoordinate: self.origenAnnotation.coordinate, newTitle: self.origenAnnotation.title!)
    }else{
      self.destinoAnnotation.updateAnnotation(newCoordinate: self.origenAnnotation.coordinate, newTitle: self.origenAnnotation.title!)
    }
    self.hideSearchPanel()
    self.getDestinoFromSearch(annotation: self.origenAnnotation)
  }
  
  @IBAction func getAddressText(_ sender: Any) {
    if self.searchingAddress == "destino"{
      if !(self.panelController.state == .collapsed){
        self.destinoAnnotation.updateAnnotation(newCoordinate: self.origenAnnotation.coordinate, newTitle: self.searchController.searchEngine.query)
        self.getDestinoFromSearch(annotation: self.destinoAnnotation)
      }else{
        self.getDestinoFromSearch(annotation: self.destinoAnnotation)
      }
    }else{
      if !(self.panelController.state == .collapsed){
        self.origenAnnotation.title = self.searchController.searchEngine.query
      }else{
        self.getAddressFromCoordinate(self.origenAnnotation)
      }
      self.origenCell.origenText.text = self.origenAnnotation.title
    }
    self.hideSearchPanel()
  } 
}




