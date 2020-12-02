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
  
  
  func initMapView(){
    mapView.setCenter(self.origenAnotacion.coordinate, zoomLevel: 15, animated: false)
    mapView.styleURL = MGLStyle.lightStyleURL
    self.origenIcono.image = UIImage(named: "origen")
    self.origenIcono.isHidden = true
    self.mapView.addAnnotation(self.origenAnotacion)
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
    self.formularioDataCellList.removeAll()
    self.formularioDataCellList.append(self.origenCell)
    
    self.voucherCell.updateVoucherOption(useVoucher: self.tabBar.selectedItem != self.ofertaItem)
    
    if self.tabBar.selectedItem == self.ofertaItem || self.tabBar.selectedItem == self.pactadaItem{
      self.formularioDataCellList.append(self.destinoCell)
      if self.tabBar.selectedItem == self.ofertaItem{
        self.ofertaDataCell.initContent(precioInicial: 2.0)
        self.formularioDataCellList.append(self.ofertaDataCell)
        self.formularioSolicitudHeight.constant = globalVariables.responsive.heightFloatPercent(percent: globalVariables.isBigIphone ? 50 : 65)
      }
    }else{
      self.formularioSolicitudHeight.constant = globalVariables.responsive.heightFloatPercent(percent: globalVariables.isBigIphone ? 35 : 55)
      if globalVariables.cliente.idEmpresa != 0{
        if self.isVoucherSelected{
          self.formularioDataCellList.append(self.destinoCell)
          self.formularioSolicitudHeight.constant = globalVariables.responsive.heightFloatPercent(percent: globalVariables.isBigIphone ? 50 : 60)
        }
        //self.tipoSolicitudSwitch.isHidden = false
        
      }
    }
    
    if self.tabBar.selectedItem == self.pactadaItem{
      self.formularioDataCellList.append(self.pactadaCell)
    }else{
      self.formularioDataCellList.append(self.voucherCell)
    }
    
    self.formularioDataCellList.append(self.contactoCell)
    print(self.formularioDataCellList.count)
    self.solicitudFormTable.reloadData()
  }
  
  //  func loadFormularioData(){
  //    self.formularioDataCellList.removeAll()
  //    self.formularioDataCellList.append(self.origenCell)
  //
  //
  ////    switch self.tabBar.selectedItem {
  ////    case 0:
  ////      self.formularioDataCellList.append(self.destinoCell)
  ////      self.ofertaDataCell.initContent(precioInicial: 2.0)
  ////      self.formularioDataCellList.append(self.ofertaDataCell)
  ////      self.formularioSolicitudHeight.constant = CGFloat(globalVariables.responsive.heightPercent(percent: 80))
  ////    case 1:
  ////      self.formularioSolicitudHeight.constant = CGFloat(globalVariables.responsive.heightPercent(percent:65))
  ////    case 3:
  ////
  ////    default:
  ////      <#code#>
  ////    }
  //
  //    self.voucherCell.updateVoucherOption(useVoucher: self.tabBar.selectedItem != 0)
  //    if self.tabBar.selectedItem == 0 || self.tabBar.selectedItem == 3{
  //      self.formularioDataCellList.append(self.destinoCell)
  //      if self.tabBar.selectedItem == 0{
  //        self.ofertaDataCell.initContent(precioInicial: 2.0)
  //        self.formularioDataCellList.append(self.ofertaDataCell)
  //        self.formularioSolicitudHeight.constant = globalVariables.responsive.heightFloatPercent(percent: globalVariables.isBigIphone ? 65 : 80)
  //      }
  //    }else{
  //      self.formularioSolicitudHeight.constant = globalVariables.responsive.heightFloatPercent(percent: globalVariables.isBigIphone ? 55 : 70)
  //      if globalVariables.cliente.idEmpresa != 0{
  //        if self.isVoucherSelected{
  //          self.formularioDataCellList.append(self.destinoCell)
  //          self.formularioSolicitudHeight.constant = globalVariables.responsive.heightFloatPercent(percent: globalVariables.isBigIphone ? 65 : 80)
  //        }
  //        self.tipoSolicitudSwitch.isHidden = false
  //
  //      }
  //    }
  //
  //    if self.tabBar.selectedItem == 3{
  //      self.formularioDataCellList.append(self.pactadaCell)
  //    }else{
  //      self.formularioDataCellList.append(self.voucherCell)
  //    }
  //
  //    self.formularioDataCellList.append(self.contactoCell)
  //    self.solicitudFormTable.reloadData()
  //  }
  
  func loadCallCenter(){
    socketService.socketEmit("telefonosdelcallcenter", datos: [:])
    //self.socketEmit("telefonosdelcallcenter", datos: [:])
  }
  
