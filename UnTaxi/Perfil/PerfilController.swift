//
//  PerfilController.swift
//  UnTaxi
//
//  Created by Done Santana on 9/3/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import UIKit
import SocketIO
import CoreImage

class PerfilController: BaseController {
  
  var userperfil : Cliente!

  var login = [String]()
  
  var camaraController: UIImagePickerController!
  
  var apiService = ApiService()
  
  var isPhotoUpdated = false
  
  @IBOutlet weak var titleText: UILabel!
  @IBOutlet weak var subtitleText: UILabel!
  
  @IBOutlet weak var perfilBackground: UIView!
  @IBOutlet weak var nombreApellidosText: UITextField!
  @IBOutlet weak var usuarioText: UITextField!
  @IBOutlet weak var emailText: UITextField!
  @IBOutlet weak var userPerfilPhoto: UIImageView!
  @IBOutlet weak var waitingView: UIVisualEffectView!
  @IBOutlet weak var updatePhto: UIButton!
  
  @IBOutlet weak var ActualizarBtn: UIButton!
  @IBOutlet weak var changePassBtn: UIButton!
  
  @IBOutlet weak var perfilViewHeight: NSLayoutConstraint!
  
  
  override func viewDidLoad() {
    super.barTitle = Customization.nameShowed
    super.viewDidLoad()
    
    self.changePassBtn.addBorder(color: CustomAppColor.buttonActionColor)
    apiService.delegate = self
    emailText.delegate = self
    self.navigationController?.navigationBar.tintColor = UIColor.black
    //UILabel.appearance().textColor = .lightGray
    
    let readString = globalVariables.userDefaults.string(forKey: "loginData") ?? ""
    
    self.login = String(readString).components(separatedBy: ",")
    self.perfilViewHeight.constant = CGFloat(globalVariables.responsive.heightPercent(percent: 70))
    ActualizarBtn.addCustomActionBtnsColors()
    //self.titleText.font = CustomAppFont.titleFont
    //self.subtitleText.font = CustomAppFont.subtitleFont
    
    self.nombreApellidosText.text = globalVariables.cliente.nombreApellidos
    self.usuarioText.text = globalVariables.cliente.user
    self.emailText.text = globalVariables.cliente.email
    globalVariables.cliente.cargarPhoto(imageView: self.userPerfilPhoto)
    self.camaraController = UIImagePickerController()
    self.camaraController.delegate = self
    
    let updateBtnImage = UIImage(named: "camera")?.withRenderingMode(.alwaysTemplate)
    self.updatePhto.setImage(updateBtnImage, for: UIControl.State())
    self.updatePhto.tintColor = .white
    
    waitingView.addStandardConfig()
    
  }
  
//  override func homeBtnAction() {
//    self.goToInicioView()
//  }
  
  func isProfileUpdated()->Bool{
    return globalVariables.cliente.nombreApellidos != self.nombreApellidosText.text || globalVariables.cliente.user != self.usuarioText.text || globalVariables.cliente.email != self.emailText.text
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
  }
  
  //FUNCIÓN ENVIAR AL SOCKET
  func EnviarSocket(_ datos: String){
    if CConexionInternet.isConnectedToNetwork() == true{
      if globalVariables.socket.status.active{
        globalVariables.socket.emit("data",datos)
      }
      else{
        let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor intentar otra vez.", preferredStyle: UIAlertController.Style.alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          exit(0)
        }))
        self.present(alertaDos, animated: true, completion: nil)
      }
    }else{
      self.ErrorConexion()
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
  
  func EnviarActualizacion() {
    if self.usuarioText.text!.isEmpty && self.emailText.text!.isEmpty{
      let alertaDos = UIAlertController (title: "Mensaje Error", message: "Está tratando de enviar un formulario vacío. Por favor introduzca los valores que desea actualizar.", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }else{
      let params = [
        "nombreapellidos": self.nombreApellidosText.text as Any,
        "movil": self.usuarioText.text as Any,
        "email": self.emailText.text as Any,
      ] as [String : Any]
      
      apiService.updateProfileAPI(parameters: params as [String: AnyObject])
    }
  }

  @IBAction func actualizarPhto(_ sender: Any) {
    self.camaraController.sourceType = .camera
    self.camaraController.cameraCaptureMode = .photo
    self.camaraController.cameraDevice = .front
    self.present(self.camaraController, animated: true, completion: nil)
  }
  
  @IBAction func ActualizarPerfil(_ sender: Any) {
    if isPhotoUpdated || self.isProfileUpdated(){
      self.view.endEditing(true)
      self.waitingView.isHidden = false
      self.EnviarActualizacion()
    }else{
      let alertaDos = UIAlertController (title: "Mensaje Error", message: "No se han modificado los datos del perfil. Por favor introduzca los valores que desea actualizar.", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        
      }))
      
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
  @IBAction func changePassword(_ sender: Any) {
    let vc = R.storyboard.main.password()
    self.present(vc!, animated: false, completion: nil)
    //self.navigationController?.show(vc!, sender: nil)
  }
  
  @IBAction func cerrarSesion(_ sender: Any) {
    globalVariables.userDefaults.set(nil, forKey: "accessToken")
    let vc = R.storyboard.main.inicioView()!
    vc.CloseAPP()   
  }
  
}
