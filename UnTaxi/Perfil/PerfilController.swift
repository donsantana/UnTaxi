//
//  PerfilController.swift
//  UnTaxi
//
//  Created by Done Santana on 9/3/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import UIKit
import SocketIO

class PerfilController: BaseController {
  
  var userperfil : Cliente!
  var NuevoTelefonoText: String = ""
  var NuevoEmailText: String = ""
  var ClaveActual: String = ""
  var NuevaClaveText: String = ""
  var ConfirmeClaveText: String = ""
  
  var login = [String]()
  
  var perfil2 : UITextField!
  
  var perfilNombreCell = Bundle.main.loadNibNamed("PerfilNombreCell", owner: self, options: nil)?.first as! PerfilNombreCell
  var userViewCell = Bundle.main.loadNibNamed("PerfilViewCell", owner: self, options: nil)?.first as! PerfilViewCell
  var emailViewCell = Bundle.main.loadNibNamed("Perfil2ViewCell", owner: self, options: nil)?.first as! Perfil2ViewCell
  
  @IBOutlet weak var perfilBackground: UIView!
  
  @IBOutlet weak var NombreApellidoText: UILabel!
  @IBOutlet weak var PerfilTable: UITableView!
  @IBOutlet weak var ActualizarBtn: UIButton!
  
  @IBOutlet weak var perfilViewHeight: NSLayoutConstraint!
  
  
  override func viewDidLoad() {
    super.barTitle = Customization.nameShowed
    super.viewDidLoad()
    
    ApiService().delegate = self
    self.navigationController?.navigationBar.tintColor = UIColor.black
    
    let readString = globalVariables.userDefaults.string(forKey: "loginData") ?? ""
    
    self.login = String(readString).components(separatedBy: ",")
    self.perfilViewHeight.constant = CGFloat(globalVariables.responsive.heightPercent(percent: 70))
    
    self.NombreApellidoText.text = globalVariables.cliente.nombreApellidos
    //MASK: - PARA MOSTRAR Y OCULTAR EL TECLADO
    //NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    
//    globalVariables.socket.on("UpdateUser"){data, ack in
//      let temporal = String(describing: data).components(separatedBy: ",")
//      if temporal[1] == "ok"{
//        let alertaDos = UIAlertController (title: "Perfil Actualizado", message: "Su perfil se actualizo con ÉXITO. Los cambios se verán reflejados una vez que vuelva ingresar a la aplicación.", preferredStyle: UIAlertController.Style.alert)
//        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
//          let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "Inicio") as! InicioController
//          self.navigationController?.show(vc, sender: nil)
//        }))
//
//        self.present(alertaDos, animated: true, completion: nil)
//      }else{
//        let alertaDos = UIAlertController (title: "Error de Perfil", message: "Se produjo un ERROR al actualizar su perfil. Sus datos continuan sin cambios.", preferredStyle: UIAlertController.Style.alert)
//        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
//
//        }))
//        self.present(alertaDos, animated: true, completion: nil)
//      }
//    }
    
    
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
    if self.NuevoTelefonoText == "" && self.NuevoEmailText == ""{
      let alertaDos = UIAlertController (title: "Mensaje Error", message: "Está tratando en enviar un formulario vacío. Por favor introduzca los valores que desea actualizar.", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        
      }))
      
      self.present(alertaDos, animated: true, completion: nil)
      
    }else{
      let params = [
        "nombreapellidos": self.perfilNombreCell.nombreApellidosText.text,
        "movil": self.userViewCell.NuevoValor.text,
        "email": self.emailViewCell.NuevoValor.text,
      ]
      ApiService().updateProfileAPI(params: params as [String: AnyObject])
      //        let datos = "#UpdateUser," + globalVariables.cliente.idUsuario + "," + globalVariables.cliente.user + "," + self.NuevoTelefonoText + "," + globalVariables.cliente.email + "," + self.NuevoEmailText + "," + self.ClaveActual + ,\(self.NuevaClaveText),# \n"
      //        EnviarSocket(datos)
    }
  }

  @IBAction func ActualizarPerfil(_ sender: Any) {
    if self.ConfirmeClaveText != "Las Claves Nuevas no coinciden"{
      self.view.endEditing(true)
      self.EnviarActualizacion()
    }
  }
  
  @IBAction func changePassword(_ sender: Any) {
    let vc = R.storyboard.main.password()
    self.navigationController?.show(vc!, sender: nil)
  }
  
}
