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
    contentPanel = storyboard?.instantiateViewController(withIdentifier: "YapaPanel") as? YapaPanel
    if indexPath.row == 0 {
      contentPanel?.actionType = 2
//      yapaPanel.set(contentViewController: contentPanel)
//      yapaPanel.addPanel(toParent: self)
    }else{
      contentPanel?.actionType = 1
//      yapaPanel.set(contentViewController: contentPanel)
//      yapaPanel.addPanel(toParent: self)
    }
    //contentPanel!.codigoText.delegate = self
    yapaPanel.set(contentViewController: contentPanel)
    yapaPanel.addPanel(toParent: self)
    //yapaPanel.move(to: .full, animated: true)
    tableView.deselectRow(at: indexPath, animated: false)
  }
  
}
