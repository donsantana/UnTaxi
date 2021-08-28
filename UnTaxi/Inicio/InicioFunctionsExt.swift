//
//  InicioFunctionsExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/4/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Mapbox
import MapboxDirections
import MapboxGeocoder

extension InicioController{
  //MARK:- FUNCIONES PROPIAS
  
  func checkForNewVersions(){
    if self.appUpdateAvailable(){
      
      let alertaVersion = UIAlertController (title: "Versión de la aplicación", message: "Estimado cliente es necesario que actualice a la última versión de la aplicación disponible en la AppStore. ¿Desea hacerlo en este momento?", preferredStyle: .alert)
      alertaVersion.addAction(UIAlertAction(title: "Si", style: .default, handler: {alerAction in
        
        UIApplication.shared.open(URL(string: GlobalConstants.itunesURL)!)
      }))
      alertaVersion.addAction(UIAlertAction(title: "No", style: .default, handler: {alerAction in
        exit(0)
      }))
      self.present(alertaVersion, animated: true, completion: nil)
    }
  }
  
  func appUpdateAvailable() -> Bool
  {
    let storeInfoURL: String = GlobalConstants.storeInfoURL
    var upgradeAvailable = false
    
    // Get the main bundle of the app so that we can determine the app's version number
    let bundle = Bundle.main
    if let infoDictionary = bundle.infoDictionary {
      // The URL for this app on the iTunes store uses the Apple ID for the  This never changes, so it is a constant
      let urlOnAppStore = URL(string: storeInfoURL)
      if let dataInJSON = try? Data(contentsOf: urlOnAppStore!) {
        // Try to deserialize the JSON that we got
        if let lookupResults = try? JSONSerialization.jsonObject(with: dataInJSON, options: JSONSerialization.ReadingOptions()) as! Dictionary<String, Any>{
          // Determine how many results we got. There should be exactly one, but will be zero if the URL was wrong
          if let resultCount = lookupResults["resultCount"] as? Int {
            if resultCount == 1 {
              // Get the version number of the version in the App Store
              //self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<String, AnyObject>>)[0]
              if let appStoreVersion = (lookupResults["results"]as! Array<Dictionary<String, AnyObject>>)[0]["version"] as? String {
                // Get the version number of the current version
                if let currentVersion = infoDictionary["CFBundleShortVersionString"] as? String {
                  // Check if they are the same. If not, an upgrade is available.
                  if appStoreVersion > currentVersion {
                    upgradeAvailable = true
                  }
                }
              }
            }
          }
        }
      }
    }
    ///Volumes/Datos/Ecuador/Desarrollo/UnTaxi/UnTaxi/LocationManager.swift:635:31: Ambiguous use of 'indexOfObject'
    return upgradeAvailable
  }
  
//  func coordinatesToAddress(annotation: MGLPointAnnotation){
//    print("mapbox \(annotation.coordinate)")
//    let options = ReverseGeocodeOptions(coordinate: annotation.coordinate)
//    // Or perhaps: ReverseGeocodeOptions(location: locationManager.location)
//
//    let task = self.geocoder.geocode(options) { (placemarks, attribution, error) in
//        guard let placemark = placemarks?.first else {
//            return
//        }
//      print("mapbox \(placemark.name)")
//      annotation.title = placemark.name
//      self.mapView.selectAnnotation(annotation, animated: true, completionHandler: nil)
////        print(placemark.imageName ?? "")
////            // telephone
////        print(placemark.genres?.joined(separator: ", ") ?? "")
////            // computer, electronic
////        print(placemark.administrativeRegion?.name ?? "")
////            // New York
////        print(placemark.administrativeRegion?.code ?? "")
////            // US-NY
////        print(placemark.place?.wikidataItemIdentifier ?? "")
////            // Q60
//    }
//  }
  
  func initTipoSolicitudBar(){
    if globalVariables.appConfig.pactadas && globalVariables.cliente.idEmpresa != 0{
      self.tabBar.setItems([self.ofertaItem, self.taximetroItem, self.horasItem, self.pactadaItem],animated: true)
      socketService.socketEmit("direccionespactadas", datos: [
      "idempresa": globalVariables.cliente.idEmpresa!
      ] as [String: Any])
    }else{
      self.tabBar.setItems([self.ofertaItem, self.taximetroItem, self.horasItem],animated: true)
    }
  
    for item in self.tabBar.items!{
      if let image = item.image
      {
        item.image = image.withRenderingMode( .alwaysOriginal)
        item.selectedImage = item.selectedImage?.withRenderingMode(.alwaysOriginal)
      }
    }
    self.tabBar.selectedItem = self.tabBar.items![1] as UITabBarItem
    self.loadFormularioData()
  }
  
