//
//  HistorialController.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 10/21/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit

class HistorialController: BaseController {
  var historialSolicitudesList: [SolicitudHistorial] = []
  let socketService = SocketService()
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var waitingView: UIVisualEffectView!
  
  @IBOutlet weak var titleText: UILabel!
  @IBOutlet weak var historyTopConstraint: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.delegate = self
    self.socketService.delegate = self
    self.historyTopConstraint.constant = super.getTopMenuBottom()
    self.waitingView.addStandardConfig()
    self.waitingView.isHidden = false
    self.loadHistorialSolicitudes()
    //self.titleText.font = CustomAppFont.titleFont
  }

  func loadHistorialSolicitudes(){
    self.socketService.socketEmit("historialdesolicitudes", datos: ["idcliente": globalVariables.cliente.id as Any])
    self.socketService.initHistorialEvents()
  }
  
  override func homeBtnAction() {
    self.goToInicioView()
  }
  
}

extension HistorialController: SocketServiceDelegate{
  func socketResponse(_ controller: SocketService, historialdesolicitudes result: [String : Any]) {
    self.waitingView.isHidden = true
    if result["code"] as! Int == 1{
      let historialJson = result["datos"] as! [[String: Any]]
      for solicitudHistory in historialJson{
        self.historialSolicitudesList.append(SolicitudHistorial(jsonData: solicitudHistory))
      }
      if self.historialSolicitudesList.count > 0{
        self.tableView.reloadData()
      }else{
        let alertaDos = UIAlertController (title: "Historial de solicitudes", message: "No se encontraron solicitudes en su historial.", preferredStyle: UIAlertController.Style.alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          self.goToInicioView()
        }))
        self.present(alertaDos, animated: true, completion: nil)
      }
    }
  }

}