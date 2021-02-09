//
//  UIViewController.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 11/24/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit
import SideMenu

internal extension UIViewController {
  
  func hideKeyboardAutomatically() {
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                             action: #selector(UIViewController.dismissKeyboard))
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
  }
  
  @objc func dismissKeyboard() {
    view.endEditing(true)
  }
  
  func addSideMenu()->SideMenuNavigationController{
    var sideMenu: SideMenuNavigationController!
    let viewController = storyboard?.instantiateViewController(withIdentifier: "MenuView")
    sideMenu = SideMenuNavigationController(rootViewController:viewController!)
    sideMenu.menuWidth = globalVariables.responsive.widthFloatPercent(percent: 80)
    sideMenu?.leftSide = true
     
    SideMenuManager.default.leftMenuNavigationController = sideMenu
    SideMenuManager.default.addPanGestureToPresent(toView: self.view)
    return sideMenu
  }
  
//  func mostrarAdvertenciaCancelacion(){
//    let alertaDos = UIAlertController (title: "Aviso Importante", message: "Estimado usuario, la cancelación frecuente del servicio puede ser motivo de un bloqueo temporal de la aplicación.", preferredStyle: .alert)
//    
//    let titleAttributes = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 20)!, NSAttributedString.Key.foregroundColor: UIColor.red]
//    let titleString = NSAttributedString(string: "Aviso Importante", attributes: titleAttributes)
//    alertaDos.setValue(titleString, forKey: "attributedTitle")
//    
//    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
//
//    }))
//    
//    self.present(alertaDos, animated: true, completion: nil)
//  }
  
//  func MostrarMotivosCancelacion(solicitud: Solicitud)->UIAlertController{
//    let motivoAlerta = UIAlertController(title: "¿Por qué cancela el viaje?", message: "", preferredStyle: UIAlertController.Style.actionSheet)
//    //    motivoAlerta.addAction(UIAlertAction(title: "No necesito", style: .default, handler: { action in
//    //      self.CancelarSolicitud("No necesito", solicitud: solicitud)
//    //    }))
//    motivoAlerta.addAction(UIAlertAction(title: "Mucho tiempo de espera", style: .default, handler: { action in
//      self.CancelarSolicitud("Mucho tiempo de espera", solicitud: solicitud)
//    }))
//    motivoAlerta.addAction(UIAlertAction(title: "El taxi no se mueve", style: .default, handler: { action in
//      self.CancelarSolicitud("El taxi no se mueve", solicitud: solicitud)
//    }))
//    motivoAlerta.addAction(UIAlertAction(title: "El conductor se fue a una dirección equivocada", style: .default, handler: { action in
//      self.CancelarSolicitud("El conductor se fue a una dirección equivocada", solicitud: solicitud)
//    }))
//    motivoAlerta.addAction(UIAlertAction(title: "Ubicación incorrecta", style: .default, handler: { action in
//      self.CancelarSolicitud("Ubicación incorrecta", solicitud: solicitud)
//    }))
//    motivoAlerta.addAction(UIAlertAction(title: "Otro", style: .default, handler: { action in
//      let ac = UIAlertController(title: "Entre el motivo", message: nil, preferredStyle: .alert)
//      ac.addTextField()
//
//      let submitAction = UIAlertAction(title: "Enviar", style: .default) { [unowned ac] _ in
//        if !ac.textFields![0].text!.isEmpty{
//          self.CancelarSolicitud(ac.textFields![0].text!, solicitud: solicitud)
//        }
//      }
//
//      ac.addAction(submitAction)
//
//      self.present(ac, animated: true)
//    }))
//    motivoAlerta.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { action in
//    }))
//
//    return motivoAlerta
//  }
  
}
internal extension UIViewController {
  func addContainer(container: UIViewController) {
    self.addChild(container)
    self.view.addSubview(container.view)
    container.didMove(toParent: self)
  }
  func removeContainer() {
    self.willMove(toParent: nil)
    self.removeFromParent()
    self.view.removeFromSuperview()
  }
}
