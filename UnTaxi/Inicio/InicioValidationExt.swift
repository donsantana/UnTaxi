//
//  InicioValidationExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 8/22/21.
//  Copyright © 2021 Done Santana. All rights reserved.
//

import UIKit

extension InicioController{
  
  func validateDestino(){
    if self.tabBar.selectedItem == self.ofertaItem || self.isVoucherSelected {
      if !(self.destinoCell.destinoText.text!.isEmpty){
        //self.crearSolicitud()
      } else {
        let alertaDos = UIAlertController (title: "Error en el formulario", message: "Por favor debe espeficicar su destino.", preferredStyle: UIAlertController.Style.alert)
        alertaDos.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alerAction in
          self.view.endEditing(true)
          self.destinoCell.destinoText.becomeFirstResponder()
        }))
        self.present(alertaDos, animated: true, completion: nil)
      }
    }
  }
}
