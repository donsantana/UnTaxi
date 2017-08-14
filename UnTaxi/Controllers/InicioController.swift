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

class InicioController: UIViewController, CLLocationManagerDelegate, UITextViewDelegate, MKMapViewDelegate, UITextFieldDelegate, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, UIApplicationDelegate, UITableViewDelegate, UITableViewDataSource {
    var coreLocationManager : CLLocationManager!
    var miposicion = MKPointAnnotation()
    var origenAnotacion : MKPointAnnotation!
    var taxiLocation : MKPointAnnotation!
    var taxi : CTaxi!
    var login = [String]()
    var idusuario : String = ""
    var indexselect = Int()
    var contador = 0
    var centro = CLLocationCoordinate2D()
    var TelefonosCallCenter = [CTelefono]()
    var opcionAnterior : IndexPath!
    var evaluacion: CEvaluacion!
    var taxiscercanos = [MKPointAnnotation]()
    //var SMSVoz = CSMSVoz()
    
    var responseData = NSMutableData()
    var data: Data!
    var timer = Timer()
    var fechahora: String!
    
    
    var tiempoTemporal = 10
    
    var TaximetroTimer = Timer()
    var TaximetroTotalTimer = Timer()
    var espera = 0
    
    var keyboardHeight:CGFloat!
    
    var DireccionesArray = [[String]]()//[["Dir 1", "Ref1"],["Dir2","Ref2"],["Dir3", "Ref3"],["Dir4","Ref4"],["Dir 5", "Ref5"]]//["Dir 1", "Dir2"]
    

    //variables de interfaz
    
    @IBOutlet weak var origenIcono: UIImageView!
    @IBOutlet weak var mapaVista: MKMapView!

    
    //@IBOutlet weak var destinoText: UITextField!
    @IBOutlet weak var origenText: UITextField!
    @IBOutlet weak var referenciaText: UITextView!
    @IBOutlet weak var TablaDirecciones: UITableView!
    @IBOutlet weak var RecordarView: UIView!
    @IBOutlet weak var RecordarSwitch: UISwitch!

 

    @IBOutlet weak var LocationBtn: UIButton!
    @IBOutlet weak var SolicitarBtn: UIButton!
    @IBOutlet weak var formularioSolicitud: UIView!
    
    @IBOutlet weak var EnviarSolBtn: UIButton!
    
    @IBOutlet weak var aceptarLocBtn: UIButton!
    @IBOutlet weak var CancelarEnvioBtn: UIButton!

    
    //MENU BUTTONS
    @IBOutlet weak var MenuView: UIView!
    @IBOutlet weak var CallCEnterBtn: UIButton!
    @IBOutlet weak var SolPendientesBtn: UIButton!
    @IBOutlet weak var MapaBtn: UIButton!
    @IBOutlet weak var SolPendImage: UIImageView!
    @IBOutlet weak var CantSolPendientes: UILabel!
    @IBOutlet weak var SolPendientesView: UIView!
    @IBOutlet weak var ExplicacionView: UIView!
    @IBOutlet weak var ExplicacionText: UILabel!
    
    
    @IBOutlet weak var AlertaEsperaView: UIView!
    @IBOutlet weak var MensajeEspera: UITextView!
    
    
    //Voucher
    @IBOutlet weak var VoucherView: UIView!
    @IBOutlet weak var VoucherCheck: UISwitch!
    @IBOutlet weak var VoucherEmpresaName: UITextField!
    
    
    @IBOutlet weak var CancelarSolicitudProceso: UIButton!
    
    
    var TimerTemporal = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()
        //LECTURA DEL FICHERO PARA AUTENTICACION
        
        mapaVista.delegate = self
        coreLocationManager = CLLocationManager()
        coreLocationManager.delegate = self
        self.referenciaText.delegate = self
        //solicitud de autorización para acceder a la localización del usuario

        coreLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        coreLocationManager.startUpdatingLocation()  //Iniciar servicios de actualiación de localización del usuario
        
