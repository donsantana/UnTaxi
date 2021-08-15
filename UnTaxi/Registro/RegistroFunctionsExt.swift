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
    let (valid, message) = correoText.validate(.email)
    if correoText.text!.isEmpty || valid{
      waitingView.isHidden = false
      apiService.registerUserAPI(url: GlobalConstants.registerUrl, params: [
                                  "password": claveText.text!,
                                  "movil": telefonoText.text!,
                                  "nombreapellidos": nombreApText.text!,
                                  "email": correoText.text!,
                                  "so": "IOS",
                                  "recomendado": ""])
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
