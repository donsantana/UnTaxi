//
//  YapaTableExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/23/21.
//  Copyright © 2021 Done Santana. All rights reserved.
//

import UIKit

extension YapaController: UITableViewDelegate, UITableViewDataSource{
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = Bundle.main.loadNibNamed("YapaViewCell", owner: self, options: nil)?.first as! YapaCell
    cell.initContent(yapaMenu: self.yapaActionsArray[indexPath.row])
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    contentPanel = storyboard?.instantiateViewController(withIdentifier: "YapaPanel") as? YapaPanel
    if indexPath.row == 0 {
      if globalVariables.cliente.yapa >= globalVariables.appConfig.uso_yapa{
      contentPanel?.actionType = 2
        yapaPanel.set(contentViewController: contentPanel)
        yapaPanel.addPanel(toParent: self)
        tableView.deselectRow(at: indexPath, animated: false)
      } else {
        let alertaDos = UIAlertController (title: "Yapa Error", message: "Solo puede utilizar su YAPA cuando acumule un valor igual o superior a $0.5", preferredStyle: UIAlertController.Style.alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          
        }))
        self.present(alertaDos, animated: true, completion: nil)
      }
//      yapaPanel.set(contentViewController: contentPanel)
//      yapaPanel.addPanel(toParent: self)
    } else {
      contentPanel?.actionType = 1
      yapaPanel.set(contentViewController: contentPanel)
      yapaPanel.addPanel(toParent: self)
      tableView.deselectRow(at: indexPath, animated: false)
    }
    
  }
  
}
