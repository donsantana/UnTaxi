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
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var waitingView: UIVisualEffectView!
  
  @IBOutlet weak var historyTopConstraint: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.delegate = self
    self.historyTopConstraint.constant = super.getTopMenuBottom()
    self.waitingView.standardConfig()
    self.waitingView.isHidden = false
    self.loadHistorialSolicitudes()
    
    
    globalVariables.socket.on("historialdesolicitudes"){data, ack in
      self.waitingView.isHidden = true
      let result = data[0] as! [String: Any]
      print(result)
      if result["code"] as! Int == 1{
        let historialJson = result["datos"] as! [[String: Any]]
        for solicitudHistory in historialJson{
          print(solicitudHistory)
          self.historialSolicitudesList.append(SolicitudHistorial(json: solicitudHistory))
        }
        self.tableView.reloadData()
      }
    }

  }
  
  func loadHistorialSolicitudes(){
    let vc = R.storyboard.main.inicioView()!
    vc.socketEmit("historialdesolicitudes", datos: ["idcliente": globalVariables.cliente.id as Any])
  }
  
}
