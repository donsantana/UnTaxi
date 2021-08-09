//
//  RegistroFunctionsExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 8/5/21.
//  Copyright © 2021 Done Santana. All rights reserved.
//

import UIKit
import CountryPicker

extension RegistroController{
  
  @objc func ocultarTeclado(){
    self.view.endEditing(true)
  }
  
  func sendNewUserData(){
    if (nombreApText.text!.isEmpty || telefonoText.text!.isEmpty || claveText.text!.isEmpty) {
      let alertaDos = UIAlertController (title: "Registro de usuario", message: "Debe llenar todos los campos del formulario", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        self.telefonoText.becomeFirstResponder()
      }))
      
      self.present(alertaDos, animated: true, completion: nil)
    }else{
//      if telefonoText.text?.first == "0"{
//        telefonoText.text!.removeFirst()
//      }
//      let movil = "\(String(describing: countryCodeText.text!))\(telefonoText.text!)"
//      print(movil)
      apiService.registerUserAPI(url: GlobalConstants.registerUrl, params: [
        "password": claveText.text!,
        "movil": telefonoText.text!,
        "nombreapellidos": nombreApText.text!,
        "email": correoText.text!,
        "so": "IOS",
        "recomendado": ""])

//      RegistroView.isHidden = true
//      RegistroView.resignFirstResponder()
    }
  }
  
  func goToLoginView(){
    let viewcontrollers = self.navigationController?.viewControllers
    viewcontrollers?.forEach({ (vc) in
      if  let inventoryListVC = vc as? LoginController {
        self.navigationController!.popToViewController(inventoryListVC, animated: true)
      }
    })
  }
}
