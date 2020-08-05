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
import GoogleMobileAds
import LocalAuthentication

class LoginController: UIViewController, CLLocationManagerDelegate{
  
  var login = [String]()
  var solitudespdtes = [Solicitud]()
  var coreLocationManager: CLLocationManager!
  var EnviosCount = 0
  var emitTimer = Timer()
  // var conexion = CSocket()
  
  //    var ServersData = [String]()
  //    var ServerParser = XMLParser()
  //    var recordKey = ""
  //    let dictionaryKeys = ["ip","p"]
  
  var results = [[String: String]]()                // the whole array of dictionaries
  var currentDictionary = [String : String]()    // the current dictionary
  var currentValue: String = ""                   // the current value for one of the keys in the dictionary
  
  var socketIOManager: SocketManager! //SocketManager(socketURL: URL(string: "http://www.xoait.com:5803")!, config: [.log(true), .forcePolling(true)])
  
  var apiService = ApiService()
  
  let myContext = LAContext()
  
  //MARK:- VARIABLES INTERFAZ
  
  @IBOutlet weak var loginBackView: UIView!
  @IBOutlet weak var usuario: UITextField!
  @IBOutlet weak var clave: UITextField!
  
  @IBOutlet weak var autenticarBtn: UIButton!
  @IBOutlet weak var AutenticandoView: UIView!
  
  
  @IBOutlet weak var DatosView: UIView!
  @IBOutlet weak var claveRecoverView: UIView!
  @IBOutlet weak var movilClaveRecover: UITextField!
  @IBOutlet weak var RecuperarClaveBtn: UIButton!
  @IBOutlet weak var recoverDataView: UIView!
  
  
  @IBOutlet weak var RegistroView: UIView!
  @IBOutlet weak var nombreApText: UITextField!
  @IBOutlet weak var claveText: UITextField!
  @IBOutlet weak var confirmarClavText: UITextField!
  @IBOutlet weak var correoText: UITextField!
  @IBOutlet weak var telefonoText: UITextField!
  @IBOutlet weak var RecomendadoText: UITextField!
  @IBOutlet weak var RegistroBtn: UIButton!
  @IBOutlet weak var correoTextTop: NSLayoutConstraint!
  @IBOutlet weak var registerDataView: UIView!
  @IBOutlet weak var crearCuentaBtn: UIButton!
  
  //Recover Password
  @IBOutlet weak var NewPasswordView: UIView!
  @IBOutlet weak var codigoText: UITextField!
  @IBOutlet weak var newPasswordText: UITextField!
  @IBOutlet weak var passwordMatch: UITextField!
  @IBOutlet weak var crearNewPasswordText: UIButton!
  
  
  //CONSTRAINTS DEFINITION
  @IBOutlet weak var textFieldHeight: NSLayoutConstraint!
  
  @IBOutlet weak var creaUsuarioBottom: NSLayoutConstraint!
  @IBOutlet weak var nombreTextBottom: NSLayoutConstraint!
  @IBOutlet weak var telefonoTextBottom: NSLayoutConstraint!
  @IBOutlet weak var claveTextBottom: NSLayoutConstraint!
  @IBOutlet weak var recomendadoLabelTop: NSLayoutConstraint!
  @IBOutlet weak var recomendadoTextTop: NSLayoutConstraint!
  @IBOutlet weak var registrarTop: NSLayoutConstraint!
  @IBOutlet weak var movilClaveRecoverHeight: NSLayoutConstraint!
  @IBOutlet weak var loginDatosViewHeight: NSLayoutConstraint!
  
  @IBOutlet weak var newPasswordFormHeight: NSLayoutConstraint!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    globalVariables.userDefaults = UserDefaults.standard
    
    self.coreLocationManager = CLLocationManager()
    coreLocationManager.delegate = self
    coreLocationManager.requestWhenInUseAuthorization()
    