  //RECONECT SOCKET
  @objc func Reconect(){
    if contador <= 5 {
      globalVariables.socket.connect()
      contador += 1
    }
    else{
      let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor intentar otra vez.", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        exit(0)
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
  func loadFormularioData(){

    self.initMapView()
    self.formularioDataCellList.removeAll()
    self.formularioDataCellList.append(self.origenCell)
    
    if self.tabBar.selectedItem == self.ofertaItem || self.tabBar.selectedItem == self.pactadaItem{
      self.destinoCell.initContent()
      self.formularioDataCellList.append(self.destinoCell)
      if self.tabBar.selectedItem == self.ofertaItem{
        self.ofertaDataCell.initContent()
        self.formularioDataCellList.append(self.ofertaDataCell)
        self.formularioSolicitudHeight.constant = globalVariables.responsive.heightFloatPercent(percent: 55).relativeToIphone8Height(shouldUseLimit: false)//globalVariables.responsive.heightFloatPercent(percent: globalVariables.isBigIphone ? 55 : 60)
        //self.getDestinoFromSearch(annotation: self.destinoAnnotation)
      }else{
        self.origenCell.origenText.text?.removeAll()
        self.destinoCell.destinoText.text?.removeAll()
        self.formularioSolicitudHeight.constant = globalVariables.responsive.heightFloatPercent(percent: 43).relativeToIphone8Height(shouldUseLimit: false)//globalVariables.responsive.heightFloatPercent(percent: globalVariables.isBigIphone ? 40 : 55)
      }
    }else{
      self.formularioSolicitudHeight.constant = globalVariables.responsive.heightFloatPercent(percent: 45).relativeToIphone8Height(shouldUseLimit: false)//globalVariables.responsive.heightFloatPercent(percent: globalVariables.isBigIphone ? 42 : 58)
      if globalVariables.cliente.idEmpresa != 0{
        if self.isVoucherSelected{
          self.destinoCell.destinoText.text?.removeAll()
          self.formularioDataCellList.append(self.destinoCell)
          self.formularioSolicitudHeight.constant = globalVariables.responsive.heightFloatPercent(percent: 50).relativeToIphone8Height(shouldUseLimit: false)//globalVariables.responsive.heightFloatPercent(percent: globalVariables.isBigIphone ? 46 : 65)
        }
      }
    }

    if self.tabBar.selectedItem == self.pactadaItem{
      self.formularioDataCellList.append(self.pactadaCell)
    }else{
      self.formularioDataCellList.append(self.pagoCell)
      self.pagoCell.updateVoucherOption(useVoucher: self.tabBar.selectedItem != self.ofertaItem)
    }
 
    self.contactoCell.clearContacto()
    self.formularioDataCellList.append(self.contactoCell)
    self.solicitudFormTable.reloadData()
    
    self.addEnvirSolictudBtn()
    self.addHeaderTitle()
    //self.SolicitudView.isHidden = false
  }
  
  //ADD FOOTER TO SOLICITDFORMTABLE
  func addEnvirSolictudBtn(){
    let enviarBtnView = UIView(frame: CGRect(x: 0, y: 0, width: self.SolicitudView.frame.width, height: 60))
    let button:UIButton = UIButton.init(frame: CGRect(x: 20, y: 10, width: self.SolicitudView.frame.width - 40, height: 50))
    button.setTitle("CONFIRMAR viaje", for: .normal)
    button.addTarget(self, action: #selector(self.enviarSolicitud), for: .touchUpInside)
    button.addCustomActionBtnsColors()
    
    //enviarBtnView.addSubview(separatorView)
    enviarBtnView.addSubview(button)
    self.solicitudFormTable.backgroundColor = .none
    self.solicitudFormTable.tableFooterView = enviarBtnView
  }
  
  func addHeaderTitle(){
    let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.SolicitudView.bounds.width, height: 21))
    let baseTitle = UILabel.init(frame: CGRect(x: 40, y: 0, width: self.SolicitudView.bounds.width - 40, height: 21))
    baseTitle.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
    baseTitle.textColor = CustomAppColor.customBlueColor
    baseTitle.text = "Hola, \(globalVariables.cliente.getName())  \(self.pagoCell.formaPagoSwitch.isHidden || !(self.pagoCell.formaPagoSwitch.selectedSegmentIndex == 1) ? "" : "Empresa: \(globalVariables.cliente.empresa ?? "")")"
    
    headerView.addSubview(baseTitle)
    self.solicitudFormTable.tableHeaderView = headerView
  }
  
  func getTaxisCercanos(){
    let data = [
      "idcliente": globalVariables.cliente.id!,
      "latitud": self.origenAnnotation.coordinate.latitude,
      "longitud": self.origenAnnotation.coordinate.longitude
      ] as [String: Any]
    socketService.socketEmit("cargarvehiculoscercanos", datos: data)
  }
  
  func socketEmit(_ eventName: String, datos: [String: Any]){
    if CConexionInternet.isConnectedToNetwork() == true{
      if globalVariables.socket.status.active{
        globalVariables.socket.emitWithAck(eventName, datos).timingOut(after: 3) {respond in
          if respond[0] as! String == "OK"{
            print(respond)
          }else{
            print("error en socket")
          }
        }
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
  
  //FUNCIONES ESCUCHAR SOCKET
  func ErrorConexion(){
    let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor revise su conexión a Internet.", preferredStyle: UIAlertController.Style.alert)
    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
      exit(0)
    }))
    self.present(alertaDos, animated: true, completion: nil)
  }
  
  func Inicio(){
    self.initMapView()
    self.view.endEditing(true)
    
    if self.mapView!.annotations != nil {
      mapView.removeAnnotations(self.mapView!.annotations!)
    }
    
    //self.SolicitudView.isHidden = true
    self.hideSolicitudView(isHidden: true)
    self.tabBar.selectedItem = self.ofertaItem
    super.topMenu.isHidden = false
    self.viewDidLoad()
  }
  
  func hideSolicitudView(isHidden: Bool){
    print("Hidding Solicitud View \(isHidden)")
    self.SolicitudView.isHidden = isHidden
  }
  
  
  //FUNCIÓN BUSCA UNA SOLICITUD DENTRO DEL ARRAY DE SOLICITUDES PENDIENTES DADO SU ID
  //devolver posicion de solicitud
  func BuscarPosSolicitudID(_ id : String)->Int{
    var temporal = 0
    var posicion = -1
    for solicitudpdt in globalVariables.solpendientes{
      if String(solicitudpdt.id) == id{
        posicion = temporal
      }
      temporal += 1
    }
    return posicion
  }
  
  //Respuesta de solicitud
  func ConfirmaSolicitud(_ newSolicitud : [String:Any]){
    //Trama IN: #Solicitud, ok, idsolicitud, fechahora
    globalVariables.solpendientes.last!.RegistrarFechaHora(Id: newSolicitud["idsolicitud"] as! Int, FechaHora: newSolicitud["fechahora"]  as! String)
    let vc = R.storyboard.main.esperaChildView()!
    vc.solicitud = globalVariables.solpendientes.last!
    self.navigationController?.show(vc, sender: nil)
  }
  
  //FUncion para mostrar los taxis
  func MostrarTaxi(_ temporal : [String]){
    //TRAMA IN: #Posicion,idtaxi,lattaxi,lngtaxi
    var i = 2
    var taxiscercanos = [MGLAnnotation]()
    while i  <= temporal.count - 6{
      let taxiTemp = MGLPointAnnotation()
      taxiTemp.coordinate = CLLocationCoordinate2DMake(Double(temporal[i + 2])!, Double(temporal[i + 3])!)
      taxiTemp.title = temporal[i]
      taxiscercanos.append(taxiTemp)
      i += 6
    }
    DibujarIconos(taxiscercanos)
  }
  
  //CANCELAR SOLICITUDES
  func MostrarMotivoCancelacion(solicitud: Solicitud){
    let motivoAlerta = UIAlertController(title: "¿Por qué cancela el viaje?", message: "", preferredStyle: UIAlertController.Style.actionSheet)

    let titleAttributes = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 20)!, NSAttributedString.Key.foregroundColor: UIColor.black]
    let titleString = NSAttributedString(string: "¿Por qué cancela el viaje?", attributes: titleAttributes)
    motivoAlerta.setValue(titleString, forKey: "attributedTitle")
    
