//
//  CallCenterController.swift
//  UnTaxi
//
//  Created by Done Santana on 4/3/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import UIKit

class CallCenterController: BaseController {
  var socketService = SocketService()
  var telefonosCallCenter = [Telefono]()
  
  @IBOutlet weak var callCenterTableView: UITableView!
  @IBOutlet weak var topViewConstraint: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.socketService.delegate = self
    self.callCenterTableView.delegate = self
    self.topViewConstraint.constant = super.getTopMenuBottom()
//    self.navigationController?.navigationBar.tintColor = CustomAppColor.textColor//UIColor.black
//    navigationItem.setHidesBackButton(false, animated: false)
    self.loadCallCenter()
  }
  
  func loadCallCenter(){
    socketService.socketEmit("telefonosdelcallcenter", datos: [:])
    self.socketService.initCallcenterEvents()
  }
  
  func openWhatsApp(number : String){
    print(number)
    var phoneNumber:String = number
    if number.first == "0"{
      phoneNumber.removeFirst()
      phoneNumber = "+593\(phoneNumber)"
    }
    let appURL = URL(string: "https://api.whatsapp.com/send?phone=\(phoneNumber)")!
    //let appURL = URL(string: "https://api.whatsapp.com/send?phone=+593991539359")!
    print(phoneNumber)
    if UIApplication.shared.canOpenURL(appURL) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
        }else {
            UIApplication.shared.openURL(appURL)
        }
    } else {
      let alertaCompartir = UIAlertController (title: "Whatsapp Error", message: "La aplicaión de whatsapp no está instalada en su dispositivo", preferredStyle: UIAlertController.Style.alert)
      alertaCompartir.addAction(UIAlertAction(title: "Cerrar", style: .default, handler: {alerAction in
        
      }))
      self.present(alertaCompartir, animated: true, completion: nil)
    }
    
//    var fullMob = number
//    fullMob = fullMob.replacingOccurrences(of: " ", with: "")
//    fullMob = fullMob.replacingOccurrences(of: "+", with: "")
//    fullMob = fullMob.replacingOccurrences(of: "-", with: "")
//    let urlWhats = "whatsapp://send?phone=\(fullMob)"
//
//    if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
//      if let whatsappURL = NSURL(string: urlString) {
//        if UIApplication.shared.canOpenURL(whatsappURL as URL) {
//          UIApplication.shared.open(whatsappURL as URL, options: [:], completionHandler: { (Bool) in
//          })
//        } else {
//          let alertaCompartir = UIAlertController (title: "Whatsapp Error", message: "La aplicaión de whatsapp no está instalada en su dispositivo", preferredStyle: UIAlertController.Style.alert)
//          alertaCompartir.addAction(UIAlertAction(title: "Cerrar", style: .default, handler: {alerAction in
//
//          }))
//          self.present(alertaCompartir, animated: true, completion: nil)
//        }
//      }
//    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func homeBtnAction() {
    self.dismiss(animated: false, completion: nil)
  }

}

extension CallCenterController: UITableViewDelegate,UITableViewDataSource{
  // MARK: - Table view data source
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    let seccionName = section == 0 ? "CALLCENTER" : "PUBLICIDAD"
    return self.telefonosCallCenter.filter({$0.seccion == seccionName}).count
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = Bundle.main.loadNibNamed("CallCenterViewCell", owner: self, options: nil)?.first as! CallCenterViewCell
    let seccionName = indexPath.section == 0 ? "CALLCENTER" : "PUBLICIDAD"
    cell.initContent(telefono: self.telefonosCallCenter.filter({$0.seccion == seccionName})[indexPath.row])
    // Configure the cell...
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if telefonosCallCenter[indexPath.row].tienewhatsapp {
      let callCenterAlert = UIAlertController(title: "Comunicar al Call Center", message: "", preferredStyle: UIAlertController.Style.actionSheet)
  //    callCenterAlert.addAction(UIAlertAction(title: "No necesito", style: .default, handler: { action in
  //      self.CancelarSolicitud("No necesito", solicitud: solicitud)
  //    }))
      callCenterAlert.addAction(UIAlertAction(title: "Llamar", style: .default, handler: { [self] action in
        if let url = URL(string: "tel://\(telefonosCallCenter[indexPath.row].numero)") {
          UIApplication.shared.open(url)
        }
      }))
      callCenterAlert.addAction(UIAlertAction(title: "Usar whatsapp", style: .default, handler: { [self] action in
        self.openWhatsApp(number: telefonosCallCenter[indexPath.row].numero)
      }))
      
      callCenterAlert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.destructive, handler: { action in
        
      }))
      
      self.present(callCenterAlert, animated: true, completion: nil)
    }else{
      if let url = URL(string: "tel://\(telefonosCallCenter[indexPath.row].numero)") {
        UIApplication.shared.open(url)
      }else{
        let callCenterAlert = UIAlertController(title: "Error", message: "No se pudo realizar la llamada", preferredStyle: .alert)
        callCenterAlert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.destructive, handler: { action in
          
        }))
        self.present(callCenterAlert, animated: true, completion: nil)
      }
    }
    tableView.deselectRow(at: indexPath, animated: false)
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return section == 0 ? "CALLCENTER" : "PUBLICIDAD"
  }
}

extension CallCenterController: SocketServiceDelegate{
  func socketResponse(_ controller: SocketService, telefonosdelcallcenter result: [[String: Any]]) {
    print("Call Center \(result)")
    var telefonoList:[Telefono] = []
    for telefonoData in result{
      telefonoList.append(Telefono(numero: telefonoData["telefono2"] as! String, operadora: telefonoData["operadora"] as! String, seccion: !(telefonoData["seccion"] is NSNull) && telefonoData["seccion"] != nil ? telefonoData["seccion"] as! String : "CALLCENTER", tienewhatsapp: (telefonoData["whatsapp"] as! Int) == 1))
    }
    
    self.telefonosCallCenter = telefonoList
    self.telefonosCallCenter.sort{$0.seccion > $1.seccion}
    self.telefonosCallCenter.sort{$0.numero > $1.numero}
    self.callCenterTableView.reloadData()
  }
}
