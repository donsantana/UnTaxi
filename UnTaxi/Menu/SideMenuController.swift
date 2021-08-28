//
//  SideMenuController.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 11/25/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit
import SideMenu

class SideMenuController: UIViewController {
  //MenuData(imagen: "nuevaSolicitud", title: "Nuevo viaje"),
  var menuArray = [[MenuData(imagen: "enProceso", title: "Viajes en proceso"),MenuData(imagen: "historial", title: "Historial de Viajes")],[MenuData(imagen: "callCenter", title: "Operadora"),MenuData(imagen: "terminos", title: "Términos y condiciones"),MenuData(imagen: "compartir", title: "Compartir app")],[MenuData(imagen: "salir2", title: "Salir")]]//,MenuData(imagen: "card", title: "Mis tarjetas")
  
  
  @IBOutlet weak var MenuView1: UIView!
  @IBOutlet weak var MenuTable: UITableView!
  @IBOutlet weak var NombreUsuario: UILabel!
  @IBOutlet weak var yapaText: UILabel!
  @IBOutlet weak var userProfilePhoto: UIImageView!
  
  @IBOutlet weak var menuHeaderHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var yapaTextHeightConstraint: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    self.view.backgroundColor = .white
    
    self.MenuTable.delegate = self
    self.MenuView1.backgroundColor = CustomAppColor.menuBackgroundColor
    self.MenuView1.layer.borderColor = CustomAppColor.menuTextColor.cgColor
    self.MenuView1.layer.borderWidth = 0.3
    self.MenuView1.layer.masksToBounds = false

    self.NombreUsuario.textColor = CustomAppColor.menuTextColor
    //self.NombreUsuario.font = CustomAppFont.subtitleFont
    
    self.menuHeaderHeightConstraint.constant = Responsive().heightFloatPercent(percent: 28)
    self.yapaTextHeightConstraint.constant = Responsive().heightFloatPercent(percent: 6)
    self.yapaText.addBorder(color: CustomAppColor.buttonActionColor)
    self.yapaText.textColor = CustomAppColor.menuTextColor
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showYapaView))
    //tapGesture.delegate = self
    self.yapaText.addGestureRecognizer(tapGesture)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    self.NombreUsuario.text = "¡Hola, \(globalVariables.cliente.nombreApellidos.uppercased())!"
    self.yapaText.text = " $\(String(format: "%.2f", globalVariables.cliente.yapa))"
    globalVariables.cliente.cargarPhoto(imageView: self.userProfilePhoto)
  }
  
  //MASK:- FUNCTIONS
  @objc func showYapaView(){
    //globalVariables.publicidadService?.stopPublicidad()
    let vc = R.storyboard.main.yapaView()!
    self.navigationController?.show(vc, sender: nil)
  }
  
  @objc func EnviarSocket(_ datos: String){
    if CConexionInternet.isConnectedToNetwork() == true{
      if globalVariables.socket.status.active{
        globalVariables.socket.emit("data",datos)
        print(datos)
        //self.EnviarTimer(estado: 1, datos: datos)
      }else{
        let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor intentar otra vez.", preferredStyle: UIAlertController.Style.alert)
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
    //self.CargarTelefonos()
    //AlertaSinConexion.isHidden = false
    
    let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor revise su conexión a Internet.", preferredStyle: UIAlertController.Style.alert)
    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
      exit(0)
    }))
    self.present(alertaDos, animated: true, completion: nil)
  }
  
  func CloseAPP(){
    let fileAudio = FileManager()
    let AudioPath = NSHomeDirectory() + "/Library/Caches/Audio"
    do {
      try fileAudio.removeItem(atPath: AudioPath)
    }catch{
      
    }
    print("closing app")
    let datos = "#SocketClose,\(globalVariables.cliente.id),# \n"
    EnviarSocket(datos)
    exit(3)
  }
  
  @IBAction func showProfile(_ sender: Any) {
    //globalVariables.publicidadService?.stopPublicidad()
    let vc = R.storyboard.main.perfil()!
    self.navigationController!.show(vc, sender: nil)
  }
  
  
}

extension SideMenuController: SocketServiceDelegate{
  func socketResponse(_ controller: SocketService, actualizaryapa result: [String : Any]) {
    self.yapaText.text = "$\(String(format: "%.2f", globalVariables.cliente.yapa))"
  }
}
