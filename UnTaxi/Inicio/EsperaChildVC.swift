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
  
  @IBOutlet weak var CancelarSolicitudProceso: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.socketService.delegate = self
    //self.socketService.initListenEventos()
    
    self.updateOfertaView.addShadow()
    self.SendOferta.addShadow()
    self.newOfertaText.addBorder(color: Customization.buttonActionColor)
    self.MensajeEspera.centerVertically()
   
    self.newOfertaText.text = "$\(Double(self.solicitud.valorOferta))"
    self.updateOfertaView.isHidden = self.solicitud!.valorOferta == 0.0
  }
  
  
  func updateOfertaValue(value: Double){
    self.newOfertaText.text = "$\(Double(self.newOfertaText.text!.dropFirst())! + value)"
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
    MostrarMotivoCancelacion(solicitud: self.solicitud)
  }
  
  @IBAction func cancelarSolicitudOferta(_ sender: Any) {
    MostrarMotivoCancelacion(solicitud: self.solicitud)
  }

}

extension EsperaChildVC: SocketServiceDelegate{
  func socketResponse(_ controller: SocketService, cancelarservicio result: [String : Any]) {
    let vc = R.storyboard.main.inicioView()!
    self.navigationController?.show(vc, sender: nil)
  }
  
  func socketResponse(_ controller: SocketService, solicitudaceptada result: [String : Any]) {
    let newTaxi = Taxi(id: result["idtaxi"] as! Int, matricula: result["matriculataxi"] as! String, codigo: result["codigotaxi"] as! String, marca: result["marcataxi"] as! String,color: result["colortaxi"] as! String, lat: result["lattaxi"] as! Double, long: result["lngtaxi"] as! Double, conductor: Conductor(idConductor: result["idconductor"] as! Int, nombre: result["nombreapellidosconductor"] as! String, telefono:  result["telefonoconductor"] as! String, urlFoto: result["foto"] as! String, calificacion: result["calificacion"] as! Double, cantidadcalificaciones: result["cantidadcalificacion"] as! Int))
    
    globalVariables.solpendientes.first{$0.id == (result["idsolicitud"] as! Int)}!.DatosTaxiConductor(taxi: newTaxi)
    
    DispatchQueue.main.async {
      let vc = R.storyboard.main.solDetalles()!
      vc.solicitudPendiente = globalVariables.solpendientes.first{$0.id == (result["idsolicitud"] as! Int)}
      self.navigationController?.show(vc, sender: nil)
    }
  }
  
  func socketResponse(_ controller: SocketService, ofertadelconductor result: [String : Any]) {
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
}
