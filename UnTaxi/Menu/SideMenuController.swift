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
    self.MenuView1.layer.borderColor = UIColor.lightGray.cgColor
    self.MenuView1.layer.borderWidth = 0.3
    self.MenuView1.layer.masksToBounds = false
    
    self.NombreUsuario.text = "¡Hola, \(globalVariables.cliente.nombreApellidos.uppercased())!"
    self.NombreUsuario.textColor = Customization.textColor
    //self.NombreUsuario.font = CustomAppFont.subtitleFont
    globalVariables.cliente.cargarPhoto(imageView: self.userProfilePhoto)
    
    self.menuHeaderHeightConstraint.constant = Responsive().heightFloatPercent(percent: 28)
    self.yapaTextHeightConstraint.constant = Responsive().heightFloatPercent(percent: 6)
    self.yapaText.addBorder(color: Customization.buttonActionColor)
    self.yapaText.text = "$\(globalVariables.cliente.yapa)"
    //self.yapaText.font = CustomAppFont.bigFont
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showYapaView))
    //tapGesture.delegate = self
    self.yapaText.addGestureRecognizer(tapGesture)
  }
  
  //MASK:- FUNCTIONS
  @objc func showYapaView(){
    //globalVariables.publicidadService?.stopPublicidad()
    let vc = R.storyboard.main.yapaView()!
    self.present(vc, animated: false, completion: nil)//self.navigationController?.show(vc, sender: nil)
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
