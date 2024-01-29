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
import RswiftResources
import LocalAuthentication


extension LoginController{
  
  func startSocketConnection(){
    //print(Customization.serverData!)
    let accessToken = globalVariables.userDefaults.value(forKey: "accessToken") as! String
    self.socketIOManager = SocketManager(socketURL: URL(string: GlobalConstants.socketurlHost)!, config: [.log(false),.compress,.forcePolling(true),.version(.two), .connectParams(["Authorization": "Bearer token", "token": accessToken])])
    
    print("token para socket \(accessToken)")
    print("Socket URL: \(GlobalConstants.socketurlHost)")
    
    globalVariables.socket = self.socketIOManager.socket(forNamespace: "/")
      
      globalVariables.socket.on(clientEvent: .connect) {data, ack in
          print("Connected")
      }
      
      globalVariables.socket.on(clientEvent: .error) {data, ack in
          if let error = data.first as? SocketIOStatus {
              print("Socket error: \(error)")
          }
      }
      
    self.socketService.initLoginEventos()
    globalVariables.socket.connect()
  }
  
  func initClientData(datos: [String: Any]) {
    
    let clientData = datos["cliente"] as! [String: Any]
    let appConfig = datos["config"] as! [String: Any]
      if let alertauso = datos["alertauso"], (alertauso as! String) == "true" {
          globalVariables.llamadaFacilAlert = ConfigMessage(key: "alertauso", value: ((datos["mensaje"] as? NSString) ?? "") as String)
      }
    print("appConfig \(appConfig)")
    
    if !(appConfig["publicidad"] is NSNull) && appConfig["publicidad"] != nil {
      let publicidad = !(appConfig["publicidad"] is NSNull) ? appConfig["publicidad"] as! [String: Any] : nil
      print("publicidades \(publicidad!["images"] as! [[String: Any]])")
      globalVariables.publicidadService = PublicidadService(publicidades: publicidad!["images"] as! [[String: Any]])
    }
    
    let solicitudesEnProceso = datos["solicitudes"] as! [[String: Any]]
    globalVariables.tarifario = Tarifario(jsonData: datos["tarifas"] as! [String: Any])
    globalVariables.cliente = Cliente(jsonData: clientData)
    globalVariables.appConfig = appConfig != nil ? AppConfig(config: appConfig) : AppConfig()
    
    print("appConfig \(globalVariables.appConfig)")
    
      if solicitudesEnProceso.count > 0 {
          self.ListSolicitudPendiente(solicitudesEnProceso)
      }
      
      AppStoreService.shared.checkNewVersionAvailable()
      self.checkLocationStatus()
  }
  
  func initConnectionError(message: String){
    let alertaDos = UIAlertController (title: "Autenticación", message: message, preferredStyle: UIAlertController.Style.alert)
    alertaDos.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alerAction in
      self.waitingView.isHidden = true
      self.usuario.text?.removeAll()
      self.usuario.text?.removeAll()
    }))
    self.present(alertaDos, animated: true, completion: nil)
  }
  
  func checkLocationStatus() {
		let authorizationStatus: CLAuthorizationStatus
    
		if #available(iOS 14.0, *) {
			authorizationStatus = coreLocationManager.authorizationStatus
		} else {
			authorizationStatus = CLLocationManager.authorizationStatus()
		}
		switch authorizationStatus {
        case .notDetermined:
            coreLocationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
			let locationAlert = UIAlertController (title: GlobalStrings.locationErrorTitle, message: GlobalStrings.locationErrorMessage, preferredStyle: .alert)
			locationAlert.addAction(UIAlertAction(title: GlobalStrings.settingsBtnTitle, style: .default, handler: {alerAction in
					let settingsURL = URL(string: UIApplication.openSettingsURLString)!
					UIApplication.shared.open(settingsURL, options: [:], completionHandler: { success in
						exit(0)
					})
			}))
			locationAlert.addAction(UIAlertAction(title: GlobalStrings.closeAppButtonTitle, style: .default, handler: {alerAction in
				exit(0)
			}))
			self.present(locationAlert, animated: true, completion: nil)
		case .authorizedAlways, .authorizedWhenInUse:
			self.checkSolPendientes()
			break
		default:
			break
		}
  }
  
  func checkSolPendientes() {
    var vc = UIViewController()
    switch globalVariables.solpendientes.count {
    case 0:
      vc = R.storyboard.main.inicioView()!
      break
    case 1:
			let solPendiente = globalVariables.solpendientes.first!
			if solPendiente.isPendientePago() {
				vc = R.storyboard.main.completadaView()!
				(vc as! CompletadaController).solicitud = solPendiente
			} else if solPendiente.isAceptada(){
				vc = R.storyboard.main.solDetalles()!
				(vc as! SolPendController).solicitudPendiente = solPendiente
			} else {
        vc = R.storyboard.main.esperaChildView()!
        (vc as! EsperaChildVC).solicitud = solPendiente
      }
      break
		default:
			let pendientePagoIndex = globalVariables.solpendientes.firstIndex(where: {$0.isPendientePago()})
			if pendientePagoIndex != nil {
				vc = R.storyboard.main.completadaView()!
				(vc as! CompletadaController).solicitud = globalVariables.solpendientes[pendientePagoIndex!]
			} else {
				vc = R.storyboard.main.listaSolPdtes()!
			}
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
	
	func checkSolPendientePago() {
		for solicitud in globalVariables.solpendientes {
			if solicitud.isPendientePago() {
				let vc = R.storyboard.main.completadaView()
				vc?.solicitud = solicitud
				self.navigationController?.show(vc!, sender: self)
			}
		}
	}
  
  
  //MARK:- FUNCIONES PROPIAS
  
  func Login(user: String, password: String){
    self.apiService.loginToAPIService(user: user, password: password)
    self.waitingView.isHidden = false
  }
  
  func sendRecoverClave(){
    waitingView.isHidden = false
    apiService.recoverUserClaveAPI(url: GlobalConstants.passRecoverUrl, params: ["nombreusuario": movilClaveRecover.text!])
    globalVariables.userDefaults.set(movilClaveRecover.text, forKey: "nombreUsuario")
  }
  
  func createNewPassword(codigo: String, newPassword: String){
    if self.newPasswordText.text == self.newPassConfirmText.text{
      waitingView.isHidden = false
      self.apiService.createNewClaveAPI(url: GlobalConstants.createPassUrl, params: [
        "nombreusuario": globalVariables.userDefaults.value(forKey: "nombreUsuario") as! String,
        "codigo": codigo,
        "password": newPassword,
      ])
    } else {
      let alertaDos = UIAlertController (title: "Nueva clave", message: "Las nueva clave no coincide en ambos campos", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alerAction in

      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
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
