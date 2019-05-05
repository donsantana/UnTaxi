//
//  InicioControllerExtension.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 2/16/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit
import AVFoundation


extension InicioController: UITextFieldDelegate{
    //Funciones para mover los elementos para que no queden detrás del teclado
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text?.removeAll()
        if textField.isEqual(self.NombreContactoText) || textField.isEqual(self.TelefonoContactoText){
            if textField.isEqual(self.TelefonoContactoText){
                self.TelefonoContactoText.textColor = UIColor.black
                if (self.NombreContactoText.text?.isEmpty)! || !self.SoloLetras(name: self.NombreContactoText.text!){
                    
                    let alertaDos = UIAlertController (title: "Contactar a otra persona", message: "Debe teclear el nombre de la persona que el conductor debe contactar.", preferredStyle: .alert)
                    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                        self.NombreContactoText.becomeFirstResponder()
                    }))
                    self.present(alertaDos, animated: true, completion: nil)
                }
            }
            self.animateViewMoving(true, moveValue: 190, view: view)
        }else{
            if textField.isEqual(self.origenText){
                if self.DireccionesArray.count != 0{
                    self.TablaDirecciones.frame = CGRect(x: 22, y: Int(self.origenText.frame.origin.y + self.origenText.frame.height), width: Int(self.origenText.frame.width - 2) , height: 44 * self.DireccionesArray.count)
                    self.TablaDirecciones.isHidden = false
                    self.RecordarView.isHidden = true
                }
            }else{
                if !(self.origenText.text?.isEmpty)!{
                    textField.text?.removeAll()
                    animateViewMoving(true, moveValue: 130, view: self.view)
                }else{
                    self.view.resignFirstResponder()
                    animateViewMoving(true, moveValue: 130, view: self.view)
                    let alertaDos = UIAlertController (title: "Dirección de Origen", message: "Debe teclear la dirección de recogida para orientar al conductor.", preferredStyle: .alert)
                    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                        self.origenText.becomeFirstResponder()
                    }))
                    
                    self.present(alertaDos, animated: true, completion: nil)
                }
            }
        }
    }
    
    func textFieldDidEndEditing(_ textfield: UITextField) {
        if textfield.isEqual(self.NombreContactoText) || textfield.isEqual(self.TelefonoContactoText){
            if textfield.isEqual(self.TelefonoContactoText) && textfield.text?.characters.count != 10 && textfield.text?.characters.count != 9 && !((self.NombreContactoText.text?.isEmpty)!){
                textfield.textColor = UIColor.red
                textfield.text = "Número de teléfono incorrecto"
            }
            self.animateViewMoving(false, moveValue: 190, view: view)
        }else{
            if textfield.isEqual(self.referenciaText) || textfield.isEqual(self.destinoText){
                self.animateViewMoving(false, moveValue: 130, view: view)
            }
        }
        self.TablaDirecciones.isHidden = true
        self.EnviarSolBtn.isEnabled = true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text?.lengthOfBytes(using: .utf8) == 0{
            self.TablaDirecciones.isHidden = false
            self.RecordarView.isHidden = true
        }else{
            if self.DireccionesArray.count < 5 && textField.text?.lengthOfBytes(using: .utf8) == 1 {
                self.RecordarView.isHidden = false
                //NSLayoutConstraint(item: self.RecordarView, attribute: .bottom, relatedBy: .equal, toItem: self.referenciaText, attribute: .top, multiplier: 1, constant: -10).isActive = true
                //NSLayoutConstraint(item: self.origenText, attribute: .bottom, relatedBy: .equal, toItem: self.referenciaText, attribute: .top, multiplier: 1, constant: -(self.RecordarView.bounds.height + 20)).isActive = true
            }
            self.TablaDirecciones.isHidden = true
        }
        self.EnviarSolBtn.isEnabled = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func animateViewMoving (_ up:Bool, moveValue :CGFloat, view : UIView){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        view.frame = view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
}

extension InicioController: UITableViewDelegate, UITableViewDataSource{
    //TABLA FUNCTIONS
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if tableView.isEqual(self.TablaDirecciones){
            return self.DireccionesArray.count
        }else{
            return self.MenuArray.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.isEqual(self.TablaDirecciones){
            let cell = tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath)
            cell.textLabel?.text = self.DireccionesArray[indexPath.row][0]
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MENUCELL", for: indexPath)
            cell.textLabel?.text = self.MenuArray[indexPath.row].title
            cell.imageView?.image = UIImage(named: self.MenuArray[indexPath.row].imagen)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEqual(self.TablaDirecciones){
            self.origenText.text = self.DireccionesArray[indexPath.row][0]
            self.TablaDirecciones.isHidden = true
            self.referenciaText.text = self.DireccionesArray[indexPath.row][1]
            self.origenText.resignFirstResponder()
        }else{
            self.MenuView1.isHidden = true
            self.TransparenciaView.isHidden = true
            tableView.deselectRow(at: indexPath, animated: false)
            switch tableView.cellForRow(at: indexPath)?.textLabel?.text{
            case "En proceso"?:
                if myvariables.solpendientes.count > 0{
                    let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "ListaSolPdtes") as! SolicitudesTableController
                    vc.solicitudesMostrar = myvariables.solpendientes
                    self.navigationController?.show(vc, sender: nil)
                }else{
                    self.SolPendientesView.isHidden = false
                }
            case "Call center"?:
                let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "CallCenter") as! CallCenterController
                vc.telefonosCallCenter = self.TelefonosCallCenter
                self.navigationController?.show(vc, sender: nil)
            case "Perfil"?:
                let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "Perfil") as! PerfilController
                self.navigationController?.show(vc, sender: nil)
            case "Compartir app"?:
                if let name = URL(string: "itms://itunes.apple.com/us/app/apple-store/id1149206387?mt=8") {
                    let objectsToShare = [name]
                    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                    
                    self.present(activityVC, animated: true, completion: nil)
                }
                else
                {
                    // show alert for not available
                }
            case "Cerrar Sesion":
                let fileManager = FileManager()
                let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
                do {
                    try fileManager.removeItem(atPath: filePath)
                }catch{
                    
                }
                self.CloseAPP()
            default:
                self.CloseAPP()
            }
        }
    }
    
    //FUNCIONES Y EVENTOS PARA ELIMIMAR CELLS, SE NECESITA AGREGAR UITABLEVIEWDATASOURCE
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView.isEqual(self.TablaDirecciones){
            return true
        }else{
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Eliminar"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            self.EliminarFavorita(posFavorita: indexPath.row)
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
            if self.DireccionesArray.count == 0{
                self.TablaDirecciones.isHidden = true
            }
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.isEqual(self.MenuTable){
            return self.MenuTable.frame.height/CGFloat(self.MenuArray.count)
        }else{
            return 44
        }
    }
}

