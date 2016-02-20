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
    override func viewDidLoad() {
       super.viewDidLoad()
        mapaVista.delegate = self
        coreLocationManager = CLLocationManager()
        coreLocationManager.delegate = self
        coreLocationManager.requestWhenInUseAuthorization() //solicitud de autorización para acceder a la localización del usuario
        coreLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        coreLocationManager.startUpdatingLocation()  //Iniciar servicios de actualiación de localización del usuario
        //INICIALIZACION DE LOS TEXTFIELD
        origenText.delegate = self
        referenciaText.delegate = self
        destinoText.delegate = self
        vestuarioText.delegate = self
        //Inicializacion del mapa con una vista panoramica de guayaquil
        
     
        span = MKCoordinateSpanMake(150 , 150)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(0.0, 0.0), span: span)
        mapaVista.setRegion(region, animated: true)
        self.GeolocalizandoView.hidden = false
       
        
         //Evento sockect para escuchar
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
        
        
        //SOLICITUDES PENDIENTES
        if myvariables.solpendientes.count != 0{
            SolPendientesBtn.hidden = false
            TablaSolPendientes.hidden = false
        }
       
        
      }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
   //función GetLocalization, para actualizar la localización del usuario automaticamente
    
    /*func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        self.miposicion = coreLocationManager.location!.coordinate
        span = MKCoordinateSpanMake(0.04 , 0.04)
        region = MKCoordinateRegion(center: miposicion, span: span)
        mapaVista.setRegion(region, animated: true)
        
        userAnotacion.coordinate = miposicion
        userAnotacion.title = "Cliente"
        mapaVista.showsUserLocation = false
        mapaVista.addAnnotation(userAnotacion)
        self.GeolocalizandoView.hidden = true
        self.SolicitarBtn.hidden = false

    }*/
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
    
        mapaVista.removeAnnotation(userAnotacion)
        self.miposicion =  newLocation.coordinate
        span = MKCoordinateSpanMake(0.4 , 0.4)
        region = MKCoordinateRegion(center: miposicion, span: span)
        mapaVista.setRegion(region, animated: true)
        
        userAnotacion.coordinate = miposicion
        userAnotacion.title = "Cliente"
        mapaVista.showsUserLocation = false
        mapaVista.addAnnotation(userAnotacion)
        self.GeolocalizandoView.hidden = true
        
        self.SolicitarBtn.hidden = false
        
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
        
        if (view.image == UIImage(named:"taxi_libre")){
        self.formularioSolicitud.hidden = false
        mapaVista.removeAnnotation(taxiLocation)
        let Datos = "#Taxi" + "," + myvariables.idusuario + "," + self.taxiLocation.title! + "," + "# /n"
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
    
    //FUncion para mostrar los taxis
    func MostrarTaxis(temporal : [String]){
            let posicionTaxi = CLLocationCoordinate2D(latitude: Double(temporal[4])!, longitude: Double(temporal[5])!)
            self.taxiLocation.coordinate = posicionTaxi
            self.taxiLocation.title = temporal[2]
        span = MKCoordinateSpanMake(0.4 , 0.4)
        let region = MKCoordinateRegion(center: taxiLocation.coordinate, span: span)
        mapaVista.setRegion(region, animated: true)
            mapaVista.addAnnotation(taxiLocation)
            mapaVista.showAnnotations([taxiLocation], animated: true)
            self.SolicitarBtn.hidden = true
        myvariables.solicitud.OtrosDatosTaxi(temporal[2], lattaxi: temporal[4], lngtaxi: temporal[5])
      }
    
    //Funcion para Mostrar Datos del Taxi seleccionado
    func MostrarDatosTaxi(temporal : [String]){
        let conductor = CConductor(IdConductor: temporal[9],Nombre: temporal[1], Telefono: temporal[2],UrlFoto: "")
        self.taxi = CTaxi(Matricula: temporal[7],CodTaxi: temporal[4],MarcaVehiculo: temporal[5],ColorVehiculo: temporal[6],GastoCombustible: temporal[8], Conductor: conductor)
        myvariables.solicitud.DatosTaxiConductor(temporal[9], nombreapellidosconductor: temporal[1], codigovehiculo: temporal[4])
        
    }
    
    //Respuesta de solicitud
    func RespuestaSolicitd(Temporal : [String]){
        //taxisDisponible.hidden = false
        //taxisDisponible.text = Temporal[0]
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
    
    let alertaDos = UIAlertController (title: "Envio de la Solicitud", message: "Desea Enviar la Solicitud en proceso", preferredStyle: UIAlertControllerStyle.Alert)

    //Ahora es mucho mas sencillo, y podemos añadir nuevos botones y usar handler para capturar el botón seleccionado y hacer algo.
        
    alertaDos.addAction(UIAlertAction(title: "Enviar", style: UIAlertActionStyle.Cancel ,handler: {alerAction in
        let Datos = "#Solicitud" + "," + myvariables.solicitud.idcliente + "," + myvariables.solicitud.idconductor + "," + myvariables.solicitud.idtaxi + "," + myvariables.solicitud.nombreapellidoscliente + "," + myvariables.solicitud.nombreapellidosconductor + "," + myvariables.solicitud.codigovehiculo + "," + myvariables.solicitud.dirorigen + "," + myvariables.solicitud.referenciaorigen + "," + myvariables.solicitud.dirdestino + "," + myvariables.solicitud.disttaxiorigen + "," + myvariables.solicitud.distorigendestino + "," + myvariables.solicitud.consumocombustible + "," + myvariables.solicitud.importe + "," + myvariables.solicitud.tiempotaxiorigen + "," + myvariables.solicitud.tiempoorigendestino + "," + myvariables.solicitud.lattaxi + "," + myvariables.solicitud.lngtaxi + "," + myvariables.solicitud.latorigen + "," + myvariables.solicitud.lngorigen + "," + myvariables.solicitud.latdestino + "," + myvariables.solicitud.lngdestino + "," + myvariables.solicitud.vestuariocliente + "," + myvariables.solicitud.movilcliente + "," + "#/ n"
        
       myvariables.socket.emit("data", Datos)
    }))
    alertaDos.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Default, handler: {alerAction in
      
        }))
    
    //Para hacer que la alerta se muestre usamos presentViewController, a diferencia de Objective C que como recordaremos se usa [Show Alerta]
    
    self.presentViewController(alertaDos, animated: true, completion: nil)
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
        let datos = "#Posicion," + myvariables.idusuario + "," + "\(self.miposicion.latitude)," + "\(self.miposicion.longitude)," + "# \n"
       myvariables.socket.emit("data", datos)
        coreLocationManager.stopUpdatingLocation()
        TablaSolPendientes.hidden = true
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
        span = MKCoordinateSpanMake(0.2 , 0.2)
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
        self.destinoText.text = String(self.destinoAnotacion.coordinate.latitude) + "," + String(self.destinoAnotacion.coordinate.longitude)
        self.origenText.text = String(self.origenAnotacion.coordinate.latitude) + "," + String(self.origenAnotacion.coordinate.longitude)
        self.formularioSolicitud.hidden = false
        myvariables.solicitud.DatosSolicitud(origenText.text!, referenciaorigen: referenciaText.text!, dirdestino: destinoText.text!, disttaxiorigen: "0", distorigendestino: "0" , consumocombustible: "0", importe: "0", tiempotaxiorigen: "0", tiempoorigendestino: "0", latorigen: String(Double(origenAnotacion.coordinate.latitude)), lngorigen: String(Double(origenAnotacion.coordinate.longitude)), latdestino: String(Double(destinoAnotacion.coordinate.latitude)), lngdestino: String(Double(destinoAnotacion.coordinate.longitude)), vestuariocliente: vestuarioText.text!)
        }
        self.aceptarLocBtn.hidden = true
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
    }
    
    //Aceptar y Enviar solicitud
    @IBAction func AceptarSolicitud(sender: AnyObject) {
        if destinoText.text != ""{
           self.confirmaCarrera()
        }
        else{
            let alertaDos = UIAlertController (title: "Datos Solicitud", message: "Debe Seleccionar una Dirección de Destino", preferredStyle: UIAlertControllerStyle.Alert)
            
            alertaDos.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default, handler: {alerAction in
                
            }))
            
            //Para hacer que la alerta se muestre usamos presentViewController, a diferencia de Objective C que como recordaremos se usa [Show Alerta]
            
            self.presentViewController(alertaDos, animated: true, completion: nil)

        }        
      
    }
    //Boton Cerrar la APP
   
    @IBAction func CerrarApp(sender: UIButton) {
        exit(0)
    }
    
   //LLENAR LA LISTA SOLICITUDES PENDIENTES
    @IBAction func MostrarSolPendientes(sender: AnyObject) {
        TablaSolPendientes.hidden = false
    }
    
  //FUNCIONES PARA LA TABLEVIEW

   func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
   func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
       return myvariables.solpendientes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        // Configure the cell...
       cell.textLabel!.text = myvariables.solpendientes[indexPath.row].FechaHora
        //cell.imageView?.image =
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        let alertaDos = UIAlertController (title: "Cancelación", message: "Desea Enviar la Solicitud en proceso", preferredStyle: UIAlertControllerStyle.Alert)
        
        //Ahora es mucho mas sencillo, y podemos añadir nuevos botones y usar handler para capturar el botón seleccionado y hacer algo.
        
        alertaDos.addAction(UIAlertAction(title: "MAPA", style: UIAlertActionStyle.Cancel ,handler: {alerAction in
            let solSeleccionada = indexPath.row
            self.performSegueWithIdentifier("haciaSolicitud", sender: solSeleccionada)
        }))
        alertaDos.addAction(UIAlertAction(title: "SI", style: UIAlertActionStyle.Default, handler: {alerAction in
            
        }))
        
        alertaDos.addAction(UIAlertAction(title: "NO", style: UIAlertActionStyle.Default, handler: {alerAction in
            
        }))
        
        alertaDos.addAction(UIAlertAction(title: "LLAMAR", style: UIAlertActionStyle.Default, handler: {alerAction in
            
        }))
        
        //Para hacer que la alerta se muestre usamos presentViewController, a diferencia de Objective C que como recordaremos se usa [Show Alerta]
        
        self.presentViewController(alertaDos, animated: true, completion: nil)
      
    }
    
    
    //FUNCION PARA EL CAMBIO DE PANTALLA
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      let seleccion = sender as! Int
        let SolicitudView : PantallaSolic = segue.destinationViewController as! PantallaSolic
        SolicitudView.Solicitud = myvariables.solpendientes[seleccion]
        
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


}