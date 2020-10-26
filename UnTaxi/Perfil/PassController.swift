//
//  ChangePasswordView.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 10/22/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit

class PassController: BaseController, UIGestureRecognizerDelegate {
  var passViewCell = Bundle.main.loadNibNamed("Perfil3ViewCell", owner: self, options: nil)?.first as! Perfil3ViewCell
  var apiService = ApiService()
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    self.tableView.delegate = self
    super.viewDidLoad()
    self.apiService.delegate = self
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado))
    tapGesture.delegate = self
    self.view.addGestureRecognizer(tapGesture)
  }
  
  func sendUpdatePassword(){
    self.apiService.changeClaveAPI(params: ["user": String(globalVariables.cliente.id), "password": self.passViewCell.claveActualText.text!, "newpassword": self.passViewCell.NuevaClaveText.text!])
  }
  
  @objc func ocultarTeclado(sender: UITapGestureRecognizer){
    self.view.endEditing(true)
  }
  
  @IBAction func updatePassword(_ sender: Any) {
    if self.passViewCell.NuevaClaveText.text != self.passViewCell.ConfirmeClaveText.text{
      let alertaDos = UIAlertController (title: "Cambiar contraseña", message: "Las Claves Nuevas no coinciden.", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in

      }))
      self.present(alertaDos, animated: true, completion: nil)
    }else{
      self.sendUpdatePassword()
    }
  }
}

extension PassController: UITableViewDelegate, UITableViewDataSource{
  func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return 1
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = Bundle.main.loadNibNamed("Perfil3ViewCell", owner: self, options: nil)?.first as! Perfil3ViewCell
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 210
  }
}

extension PassController: ApiServiceDelegate{
  func apiRequest(_ controller: ApiService, createNewClaveAPI msg: String) {
      let alertaDos = UIAlertController (title: "Nueva clave creada", message: msg, preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
 
      }))
      self.present(alertaDos, animated: true, completion: nil)

  }
}
