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
import SideMenu
import MapboxMaps
import MapboxDirections
import GoogleMobileAds

struct sosBtnData {
	let image:UIImage
	let title:String
	let type:Int
}

class SolPendController: BaseController, MKMapViewDelegate, UITextViewDelegate,URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
	internal var mapView: MapView!
  var socketService = SocketService.shared
	var coreLocationManager : CLLocationManager!
	var pointAnnotationManager: PointAnnotationManager!
  var solicitudPendiente: Solicitud!
  var solicitudIndex: Int!
  var origenAnnotation = MyMapAnnotation()
  var destinoAnnotation = MyMapAnnotation()
  var taxiAnnotation = MyMapAnnotation()
  var grabando = false
  var fechahora: String = ""
  var urlSubirVoz = globalVariables.urlSubirVoz
  var apiService = ApiService.shared
  var responsive = Responsive()
  var sideMenu: SideMenuNavigationController!

	lazy var bannerView: GADBannerView = {
		let bannerView = GADBannerView()
        bannerView.adUnitID = GoogleAdsConstant.appBannerID
		
		bannerView.rootViewController = self
		bannerView.delegate = self
			
		return bannerView
	}()
	
	var sosBtnArray = [sosBtnData(image: UIImage(named: "sosPolicia")!, title: "POLICÍA",type: 0),sosBtnData(image: UIImage(named: "sosAmbulancia")!, title: "AMBULANCIA",type: 2),sosBtnData(image: UIImage(named: "sosBombero")!, title: "BOMBEROS",type: 1),sosBtnData(image: UIImage(named: "sosTransito")!, title: "TRÁNSITO", type: 3)]
  
  //MASK:- VARIABLES INTERFAZ
  @IBOutlet weak var mapViewParent: UIView!
  @IBOutlet weak var detallesView: UIView!
  @IBOutlet weak var distanciaText: UILabel!
  @IBOutlet weak var valorOferta: UILabel!
  @IBOutlet weak var direccionOrigen: UILabel!
  @IBOutlet weak var direccionDestino: UILabel!
  @IBOutlet weak var origenIcon: UIImageView!
  
  @IBOutlet weak var ComentarioEvalua: UIView!
  
  @IBOutlet weak var cancelarBtn: UIButton!
  @IBOutlet weak var MensajesBtn: UIButton!
  @IBOutlet weak var LlamarCondBtn: UIButton!
  @IBOutlet weak var whatsappBtn: UIButton!
  @IBOutlet weak var SMSVozBtn: UIButton!
  @IBOutlet weak var compartirDetallesBtn: UIButton!
  
  @IBOutlet weak var showConductorBtn: UIButton!
  @IBOutlet weak var DatosConductor: UIView!
  @IBOutlet weak var reviewConductor: UILabel!
  @IBOutlet weak var starIcon: UIImageView!
  //datos del conductor a mostrar
  @IBOutlet weak var conductorPreview: UIView!
  @IBOutlet weak var ImagenCond: UIImageView!
  @IBOutlet weak var NombreCond: UILabel!
  @IBOutlet weak var MarcaAut: UILabel!
  @IBOutlet weak var matriculaAut: UILabel!
  
  @IBOutlet weak var valorOfertaIcon: UIImageView!
  @IBOutlet weak var destinoIcon: UIImageView!
  
	@IBOutlet weak var adsBannerView: UIView!
  
  @IBOutlet weak var bannerBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var datosCondHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var detallesVHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var detallesBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var waitingView: UIVisualEffectView!
  @IBOutlet weak var cancelarBtnLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var llamarBtnLoadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var whatsappLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var radioBtnLoadingConstraint: NSLayoutConstraint!
  
	@IBOutlet weak var sosView: UIView!
	@IBOutlet weak var sosBtnsCollectionView: UICollectionView!
	@IBOutlet weak var malUsoBtn: UIButton!
	
	override func viewDidLoad() {
    super.hideMenuBtn = true
		super.hideCloseBtn = false
    super.hideSOSBtn = false

    super.barTitle = ""
    //super.topMenu.bringSubviewToFront(self.formularioSolicitud)
    super.viewDidLoad()
    self.sideMenu = self.addSideMenu()
    self.sideMenu.delegate = self
		
		coreLocationManager = CLLocationManager()
		coreLocationManager.delegate = self
		coreLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
		coreLocationManager.startUpdatingLocation()
    
    self.socketService.delegate = self
    self.socketService.initListenEventos()
    
    waitingView.addStandardConfig()
    origenIcon.addCustomTintColor(customColor: CustomAppColor.buttonActionColor)
    
    self.origenAnnotation.coordinates = self.solicitudPendiente.origenCoord
    self.origenAnnotation.type = "origen"
		
    if self.solicitudPendiente.destinoCoord.latitude != 0.0{
      self.destinoAnnotation.coordinates = self.solicitudPendiente.destinoCoord
      self.destinoAnnotation.type = "destino"
    }
		
    starIcon.addCustomTintColor(customColor: CustomAppColor.buttonActionColor)
    sosView.addShadow()
		sosView.layer.cornerRadius = 25
    self.conductorPreview.addShadow()
    self.MostrarDetalleSolicitud()
    self.matriculaAut.titleBlueStyle()
    self.distanciaText.titleBlueStyle()
    //self.reviewConductor.font = CustomAppFont.smallFont
    self.valorOferta.titleBlueStyle()
    self.LlamarCondBtn.addShadow()
    
    print("solicitud Pendiente \(solicitudPendiente.importe)")
    let adsTapGesture = UITapGestureRecognizer(target: self, action: #selector(goToPublicidad))
    //self.adsBannerView.addGestureRecognizer(adsTapGesture)
    
    let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(SolPendController.longTap(_:)))
    longGesture.minimumPressDuration = 0.2
    self.SMSVozBtn.addGestureRecognizer(longGesture)
    
    //ADS BANNER VIEW
    let distanceBtwBtns = responsive.distanceBtwElement(elementWidth: 60, elementCount: 4)
    self.cancelarBtnLeadingConstraint.constant = distanceBtwBtns
    self.llamarBtnLoadingConstraint.constant = distanceBtwBtns
    self.whatsappLeadingConstraint.constant = distanceBtwBtns
    self.radioBtnLoadingConstraint.constant = distanceBtwBtns
    
    self.detallesVHeightConstraint.constant = responsive.heightFloatPercent(percent: globalVariables.isBigIphone ? 20 : 24)
    self.datosCondHeightConstraint.constant = responsive.heightFloatPercent(percent:  globalVariables.isBigIphone ? 35 : 40)
    self.detallesBottomConstraint.constant = responsive.heightFloatPercent(percent: 3)
    
    self.bannerBottomConstraint.constant = -(responsive.heightFloatPercent(percent: globalVariables.isBigIphone ? 35 : 40) + 15)
    
    if globalVariables.urlConductor != ""{
      self.MensajesBtn.isHidden = false
      self.MensajesBtn.setImage(UIImage(named: "mensajesnew"),for: UIControl.State())
    }
    
    let homeImage = UIImage(named: "compartir")?.withRenderingMode(.alwaysTemplate)
    compartirDetallesBtn.setImage(homeImage, for: UIControl.State())
    compartirDetallesBtn.tintColor = CustomAppColor.buttonActionColor
    compartirDetallesBtn.layer.cornerRadius = compartirDetallesBtn.frame.height/2
    compartirDetallesBtn.backgroundColor = .white
    compartirDetallesBtn.addShadow()

		malUsoBtn.addUnderline()

		initGoogleAds()
        
        SMSVozBtn.isHidden = GlobalConstants.bundleId == "com.donelkys.RuedaCar"
  }
	
	private func initGoogleAds() {
		let adSize = GADAdSizeFromCGSize(CGSize(width: adsBannerView.layer.bounds.width, height: adsBannerView.layer.bounds.height))
		bannerView.adSize = adSize

		self.loadGoogleAds()
	}
	
	func loadGoogleAds() {
		bannerView.load(GADRequest())
	}
	
  override func viewDidAppear(_ animated: Bool) {
    print("iniciar la publicidad")
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    //globalVariables.publicidadService?.showPublicidad(bannerView: self.adsBannerView)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    print("parar la publicidad")
    globalVariables.publicidadService?.stopPublicidad()
  }
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if (locations.first?.distance(from: CLLocation(latitude: globalVariables.cliente.annotation.coordinates.latitude, longitude: globalVariables.cliente.annotation.coordinates.longitude)))! > 1000 {
			globalVariables.cliente.annotation.coordinates = locations.last!.coordinate
			print("UpdateLocation")
		}
		
	}
	
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		let authorizationStatus: CLAuthorizationStatus
		
		if #available(iOS 14.0, *) {
			authorizationStatus = manager.authorizationStatus
		} else {
			authorizationStatus = CLLocationManager.authorizationStatus()
		}
		
		switch authorizationStatus {
		case .notDetermined, .restricted, .denied:
			let locationAlert = UIAlertController (title: GlobalStrings.locationErrorTitle, message: GlobalStrings.locationErrorMessage, preferredStyle: .alert)
			locationAlert.addAction(UIAlertAction(title: GlobalStrings.settingsBtnTitle, style: .default, handler: {alerAction in
					let settingsURL = URL(string: UIApplication.openSettingsURLString)!
					UIApplication.shared.open(settingsURL, options: [:], completionHandler: { success in
						exit(0)
					})
			}))
			locationAlert.addAction(UIAlertAction(title: GlobalStrings.closeAppButtonTitle, style: .default, handler: {alerAction in
				exit(0)
			}))
			self.present(locationAlert, animated: true, completion: nil)
		case .authorizedAlways, .authorizedWhenInUse:
			manager.startUpdatingLocation()
			break
		default:
			break
		}
	}
  
  override func closeBtnAction() {
		sosView.isHidden = false
//    let panicoViewController = storyboard?.instantiateViewController(withIdentifier: "panicoChildVC") as! PanicoController
//    self.addChild(panicoViewController)
//    self.view.addSubview(panicoViewController.view)
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
    self.bannerBottomConstraint.constant = -(responsive.heightFloatPercent(percent:  UIScreen.main.bounds.height > 750 ? 35 : 40) + 15)
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
  }
  
  @IBAction func compartirDetalles(_ sender: Any) {
    let alertaCompartir = UIAlertController (title: "Viaje seguro", message: "Para un viaje más seguro, puede compartir los datos de conductor con un amigo a familiar.", preferredStyle: UIAlertController.Style.alert)
    alertaCompartir.addAction(UIAlertAction(title: "Compartir", style: .default, handler: {alerAction in
      
      let datosConductor = "Hola, soy \(globalVariables.cliente.nombreApellidos!), voy viajando en Un Taxi con el conductor: \(self.solicitudPendiente.taxi.conductor.nombreApellido), en un auto marca: \(self.solicitudPendiente.taxi.marca), color: \(self.solicitudPendiente.taxi.color), con placa: \(self.solicitudPendiente.taxi.matricula)"
      let objectsToShare = [datosConductor]
      let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
      self.present(activityVC, animated: true, completion: nil)
      
    }))
    self.present(alertaCompartir, animated: true, completion: nil)
  }
  
  @IBAction func CancelarProcesoSolicitud(_ sender: AnyObject) {
    self.mostrarAdvertenciaCancelacion()
  }
  
  @IBAction func cerrarDatosConductor(_ sender: Any) {
    self.detallesView.addShadow()
    self.bannerBottomConstraint.constant = -(responsive.heightFloatPercent(percent: UIScreen.main.bounds.height > 750 ? 20 : 24) + 5)
    self.showConductorBtn.isHidden = false
    self.DatosConductor.isHidden = true
  }
	
	@IBAction func closeSOSView(_ sender: Any) {
		sosView.isHidden = true
	}
	
	@IBAction func showMalUso(_ sender: Any) {
		if let url = URL(string: "https://www.ecu911.gob.ec/preguntas-frecuentes/") {
				UIApplication.shared.open(url)
		}
	}
	
}

//extension SolPendController: SideMenuNavigationControllerDelegate {
//  
//  //    func sideMenuWillAppear(menu: SideMenuNavigationController, animated: Bool) {
//  //        print("SideMenu Appearing! (animated: \(animated))")
//  //    }
//  
//  func sideMenuDidAppear(menu: SideMenuNavigationController, animated: Bool) {
//    //globalVariables.publicidadService?.stopPublicidad()k
//    print("SideMenu Appeared! (animated: \(animated))")
//  }
//  
//  //    func sideMenuWillDisappear(menu: SideMenuNavigationController, animated: Bool) {
//  //        print("SideMenu Disappearing! (animated: \(animated))")
//  //    }
//  
//  func sideMenuDidDisappear(menu: SideMenuNavigationController, animated: Bool) {
//    //globalVariables.publicidadService?.showPublicidad(bannerView: self.adsBannerView)
//    print("SideMenu Disappeared! (animated: \(self.isBeingDismissed))")
//  }
//}
