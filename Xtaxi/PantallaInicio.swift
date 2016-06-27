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
    var cliente : CCliente!
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
    var tarifas = [CTarifa]()
    var tarifario = CTarifario()
    var taxiscercanos = [GMSMarker]()
    var SMSVoz = CSMSVoz()
    var OrigenTarifario = GMSMarker()
    var DestinoTarifario = GMSMarker()
  
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
    @IBOutlet weak var DatosCondBtn: UIButton!

    @IBOutlet weak var ColorAut: UILabel!
    @IBOutlet weak var CancelarSolBtn: UIButton!
    
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
    @IBOutlet weak var SMSVozBtn: UIButton!
    
    @IBOutlet weak var MenuView: UIView!
    @IBOutlet weak var SelectOpcion: UIView!
    @IBOutlet weak var EmergenciaBtn: UIButton!
    @IBOutlet weak var SolicitudesBtn: UIButton!
    @IBOutlet weak var TaximetroBtn: UIButton!
    @IBOutlet weak var TarifarioBtn: UIButton!
    @IBOutlet weak var MapaBtn: UIButton!
    @IBOutlet weak var EsperandoTaxiActivity: UIActivityIndicatorView!
    
    
    
    @IBOutlet weak var EsperaTaxisView: UIView!
    
    //Tarifario
    @IBOutlet weak var DestinoTarifarioBtn: UIButton!    
    @IBOutlet weak var CalcularTarifarioBtn: UIButton!
   
    @IBOutlet weak var ReinciarTarifarioBtn: UIButton!
    
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
        alerta = CAlerta(titulo: TituloAlerta, mensaje: MensajeAlerta, vistaalerta: AlertaView, aceptarbtn: AceptarAlerta, aceptarsolobtn: AceptarSolo, cancelarbtn: CancelarAlerta, tipo: 0, esperandoactivity: EsperandoTaxiActivity)
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
        self.cliente = CCliente()
        
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
                switch temporal[1]{
                case "loginok":
                    self.solicitud.DatosCliente(temporal[4], nombreapellidoscliente: temporal[5], movilcliente: self.login[1])
                    self.idusuario = temporal[2]
                    self.SolicitarBtn.hidden = false
                    if temporal[6] != "0"{
                        self.ListSolicitudPendiente(temporal)
                    }
                    print(temporal[2])
                    self.cliente.AgregarDatosCliente(temporal[2], user: temporal[4], nombre: temporal[5])
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
            else{
               exit(0)
            }
        }
        //EVENTO PARA CARGAR TARIFAS
      myvariables.socket.on("CargarTarifas"){data, ack in
        let tarifario = String(data).componentsSeparatedByString(",")
           var i = 2
            while (i < tarifario.count - 6){
                let unatarifa = CTarifa(horaInicio: tarifario[i], horaFin: tarifario[i+1], valorMinimo: Double(tarifario[i+2])!, tiempoEspera: Double(tarifario[i+3])!, valorKilometro: Double(tarifario[i+4])!, valorArranque: Double(tarifario[i+5])!)
               self.tarifas.append(unatarifa)
                i += 6
            }
        
        self.FijarTarifaSol()
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
                self.MostrarTaxi(temporal)
            }
        }
        
        //Datos del conductor del taxi seleccionado
      /*  myvariables.socket.on("Taxi"){data, ack in
            let temporal = String(data).componentsSeparatedByString(",")
            self.MostrarDatosTaxi(temporal)
        }*/
        //Respuesta de la solicitud enviada
        myvariables.socket.on("Solicitud"){data, ack in
            let temporal = String(data).componentsSeparatedByString(",")
            self.RespuestaSolicitd(temporal)
        }
        
        //GEOPOSICION DE TAXIS
        myvariables.socket.on("Geo"){data, ack in
            let temporal = String(data).componentsSeparatedByString(",")
            if (temporal[1] == self.taxiLocation.title) && (self.taxiLocation.map != nil){
            self.ActualizarTaxi([temporal[1],temporal[2],temporal[3]])
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
            if temporal[0] == "#Aceptada"{
                self.alerta.CambiarTitulo("Estado de solicitud")
                self.alerta.CambiarMensaje(temporal[2] as String)
                self.alerta.DefinirTipo(2)
                self.AlertaView.hidden = false
            }
            else{
                if temporal[0] == "#Cancelada" {
                    //#Cancelada, idsolicitud
                    self.alerta.CambiarTitulo("Estado de solicitud")
                    self.alerta.CambiarMensaje("Ningún vehículo acepto su solicitud, puede intentarlo más tarde")
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
    
    func FijarTarifaSol(){
        for var solicitud in solpendientes {
            solicitud.tarifa = Double(tarifas[2].valorKilometro)
            var temporal = String(solicitud.FechaHora).componentsSeparatedByString(" ")
            var temporal1 = String(temporal[4]).componentsSeparatedByString(":")
            if (0 <= Int(temporal1[0])) && (Int(temporal1[0]) <= 6){
                solicitud.tarifa = Double(tarifas[0].valorKilometro)
                }
                else{
                    if (7 <= Int(temporal1[0])) && (Int(temporal1[0]) <= 17){
                    solicitud.tarifa = Double(tarifas[1].valorKilometro)
                    }
                    else{
                        if (18 <= Int(temporal1[0])) && (Int(temporal1[0]) <= 23){
                        solicitud.tarifa = Double(tarifas[2].valorKilometro)
                    }
                }
            }
        }
    }
    func Inicio(){
        mapaVista!.clear()
        self.coreLocationManager.startUpdatingLocation()
        self.cliente.origenCarrera.position = (self.coreLocationManager.location?.coordinate)!
        self.origenIcono.image = UIImage(named: "origen2")
        self.cliente.origenCarrera.snippet = "Cliente"
        self.cliente.origenCarrera.icon = UIImage(named: "origen")
        mapaVista.camera = GMSCameraPosition.cameraWithLatitude(self.cliente.origenCarrera.position.latitude,longitude: self.cliente.origenCarrera.position.longitude,zoom: 15)
        self.origenIcono.hidden = false
        ExplicacionText.text = "Mueva el mapa hasta el origen"
        ExplicacionView.hidden = false        
        self.TablaSolPendientes.reloadData()
        if solpendientes.count != 0 {
        self.SolPendImage.hidden = false
        self.CantSolPendientes.text = String(self.solpendientes.count)
        self.CantSolPendientes.hidden = false
        }
        AlertaView.hidden = true
        SolicitudAceptadaView.hidden = true
        SMSVozBtn.hidden = true
        EvaluarBtn.hidden = true
        DetallesCarreraView.hidden = true
        formularioSolicitud.hidden = true
        self.SolicitarBtn.hidden = false
        DestinoTarifarioBtn.hidden = true
        CalcularTarifarioBtn.hidden = true
        ReinciarTarifarioBtn.hidden = true
        TablaSolPendientes.hidden = true
        aceptarLocBtn.hidden = true
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
            ExplicacionText.text = "Eliga un origen diferente en el mapa, si lo desea."
            ExplicacionView.hidden = false
            coreLocationManager.stopUpdatingLocation()
        }

    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        self.TablaSolPendientes.hidden = true
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
        if ((taxi.latitude == 0.0) && (taxi.longitude == 0.0)){
            let destinotext = String(destino.latitude) + "," + String(destino.longitude)
            let ruta = CRuta(origin: origentext, destination: destinotext)
            let routePolyline = ruta.drawRoute()
            let lines = GMSPolyline(path: routePolyline)
            lines.strokeWidth = 5
            lines.map = self.mapaVista
            lines.strokeColor = UIColor.greenColor()
            distancia = ruta.totalDistance
            duracion = ruta.totalDuration
        }
        else{
            if ((destino.latitude == 0) && (destino.longitude == 0)){
                let taxitext = String(taxi.latitude) + "," + String(taxi.longitude)
                let ruta = CRuta(origin: origentext, destination: taxitext)
                let routePolyline = ruta.drawRoute()
                let lines = GMSPolyline(path: routePolyline)
                lines.strokeWidth = 5
                lines.map = self.mapaVista
                lines.strokeColor = UIColor.redColor()
                distancia = ruta.totalDistance
                duracion = ruta.totalDuration
            }
            else{
                let destinotext = String(destino.latitude) + "," + String(destino.longitude)
                let taxitext = String(taxi.latitude) + "," + String(taxi.longitude)
                let rutataxi = CRuta(origin: origentext, destination: taxitext)
                let routePolylineTaxi = rutataxi.drawRoute()
                let linestaxi = GMSPolyline(path: routePolylineTaxi)
                    linestaxi.strokeWidth = 4
                    linestaxi.strokeColor = UIColor.redColor()
                    linestaxi.map = self.mapaVista
                    duracion = rutataxi.totalDuration
                let ruta = CRuta(origin: origentext, destination: destinotext)
                let routePolyline = ruta.drawRoute()
                let lines = GMSPolyline(path: routePolyline)
                lines.strokeWidth = 5
                lines.map = self.mapaVista
                lines.strokeColor = UIColor.greenColor()
                distancia = ruta.totalDistance
            }
        }
        
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

   /* func Autenticacion(resultado: [String]){
        switch resultado[1]{
        case "loginok":
            solicitud.DatosCliente(resultado[4], nombreapellidoscliente: resultado[5], movilcliente: self.login[1])
            self.idusuario = resultado[2]
            SolicitarBtn.hidden = false
            if resultado[6] != "0"{
                self.ListSolicitudPendiente(resultado)
            }
            self.cliente.AgregarDatosCliente(resultado[2], user: resultado[4], nombre: resultado[5])
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
        
    }*/
    
    //FUNCION PARA LISTAR SOLICITUDES PENDIENTES
    func ListSolicitudPendiente(listado : [String]){
        var i = 7
        while i <= listado.count-10 {
            let solicitudpdte = CSolPendiente(idSolicitud: listado[i], idTaxi: listado[i + 1], codigo: listado[i + 2], FechaHora: listado[i + 3], Latitudtaxi: listado[i + 4], Longitudtaxi: listado[i + 5], Latitudorigen: listado[i + 6], Longitudorigen: listado[i + 7], Latituddestino: listado[i + 8], Longituddestino: listado[i + 9])
            /*let temporal = RutaCliente( CLLocationCoordinate2D(latitude: Double(listado[i + 6])!, longitude: Double(listado[i + 7])!), destino: CLLocationCoordinate2D(latitude: Double(listado[i + 8])!, longitude: Double(listado[i + 9])!), taxi: CLLocationCoordinate2D(latitude: Double(listado[i + 4])!, longitude: Double(listado[i + 5])!))
            solicitudpdte.distancia = Double(temporal[0])!
            solicitudpdte.tiempo = temporal[1]
            solicitudpdte.CalcularCosto()*/
            solpendientes.append(solicitudpdte)
            i += 10
        }
        print(self.solpendientes.count)
        self.TablaSolPendientes.frame = CGRectMake(109, 56, 167, CGFloat(solpendientes.count * 44))
        self.TablaSolPendientes.reloadData()
        self.CantSolPendientes.hidden = false
        self.CantSolPendientes.text = String(self.solpendientes.count)
        self.SolPendImage.hidden = false
    }


    //FUncion para mostrar los taxis
    func MostrarTaxi(temporal : [String]){
        var i = 2
        while i  <= temporal.count - 6{ 
            let taxiTemp = GMSMarker(position: CLLocationCoordinate2DMake(Double(temporal[i + 2])!, Double(temporal[i + 3])!))
            taxiTemp.title = temporal[i]
            taxiTemp.icon = UIImage(named: "taxi_libre")
            taxiscercanos.append(taxiTemp)
            i += 6
        }
        DibujarIconos(taxiscercanos)
    }
    
    func ActualizarTaxi(temporal : [String]){
        for var taxitemporal in taxiscercanos{
            if taxitemporal.title == temporal[0]{
                
            }
        }
        self.taxiLocation.map = nil
        self.taxiLocation.position = CLLocationCoordinate2DMake(Double(temporal[1])!, Double(temporal[2])!)
        self.taxiLocation.title = temporal[0]
       // self.taxiLocation.icon = UIImage(named: "taxi_libre")
        self.taxiLocation.map = mapaVista
    }
    
    //Funcion para Mostrar Datos del Taxi seleccionado
    func MostrarDatosTaxi(temporal : [String]){
        /*let conductor = CConductor(IdConductor: temporal[9],Nombre: temporal[1], Telefono: temporal[2],UrlFoto: "")
        self.taxi = CTaxi(Matricula: temporal[7],CodTaxi: temporal[4],MarcaVehiculo: temporal[5],ColorVehiculo: temporal[6],GastoCombustible: temporal[8], Conductor: conductor)
        solicitud.DatosTaxiConductor(temporal[9], nombreapellidosconductor: temporal[1], codigovehiculo: temporal[4],movilconductor: temporal[2])*/
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
        self.solicitud.RegistrarFechaHora(Temporal[5], tarifario: self.tarifas)
        //solicitud.FijarTarifa(tarifas)
        
       }
       else{
        if Temporal[1] == "error"{
            alerta.CambiarTitulo("Solicitud")
            alerta.CambiarMensaje("No hay vehículos disponibles en este momento. Puede intentarlo más tarde")
            alerta.DefinirTipo(3)
            AlertaView.hidden = false
        }
        }
    }
    
    func CancelarSolicitudes(posicion: Int, motivo: String){
        let Datos = "#Cancelarsolicitud" + "," + self.solpendientes[posicion].idSolicitud + "," + self.solpendientes[posicion].idTaxi + "," + "# \n"
        EnviarSocket(Datos)
        self.solpendientes.removeAtIndex(posicion)
        self.TablaSolPendientes.reloadData()
        SolicitudDetalleView.hidden = true
        if solpendientes.count == 0 {
            self.SolPendImage.hidden = true
            CantSolPendientes.hidden = true
          }
    }
   
    //Alertas
    func confirmaCarrera(){
        formularioSolicitud.hidden = true
        origenIcono.hidden = true
        mapaVista.clear()
        self.solicitud.DatosSolicitud(self.origenText.text!, referenciaorigen: referenciaText.text!, dirdestino: destinoText.text!, disttaxiorigen: "0", distorigendestino: "0" , consumocombustible: "0", importe: "0", tiempotaxiorigen: "0", tiempoorigendestino: "0", latorigen: String(Double(self.cliente.origenCarrera.position.latitude)), lngorigen: String(Double(self.cliente.origenCarrera.position.longitude)), latdestino: String(Double(self.cliente.destinoCarrera.position.latitude)), lngdestino: String(Double(self.cliente.destinoCarrera.position.longitude)))
        
        self.referenciaText.text = ""
        self.destinoText.text = ""
        self.origenText.text = ""
        DibujarIconos(taxiscercanos)

        self.EnviarDatosSolicitud()
        
        alerta.CambiarTitulo("Solicitud en proceso")
        alerta.CambiarMensaje("Su solicitud se envió a los conductores más cercanos, en pocos segundos recibirá confirmación. Por favor no cierre la aplicación.")
        alerta.DefinirTipo(20)
        AlertaView.hidden = false
        
       /*let temporal = RutaCliente(self.cliente.origenCarrera.position, destino: self.cliente.destinoCarrera.position, taxi: self.taxiLocation.position)
        DistanciaText.text = temporal[0]
        //self.solicitud.AgregarDistanciaTiempo([temporal[0],temporal[1]])
        DuracionText.text = temporal[1]
        CostoText.text = "???" //self.solicitud.CalcularCosto()
        SolicitudMapaView.hidden = false
        DetallesCarreraView.hidden = false*/
        
    }
    
    //FUNCION ENVIAR DATOS DE SOLICITUD DESDE FORMULARIO SOLICITUD
    func EnviarDatosSolicitud(){
        let Datos = "#Solicitud" + "," + self.solicitud.idcliente + "," + self.solicitud.nombreapellidoscliente + "," + self.solicitud.dirorigen + "," + self.solicitud.referenciaorigen + "," + self.solicitud.dirdestino + "," + self.solicitud.distorigendestino +  "," + self.solicitud.importe + "," + self.solicitud.tiempoorigendestino  + "," + self.solicitud.latorigen + "," + self.solicitud.lngorigen + "," + self.solicitud.latdestino + "," + self.solicitud.lngdestino + "," + self.solicitud.movilcliente + "," + "# /n"
        
        EnviarSocket(Datos)
        SolicitudMapaView.hidden = true
        DetallesCarreraView.hidden = false
        LlamarBtn.hidden = false
        EvaluarBtn.hidden = true
        
        //"," + self.solicitud.idconductor + "," + self.solicitud.idtaxi + "," + self.solicitud.nombreapellidosconductor + "," + self.solicitud.codigovehiculo +"," + self.solicitud.disttaxiorigen + "," + self.solicitud.consumocombustible + + self.solicitud.tiempotaxiorigen + "," + self.solicitud.lattaxi + "," + self.solicitud.lngtaxi  "," + self.solicitud.movilconductor +
    }
    
   //FUNCION PARA DIBUJAR LAS ANOTACIONES
    
    func DibujarIconos(anotaciones: [GMSMarker]){
        if anotaciones.count == 1{
            mapaVista!.camera = GMSCameraPosition.cameraWithLatitude(anotaciones[0].position.latitude, longitude: anotaciones[0].position.longitude, zoom: 12)
            anotaciones[0].map = mapaVista
        }
        else{
            for var anotacionview in anotaciones{
                if ((anotacionview.position.latitude != 0) && (anotacionview.position.longitude != 0)){
                anotacionview.map = mapaVista
                
                    }
                fitAllMarkers(anotaciones)
            }
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
    
    //
    func MostrarDetalleSolicitud(posicion : Int){
        self.coreLocationManager.stopUpdatingLocation()
        /*self.mapaVista!.clear()
        let origen = GMSMarker(position: CLLocationCoordinate2DMake(Double(self.solpendientes[posicion].Latitudorigen)!,Double(self.solpendientes[posicion].Longitudorigen)!))
        origen.icon = UIImage(named: "origen")        
        let destino = GMSMarker(position: CLLocationCoordinate2DMake(Double(self.solpendientes[posicion].Latituddestino)!,Double(self.solpendientes[posicion].Longituddestino)!))
        destino.icon = UIImage(named: "destino")
        let taxi = GMSMarker(position: CLLocationCoordinate2DMake(Double(self.solpendientes[posicion].Latitudtaxi)!,Double(self.solpendientes[posicion].Longitudtaxi)!))
        taxi.icon = UIImage(named: "taxi_libre")
        self.DibujarIconos([origen, destino, taxi])
        self.TablaSolPendientes.hidden = true
        //SolicitudDetalleView.hidden = true
        let temporal = RutaCliente( origen.position, destino: destino.position, taxi: taxi.position)*/
        //self.solpendientes[indexselect].AgregarDistanciaTiempo(temporal)
        
        self.origenAnotacion.position = CLLocationCoordinate2DMake(Double(self.solpendientes[posicion].Latitudorigen)!,Double(self.solpendientes[posicion].Longitudorigen)!)
        self.destinoAnotacion.position = CLLocationCoordinate2DMake(Double(self.solpendientes[posicion].Latituddestino)!,Double(self.solpendientes[posicion].Longituddestino)!)
        self.taxiLocation.position = CLLocationCoordinate2DMake(Double(self.solpendientes[posicion].Latitudtaxi)!,Double(self.solpendientes[posicion].Longitudtaxi)!)
        self.taxiLocation.title = self.solpendientes[posicion].idTaxi
        self.DibujarIconos([self.origenAnotacion, self.destinoAnotacion, self.taxiLocation])
        self.TablaSolPendientes.hidden = true
        //SolicitudDetalleView.hidden = true
       let temporal = RutaCliente(self.origenAnotacion.position, destino: self.destinoAnotacion.position, taxi: self.taxiLocation.position)
        //self.solpendientes[posicion].AgregarDistanciaTiempo(temporal)
        self.solpendientes[posicion].CalcularCosto()
        DistanciaText.text = temporal[0] + " KM"
        DuracionText.text = temporal[1]
        CostoText.text = "$" + self.solpendientes[posicion].Costo
        self.SolicitarBtn.hidden = true
        SolicitudAceptadaView.hidden = false
        SMSVozBtn.hidden = false
        EvaluarBtn.hidden = false
        DetallesCarreraView.hidden = false
        //DatosCondBtn.hidden = false
        self.origenIcono.hidden = true
        
    }
    
    func GrabarSMSVoz(){
        DetallesCarreraView.hidden = false
    }
    
    
    //BOTONES DE INTERFAZ
    
    @IBAction func Solicitar(sender: AnyObject) {
        
        self.origenIcono.hidden = true
        self.cliente.origenCarrera.position = mapaVista.camera.target
        self.DireccionDeCoordenada(self.cliente.origenCarrera.position, directionText: origenText)
        coreLocationManager.stopUpdatingLocation()
        self.destinoText.text = ""
        TablaSolPendientes.hidden = true
        self.SolPendImage.hidden = true
        CantSolPendientes.hidden = true
        self.SolicitarBtn.hidden = true
        ExplicacionView.hidden = true
        self.formularioSolicitud.hidden = false
        
        let datos = "#Posicion," + self.cliente.idusuario + "," + "\(self.cliente.origenCarrera.position.latitude)," + "\(self.cliente.origenCarrera.position.longitude)," + "# /n"
        EnviarSocket(datos)
    }
    
    //Botones para solicitud
    // Boton Vista Mapa para origen
 
    //Boton Vista Mapa para Destino
    @IBAction func DestinoBtn(sender: UIButton) {
        self.formularioSolicitud.hidden = true
        self.origenIcono.image = UIImage(named: "destino2@2x")
        self.origenIcono.hidden = false
        self.mapaVista.clear()
        ExplicacionText.text = "Mueva el mapa hasta el destino"
        ExplicacionView.hidden = false
        mapaVista.camera = GMSCameraPosition.cameraWithLatitude(self.cliente.origenCarrera.position.latitude, longitude: self.cliente.origenCarrera.position.longitude, zoom: 15)
        self.coreLocationManager.stopUpdatingLocation()
        self.aceptarLocBtn.hidden = false
    }
    
    //Boton Capturar origen y destino
    @IBAction func AceptarLoc(sender: UIButton) {
            self.formularioSolicitud.hidden = false
            ExplicacionView.hidden = true
            self.aceptarLocBtn.hidden = true
            self.cliente.destinoCarrera = GMSMarker(position: mapaVista.camera.target)
        self.cliente.destinoCarrera.icon = UIImage(named: "destino")
            self.DireccionDeCoordenada(self.cliente.destinoCarrera.position, directionText: destinoText)
            self.confirmaCarrera()
            self.cliente.origenCarrera.map = mapaVista
            self.cliente.destinoCarrera.map = mapaVista
    }
    
    //Boton para Cancelar Carrera
    @IBAction func CancelarSol(sender: UIButton) {
           self.formularioSolicitud.hidden = true
            self.Inicio()
            self.origenText.text = ""
            self.destinoText.text = ""
            self.referenciaText.text = ""
            self.SolicitarBtn.hidden = false
        if solpendientes.count != 0{
            self.SolPendImage.hidden = false
            self.CantSolPendientes.text = String(solpendientes.count)
            self.CantSolPendientes.hidden = false
        }
    }
    //Boton Mostrar Datos Conductor
    @IBAction func DatosConductor(sender: AnyObject) {
        self.DatosConductor.hidden = false
        self.NombreCond.text! = "Nombre: " //+ taxi.Conductor.NombreApellido
        self.MovilCond.text! = "Movil: " //+ taxi.Conductor.Telefono
        self.MarcaAut.text! = "Marca automovil: " //+ taxi.MarcaVehiculo
        self.ColorAut.text! = "Color del automovil: " //+ taxi.ColorVehiculo
        self.MatriculaAut.text! = "Matrícula del automovil: " //+ taxi.Matricula
        //self.ImagenCond.image = UIImage(named: taxi.Conductor.UrlFoto)
    }
    
    @IBAction func AceptarCond(sender: UIButton) {
        self.DatosConductor.hidden = true
        self.NombreCond.text! = ""
        self.MovilCond.text! = ""
        self.MarcaAut.text! = ""
        self.ColorAut.text! = ""
        self.MatriculaAut.text! = ""
    }
    
    //Aceptar y Enviar solicitud desde formulario solicitud
    @IBAction func AceptarSolicitud(sender: AnyObject) {
          /*self.solicitud.DatosSolicitud( origenText.text!, referenciaorigen: referenciaText.text!, dirdestino: destinoText.text!, disttaxiorigen: "0", distorigendestino: "0" , consumocombustible: "0", importe: "0", tiempotaxiorigen: "0", tiempoorigendestino: "0", latorigen: String(Double(origenAnotacion.position.latitude)), lngorigen: String(Double(origenAnotacion.position.longitude)), latdestino: "0", lngdestino: "0")
        self.destinoAnotacion.position = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
            self.origenAnotacion.map = mapaVista*/
            confirmaCarrera()
            //fitAllMarkers([origenAnotacion,taxiLocation])
        }
    
    //Boton Cerrar la APP
   
    @IBAction func CerrarApp(sender: UIButton) {
        Inicio()
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
            Inicio()
        case 3 :
            SolicitudAceptadaView.hidden = false
            SMSVozBtn.hidden = false
            EvaluarBtn.hidden = false
            DetallesCarreraView.hidden = false
            self.CantSolPendientes.text = String(self.solpendientes.count)
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
                self.SolPendImage.hidden = true
            }
            Inicio()
        case 6 :
             Inicio()
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
        
        let Datos = "#Solicitud" + "," + self.solicitud.idcliente + "," + self.solicitud.idconductor + "," + self.solicitud.idtaxi + "," + self.solicitud.nombreapellidoscliente + "," + self.solicitud.nombreapellidosconductor + "," + self.solicitud.codigovehiculo + "," + self.solicitud.dirorigen + "," + self.solicitud.referenciaorigen + "," + self.solicitud.dirdestino + "," + self.solicitud.disttaxiorigen + "," + self.solicitud.distorigendestino + "," + self.solicitud.consumocombustible + "," + self.solicitud.importe + "," + self.solicitud.tiempotaxiorigen + "," + self.solicitud.tiempoorigendestino + "," + self.solicitud.lattaxi + "," + self.solicitud.lngtaxi + "," + self.solicitud.latorigen + "," + self.solicitud.lngorigen + "," + self.solicitud.latdestino + "," + self.solicitud.lngdestino + "," + "" + "," + self.solicitud.movilcliente + "," + self.solicitud.movilconductor + "," + "# /n"
        
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
       /* self.coreLocationManager.stopUpdatingLocation()
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
        self.origenIcono.hidden = true*/
        
    }
    
    
    //BOTONES VISTA MAPA SOLICITUD PENDIENTE
    @IBAction func SolicitarMapaBtn(sender: AnyObject) {
        Inicio()
    }
    
    @IBAction func EvaluarMapaBtn(sender: AnyObject) {
        SolicitudAceptadaView.hidden = true
        SMSVozBtn.hidden = true
        EvaluarBtn.hidden = true
        DetallesCarreraView.hidden = true
        EvaluacionView.hidden = false
    }
    @IBAction func LlamarMapaBtn(sender: AnyObject) {
        
    }
    
    @IBAction func CancelarMapaBtn(sender: AnyObject) {
        OpcionesCancelView.hidden = false        
    }
   
    @IBAction func AceptarEvalucion(sender: AnyObject) {
        EvaluacionView.hidden = true
        SelectOpcion.frame.origin.x = MapaBtn.frame.origin.x - 5
        Inicio()
    }
    
    //BOTONES DEL MENÚ
    @IBAction func MapaMenu(sender: AnyObject) {
       Inicio()
       SelectOpcion.frame.origin.x = MapaBtn.frame.origin.x - 5
    }
    @IBAction func TarifarioMenu(sender: AnyObject) {
        Inicio()
        SolicitarBtn.hidden = true
        DestinoTarifarioBtn.hidden = false
        DestinoTarifarioBtn.titleLabel?.text = "Destino"
        SelectOpcion.frame.origin.x = TarifarioBtn.frame.origin.x - 5
    }
    @IBAction func TaximetroMenu(sender: AnyObject) {
        SelectOpcion.frame.origin.x = TaximetroBtn.frame.origin.x - 5
        Inicio()
        SolicitarBtn.hidden = true
    }
    @IBAction func EmergenciaMenu(sender: AnyObject) {
        SelectOpcion.frame.origin.x = EmergenciaBtn.frame.origin.x - 5
        Inicio()
        SolicitarBtn.hidden = true
    }
    
    @IBAction func DestinoTarifario(sender: AnyObject) {
            self.OrigenTarifario = GMSMarker(position: self.mapaVista.camera.target)
            self.tarifario.InsertarOrigen(OrigenTarifario.position)
            OrigenTarifario.icon = UIImage(named: "origen")
            OrigenTarifario.map = mapaVista
            origenIcono.image = UIImage(named: "destino2@2x")
            ExplicacionText.text = "Elija el destino de la carrera y presione calcular"
            DestinoTarifarioBtn.hidden = true
            CalcularTarifarioBtn.hidden = false
    }
    //LLENAR LA LISTA SOLICITUDES PENDIENTES
    @IBAction func MostrarSolPendientes(sender: AnyObject) {
        SelectOpcion.frame.origin.x = SolPendientesBtn.frame.origin.x - 5
        self.TablaSolPendientes.frame = CGRectMake(65, 105, 225, CGFloat(solpendientes.count * 44))
        TablaSolPendientes.hidden = false
        ExplicacionView.hidden = true
        SolicitarBtn.hidden = true
        SolicitudAceptadaView.hidden = true
        SMSVozBtn.hidden = true
        EvaluarBtn.hidden = true
        DetallesCarreraView.hidden = true
        ReinciarTarifarioBtn.hidden = true
        CalcularTarifarioBtn.hidden = true
        DestinoTarifarioBtn.hidden = true
    }
    @IBAction func CalcularTarifario(sender: AnyObject) {
        self.DestinoTarifario = GMSMarker(position: self.mapaVista.camera.target)
        self.tarifario.InsertarDestino(DestinoTarifario.position)
        DestinoTarifario.icon = UIImage(named: "destino")
        DestinoTarifario.map = mapaVista
        self.fitAllMarkers([self.OrigenTarifario, self.DestinoTarifario])
        origenIcono.hidden = true
        ExplicacionView.hidden = true
        ReinciarTarifarioBtn.hidden = false
        CalcularTarifarioBtn.hidden = true
        let temporal = self.tarifario.CalcularTarifa(tarifas)
        DetallesCarreraView.hidden = false
        let lines = self.tarifario.CalcularRuta()
        lines.strokeWidth = 5
        lines.map = self.mapaVista
        lines.strokeColor = UIColor.greenColor()
        DistanciaText.text = temporal[0] + " KM"
        DuracionText.text = temporal[1]
        CostoText.text = "$" + temporal[2]
    }
    
    @IBAction func ReiniciarTarifario(sender: AnyObject) {
        Inicio()
        ReinciarTarifarioBtn.hidden = true
        DestinoTarifarioBtn.hidden = false
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
        if self.DetallesCarreraView.hidden == true{
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
  
    @IBAction func VozMensaje(sender: AnyObject) {
        if sender.state == UIGestureRecognizerState.Began{
            SMSVoz.TerminarMensaje()
            SMSVoz.ReproducirMensaje()
        }
    }
    
    @IBAction func RecordBegin(sender: AnyObject) {
        if sender.state == UIGestureRecognizerState.Began{
            SMSVoz.GrabarMensaje()
        }
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
            //SolicitudDetalleView.hidden = false
        MostrarDetalleSolicitud(indexPath.row)
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