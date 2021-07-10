//
//  OfertasControllerExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 7/26/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import UIKit


@available(iOS 10.0, *)
extension OfertasController: UITableViewDelegate, UITableViewDataSource{
  
  // MARK: - Table view data source
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return globalVariables.ofertasList.count
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   
    let cell = Bundle.main.loadNibNamed("OfertaViewCell", owner: self, options: nil)?.first as! OfertaViewCell
    
    cell.initContent(oferta: globalVariables.ofertasList[indexPath.row])
    cell.layer.backgroundColor = UIColor.clear.cgColor
    cell.backgroundColor = .clear
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //#ASO,idsolicitud,idtaxi,idcliente,#
    tableView.deselectRow(at: indexPath, animated: false)
    self.ofertaAceptadaEffect.isHidden = false
    self.ofertaSeleccionada = globalVariables.ofertasList[indexPath.row]
    print(self.ofertaSeleccionada)
    let datos = [
      "idsolicitud": ofertaSeleccionada.id,
      "idtaxi": ofertaSeleccionada.idTaxi
    ]
    self.socketService.socketEmit("aceptaroferta", datos: datos)
  }
}

extension OfertasController: SocketServiceDelegate{
  
  func socketResponse(_ controller: SocketService, ofertadelconductor result: [String : Any]) {
    
    //let array = globalVariables.ofertasList.map{$0.id}
    let arrayTaxiId = globalVariables.ofertasList.map{$0.idTaxi}
    
    if (self.solicitud.id == (result["idsolicitud"] as! Int)) && !arrayTaxiId.contains(result["idtaxi"] as! Int){
      let newOferta = Oferta(id: result["idsolicitud"] as! Int, idTaxi: result["idtaxi"] as! Int, idConductor: result["idconductor"] as! Int, codigo: result["codigotaxi"] as! String, nombreConductor: result["nombreapellidosconductor"] as! String, movilConductor: result["telefonoconductor"] as! String, lat: result["lattaxi"] as! Double, lng: result["lngtaxi"] as! Double, valorOferta: result["valoroferta"] as! Double, tiempoLLegada: result["tiempollegada"] as! Int, calificacion: result["calificacion"] as! Double, totalCalif: result["cantidadcalificacion"] as! Int, urlFoto: result["foto"] as! String, matricula: result["matriculataxi"] as! String, marca: result["marcataxi"] as! String, color: result["colortaxi"] as! String)

      globalVariables.ofertasList.append(newOferta)
      self.ofertasTableView.reloadData()
    }
  }
  
  func socketResponse(_ controller: SocketService, aceptaroferta result: [String: Any]){
    self.progressTimer.invalidate()
    self.ofertaAceptadaEffect.isHidden = true
    if result["code"] as! Int == 1{
      let solicitudCreada = globalVariables.solpendientes.filter({$0.id == self.ofertaSeleccionada.id}).first
      let newTaxi = Taxi(id: self.ofertaSeleccionada.idTaxi, matricula: self.ofertaSeleccionada.matricula, codigo: self.ofertaSeleccionada.codigo, marca: self.ofertaSeleccionada.marca, color: self.ofertaSeleccionada.color, lat: self.ofertaSeleccionada.location.latitude, long: self.ofertaSeleccionada.location.longitude, conductor: Conductor(idConductor: self.ofertaSeleccionada.idConductor, nombre: self.ofertaSeleccionada.nombreConductor, telefono: self.ofertaSeleccionada.movilConductor, urlFoto: self.ofertaSeleccionada.urlFoto, calificacion: self.ofertaSeleccionada.calificacion, cantidadcalificaciones: self.ofertaSeleccionada.totalCalif))
      solicitudCreada!.DatosTaxiConductor(taxi: newTaxi)
      globalVariables.ofertasList.removeAll()
      DispatchQueue.main.async {
        let vc = R.storyboard.main.solDetalles()!
        vc.solicitudPendiente = solicitudCreada
        self.navigationController?.show(vc, sender: nil)
      }
    }else{
      let alertaDos = UIAlertController (title: "Estado de Oferta", message: (result["msg"] as! String), preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        self.goToInicioView()
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
  func socketResponse(_ controller: SocketService, cancelarservicio result: [String : Any]) {
    print("Cancelada en oferta \(result)")
    let title = (result["code"] as! Int) == 1 ? "Solicitud Cancelada" : "Error Cancelar"
    let message = (result["code"] as! Int) == 1 ? "Su solicitud fue cancelada con éxito." : result["msg"] as! String

    let alertaDos = UIAlertController (title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
      if (result["code"] as! Int) == 1{
        print("Cancelada")
        globalVariables.ofertasList.removeAll()
        self.goToInicioView()
      }
    }))
    self.present(alertaDos, animated: true, completion: nil)
  }

}
