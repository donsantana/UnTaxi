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
import GoogleMaps
import SocketIO
import Canvas
import AddressBook
import AVFoundation
import CoreData

class InicioController: UIViewController, CLLocationManagerDelegate, UITextViewDelegate, GMSMapViewDelegate, UITextFieldDelegate, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, UIApplicationDelegate {
    var coreLocationManager : CLLocationManager!
    var miposicion = CLLocationCoordinate2D()
    var locationMarker = MKPointAnnotation()
    var taxiLocation : GMSMarker!
    var userAnotacion : GMSMarker!
    var origenAnotacion : GMSMarker!
    var destinoAnotacion : GMSMarker!
    var taxi : CTaxi!
    var login = [String]()
    var solpendientes = [CSolicitud]()
    var idusuario : String = ""
    var indexselect = Int()
    var contador = 0
    var centro = CLLocationCoordinate2D()
    var TelefonosCallCenter = [CTelefono]()
    var opcionAnterior : IndexPath!
    var evaluacion: CEvaluacion!
    var tarifas = [CTarifa]()
    var taxiscercanos = [GMSMarker]()
    var SMSVoz = CSMSVoz()
    
    var UrlSubirVoz = String()
    var responseData = NSMutableData()
    var data: Data!
    var timer = Timer()
    var fechahora: String!
    var grabando = false
    var urlconductor: String!
    let compartirOpcions = ["itms://itunes.apple.com/us/app/apple-store/id1149206387?mt=8", "https://play.google.com/store/apps/details?id=com.untaxi"]
    var tiempoTemporal = 10
    
    var taximetro: CTaximetro!
    var TaximetroTimer = Timer()
    var TaximetroTotalTimer = Timer()
    var espera = 0
    
    
    //variables de interfaz
    //@IBOutlet weak var taxisDisponible: UILabel!
    @IBOutlet weak var Geolocalizando: UIActivityIndicatorView!
    @IBOutlet weak var GeolocalizandoView: UIView!
    
    @IBOutlet weak var origenIcono: UIImageView!
    @IBOutlet weak var mapaVista : GMSMapView!

    

    
    
    @IBOutlet weak var destinoText: UITextField!
    @IBOutlet weak var origenText: UITextField!
    @IBOutlet weak var referenciaText: UITextField!

    @IBOutlet weak var SolicitarBtn: UIButton!
    @IBOutlet weak var formularioSolicitud: UIView!
    @IBOutlet weak var DatosConductor: UIView!
    
    //datos del conductor a mostrar
    @IBOutlet weak var ImagenCond: UIImageView!
    @IBOutlet weak var NombreCond: UILabel!
    @IBOutlet weak var MovilCond: UILabel!
    @IBOutlet weak var MarcaAut: UILabel!
    @IBOutlet weak var MatriculaAut: UILabel!
    @IBOutlet weak var DatosCondBtn: UIButton!
    @IBOutlet weak var ColorAut: UILabel!
    @IBOutlet weak var CancelarSolBtn: UIButton!
    
    @IBOutlet weak var EnviarSolBtn: UIButton!
    
    @IBOutlet weak var aceptarLocBtn: UIButton!
    @IBOutlet weak var CancelarEnvioBtn: UIButton!
    
 
    @IBOutlet weak var TablaSolPendientes: UITableView!
    //@IBOutlet weak var SolicitudDetalleView: UIView!
    @IBOutlet weak var DetallesCarreraView: UIView!
    

    
    
    @IBOutlet weak var PrimeraStart: UIButton!
    @IBOutlet weak var SegundaStar: UIButton!
    @IBOutlet weak var TerceraStar: UIButton!
    @IBOutlet weak var CuartaStar: UIButton!
    @IBOutlet weak var QuintaStar: UIButton!
    @IBOutlet weak var ComentarioText: UITextView!
    
    
    //@IBOutlet weak var SolicitudMapaView: UIView!
    
    @IBOutlet weak var DistanciaText: UILabel!
    @IBOutlet weak var DuracionText: UILabel!
    @IBOutlet weak var CostoText: UILabel!
    
