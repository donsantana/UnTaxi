//
//  PantallaInicioViewController.swift
//  Xtaxi
//
//  Created by Done Santana on 2/11/15.
//  Copyright © 2015 Done Santana. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import GoogleMaps
import Socket_IO_Client_Swift
import AddressBook

class PantallaInicio: UIViewController, CLLocationManagerDelegate, UITextViewDelegate, GMSMapViewDelegate, UITextFieldDelegate {
    var coreLocationManager : CLLocationManager!
    var miposicion = CLLocationCoordinate2D()
    var locationMarker = MKPointAnnotation()
    var taxiLocation : GMSMarker!
    var userAnotacion : GMSMarker!
    var origenAnotacion : GMSMarker!
    var destinoAnotacion : GMSMarker!
    var taxi : CTaxi!
    var login = [String]()
    var solpendientes = [CSolPendiente]()
    var solicitud = CSolicitud()
    var idusuario : String = ""
    var alerta: CAlerta!
    var indexselect = Int()
    var opcionselect = Int()
    var contador = 0
    var centro = CLLocationCoordinate2D()
    let Opciones = ["No necesito","Demora el servicio","Tarifa incorrecta","Solo probaba el servicio"]
    var opcionAnterior : NSIndexPath!
    var evaluacion: CEvaluacion!
    var tarifas : [CTarifa]!
  
    //variables de interfaz
    @IBOutlet weak var taxisDisponible: UILabel!        
    @IBOutlet weak var Geolocalizando: UIActivityIndicatorView!
    @IBOutlet weak var GeolocalizandoView: UIView!
    
    @IBOutlet weak var origenIcono: UIImageView!
    @IBOutlet weak var mapaVista : GMSMapView!
    @IBOutlet weak var ExplicacionView: UIView!
   
    //@IBOutlet weak var menuTable: UITableView!
    @IBOutlet weak var ExplicacionText: UILabel!
   
    
    @IBOutlet weak var destinoText: UITextField!
    @IBOutlet weak var origenText: UITextField!
    @IBOutlet weak var referenciaText: UITextField!
    @IBOutlet weak var formularioSolicitud: UIView!
    @IBOutlet weak var SolicitarBtn: UIButton!
    @IBOutlet weak var DatosConductor: UIView!
    
    //datos del conductor a mostrar
    @IBOutlet weak var ImagenCond: UIImageView!
    @IBOutlet weak var NombreCond: UILabel!
    @IBOutlet weak var MovilCond: UILabel!
    @IBOutlet weak var MarcaAut: UILabel!
    @IBOutlet weak var MatriculaAut: UILabel!

    @IBOutlet weak var ColorAut: UILabel!
    @IBOutlet weak var CancelarSolBtn: UIButton!
    @IBOutlet weak var DatosCondBtn: UIButton!
    @IBOutlet weak var EnviarSolBtn: UIButton!
    
    @IBOutlet weak var aceptarLocBtn: UIButton!
   
    @IBOutlet weak var SolPendientesBtn: UIButton!
    @IBOutlet weak var TablaSolPendientes: UITableView!
    @IBOutlet weak var SolicitudDetalleView: UIView!
    @IBOutlet weak var CantSolPendientes: UILabel!
    @IBOutlet weak var DetallesCarreraView: UIView!
    
    @IBOutlet weak var SolPendImage: UIImageView!
    
    //Alerta View
    @IBOutlet weak var AlertaView: UIView!
    @IBOutlet weak var TituloAlerta: UILabel!
    @IBOutlet weak var MensajeAlerta: UITextView!
    @IBOutlet weak var AceptarAlerta: UIButton!
    @IBOutlet weak var CancelarAlerta: UIButton!
    @IBOutlet weak var AceptarSolo: UIButton!
    @IBOutlet weak var EvaluacionView: UIView!
    @IBOutlet weak var PrimeraStart: UIButton!
    @IBOutlet weak var SegundaStar: UIButton!
    @IBOutlet weak var TerceraStar: UIButton!
    @IBOutlet weak var CuartaStar: UIButton!
    @IBOutlet weak var QuintaStar: UIButton!
    @IBOutlet weak var ComentarioText: UITextView!
   
    
    @IBOutlet weak var SolicitudMapaView: UIView!
    @IBOutlet weak var DistanciaText: UILabel!
    @IBOutlet weak var DuracionText: UILabel!
    @IBOutlet weak var CostoText: UILabel!
    @IBOutlet weak var SolicitudAceptadaView: UIView!
    @IBOutlet weak var EvaluarBtn: UIButton!
    @IBOutlet weak var LlamarBtn: UIButton!
    @IBOutlet weak var OpcionesCancelView: UIView!
    @IBOutlet weak var TablaOpcionesView: UITableView!
    
    
    
    
    
