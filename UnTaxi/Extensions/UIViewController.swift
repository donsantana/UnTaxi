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
