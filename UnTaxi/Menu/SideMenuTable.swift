//
//  SideMenuTable.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 11/25/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit

extension SideMenuController: UITableViewDelegate, UITableViewDataSource{
  func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return self.menuArray.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return self.menuArray[section].count
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "MENUCELL", for: indexPath)
      cell.textLabel?.text = self.menuArray[indexPath.section][indexPath.row].title
      //cell.textLabel?.font = CustomAppFont.normalFont
      cell.textLabel?.textColor = Customization.textColor
      cell.imageView?.image = UIImage(named: self.menuArray[indexPath.section][indexPath.row].imagen)?.imageWithColor(color1: Customization.iconColor)
      return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      tableView.deselectRow(at: indexPath, animated: false)
      switch tableView.cellForRow(at: indexPath)?.textLabel?.text{
      case "Nuevo viaje":
        let vc = R.storyboard.main.inicioView()!
        self.navigationController?.show(vc, sender: nil)
        
      case "Viajes en proceso":
        if globalVariables.solpendientes.count > 0{
          let vc = R.storyboard.main.listaSolPdtes()
          vc!.solicitudesMostrar = globalVariables.solpendientes
          self.navigationController?.show(vc!, sender: nil)
        }else{
          let alertaDos = UIAlertController (title: "Solicitudes en proceso", message: "Usted no tiene viajes en proceso.", preferredStyle: UIAlertController.Style.alert)
          alertaDos.addAction(UIAlertAction(title: "Cerrar", style: .default, handler: {alerAction in
            let vc = R.storyboard.main.inicioView()!
            self.navigationController?.show(vc, sender: nil)
          }))
          
          self.present(alertaDos, animated: true, completion: nil)
        }
        
      case "Historial de Viajes":
        let vc = R.storyboard.main.historyView()!
        self.navigationController?.show(vc, sender: nil)
        
      case "Operadora":
        let vc = R.storyboard.main.callCenter()!
        self.navigationController?.show(vc, sender: nil)
        
      case "Términos y condiciones":
        let vc = R.storyboard.main.terminosView()!
        self.navigationController?.show(vc, sender: nil)
        
      case "Compartir app":
        if let name = URL(string: GlobalConstants.itunesURL) {
          let objectsToShare = [name]
          let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
          
          self.present(activityVC, animated: true, completion: nil)
        }
        else
        {
          // show alert for not available
        }
      case "Salir":
        //                let fileManager = FileManager()
        //                let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
        //                do {
        //                    try fileManager.removeItem(atPath: filePath)
        //                }catch{
        //
        //                }
        //globalVariables.userDefaults.set(nil, forKey: "\(Customization.nameShowed)-loginData")
        self.CloseAPP()
      default:
        print("nada")
      }
  }
  
  //FUNCIONES Y EVENTOS PARA ELIMIMAR CELLS, SE NECESITA AGREGAR UITABLEVIEWDATASOURCE
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//    if tableView.isEqual(self.TablaDirecciones){
//      return true
//    }else{
      return false
//    }
  }
  
  func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
    return "Eliminar"
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//    if editingStyle == UITableViewCell.EditingStyle.delete {
//      self.EliminarFavorita(posFavorita: indexPath.row)
//      tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
//      if self.DireccionesArray.count == 0{
//        self.TablaDirecciones.isHidden = true
//      }
//      tableView.reloadData()
//    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return self.MenuTable.frame.height/CGFloat(self.menuArray[0].count + self.menuArray[1].count + self.menuArray[2].count)
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
      // UIView with darkGray background for section-separators as Section Footer
      let v = UIView(frame: CGRect(x: 0, y:0, width: tableView.frame.width, height: 1))
      v.backgroundColor = Customization.textFieldBackColor
      return v
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
      // Section Footer height
      return 1.0
  }
}
