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

class SolPendController: BaseController, MKMapViewDelegate, UITextViewDelegate,URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, UINavigationControllerDelegate {
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
  @IBOutlet weak var compartirDetallesBtn: UIButton!
  
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
  
  override func viewDidLoad() {
    super.hideMenuBtn = true
    super.hideCloseBtn = true
    super.barTitle = ""
    //super.topMenu.bringSubviewToFront(self.formularioSolicitud)
    super.viewDidLoad()
    
    self.sideMenu = self.addSideMenu()
    self.sideMenu.delegate = self

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
    //self.reviewConductor.font = CustomAppFont.smallFont
    self.valorOferta.titleBlueStyle()
    self.LlamarCondBtn.addShadow()
    
    let adsTapGesture = UITapGestureRecognizer(target: self, action: #selector(goToPublicidad))
    self.adsBannerView.addGestureRecognizer(adsTapGesture)
    
    let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(SolPendController.longTap(_:)))
    longGesture.minimumPressDuration = 0.2
    self.SMSVozBtn.addGestureRecognizer(longGesture)
    
    //ADS BANNER VIEW
//    self.adsBannerView.adUnitID = "ca-app-pub-1778988557303127/7963427999"
//    self.adsBannerView.rootViewController = self
//    self.adsBannerView.load(GADRequest())
//    self.adsBannerView.delegate = self
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
  
  override func viewDidAppear(_ animated: Bool) {
    print("iniciar la publicidad")
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    globalVariables.publicidadService?.showPublicidad(bannerView: self.adsBannerView)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    print("parar la publicidad")
    globalVariables.publicidadService?.stopPublicidad()
  }

//  override func homeBtnAction() {
//    present(sideMenu!, animated: true)
//    //self.dismiss(animated: false, completion: nil)
//  }
  
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
}

extension SolPendController: GADBannerViewDelegate{
  
  func adViewDidReceiveAd(_ bannerView: GADBannerView) {
    print("get the ads")
  }
}

extension SolPendController: SideMenuNavigationControllerDelegate {
  
  //    func sideMenuWillAppear(menu: SideMenuNavigationController, animated: Bool) {
  //        print("SideMenu Appearing! (animated: \(animated))")
  //    }
  
  func sideMenuDidAppear(menu: SideMenuNavigationController, animated: Bool) {
    //globalVariables.publicidadService?.stopPublicidad()k
    print("SideMenu Appeared! (animated: \(animated))")
  }
  
  //    func sideMenuWillDisappear(menu: SideMenuNavigationController, animated: Bool) {
  //        print("SideMenu Disappearing! (animated: \(animated))")
  //    }
  
  func sideMenuDidDisappear(menu: SideMenuNavigationController, animated: Bool) {
    //globalVariables.publicidadService?.showPublicidad(bannerView: self.adsBannerView)
    print("SideMenu Disappeared! (animated: \(self.isBeingDismissed))")
  }
}
