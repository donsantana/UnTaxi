//
//  BaseController.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 8/19/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import UIKit
import Rswift
import CoreLocation

class BaseController: UIViewController {
  var toolBar: UIToolbar = UIToolbar()
  var topMenu = UIView()
  var barTitle = Customization.nameShowed
  var hideTopMenu = false
  var hideMenuBtn = true
  var hideCloseBtn = true
  let screenBounds = UIScreen.main.bounds
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //TOP MENU
    if !self.hideTopMenu{
      self.topMenu.removeFromSuperview()
      self.topMenu = UIView()
      self.topMenu.layer.cornerRadius = 10
      self.topMenu.frame = CGRect(x: 15, y: screenBounds.origin.y + 30, width: screenBounds.width - 30, height: 60)
      //self.topMenu.backgroundColor = CustomAppColor.primaryColor//UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
      self.topMenu.tintColor = CustomAppColor.textColor//.white
      self.topMenu.addShadow()
      
      if !hideCloseBtn {
        let closeBtn = UIButton(type: UIButton.ButtonType.system)
        closeBtn.frame = CGRect(x: topMenu.frame.width - 60, y: 15, width: 45, height: 45)
        closeBtn.addTarget(self, action: #selector(closeBtnAction), for: .touchUpInside)
        closeBtn.addCustomMenuBtnsColors(image: (UIImage(named: "panicoBtn")?.withRenderingMode(.alwaysTemplate))!, tintColor: CustomAppColor.buttonActionColor, backgroundColor: nil)

        topMenu.addSubview(closeBtn)
      }
      
      let homeBtn = UIButton(type: UIButton.ButtonType.system)
      homeBtn.frame = CGRect(x: 10, y: 15, width: 45, height: 45)
      homeBtn.addCustomMenuBtnsColors(image: (UIImage(named: hideMenuBtn ? "backIcon" : "menu")?.withRenderingMode(.alwaysTemplate))!, tintColor: CustomAppColor.buttonActionColor, backgroundColor: nil)
      homeBtn.addTarget(self, action: #selector(homeBtnAction), for: .touchUpInside)
      topMenu.addSubview(homeBtn)
      
      self.view.addSubview(topMenu)
    }
    
  }
  
  func goToInicioView(){
    var inicioVC: [UIViewController] = []

    let viewcontrollers = self.navigationController?.viewControllers
    viewcontrollers?.forEach({ (vc) in
      if  let inventoryListVC = vc as? InicioController {
        //self.navigationController!.popToViewController(inventoryListVC, animated: true)
        inicioVC.append(inventoryListVC)
      }
    })
    
    if inicioVC.count != 0{
      print("Hay inicio")
      self.navigationController!.popToViewController(inicioVC.first!, animated: true)
    }else{
      print("No hay inicio")
      let vc = R.storyboard.main.inicioView()!
      self.navigationController?.show(vc, sender: self)
    }
    
//    let viewcontrollers = self.navigationController?.viewControllers
//    viewcontrollers?.forEach({ (vc) in
//      if  let inventoryListVC = vc as? InicioController {
//        self.navigationController!.popToViewController(inventoryListVC, animated: true)
//      }
//    })
  }
  
  //MENU BUTTONS FUNCTIONS
  @objc func closeBtnAction(){
    
    let fileAudio = FileManager()
    let AudioPath = NSHomeDirectory() + "/Library/Caches/Audio"
    do {
      try fileAudio.removeItem(atPath: AudioPath)
    }catch{
    }
    //let datos = "#SocketClose,\(String(describing: globalVariables.cliente.id)),# \n"
    let vc = R.storyboard.main.inicioView()
    vc!.socketService.socketEmit("SocketClose", datos: ["idcliente": globalVariables.cliente.id])
    exit(3)
    
  }
  
  @objc func homeBtnAction(){
    if hideMenuBtn{
      self.goToInicioView()
      //self.dismiss(animated: false, completion: nil)
      print("here back to inicio")
//      let vc = R.storyboard.main.inicioView()!
//      let navigationController = UINavigationController(rootViewController: vc)
//      self.present(navigationController, animated: false, completion: nil)
      //self.navigationController?.show(vc!, sender: nil)
    }
  }
  
  func getTopMenuBottom() -> CGFloat{
    return (screenBounds.origin.y + 100)
  }
  
  func getTopMenuCenter() -> CGFloat{
    return (screenBounds.origin.y + 70)
  }
  
  func hideMenuBar(isHidden: Bool){
    self.topMenu.isHidden = isHidden
  }
}