        self.origenAnotacion = MKPointAnnotation()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        
        if let tempLocation = self.coreLocationManager.location?.coordinate{
            self.origenAnotacion.coordinate = (coreLocationManager.location?.coordinate)!
            self.origenAnotacion.title = "origen"
        }else{
            coreLocationManager.requestWhenInUseAuthorization()
            self.origenAnotacion.coordinate = (CLLocationCoordinate2D(latitude: -2.173714, longitude: -79.921601))
        }
        
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegion(center: self.origenAnotacion.coordinate, span: span)
        self.mapaVista.setRegion(region, animated: true)
        //self.mapaVista.addAnnotation(self.origenAnotacion)
        
        //UBICAR LOS BOTONES DEL MENU
        var espacioBtn = self.view.frame.width / 4
        self.CallCEnterBtn.frame = CGRect(x: espacioBtn - 40, y: 5, width: 44, height: 44)
        self.SolPendientesBtn.frame = CGRect(x: (espacioBtn * 2 - 25), y: 5, width: 44, height: 44)
        self.SolPendImage.frame = CGRect(x: (espacioBtn * 2), y: 5, width: 25, height: 22)
        self.CantSolPendientes.frame = CGRect(x: (espacioBtn * 2), y: 5, width: 25, height: 22)
        self.MapaBtn.frame = CGRect(x: (espacioBtn * 3 - 10), y: 5, width: 44, height: 44)
        //self.TarifarioBtn.frame = CGRect(x: (espacioBtn * 3 - 15), y: 5, width: 44, height: 44)
        

        self.taxiLocation = MKPointAnnotation()
        
        if myvariables.solpendientes.count > 0{
            self.CantSolPendientes.isHidden = false
            self.CantSolPendientes.text = String(myvariables.solpendientes.count)
            self.SolPendImage.isHidden = false
        }
        
        if myvariables.socket.reconnects{
            let ColaHilos = OperationQueue()
            let Hilos : BlockOperation = BlockOperation ( block: {
                self.SocketEventos()
                self.timer.invalidate()
                let url = "#U,# \n"
                self.EnviarSocket(url)
                let telefonos = "#Telefonos,# \n"
                self.EnviarSocket(telefonos)
                let datos = "OT"
                self.EnviarSocket(datos)
                if myvariables.solpendientes.count > 0{
                     self.CantSolPendientes.isHidden = false
                     self.CantSolPendientes.text = String(myvariables.solpendientes.count)
                     self.SolPendImage.isHidden = false
                }
            })
            ColaHilos.addOperation(Hilos)
        }else{
            self.Reconect()
        }
        ExplicacionText.text = "Localice el origen"
        ExplicacionView.isHidden = false
        
        //self.referenciaText.enablesReturnKeyAutomatically = false
        self.origenText.delegate = self
        self.TablaDirecciones.delegate = self
        
