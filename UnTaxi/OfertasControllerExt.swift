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
    let datos = "#ASO,\(ofertaSeleccionada.id),\(ofertaSeleccionada.idTaxi),\(ofertaSeleccionada.valorOferta), \(ofertaSeleccionada.tiempoLLegada),# \n"
    inicioController!.EnviarTimer(estado: 1, datos: datos)
    print(datos)
    self.socketEventos()
  }
}

extension OfertasController{
  func socketEventos(){
//    globalVariables.socket.on("ASO"){data, ack in
//      //Trama IN: #Solicitud, ok, idsolicitud, fechahora
//      //Trama IN: #Solicitud, error
//      self.progressTimer.invalidate()
//      self.inicioController!.EnviarTimer(estado: 0, datos: "terminando")
//      let temporal = String(describing: data).components(separatedBy: ",")
//      print(temporal)
//      self.ofertaAceptadaEffect.isHidden = true
//      if temporal[1] == "ok"{
//        let solicitudCreada = globalVariables.solpendientes.filter({String($0.id) == self.ofertaSeleccionada.id}).first
//        solicitudCreada!.DatosTaxiConductor(idtaxi: self.ofertaSeleccionada.idTaxi, matricula: self.ofertaSeleccionada.matricula, codigovehiculo: self.ofertaSeleccionada.codigo, marca: self.ofertaSeleccionada.marca, color: self.ofertaSeleccionada.color, lattaxi: self.ofertaSeleccionada.location.latitude, lngtaxi: self.ofertaSeleccionada.location.longitude, idconductor: self.ofertaSeleccionada.movilConductor, nombreapellidosconductor: self.ofertaSeleccionada.nombreConductor, movilconductor: self.ofertaSeleccionada.movilConductor, foto: self.ofertaSeleccionada.urlFoto)
//        DispatchQueue.main.async {
//          let vc = R.storyboard.main.solPendientes()
//          vc!.solicitudIndex = globalVariables.solpendientes.firstIndex{String($0.id) == self.ofertaSeleccionada.id}
//          self.navigationController?.show(vc!, sender: nil)
//        }
//      }else{
//        switch temporal[2]{
//        case "0":
//          let alertaDos = UIAlertController (title: "Oferta Cancelada", message: "Error en el proceso inténtelo nuevamente.", preferredStyle: UIAlertController.Style.alert)
//          alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
//            self.inicioController!.Inicio()
//          }))
//          self.present(alertaDos, animated: true, completion: nil)
//        case "1":
//          let alertaDos = UIAlertController (title: "Oferta Cancelada", message: "La oferta seleccionada ya no está disponible, ha sido cancelada por el conductor.", preferredStyle: UIAlertController.Style.alert)
//          alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
//            globalVariables.ofertasList.removeAll{$0.idTaxi == self.ofertaSeleccionada.idTaxi}
//            self.ofertasTableView.reloadData()
//          }))
//          self.present(alertaDos, animated: true, completion: nil)
//        case "2":
//          let alertaDos = UIAlertController (title: "Oferta Cancelada", message: "El conductor no se ha desconectado. Por favor seleccione otra oferta.", preferredStyle: UIAlertController.Style.alert)
//          alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
//            globalVariables.ofertasList.removeAll{$0.idTaxi == self.ofertaSeleccionada.idTaxi}
//            self.ofertasTableView.reloadData()
//          }))
//          self.present(alertaDos, animated: true, completion: nil)
//        default:
//          break
//        }
//        
//      }
//    }
  }
}
