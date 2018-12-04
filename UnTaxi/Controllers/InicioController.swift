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

struct MenuData {
    var imagen: String
    var title: String
}

class InicioController: UIViewController, CLLocationManagerDelegate, UITextViewDelegate, MKMapViewDelegate, UITextFieldDelegate, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, UIApplicationDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
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
    var MenuArray = [MenuData(imagen: "solicitud", title: "En proceso"), MenuData(imagen: "operadora", title: "Call center"),MenuData(imagen: "clave", title: "Perfil"),MenuData(imagen: "compartir", title: "Compartir app"),MenuData(imagen: "salir2", title: "Salir")]
    //variables de interfaz
    
    @IBOutlet weak var origenIcono: UIImageView!
    @IBOutlet weak var mapaVista: MKMapView!
    
    
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
        
        //solicitud de autorización para acceder a la localización del usuario
        self.NombreUsuario.text = myvariables.cliente.nombreApellidos
        
        self.MenuTable.delegate = self
        self.MenuView1.layer.borderColor = UIColor.lightGray.cgColor
        self.MenuView1.layer.borderWidth = 0.3
        self.MenuView1.layer.masksToBounds = false
        
        self.MenuView1.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        
        coreLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        coreLocationManager.startUpdatingLocation()  //Iniciar servicios de actualiación de localización del usuario
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado))
        tapGesture.delegate = self
        self.SolicitudView.addGestureRecognizer(tapGesture)
        
        let MenuTapGesture = UITapGestureRecognizer(target: self, action: #selector(ocultarMenu))
        self.TransparenciaView.addGestureRecognizer(MenuTapGesture)
        
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

        if myvariables.socket.status.active{
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
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var anotationView = mapaVista.dequeueReusableAnnotationView(withIdentifier: "annotationView")
        anotationView = MKAnnotationView(annotation: self.origenAnotacion, reuseIdentifier: "annotationView")
        if annotation.title! == "origen"{
            self.mapaVista.removeAnnotation(self.origenAnotacion)
            anotationView?.image = UIImage(named: "origen")
        }else{
            anotationView?.image = UIImage(named: "taxi_libre")
        }
        return anotationView
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.miposicion.coordinate = (locations.last?.coordinate)!
        self.SolicitarBtn.isHidden = false
    }
    
    func mapView(_ mapView: MKMapView, rendererFor
        overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.green
        renderer.lineWidth = 4.0
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if SolicitarBtn.isHidden == false {
            self.miposicion.title = "origen"
            self.coreLocationManager.stopUpdatingLocation()
            self.mapaVista.removeAnnotations(self.mapaVista.annotations)
            self.SolPendientesView.isHidden = true
            self.origenIcono.isHidden = false
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        origenIcono.isHidden = true
        if SolicitarBtn.isHidden == false {
            miposicion.coordinate = (self.mapaVista.centerCoordinate)
            origenAnotacion.title = "origen"
            mapaVista.addAnnotation(self.miposicion)
        }
    }
    
    //MARK:- FUNCIONES PROPIAS
    
    func appUpdateAvailable() -> Bool
    {
        let storeInfoURL: String = "http://itunes.apple.com/lookup?bundleId=com.xoait.UnTaxi"
        var upgradeAvailable = false
        
        // Get the main bundle of the app so that we can determine the app's version number
        let bundle = Bundle.main
        if let infoDictionary = bundle.infoDictionary {
            // The URL for this app on the iTunes store uses the Apple ID for the  This never changes, so it is a constant
            let urlOnAppStore = URL(string: storeInfoURL)
            if let dataInJSON = try? Data(contentsOf: urlOnAppStore!) {
                // Try to deserialize the JSON that we got
                if let lookupResults = try? JSONSerialization.jsonObject(with: dataInJSON, options: JSONSerialization.ReadingOptions()) as! Dictionary<String, Any>{
                    // Determine how many results we got. There should be exactly one, but will be zero if the URL was wrong
                    if let resultCount = lookupResults["resultCount"] as? Int {
                        if resultCount == 1 {
                            // Get the version number of the version in the App Store
                            //self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<String, AnyObject>>)[0]
                            if let appStoreVersion = (lookupResults["results"]as! Array<Dictionary<String, AnyObject>>)[0]["version"] as? String {
                                // Get the version number of the current version
                                if let currentVersion = infoDictionary["CFBundleShortVersionString"] as? String {
                                    // Check if they are the same. If not, an upgrade is available.
                                    if appStoreVersion > currentVersion {
                                        upgradeAvailable = true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        ///Volumes/Datos/Ecuador/Desarrollo/UnTaxi/UnTaxi/LocationManager.swift:635:31: Ambiguous use of 'indexOfObject'
        return upgradeAvailable
    }
    
    func SocketEventos(){
        
        //Evento sockect para escuchar
        //TRAMA IN: #LoginPassword,loginok,idusuario,idrol,idcliente,nombreapellidos,cantsolpdte,idsolicitud,idtaxi,cod,fechahora,lattaxi,lngtaxi,latorig,lngorig,latdest,lngdest,telefonoconductor
        if self.appUpdateAvailable(){
            
            let alertaVersion = UIAlertController (title: "Versión de la aplicación", message: "Estimado cliente es necesario que actualice a la última versión de la aplicación disponible en la AppStore. ¿Desea hacerlo en este momento?", preferredStyle: .alert)
            alertaVersion.addAction(UIAlertAction(title: "Si", style: .default, handler: {alerAction in
                
                UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/us/app/apple-store/id1149206387?mt=8")!)
            }))
            alertaVersion.addAction(UIAlertAction(title: "No", style: .default, handler: {alerAction in
                exit(0)
            }))
            self.present(alertaVersion, animated: true, completion: nil)
            
        }
        
        myvariables.socket.on("LoginPassword"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            
            if (temporal[0] == "[#LoginPassword") || (temporal[0] == "#LoginPassword"){
                myvariables.solpendientes = [CSolicitud]()
                self.contador = 0
                switch temporal[1]{
                case "loginok":
                    let url = "#U,# \n"
                    self.EnviarSocket(url)
                    let telefonos = "#Telefonos,# \n"
                    self.EnviarSocket(telefonos)
                    self.idusuario = temporal[2]
                    self.SolicitarBtn.isHidden = false
                    //self.LoginView.isHidden = true
                    //self.LoginView.endEditing(true)
                    myvariables.cliente = CCliente(idUsuario: temporal[2],idcliente: temporal[4], user: self.login[1], nombre: temporal[5],email : temporal[3], empresa: temporal[temporal.count - 2] )
                    if temporal[6] != "0"{
                        self.ListSolicitudPendiente(temporal)
                    }
                    
                case "loginerror":
                    let fileManager = FileManager()
                    let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
                    do {
                        try fileManager.removeItem(atPath: filePath)
                    }catch{
                        
                    }
                    
                    let alertaDos = UIAlertController (title: "Autenticación", message: "Usuario y/o clave incorrectos", preferredStyle: UIAlertController.Style.alert)
                    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                        
                    }))
                    self.present(alertaDos, animated: true, completion: nil)
                default: print("Problemas de conexion")
                }
            }else{
                //exit(0)
            }
        }
        
        //Evento Posicion de taxis
        myvariables.socket.on("Posicion"){data, ack in

            let temporal = String(describing: data).components(separatedBy: ",")
            if(temporal[1] == "0") {
                let alertaDos = UIAlertController(title: "Solicitud de Taxi", message: "No hay taxis disponibles en este momento, espere unos minutos y vuelva a intentarlo.", preferredStyle: UIAlertController.Style.alert )
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                    self.Inicio()
                }))                
                self.present(alertaDos, animated: true, completion: nil)
            }else{
                self.MostrarTaxi(temporal)
            }
        }
        
        //Respuesta de la solicitud enviada
        myvariables.socket.on("Solicitud"){data, ack in
            //Trama IN: #Solicitud, ok, idsolicitud, fechahora
            //Trama IN: #Solicitud, error
            self.EnviarTimer(estado: 0, datos: "terminando")
            let temporal = String(describing: data).components(separatedBy: ",")
            if temporal[1] == "ok"{
                self.MensajeEspera.text = "Solicitud enviada a los taxis cercanos. Esperando respuesta..."
                self.AlertaEsperaView.isHidden = false
                self.CancelarSolicitudProceso.isHidden = false
                self.ConfirmaSolicitud(temporal)
            }else{
                
            }
        }
        
        //ACTIVACION DEL TAXIMETRO
        myvariables.socket.on("TI"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            if myvariables.solpendientes.count != 0 {
                //self.MensajeEspera.text = temporal
                //self.AlertaEsperaView.hidden = false
                for solicitudpendiente in myvariables.solpendientes{
                    if (temporal[2] == solicitudpendiente.idTaxi){
                        let alertaDos = UIAlertController (title: "Taximetro Activado", message: "Estimado Cliente: El conductor ha iniciado el Taximetro a las: \(temporal[1]).", preferredStyle: .alert)
                        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                            
                        }))
                        self.present(alertaDos, animated: true, completion: nil)
                    }
                }
            }
        }
        
        
        //RESPUESTA DE CANCELAR SOLICITUD
        myvariables.socket.on("Cancelarsolicitud"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            if temporal[1] == "ok"{
                let alertaDos = UIAlertController (title: "Cancelar Solicitud", message: "Su solicitud fue cancelada.", preferredStyle: UIAlertController.Style.alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                    self.Inicio()
                    if myvariables.solpendientes.count != 0{
                        self.SolPendientesView.isHidden = true
                        
                    }
                }))
                self.present(alertaDos, animated: true, completion: nil)
            }
        }
        
        //RESPUESTA DE CONDUCTOR A SOLICITUD
        
        myvariables.socket.on("Aceptada"){data, ack in
            self.Inicio()
            let temporal = String(describing: data).components(separatedBy: ",")
            //#Aceptada, idsolicitud, idconductor, nombreApellidosConductor, movilConductor, URLfoto, idTaxi, Codvehiculo, matricula, marca, color, latTaxi, lngTaxi
            if temporal[0] == "#Aceptada" || temporal[0] == "[#Aceptada"{
                var i = 0
                while myvariables.solpendientes[i].idSolicitud != temporal[1] && i < myvariables.solpendientes.count{
                    i += 1
                }
                if myvariables.solpendientes[i].idSolicitud == temporal[1]{
                    
                    let solicitud = myvariables.solpendientes[i]
                    solicitud.DatosTaxiConductor(idtaxi: temporal[6], matricula: temporal[8], codigovehiculo: temporal[7], marcaVehiculo: temporal[9],colorVehiculo: temporal[10], lattaxi: temporal[11], lngtaxi: temporal[12], idconductor: temporal[2], nombreapellidosconductor: temporal[3], movilconductor: temporal[4], foto: temporal[5])
                    
                    DispatchQueue.main.async {
                        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "SolPendientes") as! SolPendController
                        vc.SolicitudPendiente = solicitud
                        vc.posicionSolicitud = myvariables.solpendientes.count - 1
                        self.navigationController?.show(vc, sender: nil)
                    }
                
                }
            }
            else{
                if temporal[0] == "#Cancelada" {
                    //#Cancelada, idsolicitud
                    
                    let alertaDos = UIAlertController (title: "Estado de Solicitud", message: "Ningún vehículo aceptó su solicitud, puede intentarlo más tarde.", preferredStyle: .alert)
                    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                        
                    }))
                    
                    self.present(alertaDos, animated: true, completion: nil)
                }
            }
        }
        
        myvariables.socket.on("Completada"){data, ack in
            //'#Completada,'+idsolicitud+','+idtaxi+','+distancia+','+tiempoespera+','+importe+',# \n'
            let temporal = String(describing: data).components(separatedBy: ",")
            
            if myvariables.solpendientes.count != 0{
                let pos = self.BuscarPosSolicitudID(temporal[1])
                myvariables.solpendientes.remove(at: pos)
                if myvariables.solpendientes.count != 0{
                    self.SolPendientesView.isHidden = true
                   
                }
                
                DispatchQueue.main.async {
                    let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "completadaView") as! CompletadaController
                    vc.idSolicitud = temporal[1]
                    vc.idTaxi = temporal[2]
                    vc.distanciaValue = temporal[3]
                    vc.tiempoValue = temporal[4]
                    vc.costoValue = temporal[5]
                    
                    self.navigationController?.show(vc, sender: nil)
                }
                
            }
        }
        
        myvariables.socket.on("Cambioestadosolicitudconductor"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            let alertaDos = UIAlertController (title: "Estado de Solicitud", message: "Solicitud cancelada por el conductor.", preferredStyle: UIAlertController.Style.alert)
            alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                var pos = -1
                pos = self.BuscarPosSolicitudID(temporal[1])
                if  pos != -1{
                    self.CancelarSolicitudes("Conductor")
                }
                
                DispatchQueue.main.async {
                    let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "Inicio") as! InicioController
                    self.navigationController?.show(vc, sender: nil)
                }
            }))
            self.present(alertaDos, animated: true, completion: nil)
        }
        
        //SOLICITUDES SIN RESPUESTA DE TAXIS
        myvariables.socket.on("SNA"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            if myvariables.solpendientes.count != 0{
                for solicitudenproceso in myvariables.solpendientes{
                    if solicitudenproceso.idSolicitud == temporal[1]{
                        let alertaDos = UIAlertController (title: "Estado de Solicitud", message: "No se encontó ningún taxi disponible para ejecutar su solicitud. Por favor inténtelo más tarde.", preferredStyle: UIAlertController.Style.alert)
                        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                            self.CancelarSolicitudes("")
                        }))
                        
                        self.present(alertaDos, animated: true, completion: nil)
                    }
                }
            }
        }
        
        //URl PARA AUDIO
        myvariables.socket.on("U"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            myvariables.UrlSubirVoz = temporal[1]
        }
        
        myvariables.socket.on("V"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            myvariables.urlconductor = temporal[1]
            if UIApplication.shared.applicationState != .background {
                if !myvariables.grabando{
                    myvariables.SMSProceso = true
                    myvariables.SMSVoz.ReproducirMusica()
                    myvariables.SMSVoz.ReproducirVozConductor(myvariables.urlconductor)
                }
            }else{
                if myvariables.SMSProceso{
                    myvariables.SMSVoz.ReproducirMusica()
                    myvariables.SMSVoz.ReproducirVozConductor(myvariables.urlconductor)
                }else{
                    print("Esta en background")
                }
                let localNotification = UILocalNotification()
                localNotification.alertAction = "Mensaje del Conductor"
                localNotification.alertBody = "Mensaje del Conductor. Abra la aplicación para escucharlo."
                localNotification.fireDate = Date(timeIntervalSinceNow: 4)
                UIApplication.shared.scheduleLocalNotification(localNotification)
            }
        }
        
        myvariables.socket.on("disconnect"){data, ack in
            self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.Reconect), userInfo: nil, repeats: true)
        }
        
        myvariables.socket.on("connect"){data, ack in
            let ColaHilos = OperationQueue()
            let Hilos : BlockOperation = BlockOperation ( block: {
                self.SocketEventos()
                self.timer.invalidate()
            })
            ColaHilos.addOperation(Hilos)
            var read = "Vacio"
            //var vista = ""
            let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
            do {
                read = try NSString(contentsOfFile: filePath, encoding: String.Encoding.utf8.rawValue) as String
            }catch {
                
            }
        }
        
        myvariables.socket.on("Telefonos"){data, ack in
            //#Telefonos,cantidad,numerotelefono1,operadora1,siesmovil1,sitienewassap1,numerotelefono2,operadora2..,#
            self.TelefonosCallCenter = [CTelefono]()
            let temporal = String(describing: data).components(separatedBy: ",")
            
            if temporal[1] != "0"{
                var i = 2
                while i <= temporal.count - 4{
                    let telefono = CTelefono(numero: temporal[i], operadora: temporal[i + 1], esmovil: temporal[i + 2], tienewhatsapp: temporal[i + 3])
                    self.TelefonosCallCenter.append(telefono)
                    i += 4
                    
                }
                //self.GuardarTelefonos(temporal)
            }
        }
    }
    
    //RECONECT SOCKET
    @objc func Reconect(){
        if contador <= 5 {
            myvariables.socket.connect()
            contador += 1
        }
        else{
            let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor intentar otra vez.", preferredStyle: UIAlertController.Style.alert)
            alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                exit(0)
            }))
            self.present(alertaDos, animated: true, completion: nil)
        }
    }
    
    //FUNCTION ENVIO CON TIMER
    func EnviarTimer(estado: Int, datos: String){
        if estado == 1{
            self.EnviarSocket(datos)
            if !self.emitTimer.isValid{
                self.emitTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(EnviarSocket1(_:)), userInfo: ["datos": datos], repeats: true)
            }
        }else{
            self.emitTimer.invalidate()
            self.EnviosCount = 0
        }
    }
    
    //FUNCIÓN ENVIAR AL SOCKET
    @objc func EnviarSocket(_ datos: String){
        if CConexionInternet.isConnectedToNetwork() == true{
            if myvariables.socket.status.active && self.EnviosCount <= 3{
                myvariables.socket.emit("data",datos)
                //self.EnviarTimer(estado: 1, datos: datos)
            }else{
                let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor intentar otra vez.", preferredStyle: UIAlertController.Style.alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                    exit(0)
                }))
                
                self.present(alertaDos, animated: true, completion: nil)
            }
        }else{
            ErrorConexion()
        }
    }
    
    @objc func EnviarSocket1(_ timer: Timer){
        if CConexionInternet.isConnectedToNetwork() == true{
            if myvariables.socket.status.active && self.EnviosCount <= 3 {
                self.EnviosCount += 1
                let userInfo = timer.userInfo as! Dictionary<String, AnyObject>
                var datos = (userInfo["datos"] as! String)
                myvariables.socket.emit("data",datos)
            }else{
                let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor intentar otra vez.", preferredStyle: UIAlertController.Style.alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                    self.EnviarTimer(estado: 0, datos: "Terminado")
                    exit(0)
                }))
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
        
        let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor revise su conexión a Internet.", preferredStyle: UIAlertController.Style.alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
            exit(0)
        }))
        self.present(alertaDos, animated: true, completion: nil)
    }
    
    func Inicio(){
        mapaVista.removeAnnotations(self.mapaVista.annotations)
        self.coreLocationManager.startUpdatingLocation()
        self.origenAnotacion.coordinate = (self.coreLocationManager.location?.coordinate)!
        self.origenIcono.image = UIImage(named: "origen2")
        self.origenIcono.isHidden = true
        self.origenAnotacion.title = "origen"
        let span = MKCoordinateSpan.init(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: self.origenAnotacion.coordinate, span: span)
        self.mapaVista.setRegion(region, animated: true)
        self.mapaVista.addAnnotation(self.origenAnotacion)
        
        self.formularioSolicitud.isHidden = true
        self.SolicitarBtn.isHidden = false
        SolPendientesView.isHidden = true
        CancelarSolicitudProceso.isHidden = true
        AlertaEsperaView.isHidden = true
    }
    
    //DIRECCIONES FAVORITAS
    func CargarFavoritas(){
        let path = NSHomeDirectory() + "/Library/Caches/"
        let url = NSURL(fileURLWithPath: path)
        let filePath = url.appendingPathComponent("dir.plist")?.path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath!) {
            let filePath = NSURL(fileURLWithPath: NSHomeDirectory() + "/Library/Caches/dir.plist") as URL
            do {
                self.DireccionesArray = NSArray(contentsOf: filePath) as! [[String]]
            }catch{
                
            }
        }
    }
    
    func GuardarFavorita(newFavorita: [String]){
        self.DireccionesArray.append(newFavorita)
        //CREAR EL FICHERO DE LOGÍN
        let filePath = NSURL(fileURLWithPath: NSHomeDirectory() + "/Library/Caches/dir.plist")
        
        do {
            _ = try (self.DireccionesArray as NSArray).write(to: filePath as URL, atomically: true)
            
        } catch {
            
        }
    }
    
    func EliminarFavorita(posFavorita: Int){
        self.DireccionesArray.remove(at: posFavorita)
        //CREAR EL FICHERO DE LOGÍN
        let filePath = NSURL(fileURLWithPath: NSHomeDirectory() + "/Library/Caches/dir.plist")
        
        do {
            _ = try (self.DireccionesArray as NSArray).write(to: filePath as URL, atomically: true)
        } catch {
            
        }
    }
    
    
    //FUNCION PARA LISTAR SOLICITUDES PENDIENTES
    func ListSolicitudPendiente(_ listado : [String]){
        //#LoginPassword,loginok,idusuario,idrol,idcliente,nombreapellidos,cantsolpdte,idsolicitud,idtaxi,cod,fechahora,lattaxi,lngtaxi, latorig,lngorig,latdest,lngdest,telefonoconductor
        print("pendiente pinga \(listado)")
        var lattaxi = String()
        var longtaxi = String()
        var i = 7
        
        while i <= listado.count-10 {
            let solicitudpdte = CSolicitud()
            if listado[i+4] == "null"{
                lattaxi = "0"
                longtaxi = "0"
            }else{
                lattaxi = listado[i + 4]
                longtaxi = listado[i + 5]
            }
            solicitudpdte.idSolicitud = listado[i]
            solicitudpdte.DatosCliente(cliente: myvariables.cliente)
            solicitudpdte.DatosSolicitud(dirorigen: "", referenciaorigen: "", dirdestino: "", latorigen: listado[i + 6], lngorigen: listado[i + 7], latdestino: listado[i + 8], lngdestino: listado[i + 9],FechaHora: listado[i + 3])
            if listado[i + 1] != "null"{
                solicitudpdte.DatosTaxiConductor(idtaxi: listado[i + 1], matricula: "", codigovehiculo: listado[i + 2], marcaVehiculo: "", colorVehiculo: "", lattaxi: lattaxi, lngtaxi: longtaxi, idconductor: "", nombreapellidosconductor: "", movilconductor: listado[i + 10], foto: "")
            }
            myvariables.solpendientes.append(solicitudpdte)
            if solicitudpdte.idTaxi != ""{
                myvariables.solicitudesproceso = true
            }
            i += 11
        }
    }
    
    //Funcion para Mostrar Datos del Taxi seleccionado
    func AgregarTaxiSolicitud(_ temporal : [String]){
        //#Aceptada, idsolicitud, idconductor, nombreApellidosConductor, movilConductor, URLfoto, idTaxi, Codvehiculo, matricula, marca_modelo, color, latTaxi, lngTaxi
        for solicitud in myvariables.solpendientes{
            if solicitud.idSolicitud == temporal[1]{
                myvariables.solicitudesproceso = true
                solicitud.DatosTaxiConductor(idtaxi: temporal[6], matricula: temporal[8], codigovehiculo: temporal[7], marcaVehiculo: temporal[9],colorVehiculo: temporal[10], lattaxi: temporal[11], lngtaxi: temporal[12], idconductor: temporal[2], nombreapellidosconductor: temporal[3], movilconductor: temporal[4], foto: temporal[5])
            }
        }
    }
    
    
    //FUNCIÓN BUSCA UNA SOLICITUD DENTRO DEL ARRAY DE SOLICITUDES PENDIENTES DADO SU ID
    func BuscarSolicitudID(_ id : String)->CSolicitud{
        var temporal : CSolicitud!
        for solicitudpdt in myvariables.solpendientes{
            if solicitudpdt.idSolicitud == id{
                temporal = solicitudpdt
            }
        }
        return temporal
    }
    //devolver posicion de solicitud
    func BuscarPosSolicitudID(_ id : String)->Int{
        var temporal = 0
        var posicion = -1
        for solicitudpdt in myvariables.solpendientes{
            if solicitudpdt.idSolicitud == id{
                posicion = temporal
            }
            temporal += 1
        }
        return posicion
    }
    
    //Respuesta de solicitud
    func ConfirmaSolicitud(_ Temporal : [String]){
        //Trama IN: #Solicitud, ok, idsolicitud, fechahora
        
        if Temporal[1] == "ok"{
            myvariables.solpendientes.last!.RegistrarFechaHora(IdSolicitud: Temporal[2], FechaHora: Temporal[3])
        }
        else{
            if Temporal[1] == "error"{
                
            }
        }
    }
    //FUncion para mostrar los taxis
    func MostrarTaxi(_ temporal : [String]){
        //TRAMA IN: #Posicion,idtaxi,lattaxi,lngtaxi
        var i = 2
        var taxiscercanos = [MKPointAnnotation]()
        while i  <= temporal.count - 6{
            let taxiTemp = MKPointAnnotation()
            taxiTemp.coordinate = CLLocationCoordinate2DMake(Double(temporal[i + 2])!, Double(temporal[i + 3])!)
            taxiTemp.title = temporal[i]
            taxiscercanos.append(taxiTemp)
            i += 6
        }
        DibujarIconos(taxiscercanos)
    }
    
    
    //CREAR SOLICITUD CON LOS DATOS DEL CIENTE, SU LOCALIZACIÓN DE ORIGEN Y DESTINO
    func CrearSolicitud(_ nuevaSolicitud: CSolicitud, voucher: String){
        //#Solicitud, idcliente, nombrecliente, movilcliente, dirorig, referencia, dirdest,latorig,lngorig, latdest, lngdest, distancia, costo, #
        formularioSolicitud.isHidden = true
        origenIcono.isHidden = true
        myvariables.solpendientes.append(nuevaSolicitud)
        
        let datoscliente = nuevaSolicitud.idCliente + "," + nuevaSolicitud.nombreApellidos + "," + nuevaSolicitud.user
        let datossolicitud = nuevaSolicitud.dirOrigen + "," + nuevaSolicitud.referenciaorigen + "," + "null"
        let datosgeo = String(nuevaSolicitud.distancia) + "," + nuevaSolicitud.costo
        let Datos = "#Solicitud" + "," + datoscliente + "," + datossolicitud + "," + String(nuevaSolicitud.origenCarrera.latitude) + "," + String(nuevaSolicitud.origenCarrera.longitude) + "," + "0.0" + "," + "0.0" + "," + datosgeo + "," + voucher + ",# \n"
        //EnviarSocket(Datos)
        self.EnviarTimer(estado: 1, datos: Datos)
        MensajeEspera.text = "Procesando..."
        self.AlertaEsperaView.isHidden = false
        self.origenText.text?.removeAll()
        self.RecordarSwitch.isOn = false
        self.referenciaText.text?.removeAll()
    }
    
   
    
    //CANCELAR SOLICITUDES
    func MostrarMotivoCancelacion(){
        //["No necesito","Demora el servicio","Tarifa incorrecta","Solo probaba el servicio", "Cancelar"]
        let motivoAlerta = UIAlertController(title: "", message: "Seleccione el motivo de cancelación.", preferredStyle: UIAlertController.Style.actionSheet)
        motivoAlerta.addAction(UIAlertAction(title: "No necesito", style: .default, handler: { action in
            
            self.CancelarSolicitudes("No necesito")
            
        }))
        motivoAlerta.addAction(UIAlertAction(title: "Demora el servicio", style: .default, handler: { action in
            
            self.CancelarSolicitudes("Demora el servicio")
            
        }))
        motivoAlerta.addAction(UIAlertAction(title: "Tarifa incorrecta", style: .default, handler: { action in
            
            self.CancelarSolicitudes("Tarifa incorrecta")
            
        }))
        motivoAlerta.addAction(UIAlertAction(title: "Vehículo en mal estado", style: .default, handler: { action in
            
            self.CancelarSolicitudes("Vehículo en mal estado")
            
        }))
        motivoAlerta.addAction(UIAlertAction(title: "Solo probaba el servicio", style: .default, handler: { action in
            
            self.CancelarSolicitudes("Solo probaba el servicio")
            
        }))
        motivoAlerta.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.destructive, handler: { action in
        }))
        self.present(motivoAlerta, animated: true, completion: nil)
    }
    
    /*func CancelarSolicitudes(_ motivo: String){
        //#Cancelarsolicitud, idSolicitud, idTaxi, motivo, "# \n"
        let temp = (myvariables.solpendientes.last?.idTaxi)! + "," + motivo + "," + "# \n"
        let Datos = "#Cancelarsolicitud" + "," + (myvariables.solpendientes.last?.idSolicitud)! + "," + temp
        myvariables.solpendientes.removeLast()
        if myvariables.solpendientes.count == 0 {
            self.SolPendImage.isHidden = true
            CantSolPendientes.isHidden = true
            myvariables.solicitudesproceso = false
        }
        if motivo != "Conductor"{
            EnviarSocket(Datos)
        }
    }*/
    
    func CancelarSolicitudes(_ motivo: String){
        //#Cancelarsolicitud, idSolicitud, idTaxi, motivo, "# \n"
        //let temp = (myvariables.solpendientes.last?.idTaxi)! + "," + motivo + "," + "# \n"
        let Datos = "#Cancelarsolicitud" + "," + (myvariables.solpendientes.last?.idSolicitud)! + "," + "null" + "," + motivo + "," + "# \n"
        myvariables.solpendientes.removeLast()
        if myvariables.solpendientes.count == 0 {
            myvariables.solicitudesproceso = false
        }
        if motivo != "Conductor"{
            EnviarSocket(Datos)
        }
    }
    
    func CloseAPP(){
        let fileAudio = FileManager()
        let AudioPath = NSHomeDirectory() + "/Library/Caches/Audio"
        do {
            try fileAudio.removeItem(atPath: AudioPath)
        }catch{
        }
        let datos = "#SocketClose," + myvariables.cliente.idCliente + ",# \n"
        EnviarSocket(datos)
        exit(3)
    }
    
    
    //FUNCION PARA DIBUJAR LAS ANOTACIONES
    
    func DibujarIconos(_ anotaciones: [MKPointAnnotation]){
        if anotaciones.count == 1{
            self.mapaVista.addAnnotations([self.origenAnotacion,anotaciones[0]])
            self.mapaVista.fitAll(in: self.mapaVista.annotations, andShow: true)
        }else{
            self.mapaVista.addAnnotations(anotaciones)
            self.mapaVista.fitAll(in: anotaciones, andShow: true)
        }
    }
    
    
    //Validar los formularios
    func SoloLetras(name: String) -> Bool {
        // (1):
        let pat = "[0-9,.!@#$%^&*()_+-]"
        // (2):
        //let testStr = "x.wu@strath.ac.uk, ak123@hotmail.com     e1s59@oxford.ac.uk, ee123@cooleng.co.uk, a.khan@surrey.ac.uk"
        // (3):
        let regex = try! NSRegularExpression(pattern: pat, options: [])
        // (4):
        let matches = regex.matches(in: name, options: [], range: NSRange(location: 0, length: name.characters.count))
        print(matches.count)
        if matches.count == 0{
            return true
        }else{
            return false
        }
    }
    
    @objc func ocultarMenu(){
        self.MenuView1.isHidden = true
        self.TransparenciaView.isHidden = true
        self.Inicio()
    }
    
    //CONTROL DE TECLADO VIRTUAL
    //Funciones para mover los elementos para que no queden detrás del teclado
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text?.removeAll()
        if textField.isEqual(self.NombreContactoText) || textField.isEqual(self.TelefonoContactoText){
            if textField.isEqual(self.TelefonoContactoText){
                self.TelefonoContactoText.textColor = UIColor.black
                if (self.NombreContactoText.text?.isEmpty)! || !self.SoloLetras(name: self.NombreContactoText.text!){
                    
                    let alertaDos = UIAlertController (title: "Contactar a otra persona", message: "Debe teclear el nombre de la persona que el conductor debe contactar.", preferredStyle: .alert)
                    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                        self.NombreContactoText.becomeFirstResponder()
                    }))
                    self.present(alertaDos, animated: true, completion: nil)
                }
            }
            self.animateViewMoving(true, moveValue: 190, view: view)
        }else{
            if textField.isEqual(self.origenText){
                if self.DireccionesArray.count != 0{
                    self.TablaDirecciones.frame = CGRect(x: 22, y: Int(self.origenText.frame.origin.y + self.origenText.frame.height), width: Int(self.origenText.frame.width - 2) , height: 44 * self.DireccionesArray.count)
                    self.TablaDirecciones.isHidden = false
                    self.RecordarView.isHidden = true
                }
            }else{
                if !(self.origenText.text?.isEmpty)! && textField.isEqual(self.referenciaText){
                    textField.text?.removeAll()
                    animateViewMoving(true, moveValue: 100, view: self.view)
                }else{
                    self.view.resignFirstResponder()
                    animateViewMoving(true, moveValue: 100, view: self.view)
                    let alertaDos = UIAlertController (title: "Dirección de Origen", message: "Debe teclear la dirección de recogida para orientar al conductor.", preferredStyle: .alert)
                    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                        self.origenText.becomeFirstResponder()
                    }))
                    
                    self.present(alertaDos, animated: true, completion: nil)
                }
            }
        }
    }
    
    func textFieldDidEndEditing(_ textfield: UITextField) {
        if textfield.isEqual(self.NombreContactoText) || textfield.isEqual(self.TelefonoContactoText){
            if textfield.isEqual(self.TelefonoContactoText) && textfield.text?.characters.count != 10 && textfield.text?.characters.count != 9 && !((self.NombreContactoText.text?.isEmpty)!){
                textfield.textColor = UIColor.red
                textfield.text = "Número de teléfono incorrecto"
            }
            self.animateViewMoving(false, moveValue: 190, view: view)
        }else{
            if textfield.isEqual(self.referenciaText){
                self.animateViewMoving(false, moveValue: 100, view: view)
            }
        }
        self.TablaDirecciones.isHidden = true
        self.EnviarSolBtn.isEnabled = true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text?.lengthOfBytes(using: .utf8) == 0{
            self.TablaDirecciones.isHidden = false
            self.RecordarView.isHidden = true
        }else{
            if self.DireccionesArray.count < 5 && textField.text?.lengthOfBytes(using: .utf8) == 1 {
                self.RecordarView.isHidden = false
                //NSLayoutConstraint(item: self.RecordarView, attribute: .bottom, relatedBy: .equal, toItem: self.referenciaText, attribute: .top, multiplier: 1, constant: -10).isActive = true
                //NSLayoutConstraint(item: self.origenText, attribute: .bottom, relatedBy: .equal, toItem: self.referenciaText, attribute: .top, multiplier: 1, constant: -(self.RecordarView.bounds.height + 20)).isActive = true
            }
            self.TablaDirecciones.isHidden = true
        }
        self.EnviarSolBtn.isEnabled = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func animateViewMoving (_ up:Bool, moveValue :CGFloat, view : UIView){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        view.frame = view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
    
    //MARK:- CONTROL DE TECLADO VIRTUAL
    //Funciones para mover los elementos para que no queden detrás del teclado
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.keyboardHeight = keyboardSize.height
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        animateViewMoving(false, moveValue: 60, view: self.view)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.referenciaText.resignFirstResponder()
    }
    
    @objc func ocultarTeclado(sender: UITapGestureRecognizer){
        //sender.cancelsTouchesInView = false
        //self.SolicitudView.endEditing(true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: self.TablaDirecciones) == true {
            gestureRecognizer.cancelsTouchesInView = false
        }else{
            self.SolicitudView.endEditing(true)
        }
        return true
    }
    
    
    
    
    //TABLA FUNCTIONS
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if tableView.isEqual(self.TablaDirecciones){
            return self.DireccionesArray.count
        }else{
            return self.MenuArray.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.isEqual(self.TablaDirecciones){
            let cell = tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath)
            cell.textLabel?.text = self.DireccionesArray[indexPath.row][0]
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MENUCELL", for: indexPath)
            cell.textLabel?.text = self.MenuArray[indexPath.row].title
            cell.imageView?.image = UIImage(named: self.MenuArray[indexPath.row].imagen)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEqual(self.TablaDirecciones){
            self.origenText.text = self.DireccionesArray[indexPath.row][0]
            self.TablaDirecciones.isHidden = true
            self.referenciaText.text = self.DireccionesArray[indexPath.row][1]
            self.origenText.resignFirstResponder()
        }else{
            self.MenuView1.isHidden = true
            self.TransparenciaView.isHidden = true
            tableView.deselectRow(at: indexPath, animated: false)
            switch tableView.cellForRow(at: indexPath)?.textLabel?.text{
            case "En proceso"?:
                if myvariables.solpendientes.count > 0{
                    let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "ListaSolPdtes") as! SolicitudesTableController
                    vc.solicitudesMostrar = myvariables.solpendientes
                    self.navigationController?.show(vc, sender: nil)
                }else{
                    self.SolPendientesView.isHidden = false
                }
            case "Call center"?:
                let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "CallCenter") as! CallCenterController
                vc.telefonosCallCenter = self.TelefonosCallCenter
                self.navigationController?.show(vc, sender: nil)
            case "Perfil"?:
                let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "Perfil") as! PerfilController
                self.navigationController?.show(vc, sender: nil)
            case "Compartir app"?:
                if let name = URL(string: "itms://itunes.apple.com/us/app/apple-store/id1149206387?mt=8") {
                    let objectsToShare = [name]
                    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                    
                    self.present(activityVC, animated: true, completion: nil)
                }
                else
                {
                    // show alert for not available
                }
            default:
                self.CloseAPP()
            }
        }
    }
    
    //FUNCIONES Y EVENTOS PARA ELIMIMAR CELLS, SE NECESITA AGREGAR UITABLEVIEWDATASOURCE
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView.isEqual(self.TablaDirecciones){
            return true
        }else{
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Eliminar"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            self.EliminarFavorita(posFavorita: indexPath.row)
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
            if self.DireccionesArray.count == 0{
                self.TablaDirecciones.isHidden = true
            }
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.isEqual(self.MenuTable){
            return self.MenuTable.frame.height/CGFloat(self.MenuArray.count)
        }else{
            return 44
        }
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
        let datos = "#SocketClose," + myvariables.cliente.idCliente + ",# \n"
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
        
        //Constraint to formulario solicitud
        /*NSLayoutConstraint(item: myView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leadingMargin, multiplier: 1.0, constant: 0.0).isActive = true
         
         NSLayoutConstraint(item: myView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailingMargin, multiplier: 1.0, constant: 0.0).isActive = true
         
         NSLayoutConstraint(item: myView, attribute: .height, relatedBy: .equal, toItem: myView, attribute:.width, multiplier: 2.0, constant:0.0).isActive = true?*/
        
        self.CargarFavoritas()
        self.TablaDirecciones.reloadData()
        self.origenIcono.isHidden = true
        self.origenAnotacion.coordinate = mapaVista.centerCoordinate
        coreLocationManager.stopUpdatingLocation()
        self.SolicitarBtn.isHidden = true
        self.formularioSolicitud.isHidden = false
        let datos = "#Posicion," + myvariables.cliente.idCliente + "," + "\(self.origenAnotacion.coordinate.latitude)," + "\(self.origenAnotacion.coordinate.longitude)," + "# \n"
        EnviarSocket(datos)
        if myvariables.cliente.empresa != "null"{
            self.VoucherView.isHidden = false
            self.VoucherEmpresaName.text = myvariables.cliente.empresa
            NSLayoutConstraint(item: self.BtnsView, attribute: .top, relatedBy: .equal, toItem: self.VoucherView, attribute:.bottom, multiplier: 1.0, constant:15.0).isActive = true
        }else{
            NSLayoutConstraint(item: self.BtnsView, attribute: .top, relatedBy: .equal, toItem: self.ContactoView, attribute:.bottom, multiplier: 1.0, constant:15.0).isActive = true

        }
    }
    
    //Voucher check
    @IBAction func SwicthVoucher(_ sender: Any) {
        if self.VoucherCheck.isOn{
            //self.VoucherEmpresaName.isHidden = false
        }else{
            //self.VoucherEmpresaName.isHidden = true
        }
    }
    
    //Aceptar y Enviar solicitud desde formulario solicitud
    @IBAction func AceptarSolicitud(_ sender: AnyObject) {
        if !(self.NombreContactoText.text?.isEmpty)! && (self.TelefonoContactoText.text?.isEmpty)!{
            let alertaDos = UIAlertController (title: "Contactar a otra persona", message: "Debe teclear el número de teléfono de la persona que el conductor debe contactar.", preferredStyle: .alert)
            alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                
            }))
            self.present(alertaDos, animated: true, completion: nil)
        }else{
            if (!(self.origenText.text?.isEmpty)! && self.TelefonoContactoText.text != "Escriba el nombre del contacto" && self.TelefonoContactoText.text != "Número de teléfono incorrecto"){
                var voucher = "0"
                var recordar = "0"
                var origen = self.origenText.text!.uppercased()
                origen = origen.replacingOccurrences(of: "Ñ", with: "N",options: .regularExpression, range: nil)
                origen = origen.replacingOccurrences(of: "[,.]", with: "-",options: .regularExpression, range: nil)
                origen = origen.replacingOccurrences(of: "[\n]", with: " ",options: .regularExpression, range: nil)
                origen = origen.replacingOccurrences(of: "[#]", with: "No",options: .regularExpression, range: nil)
                origen = origen.folding(options: .diacriticInsensitive, locale: .current)
                
                self.referenciaText.endEditing(true)
                var referencia = self.referenciaText.text!.uppercased()
                referencia = referencia.replacingOccurrences(of: "Ñ", with: "N",options: .regularExpression, range: nil)
                referencia = referencia.replacingOccurrences(of: "[,.]", with: "-",options: .regularExpression, range: nil)
                referencia = referencia.replacingOccurrences(of: "[\n]", with: " ",options: .regularExpression, range: nil)
                referencia = referencia.replacingOccurrences(of: "[#]", with: "No",options: .regularExpression, range: nil)
                referencia = referencia.folding(options: .diacriticInsensitive, locale: .current)
                
                mapaVista.removeAnnotations(self.mapaVista.annotations)
                let nuevaSolicitud = CSolicitud()
                if !(NombreContactoText.text?.isEmpty)!{
                    nuevaSolicitud.DatosOtroCliente(clienteId: myvariables.cliente.idCliente, telefono: self.TelefonoContactoText.text!, nombre: self.NombreContactoText.text!)
                }else{
                    nuevaSolicitud.DatosCliente(cliente: myvariables.cliente)
                }
                nuevaSolicitud.DatosSolicitud(dirorigen: origen, referenciaorigen: referencia, dirdestino: "null", latorigen: String(Double(origenAnotacion.coordinate.latitude)), lngorigen: String(Double(origenAnotacion.coordinate.longitude)), latdestino: "0.0", lngdestino: "0.0",FechaHora: "null")
                if self.VoucherView.isHidden == false && self.VoucherCheck.isOn{
                    voucher = "1"
                }
                if self.RecordarView.isHidden == false && self.RecordarSwitch.isOn{
                    let newFavorita = [self.origenText.text, referenciaText.text]
                    self.GuardarFavorita(newFavorita: newFavorita as! [String])
                }
                self.CrearSolicitud(nuevaSolicitud,voucher: voucher)
                self.RecordarView.isHidden = true
                //self.CancelarSolicitudProceso.isHidden = false
            }else{
                
            }
        }
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
        if myvariables.solpendientes.count > 0{
            DispatchQueue.main.async {
                let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "ListaSolPdtes") as! SolicitudesTableController
                vc.solicitudesMostrar = myvariables.solpendientes
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

extension UITextField {
    func setBottomBorder(borderColor: UIColor) {
        self.borderStyle = UITextField.BorderStyle.none
        self.backgroundColor = UIColor.clear
        let width = 1.0
        let borderLine = UIView()
        borderLine.frame = CGRect(x: 0, y: Double(self.frame.height) - width, width: Double(self.frame.width), height: width)
        borderLine.backgroundColor = borderColor
        self.addSubview(borderLine)
    }
}

extension MKMapView {
    /// when we call this function, we have already added the annotations to the map, and just want all of them to be displayed.
    func fitAll() {
        var zoomRect            = MKMapRect.null;
        for annotation in annotations {
            let annotationPoint = MKMapPoint.init(annotation.coordinate)
            let pointRect       = MKMapRect.init(x: annotationPoint.x, y: annotationPoint.y, width: 0.01, height: 0.01)
            zoomRect            = zoomRect.union(pointRect);
        }
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets.init(top: 100, left: 100, bottom: 100, right: 100), animated: true)
    }
    
    /// we call this function and give it the annotations we want added to the map. we display the annotations if necessary
    func fitAll(in annotations: [MKAnnotation], andShow show: Bool) {
        
        var zoomRect:MKMapRect  = MKMapRect.null
        
        for annotation in annotations {
            let aPoint          = MKMapPoint.init(annotation.coordinate)
            let rect            = MKMapRect.init(x: aPoint.x, y: aPoint.y, width: 0.071, height: 0.071)
            
            if zoomRect.isNull {
                zoomRect = rect
            } else {
                zoomRect = zoomRect.union(rect)
            }
        }
        if(show) {
            addAnnotations(annotations)
        }
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
    }
}