//  //FUNCTION ENVIO CON TIMER
//  func EnviarTimer(estado: Int, datos: String){
//    if estado == 1{
//      self.EnviarSocket(datos)
//      if !self.emitTimer.isValid{
//        self.emitTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(EnviarSocket1(_:)), userInfo: ["datos": datos], repeats: true)
//      }
//    }else{
//      self.emitTimer.invalidate()
//      self.EnviosCount = 0
//    }
//  }
//
//  //FUNCIÓN ENVIAR AL SOCKET
//  @objc func EnviarSocket(_ datos: String){
//    if CConexionInternet.isConnectedToNetwork() == true{
//      if globalVariables.socket.status.active && self.EnviosCount <= 3{
//        globalVariables.socket.emit("data",datos)
//        print(datos)
//        //self.EnviarTimer(estado: 1, datos: datos)
//      }else{
//        let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor intentar otra vez.", preferredStyle: UIAlertController.Style.alert)
//        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
//          exit(0)
//        }))
//        self.present(alertaDos, animated: true, completion: nil)
//      }
//    }else{
//      ErrorConexion()
//    }
//  }
//
  
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
  
//  @objc func EnviarSocket1(_ timer: Timer){
//    if CConexionInternet.isConnectedToNetwork() == true{
//      if globalVariables.socket.status.active && self.EnviosCount <= 3 {
//        self.EnviosCount += 1
//        let userInfo = timer.userInfo as! Dictionary<String, AnyObject>
//        var datos = (userInfo["datos"] as! String)
//        globalVariables.socket.emit("data",datos)
//      }else{
//        let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor intentar otra vez.", preferredStyle: UIAlertController.Style.alert)
//        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
//          self.EnviarTimer(estado: 0, datos: "Terminado")
//          exit(0)
//        }))
//        self.present(alertaDos, animated: true, completion: nil)
//      }
//    }else{
//      ErrorConexion()
//    }
//  }
  
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
    
    self.formularioSolicitud.isHidden = true
    self.SolicitarBtn.isHidden = false
    SolPendientesView.isHidden = true
    //AlertaEsperaView.isHidden = true
    self.tabBar.selectedItem = self.ofertaItem
    super.topMenu.isHidden = false
    self.viewDidLoad()
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
    //["No necesito","Demora el servicio","Tarifa incorrecta","Solo probaba el servicio", "Cancelar"]
    let motivoAlerta = UIAlertController(title: "¿Por qué cancela el viaje?", message: "", preferredStyle: UIAlertController.Style.actionSheet)
    //    motivoAlerta.addAction(UIAlertAction(title: "No necesito", style: .default, handler: { action in
    //      self.CancelarSolicitud("No necesito", solicitud: solicitud)
    //    }))
    motivoAlerta.addAction(UIAlertAction(title: "Mucho tiempo de espera", style: .default, handler: { action in
      self.CancelarSolicitud("Mucho tiempo de espera", solicitud: solicitud)
    }))
    motivoAlerta.addAction(UIAlertAction(title: "El taxi no se mueve", style: .default, handler: { action in
      self.CancelarSolicitud("El taxi no se mueve", solicitud: solicitud)
    }))
    motivoAlerta.addAction(UIAlertAction(title: "El conductor se fue a una dirección equivocada", style: .default, handler: { action in
      self.CancelarSolicitud("El conductor se fue a una dirección equivocada", solicitud: solicitud)
    }))
    motivoAlerta.addAction(UIAlertAction(title: "Ubicación incorrecta", style: .default, handler: { action in
      self.CancelarSolicitud("Ubicación incorrecta", solicitud: solicitud)
    }))
    motivoAlerta.addAction(UIAlertAction(title: "Otro", style: .default, handler: { action in
      let ac = UIAlertController(title: "Entre el motivo", message: nil, preferredStyle: .alert)
      ac.addTextField()
      
      let submitAction = UIAlertAction(title: "Enviar", style: .default) { [unowned ac] _ in
        if !ac.textFields![0].text!.isEmpty{
          self.CancelarSolicitud(ac.textFields![0].text!, solicitud: solicitud)
        }
      }
      
      ac.addAction(submitAction)
      
      self.present(ac, animated: true)
    }))
    motivoAlerta.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.destructive, handler: { action in
    }))
    
    self.present(motivoAlerta, animated: true, completion: nil)
  }
  
  func CancelarSolicitud(_ motivo: String, solicitud: Solicitud){
    //#Cancelarsolicitud, id, idTaxi, motivo, "# \n"
    //let temp = (globalVariables.solpendientes.last?.idTaxi)! + "," + motivo + "," + "# \n"
    let datos = solicitud.crearTramaCancelar(motivo: motivo)
    globalVariables.solpendientes.removeAll{$0.id == solicitud.id}
    //EnviarSocket(Datos)
    self.socketService.socketEmit("cancelarservicio", datos: datos)
//    let vc = R.storyboard.main.inicioView()!
//    vc.socketEmit("cancelarservicio", datos: datos)
//    self.navigationController?.show(vc, sender: nil)
    
    //    let solicitudIndex = globalVariables.solpendientes.firstIndex{$0.id == idSolicitud}!
    //    let datos = globalVariables.solpendientes[solicitudIndex].crearTramaCancelar(motivo: motivo)
    //    globalVariables.solpendientes.remove(at: solicitudIndex)
    //    if globalVariables.solpendientes.count == 0 {
    //      globalVariables.solicitudesproceso = false
    //    }
    //    if motivo != "Conductor"{
    //      self.socketEmit("cancelarservicio", datos: datos)
    //    }
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
      self.mapView.addAnnotations([self.origenAnotacion,anotaciones[0]])
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
  
  @objc func ocultarMenu(){
    self.MenuView1.isHidden = true
    self.TransparenciaView.isHidden = true
    self.Inicio()
    super.topMenu.isHidden = false
  }
  
  //ADD FOOTER TO SOLICITDFORMTABLE
  func addEnvirSolictudBtn(){
    let enviarBtnView = UIView(frame: CGRect(x: 0, y: 0, width: self.SolicitudView.frame.width, height: 60))
    let button:UIButton = UIButton.init(frame: CGRect(x: 25, y: 10, width: self.SolicitudView.frame.width - 50, height: 40))
    button.backgroundColor = Customization.buttonActionColor
    button.layer.cornerRadius = 5
    button.setTitleColor(Customization.buttonsTitleColor, for: .normal)
    button.setTitle("ENVIAR SOLICITUD", for: .normal)
    button.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 20)
    button.addTarget(self, action: #selector(self.enviarSolicitud), for: .touchUpInside)
    button.addShadow()
    
    //enviarBtnView.addSubview(separatorView)
    enviarBtnView.addSubview(button)
    self.solicitudFormTable.backgroundColor = .none
    self.solicitudFormTable.tableFooterView = enviarBtnView
  }
  
  func converAddressToCoord(address: String)->CLLocationCoordinate2D{
    var coordinates = self.origenAnotacion.coordinate
    var geocoder = CLGeocoder()
    if address != ""{
      geocoder.geocodeAddressString(address) {
        placemarks, error in
        let placemark = placemarks?.first
        coordinates = (placemark?.location!.coordinate)!
        //      let lat = placemark?.location?.coordinate.latitude
        //      let lon = placemark?.location?.coordinate.longitude
      }
    }
    return coordinates
    
  }
  
  func crearTramaSolicitud(_ nuevaSolicitud: Solicitud){
    //#Solicitud, idcliente, nombrecliente, movilcliente, dirorig, referencia, dirdest,latorig,lngorig, latdest, lngdest, distancia, costo, #
    formularioSolicitud.isHidden = true
    origenIcono.isHidden = true
    globalVariables.solpendientes.append(nuevaSolicitud)
    
    socketService.socketEmit("solicitarservicio", datos: nuevaSolicitud.crearTrama())
    //self.socketEmit("solicitarservicio", datos: nuevaSolicitud.crearTrama())
    
    //MensajeEspera.text = "Buscando UnTaxi..."
    //self.AlertaEsperaView.isHidden = false
    self.origenCell.origenText.text?.removeAll()
    self.voucherCell.referenciaText.text?.removeAll()
    
//    let vc = R.storyboard.main.esperaChildView()!
//    vc.solicitud = nuevaSolicitud
//    self.navigationController?.show(vc, sender: nil)
  }
  
  func crearSolicitudOferta(){
    //#SO,idcliente,nombreapellidos,movil,dirorigen,referencia,dirdestino,latorigen,lngorigen,ladestino,lngdestino,distanciaorigendestino,valor oferta,voucher,detalle oferta,fecha reserva,tipo transporte,#
    
    if !self.origenCell.origenText.text!.isEmpty{
      
      let nombreContactar = globalVariables.cliente.nombreApellidos
      
      let telefonoContactar = globalVariables.cliente.user
      
      let origen = self.cleanTextField(textfield: self.origenCell.origenText)
      
      let origenCoord = self.origenAnotacion.coordinate
      
      let referencia = !self.voucherCell.referenciaText.text!.isEmpty ? self.cleanTextField(textfield: self.voucherCell.referenciaText) : "No referencia"
      
      let destino = self.cleanTextField(textfield: self.destinoCell.destinoText)
      
      let destinoCoord = self.converAddressToCoord(address: destino)
      
      let voucher = self.tabBar.selectedItem != self.ofertaItem && self.voucherCell.formaPagoSwitch.selectedSegmentIndex == 2 ? "1" : "0"
      
      let detalleOferta = "No detalles"
      
      let fechaReserva = ""
      
      let valorOferta = self.tabBar.selectedItem == self.ofertaItem ? Double((self.ofertaDataCell.valorOfertaText.text?.dropFirst())!)! : self.tabBar.selectedItem == self.pactadaItem ? pactadaCell.importe : 0.0
      
      let tipoServicio = self.tabBar.items?.firstIndex(of: self.tabBar.selectedItem!)
      mapView.removeAnnotations(mapView!.annotations!) 
      
      let nuevaSolicitud = Solicitud()
      self.contactoCell.contactoNameText.text!.isEmpty ? nuevaSolicitud.DatosCliente(cliente: globalVariables.cliente!) : nuevaSolicitud.DatosOtroCliente(telefono: telefonoContactar!, nombre: nombreContactar!)
      nuevaSolicitud.DatosSolicitud(id: 0, fechaHora: "", dirOrigen: origen, referenciaOrigen: referencia, dirDestino: destino, latOrigen: origenCoord.latitude, lngOrigen: origenCoord.longitude, latDestino: destinoCoord.latitude, lngDestino: destinoCoord.longitude, valorOferta: valorOferta, detalleOferta: detalleOferta, fechaReserva: fechaReserva, useVoucher: voucher,tipoServicio: tipoServicio! + 1,yapa: voucherCell.pagarYapaSwitch.isOn)
      
      if !self.contactoCell.telefonoText.text!.isEmpty{
        nuevaSolicitud.DatosOtroCliente(telefono: self.cleanTextField(textfield: self.contactoCell.telefonoText), nombre: self.cleanTextField(textfield: self.contactoCell.contactoNameText))
      }
      
      self.crearTramaSolicitud(nuevaSolicitud)
      view.endEditing(true)
      
    }else{
      let alertaDos = UIAlertController (title: "Error en el formulario", message: "Por favor debe llegar todos los campos subrayados con una línea roja porque son requeridos.", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        //self.origenCell.destinoText.becomeFirstResponder()
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
  @objc func enviarSolicitud(){
    if self.tabBar.selectedItem == self.ofertaItem {
      //if !(self.ofertaDataCell.ofertaText.text?.isEmpty)! && self.ofertaDataCell.ofertaTex != "0"{
      self.crearSolicitudOferta()
      //      }else{
      //        let alertaDos = UIAlertController (title: "Error en el formulario", message: "Por favor debe ofertar un valor $ por el servicio.", preferredStyle: UIAlertController.Style.alert)
      //        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
      //          //self.origenCell.destinoText.becomeFirstResponder()
      //        }))
      //        self.present(alertaDos, animated: true, completion: nil)
      //      }
    }else{
      self.crearSolicitudOferta()
    }
  }

  //MARK:- CONTROL DE TECLADO VIRTUAL
  //Funciones para mover los elementos para que no queden detrás del teclado
  
  @objc func keyboardWillShow(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
      self.keyboardHeight = keyboardSize.height
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
    self.voucherCell.referenciaText.resignFirstResponder()
  }
  
  @objc func ocultarTeclado(sender: UITapGestureRecognizer){
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
  
  //  func showFormularioSolicitud(){
  //    self.CargarFavoritas()
  //    self.TablaDirecciones.reloadData()
  //    self.origenIcono.isHidden = true
  //    self.origenAnotacion.coordinate = mapView.centerCoordinate
  //    coreLocationManager.stopUpdatingLocation()
  //    self.SolicitarBtn.isHidden = true
  //    self.origenCell.origenText.becomeFirstResponder()
  //    if globalVariables.cliente.empresa != "null"{
  //      self.VoucherView.isHidden = false
  //      self.VoucherEmpresaName.text = globalVariables.cliente.empresa
  //      NSLayoutConstraint(item: self.BtnsView, attribute: .top, relatedBy: .equal, toItem: self.VoucherView, attribute:.bottom, multiplier: 1.0, constant:43.0).isActive = true
  //    }else{
  //      NSLayoutConstraint(item: self.BtnsView, attribute: .top, relatedBy: .equal, toItem: self.ContactoView, attribute:.bottom, multiplier: 1.0, constant:10.0).isActive = true
  //
  //    }
  //    self.formularioSolicitud.isHidden = false
  //  }
  
  //Date picker functions
  //  @objc func dateChange( datePicker: UIDatePicker) {
  //    let dateFormatter = DateFormatter()
  //    dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
  //    //self.reservaDate.text = dateFormatter.string(from: datePicker.date)
  //  }
  //
  @objc func dismissPicker() {
    view.endEditing(true)
  }
  
  //FUNCION DETERMINAR DIRECCIÓN A PARTIR DE COORDENADAS
  func direccionDeCoordenada(_ coordenada : CLLocationCoordinate2D, directionText : UITextField){
    let geocoder = CLGeocoder()
    var address = ""
    if CConexionInternet.isConnectedToNetwork() == true {
      let temporaLocation = CLLocation(latitude: coordenada.latitude, longitude: coordenada.longitude)
      CLGeocoder().reverseGeocodeLocation(temporaLocation, completionHandler: {(placemarks, error) -> Void in
        if error != nil {
          print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
          return
        }
        
        if (placemarks?.count)! > 0 {
          let placemark = (placemarks?.first)! as CLPlacemark
          
          if let name = placemark.addressDictionary?["Name"] as? String {
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
          directionText.text = address
          //self.GeolocalizandoView.isHidden = true
        }
        else {
          directionText.text = "No disponible"
          //self.GeolocalizandoView.isHidden = true
        }
      })
      
    }else{
      ErrorConexion()
    }
  }
  
  func offSocketEventos(){
    globalVariables.socket.off("cargarvehiculoscercanos")
    globalVariables.socket.off("solicitarservicio")
    globalVariables.socket.off("cancelarservicio")
    globalVariables.socket.off("sinvehiculo")
    globalVariables.socket.off("solicitudaceptada")
    globalVariables.socket.off("serviciocancelado")
    globalVariables.socket.off("ofertadelconductor")
    globalVariables.socket.off("telefonosdelcallcenter")
    globalVariables.socket.off("taximetroiniciado")
    globalVariables.socket.off("subiroferta")
    globalVariables.socket.off("U")
    globalVariables.socket.off("voz")
    globalVariables.socket.off("direccionespactadas")
    globalVariables.socket.off("serviciocompletado")
  }
  
  //  func loadGeoJson() {
  //    DispatchQueue.global().async {
  //      // Get the path for example.geojson in the app’s bundle.
  //      guard let jsonUrl = Bundle.main.url(forResource: "example", withExtension: "geojson") else {
  //        preconditionFailure("Failed to load local GeoJSON file")
  //      }
  //
  //      guard let jsonData = try? Data(contentsOf: jsonUrl) else {
  //        preconditionFailure("Failed to parse GeoJSON file")
  //      }
  //
  //      DispatchQueue.main.async {
  //        self.drawPolyline(geoJson: jsonData)
  //      }
  //    }
  //  }
  //
  //  func drawPolyline(geoJson: Data) {
  //    // Add our GeoJSON data to the map as an MGLGeoJSONSource.
  //    // We can then reference this data from an MGLStyleLayer.
  //    // MGLMapView.style is optional, so you must guard against it not being set.
  //    guard let style = self.mapView.style else { return }
  //
  //    guard let shapeFromGeoJSON = try? MGLShape(data: geoJson, encoding: String.Encoding.utf8.rawValue) else {
  //      fatalError("Could not generate MGLShape")
  //    }
  //
  //    let source = MGLShapeSource(identifier: "polyline", shape: shapeFromGeoJSON, options: nil)
  //    style.addSource(source)
  //
  //    // Create new layer for the line.
  //    let layer = MGLLineStyleLayer(identifier: "polyline", source: source)
  //
  //    // Set the line join and cap to a rounded end.
  //    layer.lineJoin = NSExpression(forConstantValue: "round")
  //    layer.lineCap = NSExpression(forConstantValue: "round")
  //
  //    // Set the line color to a constant blue color.
  //    layer.lineColor = NSExpression(forConstantValue: UIColor(red: 59/255, green: 178/255, blue: 208/255, alpha: 1))
  //
  //    // Use `NSExpression` to smoothly adjust the line width from 2pt to 20pt between zoom levels 14 and 18. The `interpolationBase` parameter allows the values to interpolate along an exponential curve.
  //    layer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
  //                                   [14: 2, 18: 20])
  //
  //    // We can also add a second layer that will draw a stroke around the original line.
  //    let casingLayer = MGLLineStyleLayer(identifier: "polyline-case", source: source)
  //    // Copy these attributes from the main line layer.
  //    casingLayer.lineJoin = layer.lineJoin
  //    casingLayer.lineCap = layer.lineCap
  //    // Line gap width represents the space before the outline begins, so should match the main line’s line width exactly.
  //    casingLayer.lineGapWidth = layer.lineWidth
  //    // Stroke color slightly darker than the line color.
  //    casingLayer.lineColor = NSExpression(forConstantValue: UIColor(red: 41/255, green: 145/255, blue: 171/255, alpha: 1))
  //    // Use `NSExpression` to gradually increase the stroke width between zoom levels 14 and 18.
  //    casingLayer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)", [14: 1, 18: 4])
  //
  //    // Just for fun, let’s add another copy of the line with a dash pattern.
  //    let dashedLayer = MGLLineStyleLayer(identifier: "polyline-dash", source: source)
  //    dashedLayer.lineJoin = layer.lineJoin
  //    dashedLayer.lineCap = layer.lineCap
  //    dashedLayer.lineColor = NSExpression(forConstantValue: UIColor.white)
  //    dashedLayer.lineOpacity = NSExpression(forConstantValue: 0.5)
  //    dashedLayer.lineWidth = layer.lineWidth
  //    // Dash pattern in the format [dash, gap, dash, gap, ...]. You’ll want to adjust these values based on the line cap style.
  //    dashedLayer.lineDashPattern = NSExpression(forConstantValue: [0, 1.5])
  //
  //    style.addLayer(layer)
  //    style.addLayer(dashedLayer)
  //    style.insertLayer(casingLayer, below: layer)
  //  }
  
}
