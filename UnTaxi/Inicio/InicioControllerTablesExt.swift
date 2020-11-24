//
//  InicioFormSolicitudExt.swift
//  MovilClub
//
//  Created by Donelkys Santana on 5/28/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import UIKit

extension InicioController: UITableViewDelegate, UITableViewDataSource{
  //TABLA FUNCTIONS
  func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    switch tableView {
    case self.MenuTable:
      return self.menuArray.count
    default:
      return 1
    }
    
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    switch tableView {
    case self.MenuTable:
      return self.menuArray[section].count
    default:
      print(self.formularioDataCellList.count)
      return self.formularioDataCellList.count
    }
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch tableView {
    case self.MenuTable:
      let cell = tableView.dequeueReusableCell(withIdentifier: "MENUCELL", for: indexPath)
      cell.textLabel?.text = self.menuArray[indexPath.section][indexPath.row].title
      cell.textLabel?.font = AppFont.normalFont
      cell.textLabel?.textColor = Customization.textColor
      cell.imageView?.image = UIImage(named: self.menuArray[indexPath.section][indexPath.row].imagen)?.imageWithColor(color1: Customization.iconColor)
      return cell
    default:
     
      return self.formularioDataCellList[indexPath.row]
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      self.MenuView1.isHidden = true
      self.TransparenciaView.isHidden = true
      tableView.deselectRow(at: indexPath, animated: false)
      switch tableView.cellForRow(at: indexPath)?.textLabel?.text{
      case "Viajes en proceso"?:
        if globalVariables.solpendientes.count > 0{
          let vc = R.storyboard.main.listaSolPdtes()
          vc!.solicitudesMostrar = globalVariables.solpendientes
          self.navigationController?.show(vc!, sender: nil)
        }else{
          super.topMenu.isHidden = false
          self.viewDidLoad()
          self.SolPendientesView.isHidden = false
        }
      case "Historial de Viajes":
        let vc = R.storyboard.main.historyView()!
        self.navigationController?.show(vc, sender: nil)
        
      case "Operadora":
        let vc = R.storyboard.main.callCenter()!
        vc.telefonosCallCenter = globalVariables.TelefonosCallCenter
        self.navigationController?.show(vc, sender: nil)
        
      case "Terminos y condiciones":
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
    switch tableView {
    case self.MenuTable:
      return self.MenuTable.frame.height/CGFloat(self.menuArray[0].count + self.menuArray[1].count + self.menuArray[2].count)
    case self.solicitudFormTable:
      return self.formularioDataCellList[indexPath.row].bounds.height
//      switch indexPath.row {
//      case 0:
//        return 150
//      case 1:
//        return self.tabBar.selectedItem == self.ofertaItem || self.tabBar.selectedItem == self.pactadaItem ? 50 : 120
//      case 2:
//        return 60
//      default:
//        return 80
//      }
    default:
      return 44
    }
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
