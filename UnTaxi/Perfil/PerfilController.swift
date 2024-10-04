//
//  PerfilController.swift
//  UnTaxi
//
//  Created by Done Santana on 9/3/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import UIKit
internal import SocketIO
import CoreImage

class PerfilController: BaseController {
  
  var userperfil : Cliente!

  var login = [String]()
  
  var camaraController: UIImagePickerController!
  
  var apiService = ApiService.shared
  
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
    self.navigationController?.navigationBar.tintColor = UIColor.black
    //UILabel.appearance().textColor = .lightGray
    
    let readString = UserDefaults.standard.string(forKey: "loginData") ?? ""
    
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
	
	override func viewWillAppear(_ animated: Bool) {
		apiService.delegate = self
		nombreApellidosText.delegate = self
		emailText.delegate = self
	}
  
  func isProfileUpdated()->Bool{
    return globalVariables.cliente.nombreApellidos != self.nombreApellidosText.text || globalVariables.cliente.email != self.emailText.text
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
  }
  
  func EnviarActualizacion() {
    if !isPhotoUpdated && !self.isProfileUpdated(){
      let alertaDos = UIAlertController (title: "Mensaje Error", message: "No se han modificado los datos del perfil. Por favor introduzca los valores que desea actualizar.", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alerAction in
        
      }))
      self.present(alertaDos, animated: true, completion: nil)
    } else {
      self.view.endEditing(true)
      self.waitingView.isHidden = false
      let params = [
        "nombreapellidos": self.nombreApellidosText.text as Any,
        "movil": self.usuarioText.text as Any,
        "email": self.emailText.text as Any,
      ] as [String : Any]
      
        ApiService.shared.updateProfileAPI(parameters: params as [String: AnyObject]) { result in
            switch result {
            case .success(let jsonResult):
                globalVariables.cliente.updateProfile(jsonData: jsonResult["datos"] as! [String: Any])
                self.showProfileUpdated(success: true, message: jsonResult["msg"] as? String ?? "")
            case .failure(let error):
                var errorMessage = ""
                switch error {
                case .invalidResponse(message: let message):
                    errorMessage = message
                case .serverError(message: let message):
                    errorMessage = message
                default:
                    errorMessage = error.localizedDescription
                }
                self.showProfileUpdated(success: false,message: errorMessage)
            }
        }
    }
  }
    internal func showProfileUpdated(success: Bool, message: String) {
        DispatchQueue.main.async {
            self.waitingView.isHidden = true
            let alertaDos = UIAlertController (title: success ? GlobalStrings.profileUpdatedTitle :  GlobalStrings.errorTitle, message: message, preferredStyle: UIAlertController.Style.alert)
            alertaDos.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: { alerAction in
                if success {
                    self.goToInicioView()
                }
            }))
            
            self.present(alertaDos, animated: true, completion: nil)
        }
    }
	
	func closeSession() {
        UserDefaults.standard.set(nil, forKey: "accessToken")
		let vc = R.storyboard.main.inicioView()!
		vc.CloseAPP()
	}

  @IBAction func actualizarPhto(_ sender: Any) {
    self.camaraController.sourceType = .camera
    self.camaraController.cameraCaptureMode = .photo
    self.camaraController.cameraDevice = .front
    self.present(self.camaraController, animated: true, completion: nil)
  }
  
  @IBAction func ActualizarPerfil(_ sender: Any) {
    self.EnviarActualizacion()
  }
  
  @IBAction func changePassword(_ sender: Any) {
    let vc = R.storyboard.main.password()
    self.present(vc!, animated: false, completion: nil)
    //self.navigationController?.show(vc!, sender: nil)
  }
  
  @IBAction func cerrarSesion(_ sender: Any) {
		closeSession()
  }
	
	@IBAction func removeClient(_ sender: Any) {
		let okAction = UIAlertAction(title: GlobalStrings.eliminarButtonTitle, style: .destructive, handler: {_ in
            ApiService.shared.removeClientAPI() { result in
                switch result {
                case .success(let message):
                    self.showRemoveUser(message: message, success: true)
                case .failure(let error):
                    var errorMessage = ""
                    switch error {
                    case .invalidResponse(message: let message):
                        errorMessage = message
                    case .serverError(message: let message):
                        errorMessage = message
                    default:
                        errorMessage = error.localizedDescription
                    }
                    self.showRemoveUser(message: errorMessage, success: false)
                }
            }
		})
		let cancelAction = UIAlertAction(title: GlobalStrings.noButtonTitle, style: .default, handler: {_ in
			
		})
		Alert.showBasic(title: GlobalStrings.removeClientTitle, message: GlobalStrings.removeClientMessage, vc: self, withActions: [okAction, cancelAction])
	}
    
    internal func showRemoveUser(message: String, success: Bool) {
        let okAction = UIAlertAction(title: GlobalStrings.okButtonTitle, style: .default, handler: {_ in
            if success {
                self.closeSession()
            }
        })
        Alert.showBasic(title: "", message: message, vc: self, withActions: [okAction])
    }
  
}
