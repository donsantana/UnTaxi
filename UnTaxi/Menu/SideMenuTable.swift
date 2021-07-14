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
      cell.textLabel?.textColor = CustomAppColor.textColor
      cell.imageView?.image = UIImage(named: self.menuArray[indexPath.section][indexPath.row].imagen)?.imageWithColor(color1: CustomAppColor.iconColor)
      return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      tableView.deselectRow(at: indexPath, animated: false)

    var vc: UIViewController!// = R.storyboard.main.inicioView()!
      switch tableView.cellForRow(at: indexPath)?.textLabel?.text{
      case "Nuevo viaje":
        let viewcontrollers = self.navigationController?.viewControllers
        print("cantidad de viewcontrollers \(viewcontrollers?.count)")
        
        vc = R.storyboard.main.inicioView()!
        //let navigationController = UINavigationController(rootViewController: vc)
        //self.present(navigationController, animated: false, completion: nil)
        self.navigationController?.show(vc, sender: self)
        
      case "Viajes en proceso":
        if globalVariables.solpendientes.count > 0{
          vc = R.storyboard.main.listaSolPdtes()
          (vc as! SolicitudesTableController).solicitudesMostrar = globalVariables.solpendientes
          //self.present(vc, animated: false, completion: nil)
          self.navigationController?.show(vc!, sender: nil)
        }else{
          let alertaDos = UIAlertController (title: "Solicitudes en proceso", message: "Usted no tiene viajes en proceso.", preferredStyle: UIAlertController.Style.alert)
          alertaDos.addAction(UIAlertAction(title: "Cerrar", style: .default, handler: {alerAction in
    
          }))
          
          self.present(alertaDos, animated: true, completion: nil)
        }
        
      case "Historial de Viajes":
        vc = R.storyboard.main.historyView()!
        //self.present(vc, animated: false, completion: nil)
        self.navigationController?.show(vc, sender: nil)
        
      case "Operadora":
        vc = R.storyboard.main.callCenter()!
        vc.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)

        self.present(vc, animated: false, completion: nil)
        //self.navigationController?.show(vc, sender: nil)
        
      case "Términos y condiciones":
        vc = R.storyboard.main.terminosView()!
        self.present(vc, animated: false, completion: nil)
        //self.navigationController?.show(vc, sender: nil)
        
      case "Compartir app":
        if let name = URL(string: GlobalConstants.itunesURL) {
          let objectsToShare = [name]
          let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
          
          self.present(activityVC, animated: true, completion: nil)
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
      v.backgroundColor = CustomAppColor.textFieldBackColor
      return v
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
      // Section Footer height
      return 1.0
  }
}