    @IBOutlet weak var SolicitudAceptadaView: UIView!
    @IBOutlet weak var EvaluarBtn: UIButton!
    @IBOutlet weak var EvaluacionView: UIView!
    @IBOutlet weak var ComentarioEvalua: UIView!
    
    //@IBOutlet weak var LlamarBtn: UIButton!
    //@IBOutlet weak var OpcionesCancelView: UIView!
    //@IBOutlet weak var TablaOpcionesView: UITableView!
    @IBOutlet weak var SMSVozBtn: UIButton!
    @IBOutlet weak var MensajesBtn: UIButton!
    @IBOutlet weak var LlamarCondBtn: UIButton!
    
    //MENU BUTTONS
    @IBOutlet weak var MenuView: UIView!
    @IBOutlet weak var CallCEnterBtn: UIButton!
    @IBOutlet weak var SolPendientesBtn: UIButton!
    @IBOutlet weak var TaximetroBtn: UIButton!
    @IBOutlet weak var TarifarioBtn: UIButton!
    @IBOutlet weak var MapaBtn: UIButton!
    @IBOutlet weak var SolPendImage: UIImageView!
    @IBOutlet weak var CantSolPendientes: UILabel!
    @IBOutlet weak var SolPendientesView: UIView!
    @IBOutlet weak var ExplicacionView: UIView!
    @IBOutlet weak var ExplicacionText: UILabel!
    
    
    
    @IBOutlet weak var EsperandoTaxiActivity: UIActivityIndicatorView!
    
    @IBOutlet weak var CallCenterView: CSAnimationView!
    @IBOutlet weak var TablaCallCenter: UITableView!
    
    @IBOutlet weak var TablaSinInternet: UITableView!
    
    @IBOutlet weak var AlertaEsperaView: UIView!
    @IBOutlet weak var MensajeEspera: UITextView!
    
    //@IBOutlet weak var EsperaTaxisView: UIView!
    
    //Tarifario
    
    @IBOutlet weak var CancelarSolicitudProceso: UIButton!
    
    
    //@IBOutlet weak var LoginView: UIView!
    //@IBOutlet weak var Usuario: UITextField!
    //@IBOutlet weak var Clave: UITextField!
    
    @IBOutlet weak var ClaveRecover: UIView!
    @IBOutlet weak var movilClaveRecover: UITextField!
    @IBOutlet weak var RecuperarClaveBtn: UIButton!
    
    @IBOutlet weak var FondoClaveView: UIView!
    @IBOutlet weak var CambiarclaveView: UIView!
    @IBOutlet weak var ClaveActual: UITextField!
    @IBOutlet weak var ClaveNueva: UITextField!
    @IBOutlet weak var RepiteClaveNueva: UITextField!
    @IBOutlet weak var CambiarClave: UIButton!
    @IBOutlet weak var CancelaCambioClave: UIButton!
    
    @IBOutlet weak var RegistroView: UIView!
    @IBOutlet weak var AlertaSinConexion: UIView!
    @IBOutlet weak var CompartirTable: CSAnimationView!
    @IBOutlet weak var SinConexionText: UITextView!
    
    //TAXIMETRO
    @IBOutlet weak var TaximetroView: UIView!
    @IBOutlet weak var StarTaxBtn: UIButton!
    @IBOutlet weak var StopTaxBtn: UIButton!
    @IBOutlet weak var ApagarText: UILabel!
    @IBOutlet weak var TimeEsperaText: UILabel!
    @IBOutlet weak var TaximetroDistanciaText: UILabel!
    @IBOutlet weak var ArranqueText: UILabel!
    @IBOutlet weak var MinimaText: UILabel!
    @IBOutlet weak var TaximetroSpeedText: UILabel!
    @IBOutlet weak var AlertaTaximetroText: UILabel!
    @IBOutlet weak var AlertaTaximetroView: UIView!
    
    
    var TimerTemporal = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //LECTURA DEL FICHERO PARA AUTENTICACION
        
