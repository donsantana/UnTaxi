//
//  HistorialTableExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 10/21/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit

extension HistorialController: UITableViewDelegate{

  func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return self.historialSolicitudesList.count
  }


  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = Bundle.main.loadNibNamed("HistoryViewCell", owner: self, options: nil)?.first as! HistoryCell
    cell.initContent(solicitud: self.historialSolicitudesList[indexPath.row])
    // Configure the cell...

    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    if let url = URL(string: "tel://\(telefonosCallCenter[indexPath.row].numero)") {
//      UIApplication.shared.open(url)
//    }
  }
}