        self.origenText.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        switch AVAudioSession.sharedInstance().recordPermission() {
        case AVAudioSessionRecordPermission.granted:
            print("Permission granted")
        case AVAudioSessionRecordPermission.denied:
            print("Pemission denied")
        case AVAudioSessionRecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    
                } else{

                }
            })
        default:
            break
        }

    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var anotationView = mapaVista.dequeueReusableAnnotationView(withIdentifier: "annotationView")
        anotationView = MKAnnotationView(annotation: self.origenAnotacion, reuseIdentifier: "annotationView")
        if annotation.title! == "origen"{
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
            self.origenIcono.isHidden = false
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        origenIcono.isHidden = true
        if SolicitarBtn.isHidden == false {
            miposicion.coordinate = (self.mapaVista.centerCoordinate)
            //self.DireccionDeCoordenada(self.miposicion.coordinate, directionText: origenText)
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
                                    if appStoreVersion != currentVersion {
                                        
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
                
                UIApplication.shared.openURL(URL(string: "itms://itunes.apple.com/us/app/apple-store/id1149206387?mt=8")!)
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
                    
                    let alertaDos = UIAlertController (title: "Autenticación", message: "Usuario y/o clave incorrectos", preferredStyle: UIAlertControllerStyle.alert)
                    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                        
                    }))
                    self.present(alertaDos, animated: true, completion: nil)
                case "version":
                    let alertaDos = UIAlertController (title: "Versión de la aplicación", message: "Estimado cliente es necesario que actualice a la última versión de la aplicación disponible en la AppStore. Desea hacerlo en este momento:", preferredStyle: UIAlertControllerStyle.alert)
                    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                        
                    }))
                    alertaDos.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: {alerAction in
                        
                    }))
                    self.present(alertaDos, animated: true, completion: nil)
                default: print("Problemas de conexion")
                }
            }
            else{
                //exit(0)
            }
        }
        
        //EVENTO PARA CARGAR TARIFAS
        myvariables.socket.on("NuevasTarifas"){data, ack in
            let tarifario = String(describing: data).components(separatedBy: ",")            
            var i = 2
            while (i < tarifario.count - 8){
                let unatarifa = CTarifa(horaInicio: tarifario[i], horaFin: tarifario[i+1], valorMinimo: Double(tarifario[i+2])!, tiempoEspera: Double(tarifario[i+3])!, valorKilometro1: Double(tarifario[i+4])!,valorKilometro2: Double(tarifario[i+5])!,valorKilometro3: Double(tarifario[i+6])!, valorArranque: Double(tarifario[i+7])!)
                myvariables.tarifas.append(unatarifa)
                i += 8
            }
        }
        
        //Evento Posicion de taxis
        myvariables.socket.on("Posicion"){data, ack in
            //
            let temporal = String(describing: data).components(separatedBy: ",")
            if(temporal[1] == "0") {
                let alertaDos = UIAlertController(title: "Solicitud de Taxi", message: "No hay taxis disponibles en este momento, espere unos minutos y vuelva a intentarlo.", preferredStyle: UIAlertControllerStyle.alert )
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                    self.Inicio()
                }))                
                self.present(alertaDos, animated: true, completion: nil)
            }
            else{
                self.MostrarTaxi(temporal)
            }
        }
        
        //Respuesta de la solicitud enviada
        myvariables.socket.on("Solicitud"){data, ack in
            //Trama IN: #Solicitud, ok, idsolicitud, fechahora
            //Trama IN: #Solicitud, error
            
            let temporal = String(describing: data).components(separatedBy: ",")
            if temporal[1] == "ok"{
                self.MensajeEspera.text = "Solicitud enviada a todos los taxis cercanos. Esperando respuesta de un conductor."
                self.AlertaEsperaView.isHidden = false
                self.CancelarSolicitudProceso.isHidden = false
                self.ConfirmaSolicitud(temporal)
            }
            else{

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
                let alertaDos = UIAlertController (title: "Cancelar Solicitud", message: "Su solicitud fue cancelada.", preferredStyle: UIAlertControllerStyle.alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                    if myvariables.solpendientes.count != 0{
                        self.SolPendientesView.isHidden = true
                        self.CantSolPendientes.text = String(myvariables.solpendientes.count)
                    }
                    else{
                        self.SolPendImage.isHidden = true
                    }
                    self.Inicio()
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
                        
                        let alertaDos = UIAlertController (title: "Solicitud Aceptada", message: "Su vehículo se encuentra en camino, siga su trayectoria en el mapa y/o comuníquese con el conductor.", preferredStyle: .alert)
                        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                            
                            let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "SolPendientes") as! SolPendController
                            vc.SolicitudPendiente = solicitud
                            vc.posicionSolicitud = myvariables.solpendientes.count - 1
                            self.navigationController?.show(vc, sender: nil)
                        }))
                    
                        self.present(alertaDos, animated: true, completion: nil)
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
                    self.CantSolPendientes.text = String(myvariables.solpendientes.count)
                }else{
                    self.SolPendImage.isHidden = true
                }

                let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "completadaView") as! CompletadaController
                vc.idSolicitud = temporal[1]
                vc.idTaxi = temporal[2]
                vc.distanciaValue = temporal[3]
                vc.tiempoValue = temporal[4]
                vc.costoValue = temporal[5]
                
                self.navigationController?.show(vc, sender: nil)
            }
        }
        
        
        myvariables.socket.on("Cambioestadosolicitudconductor"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            let alertaDos = UIAlertController (title: "Estado de Solicitud", message: "Solicitud cancelada por el conductor.", preferredStyle: UIAlertControllerStyle.alert)
            alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                var pos = -1
                pos = self.BuscarPosSolicitudID(temporal[1])
                if  pos != -1{
                    self.CancelarSolicitudes("Conductor")
                }
                let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "Inicio") as! InicioController
                self.navigationController?.show(vc, sender: nil)
            }))
            self.present(alertaDos, animated: true, completion: nil)
        }
        //SOLICITUDES SIN RESPUESTA DE TAXIS
        myvariables.socket.on("SNA"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            if myvariables.solpendientes.count != 0{
                for solicitudenproceso in myvariables.solpendientes{
                    if solicitudenproceso.idSolicitud == temporal[1]{
                        let alertaDos = UIAlertController (title: "Estado de Solicitud", message: "No se encontó ningún taxi disponible para ejecutar su solicitud. Por favor inténtelo más tarde.", preferredStyle: UIAlertControllerStyle.alert)
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
            print("llego mensaje")
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
                self.GuardarTelefonos(temporal)
            }
        }
        
        //RECUPERAR CLAVES
        myvariables.socket.on("Recuperarclave"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            if temporal[1] == "ok"{
                let alertaDos = UIAlertController (title: "Recuperación de clave", message: "Su clave ha sido recuperada satisfactoriamente, en este momento ha recibido un correo electronico a la dirección: " + temporal[2], preferredStyle: UIAlertControllerStyle.alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                }))
                
                self.present(alertaDos, animated: true, completion: nil)
                
            }
            
        }
        
        //CAMBIAR CLAVE
        /*#Cambiarclave,idusuario,claveold,clavenew
         evento Cambiarclave
         retorno #Cambiarclave,ok
         #Cambiarclave,error*/
        myvariables.socket.on("Cambiarclave"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            if temporal[1] == "ok"{
                let alertaDos = UIAlertController (title: "Cambio de clave", message: "Su clave ha sido cambiada satisfactoriamente", preferredStyle: UIAlertControllerStyle.alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in

                }))
                
                self.present(alertaDos, animated: true, completion: nil)
                
            }else{
                let alertaDos = UIAlertController (title: "Cambio de clave", message: "Se produjo un error al cambiar su clave. Revise la información ingresada e inténtelo más tarde.", preferredStyle: UIAlertControllerStyle.alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in

                }))
                
                self.present(alertaDos, animated: true, completion: nil)
            }
            
        }
    }
    
    //RECONECT SOCKET
    func Reconect(){
        if contador <= 5 {
            myvariables.socket.connect()
            contador += 1
        }
        else{
            let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor intentar otra vez.", preferredStyle: UIAlertControllerStyle.alert)
            alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                exit(0)
            }))
            
            self.present(alertaDos, animated: true, completion: nil)
        }
    }

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
                
                self.present(alertaDos, animated: true, completion: nil)
            }
        }else{
            ErrorConexion()
        }
    }
    
    func Inicio(){
        mapaVista.removeAnnotations(self.mapaVista.annotations)
        self.coreLocationManager.startUpdatingLocation()
        self.origenAnotacion.coordinate = (self.coreLocationManager.location?.coordinate)!
        self.origenIcono.image = UIImage(named: "origen2")
        self.origenAnotacion.title = "origen"
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegion(center: self.origenAnotacion.coordinate, span: span)
        self.mapaVista.setRegion(region, animated: true)

        self.origenIcono.isHidden = false
        ExplicacionText.text = "Localice el origen"
        ExplicacionView.isHidden = false
        if myvariables.solpendientes.count != 0 {
            self.SolPendImage.isHidden = false
            self.CantSolPendientes.text = String(myvariables.solpendientes.count)
            self.CantSolPendientes.isHidden = false
        }
        self.formularioSolicitud.isHidden = true
        self.SolicitarBtn.isHidden = false
        SolPendientesView.isHidden = true
        aceptarLocBtn.isHidden = true
        CancelarEnvioBtn.isHidden = true
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
            solicitudpdte.DatosTaxiConductor(idtaxi: listado[i + 1], matricula: "", codigovehiculo: listado[i + 2], marcaVehiculo: "", colorVehiculo: "", lattaxi: lattaxi, lngtaxi: longtaxi, idconductor: "", nombreapellidosconductor: "", movilconductor: listado[i + 10], foto: "")
            myvariables.solpendientes.append(solicitudpdte)
            if solicitudpdte.idTaxi != ""{
                myvariables.solicitudesproceso = true
            }
            i += 11
        }
        self.CantSolPendientes.isHidden = false
        self.CantSolPendientes.text = String(myvariables.solpendientes.count)
        self.SolPendImage.isHidden = false
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
    
    //GUARDAR LOS DATOS CON COREDATA
    
    func GuardarTelefonos(_ telefonos: [String]) {
        // create an instance of our managedObjectContext
        let moc = DataController().managedObjectContext
        
        //let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        //let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Telefonos")
        fetchRequest.returnsObjectsAsFaults = false
        
        do
        {
            let results = try moc.fetch(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                moc.delete(managedObjectData)
            }
        } catch {
            
        }
        
        //moc.delete(data)
        var i = 2
        while i <= telefonos.count - 4{
            let entity = NSEntityDescription.insertNewObject(forEntityName: "Telefonos", into: moc) as! Telefonos
            // add our data
            entity.setValue(telefonos[i], forKey: "numerotelefono")
            entity.setValue(telefonos[i + 1], forKey: "operadoratelefono")
            
            // we save our entity
            do {
                try moc.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
            i += 4
        }
    }
    
    //Respuesta de solicitud
    func ConfirmaSolicitud(_ Temporal : [String]){
        //Trama IN: #Solicitud, ok, idsolicitud, fechahora
        
        if Temporal[1] == "ok"{
            myvariables.solpendientes.last!.RegistrarFechaHora(IdSolicitud: Temporal[2], FechaHora: Temporal[3])
            self.CantSolPendientes.isHidden = false
            self.CantSolPendientes.text = String(myvariables.solpendientes.count)
            self.SolPendImage.isHidden = false
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
        while i  <= temporal.count - 6{
            let taxiTemp = MKPointAnnotation()
            taxiTemp.coordinate = CLLocationCoordinate2DMake(Double(temporal[i + 2])!, Double(temporal[i + 3])!)
            taxiTemp.title = temporal[i]
            //taxiTemp.icon = UIImage(named: "taxi_libre")
            taxiscercanos.append(taxiTemp)
            i += 6
        }
        DibujarIconos(taxiscercanos)
    }


    //FUNCIONES ESCUCHAR SOCKET
    func ErrorConexion(){
        //self.CargarTelefonos()
        //AlertaSinConexion.isHidden = false
        
        let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor revise su conexión a Internet.", preferredStyle: UIAlertControllerStyle.alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
            exit(0)
        }))

        
        self.present(alertaDos, animated: true, completion: nil)
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
        print(Datos)
        EnviarSocket(Datos)
        MensajeEspera.text = "Procesando..."
        self.AlertaEsperaView.isHidden = false
        self.origenText.text?.removeAll()
        self.RecordarSwitch.isOn = false
        self.referenciaText.text?.removeAll()
    }
    
    //FUNCION PARA DIBUJAR LAS ANOTACIONES
    
    func DibujarIconos(_ anotaciones: [MKPointAnnotation]){
        if anotaciones.count == 1{
            let span = MKCoordinateSpanMake(0.005, 0.005)
            let region = MKCoordinateRegion(center: anotaciones[0].coordinate, span: span)
            self.mapaVista.setRegion(region, animated: true)
            self.mapaVista.addAnnotation(anotaciones[0])
        }
        else{
            for var anotacionview in anotaciones{
                if ((anotacionview.coordinate.latitude != 0) && (anotacionview.coordinate.longitude != 0)){
                    self.mapaVista.addAnnotation(anotacionview)
                }
            }
        }
    }
    
    //CANCELAR SOLICITUDES
    func MostrarMotivoCancelacion(){
        let motivoAlerta = UIAlertController(title: "", message: "Seleccione el motivo de cancelación.", preferredStyle: UIAlertControllerStyle.actionSheet)
        motivoAlerta.addAction(UIAlertAction(title: "No necesito", style: .default, handler: { action in
            //["No necesito","Demora el servicio","Tarifa incorrecta","Solo probaba el servicio", "Cancelar"]
                self.CancelarSolicitudes("No necesito")
   
        }))
        motivoAlerta.addAction(UIAlertAction(title: "Demora el servicio", style: .default, handler: { action in
            //["No necesito","Demora el servicio","Tarifa incorrecta","Solo probaba el servicio", "Cancelar"]
            
                self.CancelarSolicitudes("Demora el servicio")
      
        }))
        motivoAlerta.addAction(UIAlertAction(title: "Tarifa incorrecta", style: .default, handler: { action in
            //["No necesito","Demora el servicio","Tarifa incorrecta","Solo probaba el servicio", "Cancelar"]

                self.CancelarSolicitudes("Tarifa incorrecta")
       
        }))
        motivoAlerta.addAction(UIAlertAction(title: "Vehículo en mal estado", style: .default, handler: { action in
            //["No necesito","Demora el servicio","Tarifa incorrecta","Solo probaba el servicio", "Cancelar"]

                self.CancelarSolicitudes("Vehículo en mal estado")

        }))
        motivoAlerta.addAction(UIAlertAction(title: "Solo probaba el servicio", style: .default, handler: { action in
            //["No necesito","Demora el servicio","Tarifa incorrecta","Solo probaba el servicio", "Cancelar"]

                self.CancelarSolicitudes("Solo probaba el servicio")

        }))
        motivoAlerta.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.destructive, handler: { action in
        }))
        self.present(motivoAlerta, animated: true, completion: nil)
    }
    
    func CancelarSolicitudes(_ motivo: String){
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
    }
    
    //MARK:- BOTONES GRAFICOS ACCIONES
    @IBAction func CerrarApp(_ sender: Any) {
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
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegion(center: self.origenAnotacion.coordinate, span: span)
        self.mapaVista.setRegion(region, animated: true)

    }
    //SOLICITAR BUTTON
    @IBAction func Solicitar(_ sender: AnyObject) {
        //TRAMA OUT: #Posicion,idCliente,latorig,lngorig
        self.CargarFavoritas()
        self.TablaDirecciones.reloadData()
        self.origenIcono.isHidden = true
        self.origenAnotacion.coordinate = mapaVista.centerCoordinate
        coreLocationManager.stopUpdatingLocation()
        self.SolicitarBtn.isHidden = true
        ExplicacionView.isHidden = true
        self.formularioSolicitud.isHidden = false
        let datos = "#Posicion," + myvariables.cliente.idCliente + "," + "\(self.origenAnotacion.coordinate.latitude)," + "\(self.origenAnotacion.coordinate.longitude)," + "# \n"
        EnviarSocket(datos)
        if myvariables.cliente.empresa != "null"{
            self.VoucherView.isHidden = false
            self.VoucherEmpresaName.text = myvariables.cliente.empresa
        }
    }
    
    //Voucher check
    @IBAction func SwicthVoucher(_ sender: Any) {
        if self.VoucherCheck.isOn{
            self.VoucherEmpresaName.isHidden = false
        }else{
            self.VoucherEmpresaName.isHidden = true
        }
    }
   
    //Aceptar y Enviar solicitud desde formulario solicitud
    @IBAction func AceptarSolicitud(_ sender: AnyObject) {
        if !(self.origenText.text?.isEmpty)! {
            var voucher = "0"
            var recordar = "0"
            self.referenciaText.endEditing(true)
            
            mapaVista.removeAnnotations(self.mapaVista.annotations)
            let nuevaSolicitud = CSolicitud()
            nuevaSolicitud.DatosCliente(cliente: myvariables.cliente)
            nuevaSolicitud.DatosSolicitud(dirorigen: self.origenText.text!, referenciaorigen: referenciaText.text!, dirdestino: "null", latorigen: String(Double(origenAnotacion.coordinate.latitude)), lngorigen: String(Double(origenAnotacion.coordinate.longitude)), latdestino: "0.0", lngdestino: "0.0",FechaHora: "null")
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
    
    //Boton para Cancelar Carrera
    @IBAction func CancelarSol(_ sender: UIButton) {
        self.formularioSolicitud.isHidden = true
        self.referenciaText.endEditing(true)
        self.Inicio()
        self.origenText.text?.removeAll()
        self.RecordarView.isHidden = true
        self.RecordarSwitch.isOn = false
        //self.destinoText.text?.removeAll()
        self.referenciaText.text?.removeAll()
        self.SolicitarBtn.isHidden = false
        if myvariables.solpendientes.count != 0{
            self.SolPendImage.isHidden = false
            self.CantSolPendientes.text = String(myvariables.solpendientes.count)
            self.CantSolPendientes.isHidden = false
        }
    }
    // CANCELAR LA SOL MIENTRAS SE ESPERA LA FONFIRMACI'ON DEL TAXI
    @IBAction func CancelarProcesoSolicitud(_ sender: AnyObject) {
        MostrarMotivoCancelacion()
    }
    
    
    @IBAction func MostrarTelefonosCC(_ sender: AnyObject) {
        self.SolPendientesView.isHidden = true
        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "CallCenter") as! CallCenterController
        vc.telefonosCallCenter = self.TelefonosCallCenter
        self.navigationController?.show(vc, sender: nil)
        
    }
    
    @IBAction func MostrarSolPendientes(_ sender: AnyObject) {
        
        if myvariables.solpendientes.count > 0{
        
        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "ListaSolPdtes") as! SolicitudesTableController
        vc.solicitudesMostrar = myvariables.solpendientes
        self.navigationController?.show(vc, sender: nil)
        }else{
            self.ExplicacionView.isHidden = !self.ExplicacionView.isHidden
            self.SolPendientesView.isHidden = !self.SolPendientesView.isHidden
        }
        
    }
    @IBAction func TaximetroMenu(_ sender: AnyObject) {
        self.SolPendientesView.isHidden = true
    }
    
    @IBAction func TarifarioMenu(_ sender: AnyObject) {
        self.SolPendientesView.isHidden = true
    }
    @IBAction func MapaMenu(_ sender: AnyObject) {
        Inicio()
    }
    @IBAction func CompartirApp(_ sender: Any) {
        if let name = URL(string: "itms://itunes.apple.com/us/app/apple-store/id1149206387?mt=8") {
            let objectsToShare = [name]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            self.present(activityVC, animated: true, completion: nil)
        }
        else
        {
            // show alert for not available
        }
    }

    //CONTROL DE TECLADO VIRTUAL
    //Funciones para mover los elementos para que no queden detrás del teclado
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text?.removeAll()
        self.referenciaText.text.removeAll()
        if self.DireccionesArray.count != 0{
            self.TablaDirecciones.frame = CGRect(x: 20, y: 65, width: 261, height: 44 * self.DireccionesArray.count)
            self.TablaDirecciones.isHidden = false
            self.RecordarView.isHidden = true
        }
        self.animateViewMoving(true, moveValue: 50, view: view)
    }
    func textFieldDidEndEditing(_ textfield: UITextField) {
        self.animateViewMoving(false, moveValue: 50, view: view)
        self.EnviarSolBtn.isEnabled = true
    }
    func textFieldDidChange(_ textField: UITextField) {
        if textField.text?.lengthOfBytes(using: .utf8) == 0{
            self.TablaDirecciones.isHidden = false
        }else{
            self.TablaDirecciones.isHidden = true
        }
        
        if self.DireccionesArray.count < 5 {
            self.RecordarView.isHidden = false
        }
        
        self.EnviarSolBtn.isEnabled = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //self.origenText.resignFirstResponder()
        self.referenciaText.becomeFirstResponder()
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

    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.keyboardHeight = keyboardSize.height
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if !(self.origenText.text?.isEmpty)!{
            textView.text.removeAll()
            animateViewMoving(true, moveValue: self.keyboardHeight, view: self.view)
        }else{
            self.referenciaText.resignFirstResponder()
            animateViewMoving(true, moveValue: self.keyboardHeight, view: self.view)
            let alertaDos = UIAlertController (title: "Dirección de Origen", message: "Debe teclear la dirección de recogida para orientar al conductor.", preferredStyle: .alert)
            alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
               self.origenText.becomeFirstResponder()
            }))
            
            self.present(alertaDos, animated: true, completion: nil)
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        animateViewMoving(false, moveValue: self.keyboardHeight, view: self.view)
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.referenciaText.resignFirstResponder()
    }
    
    //TABLA FUNCTIONS
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.DireccionesArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath)
        cell.textLabel?.text = self.DireccionesArray[indexPath.row][0]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.origenText.text = self.DireccionesArray[indexPath.row][0]
        self.TablaDirecciones.isHidden = true
        self.origenText.resignFirstResponder()
        self.referenciaText.text = self.DireccionesArray[indexPath.row][1]
    }
    
    //FUNCIONES Y EVENTOS PARA ELIMIMAR CELLS, SE NECESITA AGREGAR UITABLEVIEWDATASOURCE
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Eliminar"
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            self.EliminarFavorita(posFavorita: indexPath.row)
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
            if self.DireccionesArray.count == 0{
                self.TablaDirecciones.isHidden = true
            }
            tableView.reloadData()
        
        }
    }


    
}
