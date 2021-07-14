//
//  EsperaChildVC.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 11/27/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit

class EsperaChildVC: UIViewController {
  var socketService = SocketService()
  var solicitud: Solicitud!

  @IBOutlet weak var MensajeEspera: UITextView!
  @IBOutlet weak var updateOfertaView: UIView!
  @IBOutlet weak var SendOferta: UIButton!
  @IBOutlet weak var newOfertaText: UILabel!
  @IBOutlet weak var up25: UIButton!
  @IBOutlet weak var down25: UIButton!
  @IBOutlet weak var titleText: UILabel!
  @IBOutlet weak var subtitleText: UILabel!
  
  @IBOutlet weak var CancelarSolicitudProceso: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    self.socketService.delegate = self
    self.socketService.initListenEventos()
    
    self.updateOfertaView.addShadow()
    self.SendOferta.addShadow()
    self.newOfertaText.addBorder(color: CustomAppColor.buttonActionColor)
    //self.newOfertaText.font = CustomAppFont.bigFont
    self.MensajeEspera.centerVertically()
    //self.titleText.titleBlueStyle()
    //self.subtitleText.titleBlueStyle()
    //self.newOfertaText.bigTextBlueStyle()
   
    self.newOfertaText.text = "$\(String(format: "%.2f", Double(self.solicitud.valorOferta)))"
    self.updateOfertaView.isHidden = self.solicitud!.valorOferta == 0.0
    
//    let array = globalVariables.ofertasList.map{$0.id}
//    print("ofertas \(array) \(solicitud.id)")
//    if array.contains(solicitud.id){
//      print("oferta encontrada")
//      let vc = R.storyboard.main.ofertasView()
//      vc?.solicitud = solicitud
//      self.navigationController?.show(vc!, sender: nil)
//    }
    
  }

  func updateOfertaValue(value: Double){
    self.newOfertaText.text = "$\(Double(self.newOfertaText.text!.dropFirst())! + value)"
  }
  
  //CANCELAR SOLICITUDES
  func mostrarAdvertenciaCancelacion(){
    let alertaDos = UIAlertController (title: "Aviso Importante", message: "Estimado usuario, la cancelación frecuente del servicio puede ser motivo de un bloqueo temporal de la aplicación.", preferredStyle: .alert)
    
    let titleAttributes = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 20)!, NSAttributedString.Key.foregroundColor: UIColor.red]
    let titleString = NSAttributedString(string: "Aviso Importante", attributes: titleAttributes)
    alertaDos.setValue(titleString, forKey: "attributedTitle")
    
    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { [self]alerAction in
      MostrarMotivoCancelacion()
    }))
    
    self.present(alertaDos, animated: true, completion: nil)
  }
  
  func MostrarMotivoCancelacion(){
    let motivoAlerta = UIAlertController(title: "¿Por qué cancela el viaje?", message: "", preferredStyle: .actionSheet)
    
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
              self.CancelarSolicitud(ac.textFields![0].text!)
            }
          }
          
          ac.addAction(submitAction)
          
          self.present(ac, animated: true)
        }))
      }else{
        motivoAlerta.addAction(UIAlertAction(title: Customization.motivosCancelacion[i], style: .default, handler: { action in
          self.CancelarSolicitud(Customization.motivosCancelacion[i])
        }))
      }
    }
//
//    motivoAlerta.addAction(UIAlertAction(title: "Mucho tiempo de espera", style: .default, handler: { action in
//      self.CancelarSolicitud("Mucho tiempo de espera")
//    }))
//    motivoAlerta.addAction(UIAlertAction(title: "El taxi no se mueve", style: .default, handler: { action in
//      self.CancelarSolicitud("El taxi no se mueve")
//    }))
//    motivoAlerta.addAction(UIAlertAction(title: "El conductor se fue a una dirección equivocada", style: .default, handler: { action in
//      self.CancelarSolicitud("El conductor se fue a una dirección equivocada")
//    }))
//    motivoAlerta.addAction(UIAlertAction(title: "Ubicación incorrecta", style: .default, handler: { action in
//      self.CancelarSolicitud("Ubicación incorrecta")
//    }))
//    motivoAlerta.addAction(UIAlertAction(title: "Otro", style: .default, handler: { action in
//      let ac = UIAlertController(title: "Entre el motivo", message: nil, preferredStyle: .alert)
//      ac.addTextField()
//
//      let submitAction = UIAlertAction(title: "Enviar", style: .default) { [unowned ac] _ in
//        if !ac.textFields![0].text!.isEmpty{
//          self.CancelarSolicitud(ac.textFields![0].text!)
//        }
//      }
//
//      ac.addAction(submitAction)
//
//      self.present(ac, animated: true)
//    }))
    motivoAlerta.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { action in
    }))
    
    self.present(motivoAlerta, animated: true, completion: nil)
  }
  
  func CancelarSolicitud(_ motivo: String){
    //#Cancelarsolicitud, id, idTaxi, motivo, "# \n"
    //let temp = (globalVariables.solpendientes.last?.idTaxi)! + "," + motivo + "," + "# \n"
    let datos = solicitud.crearTramaCancelar(motivo: motivo)
    globalVariables.solpendientes.removeAll{$0.id == self.solicitud.id}
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
  
  @IBAction func downOferta(_ sender: Any) {
    self.updateOfertaValue(value: -0.25)
    self.down25.isEnabled = Double(self.newOfertaText!.text!.dropFirst())! > solicitud!.valorOferta
  }
  
  @IBAction func upOferta(_ sender: Any) {
    self.down25.isEnabled = true
    self.updateOfertaValue(value: +0.25)
  }
  @IBAction func enviarNuevoValorOferta(_ sender: Any) {
    //#RSO.id,idcliente,nuevovaloroferta,#
//    let datos = "#RSO,\(self.solicitudInProcess.text!),\(globalVariables.cliente.idCliente!),\(self.newOfertaText.text!),# \n"
//    print(datos)
//    self.EnviarSocket(datos)
    self.socketService.socketEmit("subiroferta", datos: self.solicitud.updateValorOferta(newValor: self.newOfertaText.text!))
  }
  
  @IBAction func CancelarProcesoSolicitud(_ sender: AnyObject) {
    self.mostrarAdvertenciaCancelacion()
  }
  
  @IBAction func cancelarSolicitudOferta(_ sender: Any) {
    self.mostrarAdvertenciaCancelacion()
  }
}

