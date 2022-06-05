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

class InicioController: BaseController, CLLocationManagerDelegate, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, UIApplicationDelegate, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
  var socketService = SocketService.shared
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
  var apiService = ApiService.shared
  var destinoPactadas:[DireccionesPactadas] = []
  var searchAddressList:[Address] = []{
    didSet{
      DispatchQueue.main.async {
        self.addressTableView.reloadData()
      }
    }
  }
  
	var origenCell = Bundle.main.loadNibNamed("OrigenCell", owner: InicioController.self, options: nil)?.first as! OrigenViewCell
	var destinoCell = Bundle.main.loadNibNamed("DestinoCell", owner: InicioController.self, options: nil)?.first as! DestinoCell
	var ofertaDataCell = Bundle.main.loadNibNamed("OfertaDataCell", owner: InicioController.self, options: nil)?.first as! OfertaDataViewCell
	var pagoCell = Bundle.main.loadNibNamed("PagoCell", owner: InicioController.self, options: nil)?.first as! PagoViewCell
	var contactoCell = Bundle.main.loadNibNamed("ContactoCell", owner: InicioController.self, options: nil)?.first as! ContactoViewCell
	var pactadaCell = Bundle.main.loadNibNamed("PactadaCell", owner: InicioController.self, options: nil)?.first as! PactadaCell
  
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
  
  var ofertaItem = UITabBarItem(title: "", image: UIImage(named: "tipoOferta"), selectedImage: UIImage(named: "tipoOferta")!.addBorder(radius: 10, color: CustomAppColor.tabItemBorderColor))
  var taximetroItem = UITabBarItem(title: "", image: UIImage(named: "tipoTaximetro"), selectedImage: UIImage(named: "tipoTaximetro")!.addBorder(radius: 10, color: CustomAppColor.tabItemBorderColor))
  var horasItem = UITabBarItem(title: "", image: UIImage(named: "tipoHoras"), selectedImage: UIImage(named: "tipoHoras")!.addBorder(radius: 10, color: CustomAppColor.tabItemBorderColor))
  var pactadaItem = UITabBarItem(title: "", image: UIImage(named: "tipoPactada"), selectedImage: UIImage(named: "tipoPactada")!.addBorder(radius: 10, color: CustomAppColor.tabItemBorderColor))
  
  //variables de interfaz
  
  var TablaDirecciones = UITableView()
  
  let geocoder = Geocoder.shared
  
 
  
  var searchingAddress = "origen"

  //CONSTRAINTS
  var btnViewTop: NSLayoutConstraint!
  @IBOutlet weak var formularioSolicitudHeight: NSLayoutConstraint!
  @IBOutlet weak var formularioSolicitudBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var addressViewTop: NSLayoutConstraint!
  
  //MAP
  var searchEngine = SearchEngine()
  var searchController: MapboxSearchController!
  var panelController: MapboxPanelController!
  
  var solicitudPanel = FloatingPanelController()
  var nuevaSolicitud: Solicitud?
	
	lazy var openMapBtn: UIButton = {
		let openMapBtn = UIButton(type: UIButton.ButtonType.system)
		openMapBtn.frame = CGRect(x: 25, y: 20, width: self.addressTableView.frame.width - 40, height: 40)
		let mapaImage = UIImage(named: "mapLocation")?.withRenderingMode(.alwaysOriginal)
		openMapBtn.setImage(mapaImage, for: UIControl.State())
		openMapBtn.setTitle("Fijar ubicación en el mapa", for: .normal)
		openMapBtn.addTarget(self, action: #selector(openMapBtnAction), for: .touchUpInside)
		openMapBtn.layer.cornerRadius = 10
		openMapBtn.backgroundColor = .white
		openMapBtn.tintColor = .black
		openMapBtn.addShadow()
		
		return openMapBtn
	}()
  
  @IBOutlet weak var mapView: MGLMapView!
  
  @IBOutlet weak var locationIcono: UIImageView!

  @IBOutlet weak var LocationBtn: UIButton!
  @IBOutlet weak var SolicitudView: UIView!
  
  @IBOutlet weak var addressPreviewText: UILabel!
  
  
  //MENU BUTTONS
  @IBOutlet weak var TransparenciaView: UIVisualEffectView!
  
  @IBOutlet weak var solicitudFormTable: UITableView!
  
  @IBOutlet weak var addressView: UIView!
  @IBOutlet weak var addressPicker: UIPickerView!
  @IBOutlet weak var listoAddressBtn: UIButton!
  @IBOutlet weak var listoDestinoBtn: UIButton!
  
  @IBOutlet weak var destinoAddressView: UIView!
  @IBOutlet weak var destinoAddressPicker: UIPickerView!
  
  
  @IBOutlet weak var tabBar: UITabBar!

  @IBOutlet weak var panicoView: UIView!
  
  @IBOutlet weak var mapBottomConstraint: NSLayoutConstraint!
  
  //ADDRESS SEARCH
  @IBOutlet weak var searchAddressView: UIView!
  @IBOutlet weak var searchText: UITextField!
  @IBOutlet weak var addressTableView: UITableView!
  @IBOutlet weak var sinResultadosLabel: UILabel!
  
  
  override func viewDidLoad() {
    super.hideMenuBtn = false
    super.hideCloseBtn = false
    super.viewDidLoad()
    
    self.solicitudFormTable.rowHeight = UITableView.automaticDimension
    self.checkForNewVersions()
    self.tabBar.delegate = self
    self.tabBar.layer.borderColor = UIColor.clear.cgColor
    self.tabBar.clipsToBounds = true
    mapView.delegate = self
    addressTableView.delegate = self
    //mapView.automaticallyAdjustsContentInset = true
    coreLocationManager = CLLocationManager()
    coreLocationManager.delegate = self
    self.contactoCell.delegate = self
    self.contactoCell.contactoNameText.delegate = self
    self.contactoCell.telefonoText.delegate = self
    self.origenCell.origenText.delegate = self
    self.destinoCell.destinoText.delegate = self
    self.pagoCell.delegate = self
    self.pagoCell.referenciaText.delegate = self
    self.apiService.delegate = self
    self.addressPicker.delegate = self
    self.destinoAddressPicker.delegate = self
    self.ofertaDataCell.valorOfertaText.delegate = self
    
    self.origenAnnotation.subtitle = "origen"
    self.destinoAnnotation.subtitle = "destino"
    
    //MARK:- MENU INITIALIZATION
    self.sideMenu = self.addSideMenu()
		self.sideMenu!.delegate = self
  
    self.SolicitudView.addShadow()

    self.LocationBtn.addCustomMenuBtnsColors(image: UIImage(named: "locationBtn")!, tintColor: CustomAppColor.buttonActionColor, backgroundColor: nil)
    listoAddressBtn.addCustomActionBtnsColors()
    listoDestinoBtn.addCustomActionBtnsColors()

    self.TransparenciaView.addStandardConfig()
    
    //MARK:- MAPBOX SEARCH ADDRESS BAR
    let requestOptions = SearchEngine.RequestOptions(proximity: CLLocationCoordinate2D(latitude: 1.653788, longitude: -75.177630))
    
    self.searchController = MapboxSearchController()
    self.panelController = MapboxPanelController(rootViewController: self.searchController)
    
    //MARK:- PANEL DEFINITION
    self.solicitudPanel.delegate = self
    guard let contentPanel = storyboard?.instantiateViewController(withIdentifier: "SolicitudPanel") as? SolicitudPanel else{
      return
    }
    
    self.solicitudPanel.set(contentViewController: contentPanel)
    
    coreLocationManager.desiredAccuracy = kCLLocationAccuracyBest
    coreLocationManager.startUpdatingLocation()  //Iniciar servicios de actualiación de localización del usuario
    
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    
    addressViewTop.constant = super.getTopMenuCenter()
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado))
    tapGesture.delegate = self
    self.solicitudFormTable.addGestureRecognizer(tapGesture)
    
    //INITIALIZING INTERFACES VARIABLES
    globalVariables.socket.on("disconnect"){data, ack in
      print("disconnect")
      self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.Reconect), userInfo: nil, repeats: true)
    }
  }
  
  override func viewDidAppear(_ animated: Bool){
    
    self.socketService.delegate = self
    
    if let tempLocation = self.coreLocationManager.location?.coordinate{
      globalVariables.cliente.annotation.coordinate = tempLocation
      self.origenAnnotation.coordinate = tempLocation
      coreLocationManager.stopUpdatingLocation()
      initMapView()
    } else {
      globalVariables.cliente.annotation.coordinate = (CLLocationCoordinate2D(latitude: -2.173714, longitude: -79.921601))
      coreLocationManager.requestWhenInUseAuthorization()
    }
    
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    self.socketService.initListenEventos()
    self.initTipoSolicitudBar()
    self.pagoCell.initContent(isCorporativo: self.tabBar.selectedItem != self.ofertaItem)
    
    self.origenCell.initContent()
    self.origenCell.origenText.addTarget(self, action: #selector(textViewDidChange(_:)), for: .editingChanged)
    
    self.searchText.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
		
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    self.navigationController?.setNavigationBarHidden(true, animated: false)
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print("UpdateLocation")
    globalVariables.cliente.annotation.coordinate = (locations.last?.coordinate)!
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
		if let navigationController = navigationController, !navigationController.isNavigationBarHidden {
			if searchingAddress == "origen" {
				mapView.removeAnnotation(self.origenAnnotation)
				self.origenAnnotation.coordinate = coreLocationManager.location!.coordinate
				mapView.addAnnotation(self.origenAnnotation)
			} else {
				mapView.removeAnnotation(self.destinoAnnotation)
				self.destinoAnnotation.coordinate = coreLocationManager.location!.coordinate
				mapView.addAnnotation(self.destinoAnnotation)
			}
			mapView.setCenter(origenAnnotation.coordinate, zoomLevel: 15, animated: false)
		} else {
			updateMapFocus()
		}
  }

  //Boton para Cancelar Carrera
  @IBAction func CancelarSol(_ sender: UIButton) {
    self.hideSolicitudView(isHidden: true)
    //self.SolicitudView.isHidden = true
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
    self.present(vc, animated: false, completion: nil)
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
    self.addressPreviewText.isHidden = true
//		if searchText.text!.isEmpty {
//			super.hideMenuBar(isHidden: false)
//			self.mapBottomConstraint.constant = 0
//			searchText.endEditing(true)
//			self.navigationController?.setNavigationBarHidden(true, animated: true)
//			self.searchAddressView.isHidden = true
//		} else {
//			closeSearchAddress(addressSelected: nil)
//		}
		
		closeSearchAddress(addressSelected: nil)
  }
  
  @IBAction func getAddressText(_ sender: Any) {
    if self.searchingAddress == "destino" {
      if !self.searchAddressView.isHidden{
        self.destinoAnnotation.updateAnnotation(newCoordinate: self.origenAnnotation.coordinate, newTitle: searchText.text!)
        destinoCell.destinoText.text = searchText.text
      } else {
        //self.getAddressFromCoordinate(self.destinoAnnotation)
				self.getReverseAddressXoaAPI(self.destinoAnnotation)
      }
      self.getDestinoFromSearch(annotation: self.destinoAnnotation)
    } else {
      if !self.searchAddressView.isHidden {
        self.origenAnnotation.title = searchText.text
        origenCell.origenText.text = searchText.text
      } else {
        //self.getAddressFromCoordinate(self.origenAnnotation)
				self.getReverseAddressXoaAPI(self.origenAnnotation)
      }
    }

    super.hideMenuBar(isHidden: false)
    self.mapBottomConstraint.constant = 0
    searchText.endEditing(true)
    self.navigationController?.setNavigationBarHidden(true, animated: true)
    self.searchAddressView.isHidden = true
    self.addressPreviewText.isHidden = true

////    if self.searchingAddress == "destino"{
//      if !(self.panelController.state == .collapsed){
//        //self.destinoAnnotation.updateAnnotation(newCoordinate: self.origenAnnotation.coordinate, newTitle: self.searchController.searchEngine.query)
//        self.getDestinoFromSearch(annotation: self.destinoAnnotation)
//      } else {
//        self.getDestinoFromSearch(annotation: self.destinoAnnotation)
//      }
//      self.getAddressFromCoordinate(self.destinoAnnotation)
//      print("destino \(self.destinoCell.destinoText.text)")
//    } else {
//      if !(self.panelController.state == .collapsed){
//        self.origenAnnotation.title = self.searchController.searchEngine.query
//        //self.origenCell.origenText.text = self.origenAnnotation.title
//      } else {
//        self.getAddressFromCoordinate(self.origenAnnotation)
//      }
//    }
    //self.hideSearchPanel()
  } 
}




