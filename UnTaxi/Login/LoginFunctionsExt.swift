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


extension LoginController{
  
  func startSocketConnection(){
    //print(Customization.serverData!)
    self.socketIOManager = SocketManager(socketURL: URL(string: GlobalConstants.socketurlHost)!, config: [.log(false), .forcePolling(true)]) //Customization.serverData
    let accessToken = globalVariables.userDefaults.value(forKey: "accessToken") as! String
    self.socketIOManager.config = SocketIOClientConfiguration(
      arrayLiteral: .compress, .connectParams(["Authorization": "Bearer token", "token": accessToken])
    )
    if CConexionInternet.isConnectedToNetwork() == true{
      globalVariables.socket = self.socketIOManager.socket(forNamespace: "/")
      print("Trying connect socket")
      globalVariables.socket.connect()

      self.waitSocketConnection()
    }else{
      ErrorConexion()
    }
  }
  
  func initClientData(datos: [String: Any]){
    let clientData = datos["cliente"] as! [String: Any]
    let solicitudesEnProceso = datos["solicitudes"] as! [[String: Any]]
    let fotoUrl = !(clientData["foto"] != nil) ? clientData["foto"] as! String : ""
    globalVariables.cliente = Cliente(idUsuario: clientData["idusuario"] as! Int, id: clientData["idcliente"] as! Int, user: clientData["movil"] as! String, nombre: clientData["nombreapellidos"] as! String,email: clientData["email"] as! String, idEmpresa: !(clientData["idempresa"] != nil) ? clientData["idempresa"] as! Int : 0,empresa: clientData["empresa"] as! String,foto: fotoUrl)
    
    if solicitudesEnProceso.count > 0{
      self.ListSolicitudPendiente(solicitudesEnProceso)
    }
    
    self.checkLocationStatus()
  }
  
  func initConnectionError(message: String){
    let alertaDos = UIAlertController (title: "Autenticación", message: "usuario y/o clave incorrectos", preferredStyle: UIAlertController.Style.alert)
    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
      self.AutenticandoView.isHidden = true
      self.usuario.text?.removeAll()
      self.usuario.text?.removeAll()
    }))
    self.present(alertaDos, animated: true, completion: nil)
  }
  
  func checkLocationStatus(){
    
    if CLLocationManager.locationServicesEnabled(){
      switch(CLLocationManager.authorizationStatus()) {
      case .notDetermined, .restricted, .denied:
        let locationAlert = UIAlertController (title: "Error de Localización", message: "Estimado cliente es necesario que active la localización de su dispositivo.", preferredStyle: .alert)
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
      case .authorizedAlways, .authorizedWhenInUse:
        DispatchQueue.main.async {
          let vc = R.storyboard.main.inicioView()
          self.navigationController?.show(vc!, sender: nil)
        }
        break
      default:
        break
      }
    }else{
      let locationAlert = UIAlertController (title: "Error de Localización", message: "Estimado cliente es necesario que active la localización de su dispositivo.", preferredStyle: .alert)
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
  
  //FUNCION PARA LISTAR SOLICITUDES PENDIENTES
  func ListSolicitudPendiente(_ listado : [[String: Any]]){
    //#LoginPassword,loginok,idusuario,idrol,idcliente,nombreapellidos,cantsolpdte,idsolicitud,idtaxi,cod,fechahora,lattaxi,lngtaxi, latorig,lngorig,latdest,lngdest,telefonoconductor
    var i = 0
    while i < listado.count {
      let data = listado[i]
      let solicitudpdte = Solicitud()
      solicitudpdte.DatosSolicitud(id: data["idsolicitud"] as! Int, fechaHora: data["fechahora"] as! String, dirOrigen: data["dirorigen"] as! String, referenciaOrigen: data["referenciaorigen"] as! String, dirDestino: !(data["dirdestino"] is NSNull) ? data["dirdestino"] as! String : "", latOrigen: data["latorigen"] as! Double, lngOrigen: data["lngorigen"] as! Double, latDestino: !(data["latdestino"] is NSNull) ? data["latdestino"] as! Double : 0.0, lngDestino: !(data["lngdestino"] is NSNull) ? data["lngdestino"] as! Double : 0.0, valorOferta: !(data["importe"] is NSNull) ? data["importe"] as! Double : 0.0, detalleOferta: !(data["detalleoferta"] is NSNull) ? data["detalleoferta"] as! String : "", fechaReserva: !(data["fechareserva"] is NSNull) ? data["fechareserva"] as! String : "", useVoucher: !(data["nvoucher"] is NSNull) ? "1" : "0", tipoServicio: data["tiposervicio"] as! Int)
  
      solicitudpdte.DatosCliente(cliente: globalVariables.cliente)
      
      if !(data["taxi"] is NSNull){
        let taxi = data["taxi"] as! [String: Any]
        print("taxi ok")
        let newTaxi = Taxi(id: taxi["idtaxi"] as! Int, matricula: taxi["matriculataxi"] as! String, codigo: taxi["codigotaxi"] as! String, marca: taxi["marcataxi"] as! String, color: taxi["colortaxi"] as! String, lat: taxi["lattaxi"] as! Double, long: taxi["lngtaxi"] as! Double, conductor: Conductor(idConductor: taxi["idconductor"] as! Int, nombre: taxi["nombreapellidosconductor"] as! String, telefono: taxi["telefonoconductor"] as! String, urlFoto: taxi["foto"] as! String, calificacion: taxi["calificacion"] as! Double))
        solicitudpdte.DatosTaxiConductor(taxi: newTaxi)
      }
      
      globalVariables.solpendientes.append(solicitudpdte)
      if solicitudpdte.taxi.id != 0{
        globalVariables.solicitudesproceso = true
      }
      i += 1
    }
  }
  
  
  //MARK:- FUNCIONES PROPIAS
  
  func Login(user: String, password: String){
    self.apiService.loginToAPIService(user: user, password: password)
    self.AutenticandoView.isHidden = false
  }
  
  func createNewPassword(codigo: String, newPassword: String){
    print(globalVariables.userDefaults.value(forKey: "nombreUsuario") as! String)
    self.apiService.createNewClaveAPI(url: GlobalConstants.createPassUrl, params: [
      "nombreusuario": globalVariables.userDefaults.value(forKey: "nombreUsuario") as! String,
      "codigo": codigo,
      "password": newPassword,
    ])
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
      if globalVariables.socket.status.active{
        globalVariables.socket.emit("data",datos)
        self.EnviarTimer(estado: 1, datos: datos)
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
  
  @objc func EnviarSocket1(_ timer: Timer){
    if CConexionInternet.isConnectedToNetwork() == true{
      if globalVariables.socket.status.active && self.EnviosCount <= 3 {
        self.EnviosCount += 1
        let userInfo = timer.userInfo as! Dictionary<String, AnyObject>
        let datos: String = (userInfo["datos"] as! String)
        globalVariables.socket.emit("data",datos)
        //let result = globalVariables.socket.emitWithAck("data", datos)
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
    let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor revise su conexión a Internet.", preferredStyle: UIAlertController.Style.alert)
    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
      exit(0)
    }))
    self.present(alertaDos, animated: true, completion: nil)
  }
  
  
}