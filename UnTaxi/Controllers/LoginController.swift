//
//  LoginController.swift
//  UnTaxi
//
//  Created by Done Santana on 26/2/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import UIKit
import SocketIO
import CoreLocation

class LoginController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate{
    
    var login = [String]()
    var solitudespdtes = [CSolicitud]()
    var coreLocationManager: CLLocationManager!
    var EnviosCount = 0
    var emitTimer = Timer()
   // var conexion = CSocket()
    
    var ServersData = [String]()
    var ServerParser = XMLParser()
    var recordKey = ""
    let dictionaryKeys = ["ip","p"]
    
    var results = [[String: String]]()                // the whole array of dictionaries
    var currentDictionary = [String : String]()    // the current dictionary
    var currentValue: String = ""                   // the current value for one of the keys in the dictionary
    
    //MARK:- VARIABLES INTERFAZ
    
    @IBOutlet weak var Usuario: UITextField!
    @IBOutlet weak var Clave: UITextField!
    @IBOutlet weak var AutenticandoView: UIView!
    
  
    @IBOutlet weak var DatosView: UIView!
    @IBOutlet weak var ClaveRecover: UIView!
    @IBOutlet weak var movilClaveRecover: UITextField!
    @IBOutlet weak var RecuperarClaveBtn: UIButton!
    
    
    @IBOutlet weak var RegistroView: UIView!
    @IBOutlet weak var nombreApText: UITextField!
    @IBOutlet weak var claveText: UITextField!
    @IBOutlet weak var confirmarClavText: UITextField!
    @IBOutlet weak var correoText: UITextField!
    @IBOutlet weak var telefonoText: UITextField!
    @IBOutlet weak var RecomendadoText: UITextField!
    @IBOutlet weak var RegistroBtn: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coreLocationManager = CLLocationManager()
        coreLocationManager.delegate = self
        coreLocationManager.requestWhenInUseAuthorization()
        
