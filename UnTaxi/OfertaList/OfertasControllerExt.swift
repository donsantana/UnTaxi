//
//  OfertasControllerExt.swift
//  MovilClub
//
//  Created by Donelkys Santana on 7/26/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import UIKit


@available(iOS 10.0, *)
extension OfertasController: UITableViewDelegate, UITableViewDataSource{
  
  // MARK: - Table view data source
  
  func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return globalVariables.ofertasList.count
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   
    let cell = Bundle.main.loadNibNamed("OfertaViewCell", owner: self, options: nil)?.first as! OfertaViewCell
    
    cell.initContent(oferta: globalVariables.ofertasList[indexPath.row])
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //#ASO,idsolicitud,idtaxi,idcliente,#
    self.ofertaAceptadaEffect.isHidden = false
    self.ofertaSeleccionada = globalVariables.ofertasList[indexPath.row]


    let datos = [
      "idsolicitud": ofertaSeleccionada.id,
      "idtaxi": ofertaSeleccionada.idTaxi
    ]
    inicioController!.socketEmit("aceptaroferta", datos: datos)
    self.socketEventos()
  }
}

extension OfertasController{
  func socketEventos(){
    globalVariables.socket.on("aceptaroferta"){data, ack in
      self.progressTimer.invalidate()
      self.inicioController!.EnviarTimer(estado: 0, datos: "terminando")
      let temporal = data[0] as! [String: Any]
      print(temporal)
      self.ofertaAceptadaEffect.isHidden = true
      if temporal["code"] as! Int == 1{
        let solicitudCreada = globalVariables.solpendientes.filter({$0.id == self.ofertaSeleccionada.id}).first
        let newTaxi = Taxi(id: self.ofertaSeleccionada.idTaxi, matricula: self.ofertaSeleccionada.matricula, codigo: self.ofertaSeleccionada.codigo, marca: self.ofertaSeleccionada.marca, color: self.ofertaSeleccionada.color, lat: self.ofertaSeleccionada.location.latitude, long: self.ofertaSeleccionada.location.longitude, conductor: Conductor(idConductor: self.ofertaSeleccionada.idConductor, nombre: self.ofertaSeleccionada.nombreConductor, telefono: self.ofertaSeleccionada.movilConductor, urlFoto: self.ofertaSeleccionada.urlFoto, calificacion: self.ofertaSeleccionada.calificacion))
        solicitudCreada!.DatosTaxiConductor(taxi: newTaxi)
        DispatchQueue.main.async {
          let vc = R.storyboard.main.solDetalles()
          //vc!.solicitudIndex = globalVariables.solpendientes.firstIndex{$0.id == solicitudCreada?.id}
          vc!.solicitudPendiente = solicitudCreada
          self.navigationController?.show(vc!, sender: nil)
        }
      }else{
        let alertaDos = UIAlertController (title: "Estado de Oferta", message: (temporal["msg"] as! String), preferredStyle: UIAlertController.Style.alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          self.inicioController!.Inicio()
        }))
        self.present(alertaDos, animated: true, completion: nil)
      }
    }
  }
}
