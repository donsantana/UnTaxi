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
  func socketResponse(_ controller: SocketService, aceptaroferta result: [String: Any]){
    self.progressTimer.invalidate()
    self.ofertaAceptadaEffect.isHidden = true
    if result["code"] as! Int == 1{
      let solicitudCreada = globalVariables.solpendientes.filter({$0.id == self.ofertaSeleccionada.id}).first
      let newTaxi = Taxi(id: self.ofertaSeleccionada.idTaxi, matricula: self.ofertaSeleccionada.matricula, codigo: self.ofertaSeleccionada.codigo, marca: self.ofertaSeleccionada.marca, color: self.ofertaSeleccionada.color, lat: self.ofertaSeleccionada.location.latitude, long: self.ofertaSeleccionada.location.longitude, conductor: Conductor(idConductor: self.ofertaSeleccionada.idConductor, nombre: self.ofertaSeleccionada.nombreConductor, telefono: self.ofertaSeleccionada.movilConductor, urlFoto: self.ofertaSeleccionada.urlFoto, calificacion: self.ofertaSeleccionada.calificacion, cantidadcalificaciones: self.ofertaSeleccionada.totalCalif))
      solicitudCreada!.DatosTaxiConductor(taxi: newTaxi)
      DispatchQueue.main.async {
        let vc = R.storyboard.main.solDetalles()
        vc!.solicitudPendiente = solicitudCreada
        self.navigationController?.show(vc!, sender: nil)
      }
    }else{
      let alertaDos = UIAlertController (title: "Estado de Oferta", message: (result["msg"] as! String), preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        self.inicioController!.Inicio()
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
  func socketResponse(_ controller: SocketService, cancelarservicio result: [String : Any]) {
    print("cancelada \(result)")
    if (result["code"] as! Int) == 1 || (result["code"] as! Int) == 3{
      let vc = R.storyboard.main.inicioView()!
      self.navigationController?.show(vc, sender: nil)
    }
  }

}
