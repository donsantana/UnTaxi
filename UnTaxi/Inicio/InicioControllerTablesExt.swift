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
    switch tableView {
    case solicitudFormTable:
      return self.formularioDataCellList.count
    case addressTableView:
      print("addressList \(self.searchAddressList.count)")
      return self.searchAddressList.count
    default:
      return 0
    }
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch tableView {
    case solicitudFormTable:
      return self.formularioDataCellList[indexPath.row]
    case addressTableView:
      let cell = tableView.dequeueReusableCell(withIdentifier: "CELL")
      cell?.textLabel?.text = self.searchAddressList[indexPath.row].nombre
      cell?.detailTextLabel?.text = self.searchAddressList[indexPath.row].fullAddress()
      cell?.imageView?.image = UIImage(named: "mapLocation")
      return cell!
    default:
      return self.formularioDataCellList[indexPath.row]
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    closeSearchAddress(addressSelected: self.searchAddressList[indexPath.row])
  }

  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch tableView {
    case solicitudFormTable:
      return self.formularioDataCellList[indexPath.row].contentView.bounds.height
    default:
      return 44
    }
  }
  
//  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//      // UIView with darkGray background for section-separators as Section Footer
//      let v = UIView(frame: CGRect(x: 0, y:0, width: tableView.frame.width, height: 1))
//      v.backgroundColor = CustomAppColor.textFieldBackColor
//      return v
//  }
//
//  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//      // Section Footer height
//      return 1.0
//  }
}
