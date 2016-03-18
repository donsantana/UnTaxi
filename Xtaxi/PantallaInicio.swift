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

class PantallaInicio: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UITextFieldDelegate {
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
    var contador = 0
    var centro = CLLocationCoordinate2D()
    
  
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
    @IBOutlet weak var vestuarioText: UITextField!
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
    
    
    //Alerta View
    @IBOutlet weak var AlertaView: UIView!
    @IBOutlet weak var TituloAlerta: UILabel!
    @IBOutlet weak var MensajeAlerta: UITextView!
    @IBOutlet weak var AceptarAlerta: UIButton!
    @IBOutlet weak var CancelarAlerta: UIButton!
    @IBOutlet weak var AceptarSolo: UIButton!
    
    
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
        vestuarioText.delegate = self
        
        self.userAnotacion = GMSMarker()
        self.taxiLocation = GMSMarker()
        self.taxiLocation.icon = UIImage(named: "taxi_libre")
        self.origenAnotacion = GMSMarker()
        self.origenAnotacion.icon = UIImage(named: "origen")
        self.destinoAnotacion = GMSMarker()
        self.destinoAnotacion.icon = UIImage(named: "destino")
       
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
        
        //Evento Posicion de taxis
        myvariables.socket.on("Posicion"){data, ack in
            let temporal = String(data).componentsSeparatedByString(",")
            if(temporal[1] == "0") {
                self.taxisDisponible.hidden = false
                self.taxisDisponible.text = "No hay taxis"
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
            if temporal[0] == "#Geoposicion"{
                print("ok")
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
            }
            else{
                if temporal[0] == "[#Cancelada" {
                    //#Cancelada, idsolicitud
                    self.alerta.CambiarTitulo("Estado de solicitud")
                    self.alerta.CambiarMensaje("Su solicitud ha sido rechazada por el conductor")
                    self.alerta.DefinirTipo(2)
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
    }
    func setuplocationMarker(coordinate: CLLocationCoordinate2D) {
        if (userAnotacion.map == nil ){
            self.userAnotacion.position = coordinate
            userAnotacion.snippet = "Cliente"
            userAnotacion.icon = UIImage(named: "origen")
            mapaVista.camera = GMSCameraPosition.cameraWithLatitude(userAnotacion.position.latitude,longitude:userAnotacion.position.longitude,zoom: 15)
            self.origenIcono.hidden = false
            ExplicacionText.text = "Mueva el mapa hasta el origen"
            ExplicacionView.hidden = false
        }
    }

    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        self.TablaSolPendientes.hidden = true
        self.formularioSolicitud.endEditing(true)
    }
    
    //OCULTAR TECLADO CON TECLA ENTER
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
       //Funcion para ejecutar acciones cuando selecciono un icono en el mapa.
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        if (marker.icon == UIImage(named: "taxi_libre") && (SolicitarBtn.hidden == true)){
            taxiLocation.map = nil
            self.formularioSolicitud.hidden = false            
            let Datos = "#Taxi" + "," + self.idusuario + "," + self.taxiLocation.title! + "," + "# /n"
            myvariables.socket.emit("data", Datos)
            ExplicacionView.hidden = true
        }
        return true
    }
    //EVENTOS PARA TOCADAS EN MAPA
    
    //Crear las rutas entre los puntos de origen y destino
    func RutaCliente(origen: CLLocationCoordinate2D, destino: CLLocationCoordinate2D, taxi: CLLocationCoordinate2D){

        let origen = String(origen.latitude) + "," + String(origen.longitude)
        let destino = String(destino.latitude) + "," + String(destino.longitude)
        let taxi = String(taxi.latitude) + "," + String(taxi.longitude)
        let ruta = CRuta(origin: origen, destination: destino)
        let rutataxi = CRuta(origin: origen, destination: taxi)
        let routePolyline = ruta.drawRoute()
        let routePolylineTaxi = rutataxi.drawRoute()
        let lines = GMSPolyline(path: routePolyline)
        let linestaxi = GMSPolyline(path: routePolylineTaxi)
        lines.strokeWidth = 5
        linestaxi.strokeWidth = 4
        linestaxi.strokeColor = UIColor.redColor()
        linestaxi.map = self.mapaVista
        lines.map = self.mapaVista        
        ExplicacionText.text = ruta.totalDistance        
    }
    
    //FUNCIONES PROPIAS
    //FUNCION DE AUTENTICACION
    func Login(){
        var readString = ""
        let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
        
        do {
            readString = try NSString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding) as String
        } catch {
        }
        print(readString)
        if myvariables.socket.status.description == "Connected"{
            myvariables.socket.emit("data",readString)
            self.login = String(readString).componentsSeparatedByString(",")
        }
        else{
            self.alerta.CambiarTitulo("Sin Conexión")
            self.alerta.CambiarMensaje("No se puede conectar al servidor por favor intentar otra vez")
            self.alerta.DefinirTipo(4)
            self.AlertaView.hidden = false
            self.SolicitarBtn.hidden = true
        }
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
        //case "loginerror": self.Usuario.text = "usuario incorrecto"
        default: print("Problemas de conexion")
        }
        
    }
    
    //FUNCION PARA LISTAR SOLICITUDES PENDIENTES
    func ListSolicitudPendiente(listado : [String]){
        var i = 7
        while i <= listado.count-10 {
            let solicitud = CSolPendiente(idSolicitud: listado[i], idTaxi: listado[i + 1], codigo: listado[i + 2], FechaHora: listado[i + 3], Latitudtaxi: listado[i + 4], Longitudtaxi: listado[i + 5], Latitudorigen: listado[i + 6], Longitudorigen: listado[i + 7], Latituddestino: listado[i + 8], Longituddestino: listado[i + 9])
            solpendientes.append(solicitud)
            i += 10
        }
        print(self.solpendientes.count)
        self.TablaSolPendientes.frame = CGRectMake(109, 56, 167, CGFloat(solpendientes.count * 44))
        self.TablaSolPendientes.reloadData()
        self.CantSolPendientes.hidden = false
        self.CantSolPendientes.text = String(self.solpendientes.count)
        self.SolPendientesBtn.hidden = false
    }


    //FUncion para mostrar los taxis
    func MostrarTaxis(temporal : [String]){
            //let posicionTaxi = CLLocationCoordinate2D(latitude: Double(temporal[4])!, longitude: Double(temporal[5])!)
            self.taxiLocation.position = CLLocationCoordinate2DMake(Double(temporal[4])!, Double(temporal[5])!)
            self.taxiLocation.title = temporal[2]
            self.DibujarIconos([taxiLocation], span: 15)
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
        }
    }
   
    //Alertas
    func confirmaCarrera (){
        alerta.CambiarTitulo("Envio de la solicitud")
        alerta.CambiarMensaje("Desea enviar la solicitud en proceso")
        alerta.DefinirTipo(11)
        AlertaView.hidden = false
    }
   
    
    //FUNCIONES PARA CALCULAR PUNTO MEDIO
    
    func PuntoMedio(coordenadas : [CLLocationCoordinate2D])->CLLocationCoordinate2D{
        return middlePointOfListMarkers(coordenadas)
    }
    
    func degreeToRadian( angle : CLLocationDegrees) -> CGFloat{
        
        return (CGFloat(angle)) / 180.0 * CGFloat(M_PI)
        
    }
    
    //        /** Radians to Degrees **/
    
    func radianToDegree(radian:CGFloat) -> CLLocationDegrees{
        
        return CLLocationDegrees(  radian * CGFloat(180.0 / M_PI)  )
        
    }
    
    func middlePointOfListMarkers(listCoords: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
        
        var x = 0.0 as CGFloat
        
        var y = 0.0 as CGFloat
        
        var z = 0.0 as CGFloat
        
        
        
        for coordinates in listCoords{
            
            let lat = degreeToRadian(coordinates.latitude)
            
            let lon = degreeToRadian(coordinates.longitude)
            
            x = x + cos(lat) * cos(lon)
            
            y = y + cos(lat) * sin(lon);
            
            z = z + sin(lat);
            
        }
        
        x = x/CGFloat(listCoords.count)
        
        y = y/CGFloat(listCoords.count)
        
        z = z/CGFloat(listCoords.count)
        
        
        
        let resultLon: CGFloat = atan2(y, x)
        
        let resultHyp: CGFloat = sqrt(x*x+y*y)
        
        let resultLat:CGFloat = atan2(z, resultHyp)
        
        
        
        let newLat = radianToDegree(resultLat)
        
        let newLon = radianToDegree(resultLon)
        
        let result:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: newLat, longitude: newLon)
        
        return result
    }

    
    //FUNCION PARA DIBUJAR LAS ANOTACIONES
    
    func DibujarIconos(anotaciones: [GMSMarker], span: Float){
        mapaVista.clear()
        if anotaciones.count == 1{
            mapaVista!.camera = GMSCameraPosition.cameraWithLatitude(anotaciones[0].position.latitude, longitude: anotaciones[0].position.longitude, zoom: span)
            anotaciones[0].map = mapaVista
        }
        else{
            var coordenadas = [CLLocationCoordinate2D]()
            for var anotacion in anotaciones{
                coordenadas.append(anotacion.position)
            }
            let centroVista = PuntoMedio(coordenadas)
            mapaVista!.camera = GMSCameraPosition.cameraWithLatitude(centroVista.latitude, longitude: centroVista.longitude, zoom: span)
            for var anotacionview in anotaciones{
                anotacionview.map = mapaVista
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
    
  
    
    //BOTONES DE INTERFAZ
    
    @IBAction func Solicitar(sender: AnyObject) {
        let datos = "#Posicion," + self.idusuario + "," + "\(self.userAnotacion.position.latitude)," + "\(self.userAnotacion.position.longitude)," + "# /n"
        myvariables.socket.emit("data", datos)
        self.origenIcono.hidden = true
        mapaVista.clear()
        self.origenAnotacion.position = mapaVista.camera.target
        self.DireccionDeCoordenada(origenAnotacion.position, directionText: origenText)
        coreLocationManager.stopUpdatingLocation()
        self.destinoText.text = ""
        TablaSolPendientes.hidden = true
        SolPendientesBtn.hidden = true
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
        self.origenIcono.image = UIImage(named: "destino2")
        self.origenIcono.hidden = false
        ExplicacionText.text = "Mueva el mapa hasta el destino"
        ExplicacionView.hidden = false
        mapaVista.camera = GMSCameraPosition.cameraWithLatitude(origenAnotacion.position.latitude, longitude: origenAnotacion.position.longitude, zoom: 15)        
        self.coreLocationManager.stopUpdatingLocation()
        self.aceptarLocBtn.hidden = false
    }
    
    //Boton Capturar origen y destino
    @IBAction func AceptarLoc(sender: UIButton) {
        if self.SolPendientesBtn.hidden == false{
            mapaVista.clear()
            self.coreLocationManager.startUpdatingLocation()
            userAnotacion.map = self.mapaVista
            self.aceptarLocBtn.hidden = true
            self.SolicitarBtn.hidden = false
        }
        else{
            self.destinoAnotacion.position = mapaVista.camera.target
            self.DireccionDeCoordenada(destinoAnotacion.position, directionText: destinoText)
            self.DireccionDeCoordenada(origenAnotacion.position, directionText: origenText)
        self.formularioSolicitud.hidden = false
        self.solicitud.DatosSolicitud(String(origenAnotacion.position.latitude) + String(origenAnotacion.position.longitude), referenciaorigen: referenciaText.text!, dirdestino: String(destinoAnotacion.position.latitude) + String(destinoAnotacion.position.longitude), disttaxiorigen: "0", distorigendestino: "0" , consumocombustible: "0", importe: "0", tiempotaxiorigen: "0", tiempoorigendestino: "0", latorigen: String(Double(origenAnotacion.position.latitude)), lngorigen: String(Double(origenAnotacion.position.longitude)), latdestino: String(Double(destinoAnotacion.position.latitude)), lngdestino: String(Double(destinoAnotacion.position.longitude)), vestuariocliente: vestuarioText.text!)
        }
        self.aceptarLocBtn.hidden = true
        origenIcono.hidden = true
        self.formularioSolicitud.hidden = false
        ExplicacionView.hidden = true
    }
    
    //Boton para Cancelar Carrera
    @IBAction func CancelarSol(sender: UIButton) {
           self.formularioSolicitud.hidden = true
            self.Inicio()
            self.origenText.text = ""
            self.destinoText.text = ""
            self.SolicitarBtn.hidden = false
            self.SolPendientesBtn.hidden = false
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
        if destinoText.text != ""{
           self.confirmaCarrera()
        }
        else{
            alerta.tipo = 2
            alerta.CambiarMensaje("Si no selecciona un destino, no podemos calcular los detalles de su carrera")
            alerta.CambiarTitulo("Datos Solicitud")
            alerta.vista.hidden = false
        }
    }
    
    
    //Boton Cerrar la APP
   
    @IBAction func CerrarApp(sender: UIButton) {
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
        case 11 :
            let Datos = "#Solicitud" + "," + self.solicitud.idcliente + "," + self.solicitud.idconductor + "," + self.solicitud.idtaxi + "," + self.solicitud.nombreapellidoscliente + "," + self.solicitud.nombreapellidosconductor + "," + self.solicitud.codigovehiculo + "," + self.solicitud.dirorigen + "," + self.solicitud.referenciaorigen + "," + self.solicitud.dirdestino + "," + self.solicitud.disttaxiorigen + "," + self.solicitud.distorigendestino + "," + self.solicitud.consumocombustible + "," + self.solicitud.importe + "," + self.solicitud.tiempotaxiorigen + "," + self.solicitud.tiempoorigendestino + "," + self.solicitud.lattaxi + "," + self.solicitud.lngtaxi + "," + self.solicitud.latorigen + "," + self.solicitud.lngorigen + "," + self.solicitud.latdestino + "," + self.solicitud.lngdestino + "," + self.solicitud.vestuariocliente + "," + self.solicitud.movilcliente + "," + self.solicitud.movilconductor + "," + "#/ n"
            
            myvariables.socket.emit("data", Datos)
            self.formularioSolicitud.hidden = true
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
            self.mapaVista!.clear()
            self.coreLocationManager.startUpdatingLocation()
            self.SolicitarBtn.hidden = false
            self.TablaSolPendientes.reloadData()
            self.SolPendientesBtn.hidden = false
            self.CantSolPendientes.text = String(self.solpendientes.count)
            self.CantSolPendientes.hidden = false
        case 4 :
            exit(0)
        case 5 :
            
            if solpendientes.count != 0{
                self.TablaSolPendientes.hidden = true
                self.CantSolPendientes.text = String(self.solpendientes.count)
            }

        default :
            exit(0)
        }
        AlertaView.hidden = true
    }
    
   // BOTONES DE CANCELAR SOLICITUD
    @IBAction func CancelarSolicitud(sender: AnyObject) {
        let Datos = "#Cancelarsolicitud" + "," + self.solpendientes[indexselect].idSolicitud + "," + self.solpendientes[indexselect].idTaxi + "," + "# \n"
        myvariables.socket.emit("data", Datos)
        self.solpendientes.removeAtIndex(indexselect)
        //CantSolPendientes.text = String(self.solpendientes.count)
        self.TablaSolPendientes.reloadData()
        SolicitudDetalleView.hidden = true
       if solpendientes.count == 0 {
         SolPendientesBtn.hidden = true
         CantSolPendientes.hidden = true
        }
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
        self.DibujarIconos([self.origenAnotacion, self.destinoAnotacion, self.taxiLocation], span: 12)
        self.TablaSolPendientes.hidden = true
        SolicitudDetalleView.hidden = true
        RutaCliente(self.origenAnotacion.position, destino: self.destinoAnotacion.position, taxi: self.taxiLocation.position)
        ExplicacionView.hidden = false
        self.SolicitarBtn.hidden = true
        self.aceptarLocBtn.hidden = false
    }
    
    
   //LLENAR LA LISTA SOLICITUDES PENDIENTES
    @IBAction func MostrarSolPendientes(sender: AnyObject) {
        self.TablaSolPendientes.frame = CGRectMake(109, 56, 167, CGFloat(solpendientes.count * 44))
        TablaSolPendientes.hidden = false
        //CantSolPendientes.text = String(self.solpendientes.count)
    }
       
    
    //CONTROL DE TECLADO VIRTUAL
    func textFieldDidEndEditing(textfield: UITextField) {
        if textfield.isEqual(vestuarioText){
            animateViewMoving(false, moveValue: 100)
        }
        else{
        }
    }
    
    //Funciones para mover los elementos para que no queden detrás del teclado
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.isEqual(vestuarioText){
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
    
    //FUNCIONES PARA LA TABLEVIEW
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return solpendientes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        // Configure the cell...
        cell.textLabel!.text = solpendientes[indexPath.row].FechaHora
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        indexselect = indexPath.row
        SolicitudDetalleView.hidden = false
    }

}