        telefonoText.delegate = self
        claveText.delegate = self
        correoText.delegate = self
        self.movilClaveRecover.delegate = self
        confirmarClavText.delegate = self
        Clave.delegate = self
        self.RecomendadoText.delegate = self
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado))
        
        self.DatosView.addGestureRecognizer(tapGesture)
        self.ClaveRecover.addGestureRecognizer(tapGesture)
        self.RegistroView.addGestureRecognizer(tapGesture)
        self.view.addGestureRecognizer(tapGesture)
        
        if CConexionInternet.isConnectedToNetwork() == true{
            myvariables.socket = SocketIOClient(socketURL: URL(string: "http://www.xoait.com:5803")!, config: [.log(false), .forcePolling(true)])
            myvariables.socket.connect()
                
            myvariables.socket.on("connect"){data, ack in
                var loginData = "Vacio"
                let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
                do {
                    loginData = try NSString(contentsOfFile: filePath, encoding: String.Encoding.utf8.rawValue) as String
                }catch {
                }
                if loginData != "Vacio"
                {
                    self.Login(loginData: loginData)
                }else{
                    self.AutenticandoView.isHidden = true
                }
                self.SocketEventos()
            }
            
            /*var servers = "Vacio"
            let filePath = NSHomeDirectory() + "/Library/Caches/servers.txt"
            do {
                servers = try NSString(contentsOfFile: filePath, encoding: String.Encoding.utf8.rawValue) as String
            }catch {
            }
            if servers != "Vacio"{
                self.ServersData = String(describing: servers).components(separatedBy: ",")
                self.ServerConect(){data in

                }
            }else{
                self.ServerSelect(){ success in
                    self.ServerConect(){data in
                        myvariables.socket.on("connect"){data, ack in
                            print("CONECTADOOO")
                            var read = "Vacio"
                            let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
                            do {
                                read = try NSString(contentsOfFile: filePath, encoding: String.Encoding.utf8.rawValue) as String
                            }catch {
                            }
                            if read != "Vacio"
                            {
                                self.AutenticandoView.isHidden = false
                                self.Login()
                            }
                            else{
                                self.AutenticandoView.isHidden = true
                            }
                            self.SocketEventos()
                        }
                    }
                    
                }
            }*/
            
        }else{
            ErrorConexion()
        }
        self.telefonoText.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    func SocketEventos(){
        myvariables.socket.on("LoginPassword"){data, ack in
            self.EnviarTimer(estado: 0, datos: "Terminado")
            let temporal = String(describing: data).components(separatedBy: ",")
                switch temporal[1]{
                case "loginok":
                    myvariables.cliente = CCliente(idUsuario: temporal[2],idcliente: temporal[4], user: self.login[1], nombre: temporal[5],email: temporal[3],empresa: temporal[temporal.count - 2])
                    if temporal[6] != "0"{
                        self.ListSolicitudPendiente(temporal)
                    }
                    if CLLocationManager.locationServicesEnabled(){
                        switch(CLLocationManager.authorizationStatus()) {
                        case .notDetermined, .restricted, .denied:
                            let locationAlert = UIAlertController (title: "Error de Localización", message: "Estimado cliente es necesario que active la localización de su dispositivo.", preferredStyle: .alert)
                            locationAlert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                                UIApplication.shared.openURL(NSURL(string:UIApplicationOpenSettingsURLString)! as URL)
                                //self.Login()
                            }))
                            locationAlert.addAction(UIAlertAction(title: "No", style: .default, handler: {alerAction in
                                exit(0)
                            }))
                            self.present(locationAlert, animated: true, completion: nil)
                        case .authorizedAlways, .authorizedWhenInUse:
                            let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "Inicio") as! InicioController
                            self.navigationController?.show(vc, sender: nil)
                            break
                        }
                    }else{
                        let locationAlert = UIAlertController (title: "Error de Localización", message: "Estimado cliente es necesario que active la localización de su dispositivo.", preferredStyle: .alert)
                        locationAlert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                            UIApplication.shared.openURL(NSURL(string:"App-Prefs:root=Privacy&path=LOCATION_SERVICES")! as URL)
                        }))
                        locationAlert.addAction(UIAlertAction(title: "No", style: .default, handler: {alerAction in
                            exit(0)
                        }))
                        self.present(locationAlert, animated: true, completion: nil)
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
                        self.AutenticandoView.isHidden = true
                        self.Usuario.text?.removeAll()
                        self.Usuario.text?.removeAll()
                    }))
                    self.present(alertaDos, animated: true, completion: nil)
                default: print("Problemas de conexion")
                }
        }
        
        myvariables.socket.on("NR") {data, ack in
            self.EnviarTimer(estado: 0, datos: "Terminado")
            let temporal = String(describing: data).components(separatedBy: ",")
            if temporal[1] == "registrook"{
                let alertaDos = UIAlertController (title: "Registro de Usuario", message: "Registro Realizado con éxito, puede loguearse en la aplicación, ¿Desea ingresar a la Aplicación?", preferredStyle: .alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                    self.RegistroView.isHidden = true
                }))
                alertaDos.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: {alerAction in
                    exit(0)
                }))
                self.present(alertaDos, animated: true, completion: nil)
            }
            else{
                let alertaDos = UIAlertController (title: "Registro de Usuario", message: "Error al registrar el usuario: \(temporal[2])", preferredStyle: UIAlertControllerStyle.alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                    self.AutenticandoView.isHidden = true
                }))
                self.present(alertaDos, animated: true, completion: nil)
            }
        }
        
        //RECUPERAR CLAVES
        myvariables.socket.on("Recuperarclave"){data, ack in
            self.EnviarTimer(estado: 0, datos: "Terminado")
            let temporal = String(describing: data).components(separatedBy: ",")
            if temporal[1] == "ok"{
                let alertaDos = UIAlertController (title: "Recuperación de clave", message: "Su clave ha sido recuperada satisfactoriamente, en este momento ha recibido un correo electronico a la dirección: " + temporal[2], preferredStyle: UIAlertControllerStyle.alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                }))
                self.present(alertaDos, animated: true, completion: nil)
            }
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
    }
    
    
    //MARK:- FUNCIONES PROPIAS
    
    func Login(loginData: String){
        self.AutenticandoView.isHidden = false
        self.login = String(loginData).components(separatedBy: ",")
        EnviarSocket(loginData)
        //self.EnviarTimer(estado: 1, datos: loginData)
    }

    //FUNCTION ENVIO CON TIMER
    func EnviarTimer(estado: Int, datos: String){
        if estado == 1{
            if !self.emitTimer.isValid{
                self.emitTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(EnviarSocket1(_:)), userInfo: ["datos": datos], repeats: true)
            }
        }else{
            self.emitTimer.invalidate()
            self.EnviosCount = 0
        }
    }
    
    //FUNCIÓN ENVIAR AL SOCKET
    func EnviarSocket(_ datos: String){
        if CConexionInternet.isConnectedToNetwork() == true{
            if myvariables.socket.reconnects{
                myvariables.socket.emit("data",datos)
                self.EnviarTimer(estado: 1, datos: datos)
            }
            else{
                let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor intentar otra vez.", preferredStyle: UIAlertControllerStyle.alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                    exit(0)
                }))
                
                self.present(alertaDos, animated: true, completion: nil)
            }
        }else{
            self.ErrorConexion()
        }
    }
    
    @objc func EnviarSocket1(_ timer: Timer){
        if CConexionInternet.isConnectedToNetwork() == true{
            if myvariables.socket.reconnects && self.EnviosCount <= 3 {
                self.EnviosCount += 1
                let userInfo = timer.userInfo as! Dictionary<String, AnyObject>
                var datos: String = (userInfo["datos"] as! String)
                myvariables.socket.emit("data",datos)
                //let result = myvariables.socket.emitWithAck("data", datos)
            }else{
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
    
    func ErrorConexion(){
        let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor revise su conexión a Internet.", preferredStyle: UIAlertControllerStyle.alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
            exit(0)
        }))
        self.present(alertaDos, animated: true, completion: nil)
    }

    //MARK:- ACCIONES DE LOS BOTONES
    //LOGIN Y REGISTRO DE CLIENTE
    @IBAction func Autenticar(_ sender: AnyObject) {
        
        let loginData = "#LoginPassword," + self.Usuario.text! + "," + self.Clave.text! + ",# \n"
        self.Clave.endEditing(true)
        //CREAR EL FICHERO DE LOGÍN
        let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"        
        do {
            _ = try loginData.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
            
        } catch {
            
        }
        self.Login(loginData: loginData)
    }
    
    @IBAction func OlvideClave(_ sender: AnyObject) {
        ClaveRecover.isHidden = false
    }
    
    @IBAction func RecuperarClave(_ sender: AnyObject) {
        //"#Recuperarclave,numero de telefono,#"
        self.Usuario.resignFirstResponder()
        self.Clave.resignFirstResponder()
        let recuperarDatos = "#Recuperarclave," + movilClaveRecover.text! + ",# \n"
        EnviarSocket(recuperarDatos)
        //self.EnviarTimer(estado: 1, datos: recuperarDatos)
        ClaveRecover.isHidden = true
        movilClaveRecover.endEditing(true)
        movilClaveRecover.text?.removeAll()
    }
    
    @IBAction func CancelRecuperarclave(_ sender: AnyObject) {
        ClaveRecover.isHidden = true
        self.movilClaveRecover.endEditing(true)
        self.movilClaveRecover.text?.removeAll()
    }

    @IBAction func RegistrarCliente(_ sender: AnyObject) {
        self.Usuario.resignFirstResponder()
        self.Clave.resignFirstResponder()
        RegistroView.isHidden = false
        
    }
    @IBAction func EnviarRegistro(_ sender: AnyObject) {
        if (nombreApText.text!.isEmpty || telefonoText.text!.isEmpty || claveText.text!.isEmpty) {
            let alertaDos = UIAlertController (title: "Registro de Usuario", message: "Debe llenar todos los campos del formulario", preferredStyle: UIAlertControllerStyle.alert)
            alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                
            }))

            self.present(alertaDos, animated: true, completion: nil)
        }
        else{
            var posicion = "0,0"
            let temporal = "," + telefonoText.text! + "," + telefonoText.text! + "," + claveText.text!
            var correo = ",Sin correo" + "," + RecomendadoText.text!
            if !(correoText.text?.isEmpty)!{
                correo = "," + correoText.text! + "," + RecomendadoText.text!
            }
            if let posTemp = coreLocationManager.location{
                    posicion = String(posTemp.coordinate.latitude) + "," + String(posTemp.coordinate.longitude)
            }
            let registroDatos = "#NR" + "," + nombreApText.text! + temporal + correo + "," + posicion + ",# \n"
            myvariables.socket.emit("data", registroDatos)
            //self.EnviarTimer(estado: 1, datos: registroDatos)
        }
        RegistroView.isHidden = true
        claveText.resignFirstResponder()
        confirmarClavText.resignFirstResponder()
        correoText.resignFirstResponder()
        RecomendadoText.resignFirstResponder()
    }
    
    @IBAction func CancelarRegistro(_ sender: AnyObject) {
        RegistroView.isHidden = true
        claveText.endEditing(true)
        confirmarClavText.endEditing(true)
        correoText.endEditing(true)
        nombreApText.text?.removeAll()
        telefonoText.text?.removeAll()
        
        claveText.text?.removeAll()
        confirmarClavText.text?.removeAll()
        correoText.text?.removeAll()
        RecomendadoText.text?.removeAll()
    }


    //MARK:- CONTROL DE TECLADO VIRTUAL
    //Funciones para mover los elementos para que no queden detrás del teclado
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textColor = UIColor.black
        textField.text?.removeAll()
            if textField.isEqual(claveText) || textField.isEqual(Clave){
                animateViewMoving(true, moveValue: 80, view: self.view)
            }
            else{
                if textField.isEqual(movilClaveRecover){
                    textField.text?.removeAll()
                    animateViewMoving(true, moveValue: 105, view: self.view)
                }
                else{
                    if textField.isEqual(confirmarClavText) || textField.isEqual(correoText) || textField.isEqual(RecomendadoText){
                            textField.tintColor = UIColor.black
                            animateViewMoving(true, moveValue: 200, view: self.view)
                        }else{
                        if textField.isEqual(self.telefonoText){
                            textField.textColor = UIColor.black
                            //textField.text = ""
                            animateViewMoving(true, moveValue: 70, view: self.view)
                        }
                    }
        }
        }
    }
    func textFieldDidEndEditing(_ textfield: UITextField) {
        textfield.text = textfield.text!.replacingOccurrences(of: ",", with: ".")
            if textfield.isEqual(claveText) || textfield.isEqual(Clave){
                    animateViewMoving(false, moveValue: 80, view: self.view)
            }else{
                if textfield.isEqual(confirmarClavText) || textfield.isEqual(correoText) || textfield.isEqual(RecomendadoText){
                    if textfield.text != claveText.text && textfield.isEqual(confirmarClavText){
                            textfield.textColor = UIColor.red
                            textfield.text = "Las claves no coinciden"
                            textfield.isSecureTextEntry = false
                            RegistroBtn.isEnabled = false
                        }
                        else{
                            RegistroBtn.isEnabled = true
                        }
                    animateViewMoving(false, moveValue: 200, view: self.view)
                    }else{
                        if textfield.isEqual(telefonoText) || textfield.isEqual(RecomendadoText){
        
                            if textfield.text?.characters.count != 10{
                                textfield.textColor = UIColor.red
                                textfield.text = "Número de Teléfono Incorrecto"
                            }
                            animateViewMoving(false, moveValue: 70, view: self.view)
                        }else{
                            if textfield.isEqual(movilClaveRecover){
                                if movilClaveRecover.text?.characters.count != 10{
                                    textfield.text = "Número de Teléfono Incorrecto"
                                }else{
                                    self.RecuperarClaveBtn.isEnabled = true
                                }
                                animateViewMoving(false, moveValue: 105, view: self.view)
                            }
                        }
                    }
                }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {

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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        if textField.isEqual(self.Clave){
            let loginData = "#LoginPassword," + self.Usuario.text! + "," + self.Clave.text! + ",# \n"
            //CREAR EL FICHERO DE LOGÍN
            let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
            
            do {
                _ = try loginData.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
                
            } catch {
                
            }
            self.Login(loginData: loginData)
        }
        return true
    }
    
    @objc func ocultarTeclado(){
        self.ClaveRecover.endEditing(true)
        self.DatosView.endEditing(true)
        self.RegistroView.endEditing(true)
    }
}