        mapaVista.delegate = self
        coreLocationManager = CLLocationManager()
        coreLocationManager.delegate = self
        coreLocationManager.requestAlwaysAuthorization() //solicitud de autorización para acceder a la localización del usuario
        coreLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        coreLocationManager.startUpdatingLocation()  //Iniciar servicios de actualiación de localización del usuario
        
        mapaVista.isMyLocationEnabled = true
        mapaVista.camera = GMSCameraPosition.camera(withLatitude: (coreLocationManager.location?.coordinate.latitude)!,longitude: (coreLocationManager.location?.coordinate.longitude)!,zoom: 15)
        
        //UBICAR LOS BOTONES DEL MENU
        var espacioBtn = self.view.frame.width/5
        self.CallCEnterBtn.frame = CGRect(x: espacioBtn - 40, y: 5, width: 44, height: 44)
        self.SolPendientesBtn.frame = CGRect(x: (espacioBtn * 2 - 35), y: 5, width: 44, height: 44)
        self.TarifarioBtn.frame = CGRect(x: (espacioBtn * 3 - 15), y: 5, width: 44, height: 44)
        self.MapaBtn.frame = CGRect(x: (espacioBtn * 4 - 10), y: 5, width: 44, height: 44)
        self.SolPendImage.frame = CGRect(x: (espacioBtn * 2 - 10), y: 5, width: 25, height: 22)
        self.CantSolPendientes.frame = CGRect(x: (espacioBtn * 2 - 10), y: 5, width: 25, height: 22)