    for i in 0...Customization.motivosCancelacion.count - 1{
      if i == Customization.motivosCancelacion.count - 1{
        motivoAlerta.addAction(UIAlertAction(title: Customization.motivosCancelacion[i], style: .default, handler: { action in
          let ac = UIAlertController(title: Customization.motivosCancelacion[i], message: nil, preferredStyle: .alert)
          ac.addTextField()
          
          let submitAction = UIAlertAction(title: "Enviar", style: .default) { [unowned ac] _ in
            if !ac.textFields![0].text!.isEmpty{
              self.CancelarSolicitud(ac.textFields![0].text!, solicitud: solicitud)
            }
          }
          
          ac.addAction(submitAction)
          
          self.present(ac, animated: true)
        }))
      }else{
        motivoAlerta.addAction(UIAlertAction(title: Customization.motivosCancelacion[i], style: .default, handler: { action in
          self.CancelarSolicitud(Customization.motivosCancelacion[i], solicitud: solicitud)
        }))
      }
    }
    motivoAlerta.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { action in
    }))
    
    self.present(motivoAlerta, animated: true, completion: nil)
  }
  
  func CancelarSolicitud(_ motivo: String, solicitud: Solicitud){
    //#Cancelarsolicitud, id, idTaxi, motivo, "# \n"
    //let temp = (globalVariables.solpendientes.last?.idTaxi)! + "," + motivo + "," + "# \n"
    let datos = solicitud.crearTramaCancelar(motivo: motivo)
    self.socketService.socketEmit("cancelarservicio", datos: datos)
  }
  
  func CloseAPP(){
    let fileAudio = FileManager()
    let AudioPath = NSHomeDirectory() + "/Library/Caches/Audio"
    do {
      try fileAudio.removeItem(atPath: AudioPath)
    }catch{
    }
    print("closing app")
    self.socketService.socketEmit("SocketClose", datos: ["idcliente": globalVariables.cliente.id])
//    let datos = "#SocketClose,\(globalVariables.cliente.id),# \n"
//    EnviarSocket(datos)
    exit(3)
  }
  
  
  //FUNCION PARA DIBUJAR LAS ANOTACIONES
  
  func DibujarIconos(_ anotaciones: [MGLAnnotation]){
    if anotaciones.count == 1{
      self.mapView.addAnnotations([self.origenAnnotation,anotaciones[0]])
      //self.mapView.fitAll(in: self.mapView.annotations, andShow: true)
    }else{
      self.mapView.addAnnotations(anotaciones)
      //self.mapView.fitAll(in: anotaciones, andShow: true)
    }
  }
  
  
  //Validar los formularios
  func SoloLetras(name: String) -> Bool {
    // (1):
    let pat = "[0-9,.!@#$%^&*()_+-]"
    // (2):
    //let testStr = "x.wu@strath.ac.uk, ak123@hotmail.com     e1s59@oxford.ac.uk, ee123@cooleng.co.uk, a.khan@surrey.ac.uk"
    // (3):
    let regex = try! NSRegularExpression(pattern: pat, options: [])
    // (4):
    let matches = regex.matches(in: name, options: [], range: NSRange(location: 0, length: name.count))
    print(matches.count)
    if matches.count == 0{
      return true
    }else{
      return false
    }
  }

  func crearTramaSolicitud(_ nuevaSolicitud: Solicitud){
    //#Solicitud, idcliente, nombrecliente, movilcliente, dirorig, referencia, dirdest,latorig,lngorig, latdest, lngdest, distancia, costo, #
    locationIcono.isHidden = true
    globalVariables.solpendientes.append(nuevaSolicitud)
    socketService.socketEmit("solicitarservicio", datos: nuevaSolicitud.crearTrama())
  }
  
  func crearSolicitudOferta(){
    //#SO,idcliente,nombreapellidos,movil,dirorigen,referencia,dirdestino,latorigen,lngorigen,ladestino,lngdestino,distanciaorigendestino,valor oferta,voucher,detalle oferta,fecha reserva,tipo transporte,#

      let nombreContactar = globalVariables.cliente.nombreApellidos
      
      let telefonoContactar = globalVariables.cliente.user
      
      let origen = self.cleanTextField(textfield: self.origenCell.origenText)
      
      let origenCoord = self.origenAnnotation.coordinate
      
      let referencia = !self.pagoCell.referenciaText.text!.isEmpty ? self.cleanTextField(textfield: self.pagoCell.referenciaText) : "No referencia"
      
      let destino = self.cleanTextField(textfield: self.destinoCell.destinoText)
      
      let destinoCoord = self.destinoAnnotation.coordinate//self.converAddressToCoord(address: destino)

    let voucher = !self.pagoCell.formaPagoSwitch.isHidden && self.pagoCell.formaPagoSwitch.selectedSegmentIndex == 1 ? "1" : "0"
    
      //let voucher = self.tabBar.selectedItem == self.pactadaItem || self.pagoCell.formaPagoSwitch.selectedSegmentIndex == 1 ? "1" : "0"
      print("Forma de pago \(self.pagoCell.formaPagoSwitch.selectedSegmentIndex)")
      print("voucher \(voucher)")
      let detalleOferta = "No detalles"
      
      let fechaReserva = ""
      //var valorOferta = self.ofertaDataCell.valorOfertaText.text!.replacingOccurrences(of: ",", with: ".")
      let valorOferta = self.tabBar.selectedItem == self.ofertaItem ? Double((self.ofertaDataCell.valorOfertaText.text!.replacingOccurrences(of: ",", with: ".").digitsAndPeriods))! : self.tabBar.selectedItem == self.pactadaItem ? pactadaCell.importe : 0.0
    
      var tipoServicio = 1
      
      switch self.tabBar.selectedItem {
      case self.taximetroItem:
        tipoServicio = 2
      case self.horasItem:
        tipoServicio = 3
      case self.pactadaItem:
        tipoServicio = 4
      default:
        tipoServicio = 1
      }
      
      let isYapa = globalVariables.appConfig.yapa ? pagoCell.pagarYapaSwitch.isOn : false
      let nuevaSolicitud = Solicitud(id: 0, fechaHora: "", dirOrigen: origen, referenciaOrigen: referencia, dirDestino: destino, latOrigen: origenCoord.latitude, lngOrigen: origenCoord.longitude, latDestino: destinoCoord.latitude, lngDestino: destinoCoord.longitude, importe: valorOferta, detalleOferta: detalleOferta, fechaReserva: fechaReserva, useVoucher: voucher,tipoServicio: tipoServicio,yapa: isYapa)
      nuevaSolicitud.DatosCliente(cliente: globalVariables.cliente!)
      
      if !self.contactoCell.telefonoText.text!.isEmpty{
        nuevaSolicitud.DatosOtroCliente(telefono: self.cleanTextField(textfield: self.contactoCell.telefonoText), nombre: self.cleanTextField(textfield: self.contactoCell.contactoNameText))
      }
      
      self.crearTramaSolicitud(nuevaSolicitud)
      view.endEditing(true)
    
  }
  
  func showFormError(){
    
  }
  
  @objc func enviarSolicitud(){
    if self.origenCell.origenText.text!.isEmpty{
      let alertaDos = UIAlertController (title: "Error en el formulario", message: "Por favor debe espeficicar su Origen.", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        self.view.endEditing(true)
        self.origenCell.origenText.becomeFirstResponder()
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }else{
      if self.contactoCell.contactarSwitch.isOn{
        let (valid, message) = self.contactoCell.telefonoText.validate(.movilNumber)
        if !valid || self.contactoCell.telefonoText.text!.isEmpty{
          let alertaDos = UIAlertController (title: "Error en el formulario", message: "Si solicita para otra persona debe especificar el nombre y el número teléfono.", preferredStyle: .alert)
          alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
            if self.contactoCell.contactoNameText.text!.isEmpty{
              self.contactoCell.contactoNameText.becomeFirstResponder()
            }else{
              self.contactoCell.telefonoText.becomeFirstResponder()
            }
          }))
          self.present(alertaDos, animated: true, completion: nil)
        }else{
          self.crearSolicitudOferta()
        }
      }else{
        if self.tabBar.selectedItem == self.ofertaItem || self.isVoucherSelected {
          if !(self.destinoCell.destinoText.text!.isEmpty){
            if Double((self.ofertaDataCell.valorOfertaText.text!.replacingOccurrences(of: ",", with: ".").digitsAndPeriods))! < globalVariables.tarifario.valorForDistance(distance: 0.0) && self.tabBar.selectedItem == self.ofertaItem{
              let alertaDos = UIAlertController (title: "Error en el formulario", message: "El valor de la oferta debe ser igual o superior a: $\(String(format: "%.2f", globalVariables.tarifario.valorForDistance(distance: 0.0)))", preferredStyle: .alert)
              alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                self.ofertaDataCell.initContent()
              }))
              self.present(alertaDos, animated: true, completion: nil)
            }else{
              self.crearSolicitudOferta()
            }
          }else{
            
            let alertaDos = UIAlertController (title: "Error en el formulario", message: "Por favor debe espeficicar su destino.", preferredStyle: UIAlertController.Style.alert)
            alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
              self.view.endEditing(true)
              self.destinoCell.destinoText.becomeFirstResponder()
            }))
            self.present(alertaDos, animated: true, completion: nil)
            
          }
        }else{
          self.crearSolicitudOferta()
        }
      }
    }
  }
  
  func getDestinoFromSearch(annotation: MGLPointAnnotation){
    let wp1 = Waypoint(coordinate: self.origenAnnotation.coordinate, name: self.origenAnnotation.title)
    let wp2 = Waypoint(coordinate: annotation.coordinate, name: annotation.title)
    let options = RouteOptions(waypoints: [wp1, wp2])
    options.includesSteps = true
    options.routeShapeResolution = .full
    options.attributeOptions = [.congestionLevel, .maximumSpeedLimit]

    self.destinoAnnotation = annotation
    self.destinoCell.destinoText.text = annotation.title
    //self.showAnnotation([self.origenAnnotation, self.destinoAnnotation], isPOI: true)

    Directions.shared.calculate(options) { (session, result) in
      switch result {
      case let .failure(error):
        print("Error calculating directions: \(error)")
      case let .success(response):
        if let route = response.routes?.first, let leg = route.legs.first {
          print("Route via \((route.distance/1000)):")
          let costo = globalVariables.tarifario.valorForDistance(distance: route.distance/1000)

          print("costo \(costo)")
          self.ofertaDataCell.valorOfertaText.text = "$\(String(format: "%.2f", costo.rounded(to: 0.05, roundingRule: .up) > 1.5 ? costo.rounded(to: 0.05, roundingRule: .up) : 1.5))"
          self.hideSolicitudView(isHidden: false)
          //self.SolicitudView.isHidden = false

          let distanceFormatter = LengthFormatter()
          let formattedDistance = distanceFormatter.string(fromMeters: route.distance)

          let travelTimeFormatter = DateComponentsFormatter()
          travelTimeFormatter.unitsStyle = .short
          let formattedTravelTime = travelTimeFormatter.string(from: route.expectedTravelTime)

          print("Distance: \(formattedDistance); ETA: \(formattedTravelTime!)")

          for step in leg.steps {
            let direction = step.maneuverDirection?.rawValue ?? "none"
            print("\(step.instructions) [\(step.maneuverType) \(direction)]")
            if step.distance > 0 {
              let formattedDistance = distanceFormatter.string(fromMeters: step.distance)
              print("— \(step.transportType) for \(formattedDistance) —")
            }
          }

          if var routeCoordinates = route.shape?.coordinates, routeCoordinates.count > 0 {
            // Convert the route’s coordinates into a polyline.
            let routeLine = MGLPolyline(coordinates: &routeCoordinates, count: UInt(routeCoordinates.count))

            // Add the polyline to the map.
            if route.distance > 500{
              self.mapView.addAnnotation(routeLine)
              self.mapView.showAnnotations([self.origenAnnotation, self.destinoAnnotation], animated: true)
            }
          }
        }
      }
    }
  }

  func openSearchPanel(){
    print("open SearchPanel")
    super.hideMenuBar(isHidden: true)
    self.panelController.setState(.opened)
    self.mapBottomConstraint.constant = self.formularioSolicitudHeight.constant
    self.view.endEditing(true)
    if searchingAddress == "destino"{
      print(self.origenAnnotation.title)
      self.destinoAnnotation.title = self.origenAnnotation.title
      self.destinoAnnotation.coordinate = self.origenAnnotation.coordinate
    }
    //self.destinoCell.destinoText.text?.removeAll()
    self.navigationController?.setNavigationBarHidden(false, animated: true)
    openMapBtn.frame = CGRect(x: 0, y: Responsive().heightFloatPercent(percent: 80), width: self.view.bounds.width - 40, height: 40)
    let mapaImage = UIImage(named: "mapLocation")?.withRenderingMode(.alwaysOriginal)
    openMapBtn.setImage(mapaImage, for: UIControl.State())
    openMapBtn.setTitle("Fijar ubicación en el mapa", for: .normal)
    openMapBtn.addTarget(self, action: #selector(openMapBtnAction), for: .touchUpInside)
    openMapBtn.layer.cornerRadius = 10
    //openMapBtn.titleLabel?.font = CustomAppFont.buttonFont
    openMapBtn.backgroundColor = .white
    openMapBtn.tintColor = .black
    openMapBtn.addShadow()
    panelController.view.addSubview(openMapBtn)
    
    addChild(panelController)
  }
  
  @objc func openMapBtnAction(){
    print("Go to map")
    self.addressPreviewText.isHidden = false
    self.view.endEditing(true)
    self.panelController.removeContainer()
  }
  
  @objc func hideSearchPanel(){
    if self.navigationController != nil && !self.navigationController!.isNavigationBarHidden{
      super.hideMenuBar(isHidden: false)
      self.navigationController?.setNavigationBarHidden(true, animated: true)
      self.panelController.removeContainer()
      self.mapBottomConstraint.constant = 0
      self.addressPreviewText.isHidden = true
    }
    //self.destinoCell.destinoText.text = self.origenAnnotation.title
    //    self.ofertaDataCell.valorOfertaText.text = "$\(String(format: "%.2f", globalVariables.tarifario.valorForDistance(distance: 0.0)))"
    //self.loadFormularioData()
    
  }
  
  //MARK:- CONTROL DE TECLADO VIRTUAL
  //Funciones para mover los elementos para que no queden detrás del teclado
  
  @objc func keyboardWillShow(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
      if self.navigationController != nil && self.navigationController?.isNavigationBarHidden == false {
        self.openMapBtn.frame = CGRect(x: 0, y: Responsive().heightFloatPercent(percent: 80) - keyboardSize.height, width: self.view.bounds.width - 40, height: 40)
      }else{
        self.view.frame.origin.y = -keyboardSize.height
        self.keyboardHeight = keyboardSize.height
      }
    }
  }
  
  @objc func keyboardWillHide(notification: NSNotification) {
    if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
      if self.navigationController?.isNavigationBarHidden == false {
        self.openMapBtn.frame = CGRect(x: 0, y: Responsive().heightFloatPercent(percent: 80), width: self.view.bounds.width - 40, height: 40)
      }else{
        self.view.frame.origin.y = 0
      }
    }
    
  }
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    animateViewMoving(false, moveValue: 60, view: self.view)
  }
  
  @objc func textViewDidChange(_ textView: UITextView) {
    
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.pagoCell.referenciaText.resignFirstResponder()
  }
  
  @objc func ocultarTeclado(sender: UITapGestureRecognizer){
    print("ocultar teclado")
    //sender.cancelsTouchesInView = false
    self.SolicitudView.endEditing(true)
  }
  
  //  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
  //    if touch.view?.isDescendant(of: self.TablaDirecciones) == true {
  //      gestureRecognizer.cancelsTouchesInView = false
  //    }else{
  //      self.SolicitudView.endEditing(true)
  //    }
  //    return true
  //  }
  //
  func cleanTextField(textfield: UITextField)->String{
    var cleanedTextField = textfield.text?.uppercased()
    cleanedTextField = cleanedTextField!.replacingOccurrences(of: "Ñ", with: "N",options: .regularExpression, range: nil)
    cleanedTextField = cleanedTextField!.replacingOccurrences(of: "[,.]", with: "-",options: .regularExpression, range: nil)
    cleanedTextField = cleanedTextField!.replacingOccurrences(of: "[\n]", with: "-",options: .regularExpression, range: nil)
    cleanedTextField = cleanedTextField!.replacingOccurrences(of: "[#]", with: "No",options: .regularExpression, range: nil)
    return cleanedTextField!.folding(options: .diacriticInsensitive, locale: .current)
  }
  
  @objc func dismissPicker() {
    view.endEditing(true)
  }
  
  //MARK:- FUNCION DETERMINAR DIRECCIÓN A PARTIR DE COORDENADAS
  func getAddressFromCoordinate(_ annotation: MGLPointAnnotation){
    if annotation.coordinate.latitude != 0.0{
      print("google \(annotation.coordinate)")
      let geocoder = CLGeocoder()
      var address = ""
      
      let temporaLocation = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
      geocoder.reverseGeocodeLocation(temporaLocation, completionHandler: { [self](placemarks, error) -> Void in
        if error != nil {
          print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
          return
        }
        
        if (placemarks?.count)! > 0{
          let placemark = (placemarks?.first)! as CLPlacemark
          
          if let name = placemark.addressDictionary?["Name"] as? String {
            print("google \(name) \(annotation.subtitle)")
            address += name
          }
          
          //            if let locality = placemark.addressDictionary?["City"] as? String {
          //              address += " \(locality)"
          //            }
          //
          //          if let state = placemark.addressDictionary?["State"] as? String {
          //            address += " \(state)"
          //          }
          //
          //          if let country = placemark.country{
          //            address += " \(country)"
          //          }
          annotation.title = address
          annotation.subtitle == "origen" ? (self.origenCell.origenText.text = address) : (self.destinoCell.destinoText.text = address)
          self.addressPreviewText.text = address
          print("direccion \(self.destinoCell.destinoText.text)")
        }else {
          annotation.title = "No disponible"
        }
      })
    }
  }
  
  func converAddressToCoord(address: String)->CLLocationCoordinate2D{
    var coordinates = self.origenAnnotation.coordinate
    let geocoder = CLGeocoder()
    if address != ""{
      geocoder.geocodeAddressString(address) {
        placemarks, error in
        let placemark = placemarks?.first
        coordinates = (placemark?.location!.coordinate)!
      }
    }
    return coordinates
  }
  