extension LoginController: XMLParserDelegate {
    func parserDidEndDocument(_ parser: XMLParser) {
        //print("Person str is:: " + self.serverStr)
        //TODO: You have to build your json object from the PersonStr now
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue += string
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "untaxi" {
            self.recordKey = "untaxi"
            self.currentDictionary = [String : String]()
        } else if dictionaryKeys.contains(elementName) {
            self.currentValue = String()
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "cliente"{
            if self.recordKey == "untaxi"{
            self.results.append(self.currentDictionary)
            self.currentDictionary = [String:String]()
                self.recordKey = ""
            }
        } else if dictionaryKeys.contains(elementName) {
            self.currentDictionary[elementName] = currentValue
            self.currentValue = ""
        }
    }
    // Just in case, if there's an error, report it. (We don't want to fly blind here.)
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.currentValue = ""
        self.currentDictionary = [String:String]()
        self.results = [[String:String]]()
    }
    
    func ServerSelect(completionHandler:@escaping (Bool)->()){
        let url = NSURL(string: "http://www.xoait.com/dirtablesios.xml")
        let ServerXml = XMLParser(contentsOf: url! as URL)
        //print(ServerXml)
        ServerXml?.delegate = self
        let result = ServerXml?.parse()
        var writeString = "http://www.xoait.com:5803"
        if result!{
            for server in results {
                writeString = server["ip"]!+":"+server["p"]!+","
            }
            //CREAR EL FICHERO DE LOGÍN
        }
        let filePath = NSHomeDirectory() + "/Library/Caches/servers.txt"
        
        do {
            _ = try writeString.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            
        }
        self.ServersData = String(describing: writeString).components(separatedBy: ",")
        completionHandler(true)
    }
    func ServerConect(completionHandler:@escaping (Bool)->()){
        var i = 0
        while i < self.ServersData.count - 1{
            myvariables.socket = SocketIOClient(socketURL: URL(string: "http://"+self.ServersData[i])!, config: [.log(false), .forcePolling(true)])
            myvariables.socket.connect()
            i += 1
        }
        completionHandler(true)
    }
}