    override func viewDidLoad() {
       super.viewDidLoad()
        //LECTURA DEL FICHERO PARA AUTENTICACION
        //if myvariables.socket
        
        mapaVista.delegate = self
        coreLocationManager = CLLocationManager()
        coreLocationManager.delegate = self
        coreLocationManager.requestWhenInUseAuthorization() //solicitud de autorización para acceder a la localización del usuario
        coreLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        coreLocationManager.startUpdatingLocation()  //Iniciar servicios de actualiación de localización del usuario
        alerta = CAlerta(titulo: TituloAlerta, mensaje: MensajeAlerta, vistaalerta: AlertaView, aceptarbtn: AceptarAlerta, aceptarsolobtn: AceptarSolo, cancelarbtn: CancelarAlerta, tipo: 0)
        //INICIALIZACION DE LOS TEXTFIELD
        origenText.delegate = self
        referenciaText.delegate = self
        destinoText.delegate = self
        ComentarioText.delegate = self
        
        self.userAnotacion = GMSMarker()
        self.taxiLocation = GMSMarker()
        self.taxiLocation.icon = UIImage(named: "taxi_libre")
        self.origenAnotacion = GMSMarker()
        self.origenAnotacion.icon = UIImage(named: "origen")
        self.destinoAnotacion = GMSMarker()
        self.destinoAnotacion.icon = UIImage(named: "destino")
        
        evaluacion = CEvaluacion(botones: [PrimeraStart, SegundaStar,TerceraStar,CuartaStar,QuintaStar])
        
        //Inicializacion del mapa con una vista panoramica de guayaquil
        mapaVista.myLocationEnabled = false
        mapaVista.camera = GMSCameraPosition.cameraWithLatitude(-2.137072,longitude:-79.903454,zoom: 15)
        self.GeolocalizandoView.hidden = false
        
        if myvariables.socket.status.description == "Connecting"{
         sleep(4)
        }
        let ColaHilos = NSOperationQueue()
        let Hilos : NSBlockOperation = NSBlockOperation ( block: {
           self.SocketEventos()            
        })
        ColaHilos.addOperation(Hilos)
        
    }
    
    //FUNCIONES ESCUCHAR SOCKET
    func SocketEventos(){
        //Evento sockect para escuchar
       myvariables.socket.on("LoginPassword"){data, ack in
            let temporal = String(data).componentsSeparatedByString(",")
            if (temporal[0] == "[#LoginPassword"){
                self.Autenticacion(temporal)
            }
            else{
               
            }
        }
        //EVENTO PARA CARGAR TARIFAS
      myvariables.socket.on("CargarTarifas"){data, ack in
       self.prueba()
        /*let tarifario = String(data).componentsSeparatedByString(",")
            print(tarifario)
            var i = 0
            var unatarifa : CTarifa!
            while i < Int(tarifario[1]){
                unatarifa = CTarifa(horaInicio: tarifario[i+2], horaFin: tarifario[i+3], valorMinimo: Double(tarifario[i+4])!, tiempoEspera: Double(tarifario[i+5])!, valorKilometro: Double(tarifario[i+6])!, valorArranque: Double(tarifario[i+7])!)
                i + 8
                self.tarifas.append(unatarifa)
            }*/
        }
        
        //Evento Posicion de taxis
        myvariables.socket.on("Posicion"){data, ack in
            let temporal = String(data).componentsSeparatedByString(",")
            if(temporal[1] == "0") {
                self.alerta.CambiarTitulo("Solicitud de Taxi")
                self.alerta.CambiarMensaje("No hay taxis disponibles en este momento, espere unos minutos e intente otra vez.")
                self.alerta.DefinirTipo(7)
                self.AlertaView.hidden = false
            }
            else{
                self.MostrarTaxis(temporal)
            }
        }
        //Datos del conductor del taxi seleccionado
        myvariables.socket.on("Taxi"){data, ack in
            let temporal = String(data).componentsSeparatedByString(",")
            self.MostrarDatosTaxi(temporal)
        }
        //Respuesta de la solicitud enviada
        myvariables.socket.on("Solicitud"){data, ack in
            let temporal = String(data).componentsSeparatedByString(",")
            self.RespuestaSolicitd(temporal)
        }
        
        //GEOPOSICION DE TAXIS
        myvariables.socket.on("Geoposicion"){data, ack in
            
            self.AlertaView.hidden = false
            let temporal = String(data).componentsSeparatedByString(",")
            var i = 0
            for var solicitudes in self.solpendientes{
           if (temporal[1] == self.solpendientes[i].idTaxi) && (self.taxiLocation.map != nil){
                self.taxiLocation.position = CLLocationCoordinate2D(latitude: Double(temporal[2])!, longitude: Double(temporal[3])!)
            self.DibujarIconos([self.taxiLocation])
            
            }
                i++
          }
        }
        
        //RESPUESTA DE CANCELAR SOLICITUD
        myvariables.socket.on("Cancelarsolicitud"){data, ack in
            let temporal = String(data).componentsSeparatedByString(",")
            if temporal[1] == "ok"{
                self.alerta.CambiarTitulo("Cancelar solicitud")
                self.alerta.CambiarMensaje("Su solicitud ha sido cancelada")
                self.alerta.DefinirTipo(5)
                self.AlertaView.hidden = false
            }
        }
        
        //RESPUESTA DE CONDUCTOR A SOLICITUD
        myvariables.socket.on("Solicitudestado"){data, ack in
            
            let temporal = String(data).componentsSeparatedByString(",")
            //#Sms,idcliente,mensaje
            if temporal[0] == "[#Sms"{
                self.alerta.CambiarTitulo("Estado de solicitud")
                self.alerta.CambiarMensaje(temporal[2] as String)
                self.alerta.DefinirTipo(2)
                self.AlertaView.hidden = false
                self.OcultarVistas()
                let solicitudok = self.BuscarSolicitudID(temporal[1])
                self.origenAnotacion.position = CLLocationCoordinate2DMake(Double(solicitudok.Latitudorigen)!, Double(solicitudok.Longitudorigen)!)
                self.destinoAnotacion.position = CLLocationCoordinate2DMake(Double(solicitudok.Latituddestino)!, Double(solicitudok.Longituddestino)!)
                self.taxiLocation.position = CLLocationCoordinate2DMake(Double(solicitudok.Latitudtaxi)!, Double(solicitudok.Longitudtaxi)!)
                self.DibujarIconos([self.origenAnotacion, self.destinoAnotacion, self.taxiLocation])
                self.RutaCliente(self.origenAnotacion.position, destino: self.destinoAnotacion.position, taxi: self.taxiLocation.position)
                
            }
            else{
                if temporal[0] == "[#Cancelada" {
                    //#Cancelada, idsolicitud
                    self.alerta.CambiarTitulo("Estado de solicitud")
                    self.alerta.CambiarMensaje("Su solicitud ha sido rechazada por el conductor")
                    self.alerta.DefinirTipo(6)
                    self.AlertaView.hidden = false
                }
            }
        }
        
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        miposicion = newLocation.coordinate
        self.setuplocationMarker(miposicion)
        GeolocalizandoView.hidden = true
        self.SolicitarBtn.hidden = false        
        if contador == 0 {
            self.Login()
            contador++
        }
    }
    
    
    func prueba(){
        print("parece")
    }
    func Inicio()
    {
        mapaVista!.clear()
        self.coreLocationManager.startUpdatingLocation()
        self.userAnotacion.position = (self.coreLocationManager.location?.coordinate)!
        self.origenIcono.image = UIImage(named: "origen2")
        userAnotacion.snippet = "Cliente"
        userAnotacion.icon = UIImage(named: "origen")
        mapaVista.camera = GMSCameraPosition.cameraWithLatitude(userAnotacion.position.latitude,longitude:userAnotacion.position.longitude,zoom: 15)
        self.origenIcono.hidden = false
        ExplicacionText.text = "Mueva el mapa hasta el origen"
        ExplicacionView.hidden = false        
        self.TablaSolPendientes.reloadData()
        if solpendientes.count != 0 {
        self.SolPendientesBtn.hidden = false
        self.SolPendImage.hidden = false
        self.CantSolPendientes.text = String(self.solpendientes.count)
        self.CantSolPendientes.hidden = false
        }
        SolicitudAceptadaView.hidden = true
        DetallesCarreraView.hidden = true
        self.SolicitarBtn.hidden = false
    }
    //FUNCIÓN ENVIAR AL SOCKET
    func EnviarSocket(datos: String){
        if myvariables.socket.status.description == "Connected"{
            myvariables.socket.emit("data",datos)
        }
        else{
            self.alerta.CambiarTitulo("Sin Conexión")
            self.alerta.CambiarMensaje("No se puede conectar al servidor por favor intentar otra vez")
            self.alerta.DefinirTipo(4)
            self.AlertaView.hidden = false
        }
    }
    