extension EsperaChildVC: SocketServiceDelegate{
  func socketResponse(_ controller: SocketService, cancelarservicio result: [String : Any]) {
    print("cancelarservicio")
//    let viewcontrollers = self.navigationController?.viewControllers
//
//    viewcontrollers?.forEach({ (vc) in
//      if  let inventoryListVC = vc as? InicioController {
//        self.navigationController!.popToViewController(inventoryListVC, animated: true)
//      }
//    })
//
    globalVariables.ofertasList.removeAll()
    let vc = R.storyboard.main.inicioView()!
    self.navigationController?.show(vc, sender: nil)
//    let navigationController = UINavigationController(rootViewController: vc)
//    //self.present(navigationController, animated: false, completion: nil)
//    self.navigationController?.popToViewController(vc, animated: false)//show(vc, sender: nil)
//    self.dismiss(animated: false, completion: nil)
  }
  
  func socketResponse(_ controller: SocketService, solicitudaceptada result: [String : Any]) {
    let newTaxi = Taxi(id: result["idtaxi"] as! Int, matricula: result["matriculataxi"] as! String, codigo: result["codigotaxi"] as! String, marca: result["marcataxi"] as! String,color: result["colortaxi"] as! String, lat: result["lattaxi"] as! Double, long: result["lngtaxi"] as! Double, conductor: Conductor(idConductor: result["idconductor"] as! Int, nombre: result["nombreapellidosconductor"] as! String, telefono:  result["telefonoconductor"] as! String, urlFoto: result["foto"] as! String, calificacion: result["calificacion"] as! Double, cantidadcalificaciones: result["cantidadcalificacion"] as! Int))
    print(globalVariables.solpendientes.first{$0.id == (result["idsolicitud"] as! Int)}!)
    globalVariables.solpendientes.first{$0.id == (result["idsolicitud"] as! Int)}!.DatosTaxiConductor(taxi: newTaxi)
    
    DispatchQueue.main.async {
      let vc = R.storyboard.main.solDetalles()!
      vc.solicitudPendiente = globalVariables.solpendientes.first{$0.id == (result["idsolicitud"] as! Int)}
      self.navigationController?.show(vc, sender: nil)
    }
  }
  
  func socketResponse(_ controller: SocketService, ofertadelconductor result: [String : Any]) {
    print("hereeee \(self.solicitud.id)")
    print("oferta \(result)")
    let array = globalVariables.ofertasList.map{$0.id}
    if !array.contains(result["idsolicitud"] as! Int){
      let newOferta = Oferta(id: result["idsolicitud"] as! Int, idTaxi: result["idtaxi"] as! Int, idConductor: result["idconductor"] as! Int, codigo: result["codigotaxi"] as! String, nombreConductor: result["nombreapellidosconductor"] as! String, movilConductor: result["telefonoconductor"] as! String, lat: result["lattaxi"] as! Double, lng: result["lngtaxi"] as! Double, valorOferta: result["valoroferta"] as! Double, tiempoLLegada: result["tiempollegada"] as! Int, calificacion: result["calificacion"] as! Double, totalCalif: result["cantidadcalificacion"] as! Int, urlFoto: result["foto"] as! String, matricula: result["matriculataxi"] as! String, marca: result["marcataxi"] as! String, color: result["colortaxi"] as! String)

      globalVariables.ofertasList.append(newOferta)

      DispatchQueue.main.async {
        let vc = R.storyboard.main.ofertasView()
        vc?.solicitud = self.solicitud
        self.navigationController?.show(vc!, sender: nil)
      }
    }
  }
  
  func socketResponse(_ controller: SocketService, sinvehiculo result: [String : Any]) {
    let solicitud = globalVariables.solpendientes.first{$0.id == result["idsolicitud"] as! Int}
    if (solicitud != nil) {
      let alertaDos = UIAlertController (title: "Estado de Solicitud", message: "No se encontó ningún taxi disponible para ejecutar su solicitud. Por favor inténtelo más tarde.", preferredStyle: .alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        self.CancelarSolicitud("")
//        let vc = R.storyboard.main.inicioView()!
//        self.navigationController?.show(vc, sender: nil)
      }))
      
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
}
