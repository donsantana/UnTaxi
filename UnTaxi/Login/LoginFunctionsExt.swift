//
//  PrivateFunctions.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/2/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import Foundation
import SocketIO
import CoreLocation
import Rswift
import LocalAuthentication


extension LoginController{
  
  func startSocketConnection(){
    //print(Customization.serverData!)
    let accessToken = globalVariables.userDefaults.value(forKey: "accessToken") as! String
    self.socketIOManager = SocketManager(socketURL: URL(string: GlobalConstants.socketurlHost)!, config: [.log(false),.compress,.forcePolling(true),.version(.two), .connectParams(["Authorization": "Bearer token", "token": accessToken])]) //Customization.serverData
    
    print("token para socket \(accessToken)")
//    self.socketIOManager.config = SocketIOClientConfiguration(
//      arrayLiteral: .compress, .connectParams(["Authorization": "Bearer token", "token": accessToken])
//    )
    
    globalVariables.socket = self.socketIOManager.socket(forNamespace: "/")
    //self.waitSocketConnection()
    self.socketService.initLoginEventos()
    globalVariables.socket.connect()

  }
  
  func initClientData(datos: [String: Any]){
    
    let clientData = datos["cliente"] as! [String: Any]
    let appConfig = datos["config"] as! [String: Any]
    print("appConfig \(appConfig)")
    
    if !(appConfig["publicidad"] is NSNull) && appConfig["publicidad"] != nil{
      let publicidad = !(appConfig["publicidad"] is NSNull) ? appConfig["publicidad"] as! [String: Any] : nil
      print("publicidades \(publicidad!["images"] as! [[String: Any]])")
      globalVariables.publicidadService = PublicidadService(publicidades: publicidad!["images"] as! [[String: Any]])
    }
    
    let solicitudesEnProceso = datos["solicitudes"] as! [[String: Any]]
    globalVariables.tarifario = Tarifario(jsonData: datos["tarifas"] as! [String: Any])
    globalVariables.cliente = Cliente(jsonData: clientData)
    globalVariables.appConfig = appConfig != nil ? AppConfig(config: appConfig) : AppConfig()
    
    print("appConfig \(globalVariables.appConfig)")
    
    if solicitudesEnProceso.count > 0{
      self.ListSolicitudPendiente(solicitudesEnProceso)
    }
    
    self.checkLocationStatus()
  }
  
  func initConnectionError(message: String){
    let alertaDos = UIAlertController (title: "Autenticación", message: message, preferredStyle: UIAlertController.Style.alert)
    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
      self.waitingView.isHidden = true
      self.usuario.text?.removeAll()
      self.usuario.text?.removeAll()
    }))
    self.present(alertaDos, animated: true, completion: nil)
  }
  
  func checkLocationStatus(){
    
    if CLLocationManager.locationServicesEnabled(){
      switch(CLLocationManager.authorizationStatus()) {
      case .notDetermined, .restricted, .denied:
        let locationAlert = UIAlertController (title: "Error de Localización", message: "La aplicación solo utiliza su localización para buscar los taxis cercanos. Por favor autorice el acceso de la aplición al servicio de localización.", preferredStyle: .alert)
        locationAlert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          if #available(iOS 10.0, *) {
            let settingsURL = URL(string: UIApplication.openSettingsURLString)!
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: { success in
              exit(0)
            })
          } else {
            if let url = NSURL(string:UIApplication.openSettingsURLString) {
              UIApplication.shared.openURL(url as URL)
              exit(0)
            }
          }
        }))
        locationAlert.addAction(UIAlertAction(title: "Cerrar Aplicación", style: .default, handler: {alerAction in
          exit(0)
        }))
        self.present(locationAlert, animated: true, completion: nil)
      case .authorizedAlways, .authorizedWhenInUse:
        self.checkSolPendientes()
        break
      default:
        break
      }
    }else{
      let locationAlert = UIAlertController (title: "Error de Localización", message: "La aplicación solo utiliza su localización para buscar los taxis cercanos. Por favor autorice el acceso de la aplición al servicio de localización.", preferredStyle: .alert)
      locationAlert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        if #available(iOS 10.0, *) {
          let settingsURL = URL(string: UIApplication.openSettingsURLString)!
          UIApplication.shared.open(settingsURL, options: [:], completionHandler: { success in
            exit(0)
          })
        } else {
          if let url = NSURL(string:UIApplication.openSettingsURLString) {
            UIApplication.shared.openURL(url as URL)
            exit(0)
          }
        }
      }))
      locationAlert.addAction(UIAlertAction(title: "No", style: .default, handler: {alerAction in
        exit(0)
      }))
      self.present(locationAlert, animated: true, completion: nil)
    }
  }
  
  func checkSolPendientes(){
    print("checkSolPendientes")
    var vc = UIViewController()
    switch globalVariables.solpendientes.count {
    case 0:
      vc = R.storyboard.main.inicioView()!
      break
    case 1:
      if globalVariables.solpendientes.first!.isAceptada(){
        vc = R.storyboard.main.solDetalles()!
        (vc as! SolPendController).solicitudPendiente = globalVariables.solpendientes.first!
      }else{
        vc = R.storyboard.main.esperaChildView()!
        (vc as! EsperaChildVC).solicitud = globalVariables.solpendientes.first!
      }
      //self.navigationController?.show(vc, sender: self)
      break
    default:
      let vc = R.storyboard.main.listaSolPdtes()!
                                   
    }
    
    self.navigationController?.show(vc, sender: self)
    
  }
  
  //FUNCION PARA LISTAR SOLICITUDES PENDIENTES
  func ListSolicitudPendiente(_ listado : [[String: Any]]){
    //#LoginPassword,loginok,idusuario,idrol,idcliente,nombreapellidos,cantsolpdte,idsolicitud,idtaxi,cod,fechahora,lattaxi,lngtaxi, latorig,lngorig,latdest,lngdest,telefonoconductor
    globalVariables.solpendientes.removeAll()
    var i = 0
    while i < listado.count {
      let data = listado[i]
      let solpendiente = Solicitud(jsonData: data)
      solpendiente.DatosCliente(cliente: globalVariables.cliente)
      globalVariables.solpendientes.append(solpendiente)
      if solpendiente.taxi.id != 0{
        globalVariables.solicitudesproceso = true
      }
      i += 1
    }
  }
  
  
  //MARK:- FUNCIONES PROPIAS
  
  func Login(user: String, password: String){
    self.apiService.loginToAPIService(user: user, password: password)
    self.waitingView.isHidden = false
  }
  
  func createNewPassword(codigo: String, newPassword: String){
    self.apiService.createNewClaveAPI(url: GlobalConstants.createPassUrl, params: [
      "nombreusuario": globalVariables.userDefaults.value(forKey: "nombreUsuario") as! String,
      "codigo": codigo,
      "password": newPassword,
    ])
  }
  
  func checkifBioAuth(){
    let myLocalizedReasonString = "Biometric Authntication testing !!"
    
    var authError: NSError?
    if myContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError) {
      myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString) { success, evaluateError in
        
        DispatchQueue.main.async {
          if success {
            print("success")
            // User authenticated successfully, take appropriate action
            //self.successLabel.text = "Awesome!!... User authenticated successfully"
          } else {
            print("Unsuccess")
            // User did not authenticate successfully, look at error and take appropriate action
            //self.successLabel.text = "Sorry!!... User did not authenticate successfully"
          }
        }
      }
    } else {
      print("evaluation error")
      // Could not evaluate policy; look at authError and present an appropriate message to user
      //successLabel.text = "Sorry!!.. Could not evaluate policy."
    }
  }

}