    //MOSTRAR TODOS LOS MARCADORES EN PANTALLA
    func fitAllMarkers(markers: [GMSMarker]) {
        var bounds = GMSCoordinateBounds()
        for marcador in markers{
            bounds = bounds.includingCoordinate(marcador.position)
        }
        mapaVista.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds))
    }
    func setuplocationMarker(coordinate: CLLocationCoordinate2D) {        
            self.userAnotacion.position = coordinate
            userAnotacion.snippet = "Cliente"
            userAnotacion.icon = UIImage(named: "origen")
            mapaVista.camera = GMSCameraPosition.cameraWithLatitude(userAnotacion.position.latitude,longitude:userAnotacion.position.longitude,zoom: 15)
            self.origenIcono.hidden = false
            ExplicacionText.text = "Mueva el mapa hasta el origen"
            ExplicacionView.hidden = false
            coreLocationManager.stopUpdatingLocation()
        }

    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        //self.TablaSolPendientes.hidden = true
        self.formularioSolicitud.endEditing(true)
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.ComentarioText.resignFirstResponder()
    }
    
    //OCULTAR TECLADO CON TECLA ENTER
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
       //Funcion para ejecutar acciones cuando selecciono un icono en el mapa.
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
       if (self.SolicitarBtn.hidden == true) && (marker.icon == UIImage(named: "taxi_libre"))
        {
            self.formularioSolicitud.hidden = false            
            let Datos = "#Taxi" + "," + self.idusuario + "," + self.taxiLocation.title! + "," + "# /n"
            self.EnviarSocket(Datos)
            ExplicacionView.hidden = true
        }
        return true
    }
    
    
    //Crear las rutas entre los puntos de origen y destino
    func RutaCliente(origen: CLLocationCoordinate2D, destino: CLLocationCoordinate2D, taxi: CLLocationCoordinate2D)->[String]{

        var distancia = "???"
        var duracion = "???"
        let origentext = String(origen.latitude) + "," + String(origen.longitude)
        let destinotext = String(destino.latitude) + "," + String(destino.longitude)
        let taxitext = String(taxi.latitude) + "," + String(taxi.longitude)
        let rutataxi = CRuta(origin: origentext, destination: taxitext)
        let routePolylineTaxi = rutataxi.drawRoute()
        let linestaxi = GMSPolyline(path: routePolylineTaxi)
        linestaxi.strokeWidth = 4
        linestaxi.strokeColor = UIColor.redColor()
        linestaxi.map = self.mapaVista
        if ((destino.latitude != 0) && (destino.longitude != 0)){
          let ruta = CRuta(origin: origentext, destination: destinotext)
          let routePolyline = ruta.drawRoute()
          let lines = GMSPolyline(path: routePolyline)
          lines.strokeWidth = 5
          lines.map = self.mapaVista
            lines.strokeColor = UIColor.greenColor()
            distancia = ruta.totalDistance
            
        }
        duracion = rutataxi.totalDuration
        return [distancia, duracion]
    }
    
    
    //FUNCION DE AUTENTICACION
    func Login(){
        var readString = ""
        let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
        
        do {
            readString = try NSString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding) as String
        } catch {
        }
        self.login = String(readString).componentsSeparatedByString(",")
        EnviarSocket(readString)
        let datos = "#CargarTarifas"
        EnviarSocket(datos)
        
    }

    func Autenticacion(resultado: [String]){
        switch resultado[1]{
        case "loginok":
            solicitud.DatosCliente(resultado[4], nombreapellidoscliente: resultado[5], movilcliente: self.login[1])
            self.idusuario = resultado[2]
            SolicitarBtn.hidden = false
            if resultado[6] != "0"{
                self.ListSolicitudPendiente(resultado)
            }
        case "loginerror":
            let fileManager = NSFileManager()
            let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
            do {
                try fileManager.removeItemAtPath(filePath)
            }catch{
                
            }
            self.alerta.CambiarTitulo("Autenticación")
            self.alerta.CambiarMensaje("Usuario y/o clave incorrectos")
            self.alerta.DefinirTipo(4)
            self.AlertaView.hidden = false
        default: print("Problemas de conexion")
        }
        
    }
    
    //FUNCION PARA LISTAR SOLICITUDES PENDIENTES
    func ListSolicitudPendiente(listado : [String]){
        var i = 7
        while i <= listado.count-10 {
            let solicitudpdte = CSolPendiente(idSolicitud: listado[i], idTaxi: listado[i + 1], codigo: listado[i + 2], FechaHora: listado[i + 3], Latitudtaxi: listado[i + 4], Longitudtaxi: listado[i + 5], Latitudorigen: listado[i + 6], Longitudorigen: listado[i + 7], Latituddestino: listado[i + 8], Longituddestino: listado[i + 9])
            //solicitudpdte.FijarTarifa(tarifas)
            //solicitudpdte.CalcularCosto()
            solpendientes.append(solicitudpdte)
            i += 10
        }
        print(self.solpendientes.count)
        self.TablaSolPendientes.frame = CGRectMake(109, 56, 167, CGFloat(solpendientes.count * 44))
        self.TablaSolPendientes.reloadData()
        self.CantSolPendientes.hidden = false
        self.CantSolPendientes.text = String(self.solpendientes.count)
        self.SolPendientesBtn.hidden = false
        self.SolPendImage.hidden = false
    }


    //FUncion para mostrar los taxis
    func MostrarTaxis(temporal : [String]){
            self.taxiLocation.position = CLLocationCoordinate2DMake(Double(temporal[4])!, Double(temporal[5])!)
            self.taxiLocation.title = temporal[2]
            self.taxiLocation.icon = UIImage(named: "taxi_libre")
            mapaVista!.camera = GMSCameraPosition.cameraWithLatitude(taxiLocation.position.latitude, longitude: taxiLocation.position.longitude, zoom: 13)
        taxiLocation.map = mapaVista
            self.SolicitarBtn.hidden = true
            solicitud.OtrosDatosTaxi(temporal[2], lattaxi: temporal[4], lngtaxi: temporal[5])
      }
    
    //Funcion para Mostrar Datos del Taxi seleccionado
    func MostrarDatosTaxi(temporal : [String]){
        let conductor = CConductor(IdConductor: temporal[9],Nombre: temporal[1], Telefono: temporal[2],UrlFoto: "")
        self.taxi = CTaxi(Matricula: temporal[7],CodTaxi: temporal[4],MarcaVehiculo: temporal[5],ColorVehiculo: temporal[6],GastoCombustible: temporal[8], Conductor: conductor)
        solicitud.DatosTaxiConductor(temporal[9], nombreapellidosconductor: temporal[1], codigovehiculo: temporal[4],movilconductor: temporal[2])
    }
    
    //Respuesta de solicitud
    func RespuestaSolicitd(Temporal : [String]){
       if Temporal[1] == "ok"{
        alerta.CambiarTitulo("Solicitud")
        alerta.CambiarMensaje("Su solicitud se procesó con exito, espere la confirmación del conductor.")
        alerta.DefinirTipo(3)
        AlertaView.hidden = false
        let soltemporal = CSolPendiente(idSolicitud: Temporal[2], idTaxi: Temporal[3], codigo: Temporal[4], FechaHora: Temporal[5], Latitudtaxi: Temporal[6], Longitudtaxi: Temporal[7], Latitudorigen: self.solicitud.latorigen, Longitudorigen: self.solicitud.lngorigen, Latituddestino: self.solicitud.latdestino, Longituddestino: self.solicitud.lngdestino)
        self.solpendientes.append(soltemporal)
        self.solicitud.RegistrarFechaHora(Temporal[5])
        //solicitud.FijarTarifa(tarifas)
       }
    }
    
    func CancelarSolicitudes(posicion: Int, motivo: String){
        let Datos = "#Cancelarsolicitud" + "," + self.solpendientes[posicion].idSolicitud + "," + self.solpendientes[posicion].idTaxi + "," + "# \n"
        EnviarSocket(Datos)
        self.solpendientes.removeAtIndex(posicion)
        self.TablaSolPendientes.reloadData()
        SolicitudDetalleView.hidden = true
        if solpendientes.count == 0 {
            SolPendientesBtn.hidden = true
            self.SolPendImage.hidden = true
            CantSolPendientes.hidden = true
          }
    }
   
    //Alertas
    func confirmaCarrera(){
        formularioSolicitud.hidden = true
        origenIcono.hidden = true
       let temporal = RutaCliente(self.origenAnotacion.position, destino: self.destinoAnotacion.position, taxi: self.taxiLocation.position)
        DistanciaText.text = temporal[0]
        //self.solicitud.AgregarDistanciaTiempo([temporal[0],temporal[1]])
        DuracionText.text = temporal[1]
        CostoText.text = "???" //self.solicitud.CalcularCosto()
        SolicitudMapaView.hidden = false
        DetallesCarreraView.hidden = false
    }   
    
   //FUNCION PARA DIBUJAR LAS ANOTACIONES
    
    func DibujarIconos(anotaciones: [GMSMarker]){
        mapaVista.clear()
        var anotacion = [GMSMarker]()
        if anotaciones.count == 1{
            mapaVista!.camera = GMSCameraPosition.cameraWithLatitude(anotaciones[0].position.latitude, longitude: anotaciones[0].position.longitude, zoom: 12)
            anotaciones[0].map = mapaVista
        }
        else{
            
            var coordenadas = [CLLocationCoordinate2D]()
            for var anotacion in anotaciones{
                if ((anotacion.position.latitude != 0) && (anotacion.position.longitude != 0)){
                coordenadas.append(anotacion.position)
                    }
            }
            mapaVista!.camera = GMSCameraPosition.cameraWithLatitude(self.origenAnotacion.position.latitude, longitude: origenAnotacion.position.longitude, zoom: 12)
            for var anotacionview in anotaciones{
                if ((anotacionview.position.latitude != 0) && (anotacionview.position.longitude != 0)){
                anotacionview.map = mapaVista
                   anotacion.append(anotacionview)
                    }
            }
            fitAllMarkers(anotacion)
        }
        
    }
    
    //FUNCION DETERMINAR DIRECCIÓN A PARTIR DE COORDENADAS
    func DireccionDeCoordenada(coodenada : CLLocationCoordinate2D, directionText : UITextField){
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coodenada) {response, error in
            if let address = response.firstResult() {
                let lines = address.lines as! [String]
                directionText.text = lines.joinWithSeparator(" \n")
            }
        }
    }   
  
    
    //FUNCION LIMPIAR MAPA Y OCULTAR VISTAS
    func OcultarVistas(){
        GeolocalizandoView.hidden = true
        TablaSolPendientes.hidden = true
        formularioSolicitud.hidden = true
        ExplicacionView.hidden = true
        SolicitudDetalleView.hidden = true
        SolicitudMapaView.hidden = true
        AlertaView.hidden = true
        SolicitarBtn.hidden = true
        mapaVista.clear()
    }
    
    //FUNCIÓN BUSCA UNA SOLICITUD DENTRO DEL ARRAY DE SOLICITUDES PENDIENTES DADO SU ID
    func BuscarSolicitudID(id : String)->CSolPendiente{
        var temporal : CSolPendiente!
        for solicitudpdt in solpendientes{
            if solicitudpdt.idSolicitud == id{
                temporal = solicitudpdt
            }
        }
        return temporal
    }
    
    
    
    
    //BOTONES DE INTERFAZ
    
    @IBAction func Solicitar(sender: AnyObject) {
        let datos = "#Posicion," + self.idusuario + "," + "\(self.userAnotacion.position.latitude)," + "\(self.userAnotacion.position.longitude)," + "# /n"
        EnviarSocket(datos)
        //myvariables.socket.emit("data", datos)
        self.origenIcono.hidden = true
        self.origenAnotacion.position = mapaVista.camera.target
        self.DireccionDeCoordenada(origenAnotacion.position, directionText: origenText)
        coreLocationManager.stopUpdatingLocation()
        self.destinoText.text = ""
        TablaSolPendientes.hidden = true
        SolPendientesBtn.hidden = true
        self.SolPendImage.hidden = true
        CantSolPendientes.hidden = true
        ExplicacionText.text = "Pulse sobre el vehículo"
        ExplicacionView.hidden = false
    }
    
    //Botones para solicitud
    // Boton Vista Mapa para origen
 
    //Boton Vista Mapa para Destino
    @IBAction func DestinoBtn(sender: UIButton) {
        self.formularioSolicitud.hidden = true
        self.origenAnotacion.map = mapaVista
        self.origenIcono.image = UIImage(named: "destino2@2x")
        self.origenIcono.hidden = false
        ExplicacionText.text = "Mueva el mapa hasta el destino"
        ExplicacionView.hidden = false
        mapaVista.camera = GMSCameraPosition.cameraWithLatitude(origenAnotacion.position.latitude, longitude: origenAnotacion.position.longitude, zoom: 15)        
        self.coreLocationManager.stopUpdatingLocation()
        self.aceptarLocBtn.hidden = false
    }
    
    //Boton Capturar origen y destino
    @IBAction func AceptarLoc(sender: UIButton) {
     
            self.formularioSolicitud.hidden = false
            ExplicacionView.hidden = true
            self.aceptarLocBtn.hidden = true
            self.destinoAnotacion.position = mapaVista.camera.target
        let destino = GMSMarker(position: self.destinoAnotacion.position)
        destino.icon = UIImage(named: "destino")
        destino.map = mapaVista
            self.DireccionDeCoordenada(destinoAnotacion.position, directionText: destinoText)
        
        
        self.solicitud.DatosSolicitud(String(origenAnotacion.position.latitude) + String(origenAnotacion.position.longitude), referenciaorigen: referenciaText.text!, dirdestino: destinoText.text!, disttaxiorigen: "0", distorigendestino: "0" , consumocombustible: "0", importe: "0", tiempotaxiorigen: "0", tiempoorigendestino: "0", latorigen: String(Double(origenAnotacion.position.latitude)), lngorigen: String(Double(origenAnotacion.position.longitude)), latdestino: String(Double(destinoAnotacion.position.latitude)), lngdestino: String(Double(destinoAnotacion.position.longitude)), vestuariocliente: "")
        self.confirmaCarrera()
        fitAllMarkers([origenAnotacion,destinoAnotacion,taxiLocation])
        
    }
    
    //Boton para Cancelar Carrera
    @IBAction func CancelarSol(sender: UIButton) {
           self.formularioSolicitud.hidden = true
            self.Inicio()
            self.origenText.text = ""
            self.destinoText.text = ""
            self.referenciaText.text = ""
            self.SolicitarBtn.hidden = false
            self.SolPendientesBtn.hidden = false
            self.SolPendImage.hidden = false
            self.CantSolPendientes.text = String(solpendientes.count)
            self.CantSolPendientes.hidden = false
        
    }
    //Boton Mostrar Datos Conductor
    @IBAction func DatosConductor(sender: AnyObject) {
        self.DatosConductor.hidden = false
        self.NombreCond.text! = "Nombre: " + taxi.Conductor.NombreApellido
        self.MovilCond.text! = "Movil: " + taxi.Conductor.Telefono
        self.MarcaAut.text! = "Marca automovil: " + taxi.MarcaVehiculo
        self.ColorAut.text! = "Color del automovil: " + taxi.ColorVehiculo
        self.MatriculaAut.text! = "Matrícula del automovil: " + taxi.Matricula
        self.ImagenCond.image = UIImage(named: taxi.Conductor.UrlFoto)
        }
    
    @IBAction func AceptarCond(sender: UIButton) {
        self.DatosConductor.hidden = true
        self.NombreCond.text! = ""
        self.MovilCond.text! = ""
        self.MarcaAut.text! = ""
        self.ColorAut.text! = ""
        self.MatriculaAut.text! = ""
    }
    
    //Aceptar y Enviar solicitud
    @IBAction func AceptarSolicitud(sender: AnyObject) {
          self.solicitud.DatosSolicitud( origenText.text!, referenciaorigen: referenciaText.text!, dirdestino: destinoText.text!, disttaxiorigen: "0", distorigendestino: "0" , consumocombustible: "0", importe: "0", tiempotaxiorigen: "0", tiempoorigendestino: "0", latorigen: String(Double(origenAnotacion.position.latitude)), lngorigen: String(Double(origenAnotacion.position.longitude)), latdestino: "0", lngdestino: "0", vestuariocliente: "")
        self.destinoAnotacion.position = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
            self.origenAnotacion.map = mapaVista
            confirmaCarrera()
            fitAllMarkers([origenAnotacion,taxiLocation])
        self.referenciaText.text = ""
    }
    
    
    //Boton Cerrar la APP
   
    @IBAction func CerrarApp(sender: UIButton) {
        Inicio()
        SolicitudDetalleView.hidden = true
        alerta.CambiarTitulo("Cerrar sesion")
        alerta.CambiarMensaje("Desea cerrar su sesión")
        alerta.DefinirTipo(10)
        AlertaView.hidden = false     
    }
    
    //BOTENES DE ALERTAS
    @IBAction func AceptarAlerta(sender: AnyObject) {
        //BORRAR FICHERO LOG EN UN DIRECTORIO
        switch alerta.tipo {
        case 10 :
        let fileManager = NSFileManager()
        let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
        do {
            try fileManager.removeItemAtPath(filePath)
        }catch{
            
        }
        exit(0)
        default : exit(0)
        }
        
    }
    
    @IBAction func CancelarAlerta(sender: AnyObject) {
        switch alerta.tipo {
        case 10 :
            exit(0)
        case 11 :
            AlertaView.hidden = true
        default :
            exit(0)
        }
    }
    
    @IBAction func AceptarSoloBtn(sender: AnyObject) {
        switch alerta.tipo{
        case 2 :
            AlertaView.hidden = true
        case 3 :
            SolicitudAceptadaView.hidden = false
            DetallesCarreraView.hidden = false
            self.CantSolPendientes.text = String(self.solpendientes.count)
            SolPendientesBtn.hidden = false
            SolPendImage.hidden = false
            CantSolPendientes.hidden = false
        case 4 :
            exit(0)
        case 5 :
            if solpendientes.count != 0{
                self.TablaSolPendientes.hidden = true
                self.CantSolPendientes.text = String(self.solpendientes.count)
            }
            else{
                self.SolPendientesBtn.hidden = true
                self.SolPendImage.hidden = true
            }
            Inicio()
        case 6 :
             OpcionesCancelView.hidden = false
        case 7 :
            Inicio()
        default :
            exit(0)
        }
        AlertaView.hidden = true
    }
    
    // BOTONES DE VISTA SOLICITUD MAPA 
    //BOTON ACEPTAR Y ENVIAR LA SOLICITUD
    @IBAction func EnviarSolicitudBtn(sender: AnyObject) {
        
        let Datos = "#Solicitud" + "," + self.solicitud.idcliente + "," + self.solicitud.idconductor + "," + self.solicitud.idtaxi + "," + self.solicitud.nombreapellidoscliente + "," + self.solicitud.nombreapellidosconductor + "," + self.solicitud.codigovehiculo + "," + self.solicitud.dirorigen + "," + self.solicitud.referenciaorigen + "," + self.solicitud.dirdestino + "," + self.solicitud.disttaxiorigen + "," + self.solicitud.distorigendestino + "," + self.solicitud.consumocombustible + "," + self.solicitud.importe + "," + self.solicitud.tiempotaxiorigen + "," + self.solicitud.tiempoorigendestino + "," + self.solicitud.lattaxi + "," + self.solicitud.lngtaxi + "," + self.solicitud.latorigen + "," + self.solicitud.lngorigen + "," + self.solicitud.latdestino + "," + self.solicitud.lngdestino + "," + self.solicitud.vestuariocliente + "," + self.solicitud.movilcliente + "," + self.solicitud.movilconductor + "," + "# /n"
        
        EnviarSocket(Datos)
        SolicitudMapaView.hidden = true
        DetallesCarreraView.hidden = false
        LlamarBtn.hidden = false
        EvaluarBtn.hidden = true
    }
    
    
    //BOTON DE CANCELAR EL ENVIO DE LA SOLICITUD
    @IBAction func CancelarEnvioBtn(sender: AnyObject) {
        self.formularioSolicitud.hidden = false
        mapaVista.clear()
        origenAnotacion.map = mapaVista
        taxiLocation.map = mapaVista
        destinoText.text = ""
        SolicitudMapaView.hidden = true
        DetallesCarreraView.hidden = true
    }
    
    
   // BOTONES DE CANCELAR SOLICITUD
    @IBAction func CancelarSolicitud(sender: AnyObject) {
       OpcionesCancelView.hidden = false
        
        //CancelarSolicitudes(indexselect)
    }
   
    @IBAction func NoCancelar(sender: AnyObject) {
        SolicitudDetalleView.hidden = true
        Inicio()
    }
    
    //Botones de Alerta Detalles de Solicitud
    @IBAction func LLamarConductor(sender: AnyObject) {
        
    }
    
    @IBAction func MostrarSolMapa(sender: AnyObject) {
        self.coreLocationManager.stopUpdatingLocation()
        self.mapaVista!.clear()
        self.origenAnotacion.position =  CLLocationCoordinate2DMake(Double(self.solpendientes[indexselect].Latitudorigen)!,Double(self.solpendientes[indexselect].Longitudorigen)!)
        self.destinoAnotacion.position =  CLLocationCoordinate2DMake(Double(self.solpendientes[indexselect].Latituddestino)!,Double(self.solpendientes[indexselect].Longituddestino)!)
        self.taxiLocation.position =  CLLocationCoordinate2DMake(Double(self.solpendientes[indexselect].Latitudtaxi)!,Double(self.solpendientes[indexselect].Longitudtaxi)!)
        self.DibujarIconos([self.origenAnotacion, self.destinoAnotacion, self.taxiLocation])
        self.TablaSolPendientes.hidden = true
        SolicitudDetalleView.hidden = true
        let temporal = RutaCliente(self.origenAnotacion.position, destino: self.destinoAnotacion.position, taxi: self.taxiLocation.position)
        //self.solpendientes[indexselect].AgregarDistanciaTiempo(temporal)
        DistanciaText.text = temporal[0]
        DuracionText.text = temporal[1]
        CostoText.text = "???"
        self.SolicitarBtn.hidden = true
        SolicitudAceptadaView.hidden = false
        DetallesCarreraView.hidden = false
        EvaluarBtn.hidden = false
        LlamarBtn.hidden = true
        self.origenIcono.hidden = true
        
    }
    
    
    //BOTONES VISTA MAPA SOLICITUD PENDIENTE
    @IBAction func SolicitarMapaBtn(sender: AnyObject) {
        Inicio()
    }
    
    @IBAction func EvaluarMapaBtn(sender: AnyObject) {
        SolicitudAceptadaView.hidden = true
        DetallesCarreraView.hidden = true
        EvaluacionView.hidden = false
    }
    @IBAction func LlamarMapaBtn(sender: AnyObject) {
        
    }
    
    @IBAction func CancelarMapaBtn(sender: AnyObject) {
        OpcionesCancelView.hidden = false        
    }
   //LLENAR LA LISTA SOLICITUDES PENDIENTES
    @IBAction func MostrarSolPendientes(sender: AnyObject) {
        self.TablaSolPendientes.frame = CGRectMake(65, 60, 225, CGFloat(solpendientes.count * 44))
        TablaSolPendientes.hidden = false
        ExplicacionView.hidden = true
        SolicitarBtn.hidden = true
        SolicitudAceptadaView.hidden = true
        DetallesCarreraView.hidden = true
        
    }
    @IBAction func AceptarEvalucion(sender: AnyObject) {
        EvaluacionView.hidden = true
        Inicio()
    }
       
    
    //CONTROL DE TECLADO VIRTUAL
    func textFieldDidEndEditing(textfield: UITextField) {
        if textfield.isEqual(destinoText){
            animateViewMoving(false, moveValue: 100)
        }
        else{
        
        }
    }
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.isEqual(ComentarioText){
            animateViewMoving(true, moveValue: 50)
        }
    }
    func textViewDidEndEditing(textView: UITextView) {
        if textView.isEqual(ComentarioText){
            animateViewMoving(false, moveValue: 50)
        }
    }
    //Funciones para mover los elementos para que no queden detrás del teclado
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.isEqual(destinoText){
            animateViewMoving(true, moveValue: 100)
        }
        else{
            
        }
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:NSTimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
        UIView.commitAnimations()
    }
    
    @IBAction func EnviarMotivo(sender: AnyObject) {
        if self.SolPendientesBtn.hidden == true{
            CancelarSolicitudes(solpendientes.count-1, motivo: Opciones[opcionselect])
        }
        else{
            CancelarSolicitudes(indexselect, motivo: Opciones[opcionselect])
        }
        OpcionesCancelView.hidden = true
        opcionAnterior = nil
        TablaOpcionesView.reloadData()
        Inicio()
    }
    @IBAction func CancelarMotivo(sender: AnyObject) {
        OpcionesCancelView.hidden = true
        opcionAnterior = nil
        TablaOpcionesView.reloadData()
    }
    
    //BOTONES PARA EVALUCIÓN DE CARRERA
    
    @IBAction func Star1(sender: AnyObject) {
        evaluacion.EvaluarCarrera(1)
    }
    @IBAction func Star2(sender: AnyObject) {
        evaluacion.EvaluarCarrera(2)
    }
    @IBAction func Star3(sender: AnyObject) {
        evaluacion.EvaluarCarrera(3)
    }
    @IBAction func Star4(sender: AnyObject) {
        evaluacion.EvaluarCarrera(4)
    }
    @IBAction func Star5(sender: AnyObject) {
        evaluacion.EvaluarCarrera(5)
    }
   
    
    //FUNCIONES PARA LA TABLEVIEW
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
       if tableView.isEqual(TablaSolPendientes){
        return solpendientes.count
        }
       else{
            return Opciones.count
        }       
       
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView.isEqual(TablaSolPendientes){
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        // Configure the cell...
        cell.textLabel!.text = solpendientes[indexPath.row].FechaHora
            return cell
        }
        else{
            let cell2 = tableView.dequeueReusableCellWithIdentifier("Opcion", forIndexPath: indexPath)
            if opcionAnterior != indexPath{
                cell2.imageView?.image = UIImage(named: "OpcionesTest")
                cell2.textLabel!.text = Opciones[indexPath.row]
                cell2.backgroundColor = UIColor.darkGrayColor()
            }
            else{
           // Configure the cell...
            cell2.textLabel!.text = Opciones[indexPath.row]
            cell2.imageView?.image = UIImage(named: "OpcionSelecTest")
            cell2.backgroundColor = UIColor(red: 126, green: 126, blue: 126, alpha: 1)
            }
            return cell2
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if tableView.isEqual(TablaSolPendientes){
        indexselect = indexPath.row
        SolicitudDetalleView.hidden = false
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.hidden = true
        }
        else{
            let cell = tableView.dequeueReusableCellWithIdentifier("Opcion", forIndexPath: indexPath)
            // Configure the cell...
            cell.textLabel!.text = Opciones[indexPath.row]
            cell.imageView?.image = UIImage(named: "OpcionSelecTest")
            opcionAnterior = indexPath
            opcionselect = indexPath.row            
            tableView.reloadData()            
        }
    }

}