    //telefonoText.delegate = self
    claveText.delegate = self
    correoText.delegate = self
    self.movilClaveRecover.delegate = self
    confirmarClavText.delegate = self
    clave.delegate = self
    self.RecomendadoText.delegate = self
    self.apiService.delegate = self
    
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado))
    
    self.DatosView.addGestureRecognizer(tapGesture)
    self.claveRecoverView.addGestureRecognizer(tapGesture)
    self.RegistroView.addGestureRecognizer(tapGesture)
    self.view.addGestureRecognizer(tapGesture)
    self.DatosView.addShadow()
    self.autenticarBtn.addShadow()
    self.recoverDataView.addShadow()
    self.RecuperarClaveBtn.addShadow()
    self.registerDataView.addShadow()
    self.crearCuentaBtn.addShadow()
    self.NewPasswordView.addShadow()
    self.crearNewPasswordText.addShadow()
    
    self.autenticarBtn.heightAnchor 
    self.loginDatosViewHeight.constant = CGFloat(globalVariables.responsive.heightPercent(percent: 30))
    self.newPasswordFormHeight.constant = 40
    
    //Put Background image to View
    //self.loginBackView.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
    
    //Calculate the custom constraints
    if UIScreen.main.bounds.height < 736{
      self.textFieldHeight.constant = 40
    }else{
      self.textFieldHeight.constant = 45
    }
    
    let spaceBetween = (UIScreen.main.bounds.height - self.textFieldHeight.constant * 9) / 17
    
    self.claveTextBottom.constant = -spaceBetween
    self.telefonoTextBottom.constant = -spaceBetween
    self.nombreTextBottom.constant = -spaceBetween
    self.creaUsuarioBottom.constant = -spaceBetween
    
    self.correoTextTop.constant = spaceBetween
    self.recomendadoLabelTop.constant = spaceBetween
    self.recomendadoTextTop.constant = 5
    self.registrarTop.constant = spaceBetween
    
    self.myContext.localizedCancelTitle = "Autenticar con Usuario/Clave"
    
    NSLayoutConstraint(item: self.codigoText, attribute: .bottom, relatedBy: .equal, toItem: self.newPasswordText, attribute: .top, multiplier: 1, constant: -spaceBetween).isActive = true
    
    NSLayoutConstraint(item: self.passwordMatch as Any, attribute: .top, relatedBy: .equal, toItem: self.newPasswordText, attribute: .bottom, multiplier: 1, constant: spaceBetween).isActive = true
    
    
    self.movilClaveRecoverHeight.constant = 40
    
    if CConexionInternet.isConnectedToNetwork() == true{
      print("login \(globalVariables.userDefaults.value(forKey: "accessToken"))")
      if globalVariables.userDefaults.value(forKey: "accessToken") != nil{
        self.startSocketConnection()
      }else{
        self.AutenticandoView.isHidden = true
      }
    }else{
      ErrorConexion()
    }
    self.telefonoText.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    
    self.checkifBioAuth()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    
  }
  
  
  
  
 
  //MARK:- ACCIONES DE LOS BOTONES
  //LOGIN Y REGISTRO DE CLIENTE
  @IBAction func Autenticar(_ sender: AnyObject) {
    if !self.usuario.text!.isEmpty && !self.clave.text!.isEmpty{
      self.clave.endEditing(true)
      self.Login(user: self.usuario.text!, password: self.clave.text!)
      self.usuario.text?.removeAll()
      self.clave.text?.removeAll()
    }else{
      let alertaDos = UIAlertController (title: "Formulario incompleto", message: "Debe llenar todos los campos del formulario", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        self.movilClaveRecover.becomeFirstResponder()
      }))
      
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
  @IBAction func OlvideClave(_ sender: AnyObject) {
    claveRecoverView.isHidden = false
    self.movilClaveRecover.becomeFirstResponder()
  }
  
  @IBAction func RecuperarClave(_ sender: AnyObject) {
    //"#Recuperarclave,numero de telefono,#"
    if !self.movilClaveRecover.text!.isEmpty{
      self.view.resignFirstResponder()
      apiService.recoverUserClaveAPI(url: GlobalConstants.passRecoverUrl, params: ["nombreusuario": movilClaveRecover.text!])
      globalVariables.userDefaults.set(movilClaveRecover.text, forKey: "nombreUsuario")
//      let recuperarDatos = "#Recuperarclave," + movilClaveRecover.text! + ",# \n"
//      EnviarSocket(recuperarDatos)
      //self.EnviarTimer(estado: 1, datos: recuperarDatos)
      movilClaveRecover.endEditing(true)
      movilClaveRecover.text?.removeAll()
    }else{
      let alertaDos = UIAlertController (title: "Recuperar clave", message: "Debe llenar todos los campos del formulario", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        self.movilClaveRecover.becomeFirstResponder()
      }))
      
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
  @IBAction func createNewPassword(_ sender: Any) {
    if self.newPasswordText.text == self.passwordMatch.text{
      self.createNewPassword(codigo: self.codigoText.text!, newPassword: self.newPasswordText.text!)
    }else{
      let alertaDos = UIAlertController (title: "Nueva clave", message: "Las nueva clave no coincide en ambos campos", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        self.RegistroView.isHidden = false
        self.nombreApText.becomeFirstResponder()
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
   
  }
  
  @IBAction func closeNewPasswordView(_ sender: Any) {
    self.NewPasswordView.isHidden = true
  }
  
  @IBAction func CancelRecuperarclave(_ sender: AnyObject) {
    claveRecoverView.isHidden = true
    self.movilClaveRecover.endEditing(true)
    self.movilClaveRecover.text?.removeAll()
  }
  
  @IBAction func RegistrarCliente(_ sender: AnyObject) {
    self.usuario.resignFirstResponder()
    self.clave.resignFirstResponder()
    RegistroView.isHidden = false
    self.nombreApText.becomeFirstResponder()
    
  }
  @IBAction func EnviarRegistro(_ sender: AnyObject) {
    if (nombreApText.text!.isEmpty || telefonoText.text!.isEmpty || claveText.text!.isEmpty) {
      let alertaDos = UIAlertController (title: "Registro de usuario", message: "Debe llenar todos los campos del formulario", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        self.RegistroView.isHidden = false
        self.nombreApText.becomeFirstResponder()
      }))
      
      self.present(alertaDos, animated: true, completion: nil)
    }else{
      apiService.registerUserAPI(url: GlobalConstants.registerUrl, params: [
        "password": claveText.text!,
        "movil": telefonoText.text!,
        "nombreapellidos": nombreApText.text!,
        "email": correoText.text!,
        "so": "IOS",
        
        "recomendado": RecomendadoText.text!])
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
  
}
