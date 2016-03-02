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
import Socket_IO_Client_Swift
import AddressBook

class PantallaInicio: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate {
    var coreLocationManager : CLLocationManager!
    var miposicion = CLLocationCoordinate2D()
    var locationMarker = MKPointAnnotation()
    var taxiLocation = MKPointAnnotation()
    var userAnotacion = MKPointAnnotation()
    var origenAnotacion = MKPointAnnotation()
    var destinoAnotacion = MKPointAnnotation()
    var span : MKCoordinateSpan!
    var region : MKCoordinateRegion!
    var puntoOrigen : MKMapItem!
    var puntoDestino : MKMapItem!
    //var directionsResponse : MKDirectionsResponse!
    //var route : MKRoute!
    var taxi : CTaxi!
    var login = [String]()
    var solpendientes = [CSolPendiente]()
    var solicitud = CSolicitud()
    var idusuario : String = ""
    var timer = NSTimer()
    var alerta: CAlerta!
    var indexselect = Int()
    //var cliente : CCliente! //usuario y contraseña para el login automatico
  
    //variables de interfaz
    @IBOutlet weak var taxisDisponible: UILabel!        
    @IBOutlet weak var Geolocalizando: UIActivityIndicatorView!
    @IBOutlet weak var GeolocalizandoView: UIView!
    @IBOutlet weak var origenIcono: UIImageView!
    @IBOutlet weak var mapaVista: MKMapView!
    @IBOutlet weak var ExplicacionView: UIView!
   
