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
  var socketService = SocketService()
  
  let myContext = LAContext()
  
  //MARK:- VARIABLES INTERFAZ
  
  @IBOutlet weak var loginBackView: UIView!
  @IBOutlet weak var usuario: UITextField!
  @IBOutlet weak var clave: UITextField!
  
  @IBOutlet weak var autenticarBtn: UIButton!
  @IBOutlet weak var waitingView: UIVisualEffectView!
  
  @IBOutlet weak var DatosView: UIView!
  @IBOutlet weak var claveRecoverView: UIView!
  @IBOutlet weak var movilClaveRecover: UITextField!
  @IBOutlet weak var RecuperarClaveBtn: UIButton!
  @IBOutlet weak var recoverDataView: UIView!
  @IBOutlet weak var showHideClaveBtn: UIButton!
  @IBOutlet weak var RegistroBtn: UIButton!
  
  //Recover Password
  @IBOutlet weak var NewPasswordView: UIView!
  @IBOutlet weak var codigoText: UITextField!
  @IBOutlet weak var newPasswordText: UITextField!
  @IBOutlet weak var passwordMatch: UITextField!
  @IBOutlet weak var crearNewPasswordText: UIButton!
  
  
  //CONSTRAINTS DEFINITION
  @IBOutlet weak var textFieldHeight: NSLayoutConstraint!
  
  @IBOutlet weak var movilClaveRecoverHeight: NSLayoutConstraint!
  @IBOutlet weak var loginDatosViewHeight: NSLayoutConstraint!
  
  @IBOutlet weak var newPasswordFormHeight: NSLayoutConstraint!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    globalVariables.userDefaults = UserDefaults.standard
    
    self.coreLocationManager = CLLocationManager()
    coreLocationManager.delegate = self
    coreLocationManager.requestWhenInUseAuthorization()

    self.movilClaveRecover.delegate = self
    self.clave.delegate = self
    self.apiService.delegate = self
    self.socketService.delegate = self
    
    self.waitingView.addStandardConfig()
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado))
    
    self.DatosView.addGestureRecognizer(tapGesture)
    self.claveRecoverView.addGestureRecognizer(tapGesture)
    self.view.addGestureRecognizer(tapGesture)
 
    self.autenticarBtn.addShadow()
    self.RecuperarClaveBtn.addShadow()
    self.crearNewPasswordText.addShadow()
    
    self.autenticarBtn.heightAnchor 
    self.loginDatosViewHeight.constant = CGFloat(globalVariables.responsive.heightPercent(percent: 30))
    self.newPasswordFormHeight.constant = 40
    
    self.clave.clearButtonMode = .never

    //Calculate the custom constraints
    self.getTextfieldHeight(textFieldHeight: self.textFieldHeight)
    
    let spaceBetween = (UIScreen.main.bounds.height - self.textFieldHeight.constant * 9) / 17
    
    self.myContext.localizedCancelTitle = "Autenticar con Usuario/Clave"
    
    NSLayoutConstraint(item: self.codigoText, attribute: .bottom, relatedBy: .equal, toItem: self.newPasswordText, attribute: .top, multiplier: 1, constant: -spaceBetween).isActive = true
    
    NSLayoutConstraint(item: self.passwordMatch as Any, attribute: .top, relatedBy: .equal, toItem: self.newPasswordText, attribute: .bottom, multiplier: 1, constant: spaceBetween).isActive = true
    
    self.movilClaveRecoverHeight.constant = 40
    
    if CConexionInternet.isConnectedToNetwork() == true{
      print("login \(globalVariables.userDefaults.value(forKey: "accessToken"))")
      if globalVariables.userDefaults.value(forKey: "accessToken") != nil{
        //self.socketService.initLoginEventos()
        self.startSocketConnection()
      }else{
        self.waitingView.isHidden = true
      }
    }else{
      //ErrorConexion()
    }
//    self.telefonoText.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    
    //self.checkifBioAuth()
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
    if self.newPasswordText.text!.isEmpty || self.passwordMatch.text!.isEmpty || self.codigoText.text!.isEmpty{
      let alertaDos = UIAlertController (title: "Crear nueva clave", message: "Debe llenar todos los campos del formulario", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in

      }))
      
      self.present(alertaDos, animated: true, completion: nil)
    }else{
    if self.newPasswordText.text == self.passwordMatch.text{
      self.createNewPassword(codigo: self.codigoText.text!, newPassword: self.newPasswordText.text!)
    }else{
      let alertaDos = UIAlertController (title: "Nueva clave", message: "Las nueva clave no coincide en ambos campos", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        //self.RegistroView.isHidden = false
        //self.nombreApText.becomeFirstResponder()
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
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
    let vc = R.storyboard.login.registroView()!
    self.navigationController?.show(vc, sender: self)
    //RegistroView.isHidden = false
    //self.telefonoText.becomeFirstResponder()
    
  }

  @IBAction func showHideClave(_ sender: Any) {
    if self.clave.isSecureTextEntry{
      self.showHideClaveBtn.setImage(UIImage(named: "hideClave"), for: .normal)
      self.clave.isSecureTextEntry = false
    }else{
      self.showHideClaveBtn.setImage(UIImage(named: "showClave"), for: .normal)
      self.clave.isSecureTextEntry = true
    }
  }
}
