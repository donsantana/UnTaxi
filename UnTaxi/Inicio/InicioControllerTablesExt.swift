//
//  InicioFormSolicitudExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/28/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import UIKit

extension InicioController: UITableViewDelegate, UITableViewDataSource{
  //TABLA FUNCTIONS
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return self.formularioDataCellList.count
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return self.formularioDataCellList[indexPath.row]
  }

  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return self.formularioDataCellList[indexPath.row].contentView.bounds.height
  }
  
//  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//      // UIView with darkGray background for section-separators as Section Footer
//      let v = UIView(frame: CGRect(x: 0, y:0, width: tableView.frame.width, height: 1))
//      v.backgroundColor = Customization.textFieldBackColor
//      return v
//  }
//
//  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//      // Section Footer height
//      return 1.0
//  }
}