    //@IBOutlet weak var menuTable: UITableView!
   
    
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
        
        
        //Inicializacion del mapa con una vista panoramica de guayaquil
        span = MKCoordinateSpanMake(150.0 , 150.0)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(0.0, 0.0), span: span)
        mapaVista.setRegion(region, animated: true)
        self.GeolocalizandoView.hidden = false
        
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
            if temporal[0] == "#Sms"{
                self.alerta.CambiarTitulo("Estado de solicitud")
                self.alerta.CambiarMensaje(temporal[2] as String)
                self.alerta.DefinirTipo(2)
                self.AlertaView.hidden = false
            }
            else{
                if temporal[0] == "#Cancelada" {
                    //#Cancelada, idsolicitud
                    self.alerta.CambiarTitulo("Estado de solicitud")
                    self.alerta.CambiarMensaje("Su solicitud ha sido rechazada por el conductor")
                    self.alerta.DefinirTipo(2)
                    self.AlertaView.hidden = false
                }
            }
        }
        
        //GEOPOSICION DE TAXIS
        myvariables.socket.on("Geoposicion"){data, ack in
           let temporal = String(data).componentsSeparatedByString(",")
           if temporal[0] == "#Geoposicion"{
            
            }
        }
    }
    override func viewDidAppear(animated: Bool) {
        var readString = ""
        let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
        
        do {
            readString = try NSString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding) as String
        } catch {
        }
        print(myvariables.socket.status.description)
        if myvariables.socket.status.description == "Connected"{
        myvariables.socket.emit("data",readString)
            self.login = String(readString).componentsSeparatedByString(",")
        }
        else{
            sleep(4)
            if myvariables.socket.status.description == "Connected"{
                myvariables.socket.emit("data",readString)
                self.login = String(readString).componentsSeparatedByString(",")
            }
            else{
                alerta.CambiarTitulo("Sin Conexión")
                alerta.CambiarMensaje("No se puede conectar al servidor por favor intentar otra vez")
                alerta.DefinirTipo(4)
                AlertaView.hidden = false
                SolicitarBtn.hidden = true
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
   //función GetLocalization, para actualizar la localización del usuario automaticamente
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
    
        mapaVista.removeAnnotation(userAnotacion)
        self.miposicion =  newLocation.coordinate
        span = MKCoordinateSpanMake(0.1 , 0.1)
        userAnotacion.coordinate = miposicion
        userAnotacion.title = "Cliente"
        mapaVista.showsUserLocation = false
        self.DibujarIconos([userAnotacion], span: span)
        self.GeolocalizandoView.hidden = true
        //self.SolicitarBtn.hidden = false
        
    }
    //Función para personalizar las anotaciones en el mapa, se llama automaticamente cada vez que se dibuja una anotación.
   func mapView(mapaView: MKMapView, viewForAnnotation anotacion: MKAnnotation) -> MKAnnotationView? {

        let reusarId = "anotacion"
        var anotacionView = mapaView.dequeueReusableAnnotationViewWithIdentifier(reusarId)
        if anotacionView == nil {
            anotacionView = MKAnnotationView(annotation: anotacion, reuseIdentifier: reusarId)
           }
        else {
        anotacionView!.annotation = anotacion
       }
    if anotacion.isEqual(userAnotacion) {
        anotacionView!.image = UIImage(named:"origen")
    }
    else {
        if anotacion.isEqual(origenAnotacion) {
            anotacionView!.image = UIImage(named:"origen")
        }
        else {
            if anotacion.isEqual(destinoAnotacion){
                anotacionView!.image = UIImage(named:"destino")
            }
            else {
                if anotacion.isEqual(taxiLocation){
                    anotacionView!.image = UIImage(named:"taxi_libre")
                }
                
            }
        }
    }
    anotacionView!.canShowCallout = true

    return anotacionView
    
    }
     //Función para realizar acciones cuando se toca y mueve el mapa
  /*override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        origenAnotacion.coordinate = userAnotacion.coordinate
        coreLocationManager.stopUpdatingLocation()
        self.origenIcono.hidden = false
        mapaVista.removeAnnotation(userAnotacion)
        origenAnotacion.title = "Origen"
        mapaVista.addAnnotation(origenAnotacion)
        
        
    }
    //Función para realizar acciones cuando se deja de tocar el mapa
   override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        self.origenIcono.hidden = true
        destinoAnotacion.coordinate = mapaVista.centerCoordinate
        destinoAnotacion.title = "Destino"
        mapaVista.addAnnotation(destinoAnotacion)
        //self.confirmaCarrera()
        //RutaCarrera()
    }*/
   override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       self.TablaSolPendientes.hidden = true
       self.formularioSolicitud.endEditing(true)
    
    }
    //OCULTAR TECLADO CON TECLA ENTER
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
       //Funcion para ejecutar acciones cuando selecciono un icono en el mapa.
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        if (view.image == UIImage(named:"taxi_libre") && (SolicitarBtn.hidden == true)){
        self.formularioSolicitud.hidden = false
        mapaVista.removeAnnotation(taxiLocation)
        let Datos = "#Taxi" + "," + self.idusuario + "," + self.taxiLocation.title! + "," + "# /n"
            myvariables.socket.emit("data", Datos)
             ExplicacionView.hidden = true
        }

    }
    
    /*func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineOverlay = overlay as? MKPolyline
            let render = MKPolylineRenderer(polyline: polylineOverlay!)
            render.strokeColor = UIColor.blueColor()
            return render
    }*/
    
    //FUNCIONES PROPIAS
    //FUNCION DE AUTENTICACION
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
        self.TablaSolPendientes.frame = CGRectMake(109, 56, 167, CGFloat(solpendientes.count * 44))
        self.TablaSolPendientes.reloadData()
        self.CantSolPendientes.hidden = false
        self.CantSolPendientes.text = String(self.solpendientes.count)
        //self.TablaSolPendientes.hidden = false
        self.SolPendientesBtn.hidden = false
        
    }


    //FUncion para mostrar los taxis
    func MostrarTaxis(temporal : [String]){
            let posicionTaxi = CLLocationCoordinate2D(latitude: Double(temporal[4])!, longitude: Double(temporal[5])!)
            self.taxiLocation.coordinate = posicionTaxi
            self.taxiLocation.title = temporal[2]
        let span = MKCoordinateSpanMake(0.1 , 0.1)
        self.DibujarIconos([taxiLocation], span: span)
            self.SolicitarBtn.hidden = true
        solicitud.OtrosDatosTaxi(temporal[2], lattaxi: temporal[4], lngtaxi: temporal[5])
      }
    
    //Funcion para Mostrar Datos del Taxi seleccionado
    func MostrarDatosTaxi(temporal : [String]){
        let conductor = CConductor(IdConductor: temporal[9],Nombre: temporal[1], Telefono: temporal[2],UrlFoto: "")
        self.taxi = CTaxi(Matricula: temporal[7],CodTaxi: temporal[4],MarcaVehiculo: temporal[5],ColorVehiculo: temporal[6],GastoCombustible: temporal[8], Conductor: conductor)
        solicitud.DatosTaxiConductor(temporal[9], nombreapellidosconductor: temporal[1], codigovehiculo: temporal[4])
    }
    
    //Respuesta de solicitud
    func RespuestaSolicitd(Temporal : [String]){
       if Temporal[1] == "ok"{
        alerta.CambiarTitulo("Solicitud")
        alerta.CambiarMensaje("Su solicitud se procesó con exito, espere la confirmación del conductor.")
        alerta.DefinirTipo(3)
        AlertaView.hidden = false
        }
    }
    
    //Crear las rutas entre los puntos de origen y destino
   /*func RutaCarrera(){
     let placemark = MKPlacemark(coordinate: origenAnotacion.coordinate, addressDictionary: nil)
     puntoOrigen = MKMapItem(placemark: placemark)
    
     let placemark1 = MKPlacemark(coordinate: destinoAnotacion.coordinate, addressDictionary: nil)
     puntoDestino = MKMapItem(placemark: placemark1)
    
    //Solicitud de la Ruta
    let request:MKDirectionsRequest = MKDirectionsRequest()
    
    // source and destination are the relevant MKMapItems
    request.source = puntoOrigen
    request.destination = puntoDestino
    
    // Specify the transportation type
    request.transportType = MKDirectionsTransportType.Automobile;
    
    // If you're open to getting more than one route,
    // requestsAlternateRoutes = true; else requestsAlternateRoutes = false;
    request.requestsAlternateRoutes = false
    
    let directions = MKDirections(request: request)
    
    directions.calculateDirectionsWithCompletionHandler ({
        (response: MKDirectionsResponse?, error: NSError?) in
        
        if error == nil {
            self.taxisDisponible.hidden = false
            self.taxisDisponible.text = "ok"
            self.directionsResponse = response
            // Get whichever currentRoute you'd like, ex. 0
            self.mapaVista.removeOverlays(self.mapaVista.overlays)
            self.route = self.directionsResponse.routes[0] as MKRoute
            self.mapaVista.addOverlay(self.route.polyline)
        }
        
    })
}*/
   
    //Alertas
    func confirmaCarrera (){
        alerta.CambiarTitulo("Envio de la solicitud")
        alerta.CambiarMensaje("Desea enviar la solicitud en proceso")
        alerta.DefinirTipo(11)
        AlertaView.hidden = false
    }

    func PuntoMedio(coordenadas : [CLLocationCoordinate2D])->CLLocationCoordinate2D{
        return middlePointOfListMarkers(coordenadas)
    }
    
    //FUNCIONES PARA CALCULAR PUNTO MEDIO
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
    
    func DibujarIconos(anotaciones: [MKPointAnnotation], span: MKCoordinateSpan){
        if anotaciones.count == 1{
            region = MKCoordinateRegion(center: anotaciones[0].coordinate, span: span)
        }
        else{
            var coordenadas = [CLLocationCoordinate2D]()
            for var anotacion in anotaciones{
                coordenadas.append(anotacion.coordinate)
            }
            let centroVista = PuntoMedio(coordenadas)
            region = MKCoordinateRegion(center: centroVista, span: span)
        }
        mapaVista.setRegion(region, animated: true)
        for var anotacion in anotaciones{
           mapaVista.addAnnotation(anotacion)
        }
    }
    
    //API GOOGLE para obtener Direcciones
  /*func directionAPITest() {
    
        let directionURL = "https://maps.googleapis.com/maps/api/directions/json?origin=sanfrancisco&destination=sanjose&key=YOUR_API_KEY"
        let request = NSURLRequest(URL: NSURL(string:directionURL)!)
        let session = NSURLSession.sharedSession()
    let opcion = NSJSONReadingOptions()
    session.dataTaskWithRequest(request, completionHandler: {(data: NSData?, response: NSURLResponse?, error: NSError?) in
               if error == nil {
                    let object = NSJSONSerialization.JSONObjectWithData(data!, options: opcion) as! NSDictionary
                
                    let routes = object["routes"] as! [NSDictionary]
                    for route in routes {
                        let overviewPolyline = route["overview_polyline"] as! NSDictionary
                        let points = overviewPolyline["points"] as! String
                        self.mapPolyline = self.polyLineWithEncodedString(points)
                        dispatch_async(dispatch_get_main_queue()) {
                            self.mapView.addOverlay(self.mapPolyline)
                        }
                    }
                }
                else {
                    print("Direction API error")
                }
                
        }).resume()
    }*/

    
    //Botones de Interfaz Grafica
    
    @IBAction func Solicitar(sender: AnyObject) {
        let datos = "#Posicion," + self.idusuario + "," + "\(self.miposicion.latitude)," + "\(self.miposicion.longitude)," + "# /n"
       myvariables.socket.emit("data", datos)
        mapaVista.removeAnnotations(mapaVista.annotations)
        mapaVista.addAnnotation(userAnotacion)
        coreLocationManager.stopUpdatingLocation()
        TablaSolPendientes.hidden = true
        SolPendientesBtn.hidden = true
        CantSolPendientes.hidden = true
        ExplicacionView.hidden = false
    }
    
    //Botones para solicitud
    // Boton Vista Mapa para origen
   @IBAction func OrigenBtn(sender: UIButton) {
        self.formularioSolicitud.hidden = true
        self.coreLocationManager.stopUpdatingLocation()
        self.origenIcono.image = UIImage(named:"origen2")
        self.origenIcono.hidden = false
        mapaVista.removeAnnotations(mapaVista.annotations)
        span = MKCoordinateSpanMake(0.06 , 0.06)
        region = MKCoordinateRegion(center: self.userAnotacion.coordinate, span: span)
        mapaVista.setRegion(region, animated: true)
        self.aceptarLocBtn.hidden = false    
    }
    //Boton Vista Mapa para Destino
    @IBAction func DestinoBtn(sender: UIButton) {
        self.formularioSolicitud.hidden = true
        self.origenIcono.hidden = false
        self.origenIcono.image = UIImage(named: "destino2")
        if origenText.text == "" {
         origenAnotacion.coordinate = coreLocationManager.location!.coordinate
            span = MKCoordinateSpanMake(0.06 , 0.06)
            region = MKCoordinateRegion(center: self.userAnotacion.coordinate, span: span)
            mapaVista.setRegion(region, animated: true)
        }
        self.coreLocationManager.stopUpdatingLocation()
        self.aceptarLocBtn.hidden = false
    }
    
    //Boton Capturar origen y destino
    @IBAction func AceptarLoc(sender: UIButton) {
        
        if origenIcono.image == UIImage(named: "origen2"){
        self.origenIcono.hidden = true
        self.origenAnotacion.coordinate = mapaVista.centerCoordinate
        self.origenText.text = String(self.origenAnotacion.coordinate.latitude) +  String(self.origenAnotacion.coordinate.longitude)
        mapaVista.addAnnotation(origenAnotacion)
        }
        else{
        self.destinoAnotacion.coordinate = mapaVista.centerCoordinate
        mapaVista.addAnnotation(destinoAnotacion)
        self.destinoText.text = String(self.destinoAnotacion.coordinate.latitude) + String(self.destinoAnotacion.coordinate.longitude)
        self.origenText.text = String(self.origenAnotacion.coordinate.latitude) + String(self.origenAnotacion.coordinate.longitude)
        self.formularioSolicitud.hidden = false
        self.solicitud.DatosSolicitud(origenText.text!, referenciaorigen: referenciaText.text!, dirdestino: destinoText.text!, disttaxiorigen: "0", distorigendestino: "0" , consumocombustible: "0", importe: "0", tiempotaxiorigen: "0", tiempoorigendestino: "0", latorigen: String(Double(origenAnotacion.coordinate.latitude)), lngorigen: String(Double(origenAnotacion.coordinate.longitude)), latdestino: String(Double(destinoAnotacion.coordinate.latitude)), lngdestino: String(Double(destinoAnotacion.coordinate.longitude)), vestuariocliente: vestuarioText.text!)
        }
        self.aceptarLocBtn.hidden = true
        origenIcono.hidden = true
        self.formularioSolicitud.hidden = false
    }
    
    
    //Boton para Cancelar Carrera
    
    @IBAction func CancelarSol(sender: UIButton) {
            self.formularioSolicitud.hidden = true
           mapaVista.removeAnnotations(mapaVista.annotations)
           self.coreLocationManager.startUpdatingLocation()
            origenIcono.hidden = true
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
        self.NombreCond.text! += taxi.Conductor.NombreApellido
        self.MovilCond.text! += taxi.Conductor.Telefono
        self.MarcaAut.text! += taxi.MarcaVehiculo
        self.ColorAut.text! += taxi.ColorVehiculo
        self.MatriculaAut.text! += taxi.Matricula
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
            alerta.CambiarMensaje("Debe Seleccionar una Dirección de Destino")
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
            let Datos = "#Solicitud" + "," + self.solicitud.idcliente + "," + self.solicitud.idconductor + "," + self.solicitud.idtaxi + "," + self.solicitud.nombreapellidoscliente + "," + self.solicitud.nombreapellidosconductor + "," + self.solicitud.codigovehiculo + "," + self.solicitud.dirorigen + "," + self.solicitud.referenciaorigen + "," + self.solicitud.dirdestino + "," + self.solicitud.disttaxiorigen + "," + self.solicitud.distorigendestino + "," + self.solicitud.consumocombustible + "," + self.solicitud.importe + "," + self.solicitud.tiempotaxiorigen + "," + self.solicitud.tiempoorigendestino + "," + self.solicitud.lattaxi + "," + self.solicitud.lngtaxi + "," + self.solicitud.latorigen + "," + self.solicitud.lngorigen + "," + self.solicitud.latdestino + "," + self.solicitud.lngdestino + "," + self.solicitud.vestuariocliente + "," + self.solicitud.movilcliente + "," + "#/ n"
            
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
            self.mapaVista.removeAnnotations(self.mapaVista.annotations)
            self.coreLocationManager.startUpdatingLocation()
            self.SolicitarBtn.hidden = false
            self.SolPendientesBtn.hidden = false
            self.CantSolPendientes.text = String(self.solpendientes.count)
            self.CantSolPendientes.hidden = false
        case 4 :
            exit(0)
        case 5 :
            TablaSolPendientes.hidden = true
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
        
        CantSolPendientes.text = String(self.solpendientes.count)
        SolicitudDetalleView.hidden = true
       if solpendientes.count == 0 {
         SolPendientesBtn.hidden = true
         CantSolPendientes.hidden = true
        }

    }
    
    @IBAction func LLamarConductor(sender: AnyObject) {
        
    }
    
    @IBAction func MostrarSolMapa(sender: AnyObject) {
        self.coreLocationManager.stopUpdatingLocation()
        let span = MKCoordinateSpanMake(0.15 , 0.15)
        self.mapaVista.removeAnnotations(self.mapaVista.annotations)
        self.origenAnotacion.coordinate =  CLLocationCoordinate2DMake(Double(self.solpendientes[indexselect].Latitudorigen)!,Double(self.solpendientes[indexselect].Longitudorigen)!)
        self.destinoAnotacion.coordinate =  CLLocationCoordinate2DMake(Double(self.solpendientes[indexselect].Latituddestino)!,Double(self.solpendientes[indexselect].Longituddestino)!)
        self.taxiLocation.coordinate =  CLLocationCoordinate2DMake(Double(self.solpendientes[indexselect].Latitudtaxi)!,Double(self.solpendientes[indexselect].Longitudtaxi)!)
        self.DibujarIconos([self.origenAnotacion, self.destinoAnotacion, self.taxiLocation], span: span)
        self.TablaSolPendientes.hidden = true
        SolicitudDetalleView.hidden = true
    }
    
    
   //LLENAR LA LISTA SOLICITUDES PENDIENTES
    @IBAction func MostrarSolPendientes(sender: AnyObject) {
        self.TablaSolPendientes.frame = CGRectMake(109, 56, 167, CGFloat(solpendientes.count * 44))
        TablaSolPendientes.hidden = false
        CantSolPendientes.text = String(self.solpendientes.count)
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
        
        //cell.imageView?.image =
       return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        indexselect = indexPath.row
        
        /*let alertaDos = UIAlertController (title: "Cancelación", message: "Desea cancelar la solicitud en proceso", preferredStyle: UIAlertControllerStyle.Alert)
        
        //Ahora es mucho mas sencillo, y podemos añadir nuevos botones y usar handler para capturar el botón seleccionado y hacer algo.
        
        alertaDos.addAction(UIAlertAction(title: "MAPA", style: UIAlertActionStyle.Cancel ,handler: {alerAction in
            self.coreLocationManager.stopUpdatingLocation()
            let span = MKCoordinateSpanMake(0.15 , 0.15)
            self.mapaVista.removeAnnotations(self.mapaVista.annotations)
            self.origenAnotacion.coordinate =  CLLocationCoordinate2DMake(Double(self.solpendientes[indexPath.row].Latitudorigen)!,Double(self.solpendientes[indexPath.row].Longitudorigen)!)
            self.destinoAnotacion.coordinate =  CLLocationCoordinate2DMake(Double(self.solpendientes[indexPath.row].Latituddestino)!,Double(self.solpendientes[indexPath.row].Longituddestino)!)
            self.taxiLocation.coordinate =  CLLocationCoordinate2DMake(Double(self.solpendientes[indexPath.row].Latitudtaxi)!,Double(self.solpendientes[indexPath.row].Longitudtaxi)!)
            self.DibujarIconos([self.origenAnotacion, self.destinoAnotacion, self.taxiLocation], span: span)
            self.TablaSolPendientes.hidden = true
            self.TablaSolPendientes.deselectRowAtIndexPath(indexPath, animated: true)
        }))
        alertaDos.addAction(UIAlertAction(title: "SI", style: UIAlertActionStyle.Default, handler: {alerAction in
            let Datos = "#Cancelarsolicitud" + "," + self.solpendientes[indexPath.row].idSolicitud + "," + self.solpendientes[indexPath.row].idTaxi + "," + "# \n"
            myvariables.socket.emit("data", Datos)
            self.solpendientes.removeAtIndex(indexPath.row)
            self.TablaSolPendientes.deleteRowsAtIndexPaths(self.TablaSolPendientes.indexPathsForSelectedRows!, withRowAnimation: UITableViewRowAnimation.Fade)
            self.TablaSolPendientes.deselectRowAtIndexPath(indexPath, animated: true)
            self.TablaSolPendientes.hidden = true
        }))
        
        alertaDos.addAction(UIAlertAction(title: "NO", style: UIAlertActionStyle.Default, handler: {alerAction in
            self.TablaSolPendientes.deselectRowAtIndexPath(indexPath, animated: true)
            self.TablaSolPendientes.hidden = true
        }))
        
        alertaDos.addAction(UIAlertAction(title: "LLAMAR", style: UIAlertActionStyle.Default, handler: {alerAction in
            
        }))
        
        //Para hacer que la alerta se muestre usamos presentViewController, a diferencia de Objective C que como recordaremos se usa [Show Alerta]
        
        self.presentViewController(alertaDos, animated: true, completion: nil)*/
        SolicitudDetalleView.hidden = false        
        self.TablaSolPendientes.deselectRowAtIndexPath(indexPath, animated: true)
        if solpendientes.count != 0{
          self.TablaSolPendientes.hidden = true
            self.CantSolPendientes.text = String(solpendientes.count)
        }
      
    }


    //FUNCION PARA EL CAMBIO DE PANTALLA
    /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      let seleccion = sender as! Int
        let SolicitudView : PantallaSolic = segue.destinationViewController as! PantallaSolic
        SolicitudView.Solicitud = myvariables.solpendientes[seleccion]
        
    }*/
    
    
    
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
}