extension InicioController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var anotationView = mapaVista.dequeueReusableAnnotationView(withIdentifier: "annotationView")
        anotationView = MKAnnotationView(annotation: self.origenAnotacion, reuseIdentifier: "annotationView")
        if annotation.title! == "origen"{
            self.mapaVista.removeAnnotation(self.origenAnotacion)
            anotationView?.image = UIImage(named: "origen")
        }else{
            anotationView?.image = UIImage(named: "taxi_libre")
        }
        return anotationView
    }
    
    
    
    func mapView(_ mapView: MKMapView, rendererFor
        overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.green
        renderer.lineWidth = 4.0
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if SolicitarBtn.isHidden == false {
            self.miposicion.title = "origen"
            self.coreLocationManager.stopUpdatingLocation()
            self.mapaVista.removeAnnotations(self.mapaVista.annotations)
            self.SolPendientesView.isHidden = true
            self.origenIcono.isHidden = false
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        origenIcono.isHidden = true
        if SolicitarBtn.isHidden == false {
            miposicion.coordinate = (self.mapaVista.centerCoordinate)
            origenAnotacion.title = "origen"
            mapaVista.addAnnotation(self.miposicion)
        }
    }
}

extension InicioController{
    func SocketEventos(){
        
        //Evento sockect para escuchar
        //TRAMA IN: #LoginPassword,loginok,idusuario,idrol,idcliente,nombreapellidos,cantsolpdte,idsolicitud,idtaxi,cod,fechahora,lattaxi,lngtaxi,latorig,lngorig,latdest,lngdest,telefonoconductor
        if self.appUpdateAvailable(){
            
            let alertaVersion = UIAlertController (title: "Versión de la aplicación", message: "Estimado cliente es necesario que actualice a la última versión de la aplicación disponible en la AppStore. ¿Desea hacerlo en este momento?", preferredStyle: .alert)
            alertaVersion.addAction(UIAlertAction(title: "Si", style: .default, handler: {alerAction in
                
                UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/us/app/apple-store/id1149206387?mt=8")!)
            }))
            alertaVersion.addAction(UIAlertAction(title: "No", style: .default, handler: {alerAction in
                exit(0)
            }))
            self.present(alertaVersion, animated: true, completion: nil)
            
        }
        
        myvariables.socket.on("LoginPassword"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            
            if (temporal[0] == "[#LoginPassword") || (temporal[0] == "#LoginPassword"){
                myvariables.solpendientes = [CSolicitud]()
                self.contador = 0
                switch temporal[1]{
                case "loginok":
                    let url = "#U,# \n"
                    self.EnviarSocket(url)
                    let telefonos = "#Telefonos,# \n"
                    self.EnviarSocket(telefonos)
                    self.idusuario = temporal[2]
                    self.SolicitarBtn.isHidden = false
                    myvariables.cliente = CCliente(idUsuario: temporal[2],idcliente: temporal[4], user: self.login[1], nombre: temporal[5],email : temporal[3], empresa: temporal[temporal.count - 2] )
                    if temporal[6] != "0"{
                        self.ListSolicitudPendiente(temporal)
                    }
                    
                case "loginerror":
                    let fileManager = FileManager()
                    let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
                    do {
                        try fileManager.removeItem(atPath: filePath)
                    }catch{
                        
                    }
                    
                    let alertaDos = UIAlertController (title: "Autenticación", message: "Usuario y/o clave incorrectos", preferredStyle: UIAlertController.Style.alert)
                    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                        
                    }))
                    self.present(alertaDos, animated: true, completion: nil)
                default: print("Problemas de conexion")
                }
            }else{
                //exit(0)
            }
        }
        
        //Evento Posicion de taxis
        myvariables.socket.on("Posicion"){data, ack in
            
            let temporal = String(describing: data).components(separatedBy: ",")
            if(temporal[1] == "0") {
                let alertaDos = UIAlertController(title: "Solicitud de Taxi", message: "No hay taxis disponibles en este momento, espere unos minutos y vuelva a intentarlo.", preferredStyle: UIAlertController.Style.alert )
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                    self.Inicio()
                }))
                self.present(alertaDos, animated: true, completion: nil)
            }else{
                self.showFormularioSolicitud()
                self.MostrarTaxi(temporal)
            }
        }
        
        //Respuesta de la solicitud enviada
        myvariables.socket.on("Solicitud"){data, ack in
            //Trama IN: #Solicitud, ok, idsolicitud, fechahora
            //Trama IN: #Solicitud, error
            self.EnviarTimer(estado: 0, datos: "terminando")
            let temporal = String(describing: data).components(separatedBy: ",")
            if temporal[1] == "ok"{
                self.MensajeEspera.text = "Solicitud enviada a los taxis cercanos. Esperando respuesta..."
                self.AlertaEsperaView.isHidden = false
                self.CancelarSolicitudProceso.isHidden = false
                self.ConfirmaSolicitud(temporal)
            }else{
                
            }
        }
        
        //ACTIVACION DEL TAXIMETRO
        myvariables.socket.on("TI"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            if myvariables.solpendientes.count != 0 {
                //self.MensajeEspera.text = temporal
                //self.AlertaEsperaView.hidden = false
                for solicitudpendiente in myvariables.solpendientes{
                    if (temporal[2] == solicitudpendiente.idTaxi){
                        let alertaDos = UIAlertController (title: "Taximetro Activado", message: "Estimado Cliente: El conductor ha iniciado el Taximetro a las: \(temporal[1]).", preferredStyle: .alert)
                        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                            
                        }))
                        self.present(alertaDos, animated: true, completion: nil)
                    }
                }
            }
        }
        
        
        //RESPUESTA DE CANCELAR SOLICITUD
        myvariables.socket.on("Cancelarsolicitud"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            if temporal[1] == "ok"{
                let alertaDos = UIAlertController (title: "Cancelar Solicitud", message: "Su solicitud fue cancelada.", preferredStyle: UIAlertController.Style.alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                    self.Inicio()
                    if myvariables.solpendientes.count != 0{
                        self.SolPendientesView.isHidden = true
                        
                    }
                }))
                self.present(alertaDos, animated: true, completion: nil)
            }
        }
        
        //RESPUESTA DE CONDUCTOR A SOLICITUD
        
        myvariables.socket.on("Aceptada"){data, ack in
            self.Inicio()
            let temporal = String(describing: data).components(separatedBy: ",")
            //#Aceptada, idsolicitud, idconductor, nombreApellidosConductor, movilConductor, URLfoto, idTaxi, Codvehiculo, matricula, marca, color, latTaxi, lngTaxi
            if temporal[0] == "#Aceptada" || temporal[0] == "[#Aceptada"{
                var i = 0
                while myvariables.solpendientes[i].idSolicitud != temporal[1] && i < myvariables.solpendientes.count{
                    i += 1
                }
                if myvariables.solpendientes[i].idSolicitud == temporal[1]{
                    
                    let solicitud = myvariables.solpendientes[i]
                    solicitud.DatosTaxiConductor(idtaxi: temporal[6], matricula: temporal[8], codigovehiculo: temporal[7], marcaVehiculo: temporal[9],colorVehiculo: temporal[10], lattaxi: temporal[11], lngtaxi: temporal[12], idconductor: temporal[2], nombreapellidosconductor: temporal[3], movilconductor: temporal[4], foto: temporal[5])
                    
                    DispatchQueue.main.async {
                        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "SolPendientes") as! SolPendController
                        vc.SolicitudPendiente = solicitud
                        vc.posicionSolicitud = myvariables.solpendientes.count - 1
                        self.navigationController?.show(vc, sender: nil)
                    }
                    
                }
            }
            else{
                if temporal[0] == "#Cancelada" {
                    //#Cancelada, idsolicitud
                    
                    let alertaDos = UIAlertController (title: "Estado de Solicitud", message: "Ningún vehículo aceptó su solicitud, puede intentarlo más tarde.", preferredStyle: .alert)
                    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                        
                    }))
                    
                    self.present(alertaDos, animated: true, completion: nil)
                }
            }
        }
        
        myvariables.socket.on("Completada"){data, ack in
            //'#Completada,'+idsolicitud+','+idtaxi+','+distancia+','+tiempoespera+','+importe+',# \n'
            let temporal = String(describing: data).components(separatedBy: ",")
            
            if myvariables.solpendientes.count != 0{
                let pos = self.BuscarPosSolicitudID(temporal[1])
                myvariables.solpendientes.remove(at: pos)
                if myvariables.solpendientes.count != 0{
                    self.SolPendientesView.isHidden = true
                    
                }
                
                DispatchQueue.main.async {
                    let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "completadaView") as! CompletadaController
                    vc.idSolicitud = temporal[1]
                    vc.idTaxi = temporal[2]
                    vc.distanciaValue = temporal[3]
                    vc.tiempoValue = temporal[4]
                    vc.costoValue = temporal[5]
                    
                    self.navigationController?.show(vc, sender: nil)
                }
                
            }
        }
        
        myvariables.socket.on("Cambioestadosolicitudconductor"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            let alertaDos = UIAlertController (title: "Estado de Solicitud", message: "Solicitud cancelada por el conductor.", preferredStyle: UIAlertController.Style.alert)
            alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                var pos = -1
                pos = self.BuscarPosSolicitudID(temporal[1])
                if  pos != -1{
                    self.CancelarSolicitudes("Conductor")
                }
                
                DispatchQueue.main.async {
                    let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "Inicio") as! InicioController
                    self.navigationController?.show(vc, sender: nil)
                }
            }))
            self.present(alertaDos, animated: true, completion: nil)
        }
        
        //SOLICITUDES SIN RESPUESTA DE TAXIS
        myvariables.socket.on("SNA"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            if myvariables.solpendientes.count != 0{
                for solicitudenproceso in myvariables.solpendientes{
                    if solicitudenproceso.idSolicitud == temporal[1]{
                        let alertaDos = UIAlertController (title: "Estado de Solicitud", message: "No se encontó ningún taxi disponible para ejecutar su solicitud. Por favor inténtelo más tarde.", preferredStyle: UIAlertController.Style.alert)
                        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                            self.CancelarSolicitudes("")
                        }))
                        
                        self.present(alertaDos, animated: true, completion: nil)
                    }
                }
            }
        }
        
        //URl PARA AUDIO
        myvariables.socket.on("U"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            myvariables.UrlSubirVoz = temporal[1]
        }
        
        myvariables.socket.on("V"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            myvariables.urlconductor = temporal[1]
            if UIApplication.shared.applicationState != .background {
                if !myvariables.grabando{
                    myvariables.SMSProceso = true
                    myvariables.SMSVoz.ReproducirMusica()
                    myvariables.SMSVoz.ReproducirVozConductor(myvariables.urlconductor)
                }
            }else{
                if  myvariables.SMSProceso{
                    myvariables.SMSProceso = true
                    myvariables.SMSVoz.ReproducirMusica()
                    myvariables.SMSVoz.ReproducirVozConductor(myvariables.urlconductor)
                }else{
                    let session = AVAudioSession.sharedInstance()
                }
                let localNotification = UILocalNotification()
                localNotification.alertAction = "Mensaje del Conductor"
                localNotification.alertBody = "Mensaje del Conductor. Abra la aplicación para escucharlo."
                localNotification.fireDate = Date(timeIntervalSinceNow: 4)
                UIApplication.shared.scheduleLocalNotification(localNotification)
            }
        }
        
        myvariables.socket.on("disconnect"){data, ack in
            self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.Reconect), userInfo: nil, repeats: true)
        }
        
        myvariables.socket.on("connect"){data, ack in
            let ColaHilos = OperationQueue()
            let Hilos : BlockOperation = BlockOperation ( block: {
                self.SocketEventos()
                self.timer.invalidate()
            })
            ColaHilos.addOperation(Hilos)
            var read = "Vacio"
            //var vista = ""
            let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
            do {
                read = try NSString(contentsOfFile: filePath, encoding: String.Encoding.utf8.rawValue) as String
            }catch {
                
            }
        }
        
        myvariables.socket.on("Telefonos"){data, ack in
            //#Telefonos,cantidad,numerotelefono1,operadora1,siesmovil1,sitienewassap1,numerotelefono2,operadora2..,#
            self.TelefonosCallCenter = [CTelefono]()
            let temporal = String(describing: data).components(separatedBy: ",")
            
            if temporal[1] != "0"{
                var i = 2
                while i <= temporal.count - 4{
                    let telefono = CTelefono(numero: temporal[i], operadora: temporal[i + 1], esmovil: temporal[i + 2], tienewhatsapp: temporal[i + 3])
                    self.TelefonosCallCenter.append(telefono)
                    i += 4
                    
                }
                //self.GuardarTelefonos(temporal)
            }
        }
    }
}