        self.userAnotacion = GMSMarker()
        self.taxiLocation = GMSMarker()
        self.taxiLocation.icon = UIImage(named: "taxi_libre")
        self.origenAnotacion = GMSMarker()
        self.origenAnotacion.icon = UIImage(named: "origen")
        self.destinoAnotacion = GMSMarker()
        self.destinoAnotacion.icon = UIImage(named: "destino")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            self.miposicion = (locations.last?.coordinate)!
            self.setuplocationMarker(miposicion)
            //GeolocalizandoView.isHidden = true
            self.SolicitarBtn.isHidden = false
    }
    
    func setuplocationMarker(_ coordinate: CLLocationCoordinate2D) {
        self.userAnotacion.position = coordinate
        userAnotacion.snippet = "Cliente"
        userAnotacion.icon = UIImage(named: "origen")
        mapaVista.camera = GMSCameraPosition.camera(withLatitude: userAnotacion.position.latitude,longitude:userAnotacion.position.longitude,zoom: 14)
        self.origenIcono.isHidden = false
        ExplicacionText.text = "Localice el origen en el mapa"
        ExplicacionView.isHidden = false
        coreLocationManager.stopUpdatingLocation()
    }

    
    //MARK:- FUNCIONES PROPIAS
    
    //FUNCIÓN ENVIAR AL SOCKET
    func EnviarSocket(_ datos: String){
        if CConexionInternet.isConnectedToNetwork() == true{
            if myvariables.socket.reconnects{
                myvariables.socket.emit("data",datos)
            }
            else{
                let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor intentar otra vez.", preferredStyle: UIAlertControllerStyle.alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                    exit(0)
                }))
                
                //Para hacer que la alerta se muestre usamos presentViewController, a diferencia de Objective C que como recordaremos se usa [Show Alerta]
                alertaDos.view.tintColor = UIColor.black
                let subview = alertaDos.view.subviews.last! as UIView
                let alertContentView = subview.subviews.last! as UIView
                alertContentView.backgroundColor = UIColor(red: 252.0/255.0, green: 238.0/255.0, blue: 129.0/255.0, alpha: 1.0)
                alertContentView.layer.cornerRadius = 5
                let TitleString = NSAttributedString(string: "Sin Conexión", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 19), NSForegroundColorAttributeName : UIColor.black])
                alertaDos.setValue(TitleString, forKey: "attributedTitle")
                //let MessageString = NSAttributedString(string: Message, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15), NSForegroundColorAttributeName : MessageColor])
                
                self.present(alertaDos, animated: true, completion: nil)
            }
        }else{
            ErrorConexion()
        }
    }
    
    //FUNCIONES ESCUCHAR SOCKET
    func ErrorConexion(){
        //self.CargarTelefonos()
        //AlertaSinConexion.isHidden = false
        
        let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor revise su conexión a Internet.", preferredStyle: UIAlertControllerStyle.alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
            exit(0)
        }))
        
        //Para hacer que la alerta se muestre usamos presentViewController, a diferencia de Objective C que como recordaremos se usa [Show Alerta]
        alertaDos.view.tintColor = UIColor.black
        let subview = alertaDos.view.subviews.last! as UIView
        let alertContentView = subview.subviews.last! as UIView
        alertContentView.backgroundColor = UIColor(red: 252.0/255.0, green: 238.0/255.0, blue: 129.0/255.0, alpha: 1.0)
        alertContentView.layer.cornerRadius = 5
        let TitleString = NSAttributedString(string: "Sin Conexión", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 19), NSForegroundColorAttributeName : UIColor.black])
        alertaDos.setValue(TitleString, forKey: "attributedTitle")
        //let MessageString = NSAttributedString(string: Message, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15), NSForegroundColorAttributeName : MessageColor])
        
        self.present(alertaDos, animated: true, completion: nil)
    }

    
    //MARK:- BOTONES GRAFICOS ACCIONES
    @IBAction func CerrarApp(_ sender: Any) {
        if !myvariables.taximetroActive{
            let fileAudio = FileManager()
            let AudioPath = NSHomeDirectory() + "/Library/Caches/Audio"
            do {
                try fileAudio.removeItem(atPath: AudioPath)
            }catch{
            }
            let datos = "#SocketClose," + myvariables.cliente.idCliente + ",# \n"
            EnviarSocket(datos)
            let alertaDos = UIAlertController (title: "Cerrar sesión", message: "Si cierra su sesión tendrá que autenticarse la próxima vez que inicie la aplicación.", preferredStyle: UIAlertControllerStyle.alert)
            alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                let fileManager = FileManager()
                let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
                do {
                    try fileManager.removeItem(atPath: filePath)
                }catch{
                }
                exit(0)
            }))
            alertaDos.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: {alerAction in
                exit(0)
            }))
            
            //Para hacer que la alerta se muestre usamos presentViewController, a diferencia de Objective C que como recordaremos se usa [Show Alerta]
            alertaDos.view.tintColor = UIColor.black
            let subview = alertaDos.view.subviews.last! as UIView
            let alertContentView = subview.subviews.last! as UIView
            alertContentView.backgroundColor = UIColor(red: 252.0/255.0, green: 238.0/255.0, blue: 129.0/255.0, alpha: 1.0)
            alertContentView.layer.cornerRadius = 5
            let TitleString = NSAttributedString(string: "Cerrar Sesión", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 19), NSForegroundColorAttributeName : UIColor.black])
            alertaDos.setValue(TitleString, forKey: "attributedTitle")
            self.present(alertaDos, animated: true, completion: nil)
        }else{
            self.AlertaTaximetroView.isHidden = false
            self.TaximetroView.isHidden = false
        }
    }
    //SOLICITAR BUTTON
    @IBAction func Solicitar(_ sender: AnyObject) {
        //TRAMA OUT: #Posicion,idCliente,latorig,lngorig
        self.origenIcono.isHidden = true
        self.origenAnotacion.position = mapaVista.camera.target
        //self.DireccionDeCoordenada(self.origenAnotacion.position, directionText: origenText)
        coreLocationManager.stopUpdatingLocation()
        //self.destinoText.text?.removeAll()
        self.SolicitarBtn.isHidden = true
        ExplicacionView.isHidden = true
        self.formularioSolicitud.isHidden = false
        let datos = "#Posicion," + myvariables.cliente.idCliente + "," + "\(self.origenAnotacion.position.latitude)," + "\(self.origenAnotacion.position.longitude)," + "# \n"
        EnviarSocket(datos)
    }


}