//  func getDetailsBeetwen(annotation1: MGLPointAnnotation, annotation2: MGLPointAnnotation){
//    let wp1 = Waypoint(coordinate: annotation1.coordinate, name: annotation1.title)
//    let wp2 = Waypoint(coordinate: annotation2.coordinate, name: annotation2.title)
//    let options = RouteOptions(waypoints: [wp1, wp2])
//    options.includesSteps = true
//    options.routeShapeResolution = .full
//    options.attributeOptions = [.congestionLevel, .maximumSpeedLimit]
//
//    self.destinoAnnotation = annotation
//    self.destinoCell.destinoText.text = annotation.title
//    //self.showAnnotation([self.origenAnnotation, self.destinoAnnotation], isPOI: true)
//
//    Directions.shared.calculate(options) { (session, result) in
//      switch result {
//      case let .failure(error):
//        print("Error calculating directions: \(error)")
//      case let .success(response):
//        if let route = response.routes?.first, let leg = route.legs.first {
//          print("Route via \((route.distance/1000)):")
//          let costo = globalVariables.tarifario.valorForDistance(distance: route.distance/1000)
//          //self.panelController.removeContainer()
//
//
//          print("costo \(costo)")
//          self.ofertaDataCell.valorOfertaText.text = "$\(String(format: "%.2f", costo.rounded(to: 0.05, roundingRule: .up)))"
//          self.SolicitudView.isHidden = false
//
//          let distanceFormatter = LengthFormatter()
//          let formattedDistance = distanceFormatter.string(fromMeters: route.distance)
//
//          let travelTimeFormatter = DateComponentsFormatter()
//          travelTimeFormatter.unitsStyle = .short
//          let formattedTravelTime = travelTimeFormatter.string(from: route.expectedTravelTime)
//
//          print("Distance: \(formattedDistance); ETA: \(formattedTravelTime!)")
//
//          for step in leg.steps {
//            let direction = step.maneuverDirection?.rawValue ?? "none"
//            print("\(step.instructions) [\(step.maneuverType) \(direction)]")
//            if step.distance > 0 {
//              let formattedDistance = distanceFormatter.string(fromMeters: step.distance)
//              print("— \(step.transportType) for \(formattedDistance) —")
//            }
//          }
//
//          if var routeCoordinates = route.shape?.coordinates, routeCoordinates.count > 0 {
//            // Convert the route’s coordinates into a polyline.
//            let routeLine = MGLPolyline(coordinates: &routeCoordinates, count: UInt(routeCoordinates.count))
//
//            // Add the polyline to the map.
//            if route.distance > 500{
//              self.mapView.addAnnotation(routeLine)
//              self.mapView.showAnnotations([self.origenAnnotation, self.destinoAnnotation], animated: true)
//            }
//          }
//        }
//      }
//    }
//  }

}
