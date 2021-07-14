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
      
//      let baseTitle = UILabel()
//      baseTitle.frame = CGRect(x: screenBounds.width/2 - 100, y: 20, width: 220, height: 21)
//      baseTitle.font = UIFont(name: "HelveticaNeue-Bold", size: 25)
//      baseTitle.textColor = CustomAppColor.textColor//.white
//      baseTitle.text = self.barTitle
//      topMenu.addSubview(baseTitle)
      if !hideCloseBtn {
        let closeBtn = UIButton(type: UIButton.ButtonType.system)
        closeBtn.frame = CGRect(x: topMenu.frame.width - 60, y: 15, width: 45, height: 45)
        let closeImage = UIImage(named: "panicoBtn")?.withRenderingMode(.alwaysOriginal)
        closeBtn.setImage(closeImage, for: UIControl.State())
        closeBtn.addTarget(self, action: #selector(closeBtnAction), for: .touchUpInside)
        closeBtn.layer.cornerRadius = closeBtn.frame.height/2
        //closeBtn.backgroundColor = .white
        //closeBtn.tintColor = CustomAppColor.buttonsTitleColor
        //closeBtn.addShadow()
        topMenu.addSubview(closeBtn)
      }
      
      if hideMenuBtn{
        let backBtn = UIButton(type: UIButton.ButtonType.system)
        backBtn.frame = CGRect(x: 10, y: 15, width: 45, height: 45)
        let backImage = UIImage(named: "backIcon")?.withRenderingMode(.alwaysTemplate)
        backBtn.setImage(backImage, for: UIControl.State())
        backBtn.addTarget(self, action: #selector(homeBtnAction), for: .touchUpInside)
        backBtn.tintColor = hideMenuBtn ? .black : CustomAppColor.buttonActionColor
        backBtn.layer.cornerRadius = backBtn.frame.height/2
        backBtn.backgroundColor = .white
        backBtn.addShadow()
        topMenu.addSubview(backBtn)
        topMenu.removeShadow()
      }else{
        let homeBtn = UIButton(type: UIButton.ButtonType.system)
        homeBtn.frame = CGRect(x: 10, y: 15, width: 45, height: 45)
        let homeImage = UIImage(named: hideMenuBtn ? "backIcon" : "menu")?.withRenderingMode(.alwaysTemplate)
        homeBtn.setImage(homeImage, for: UIControl.State())
        homeBtn.addTarget(self, action: #selector(homeBtnAction), for: .touchUpInside)
        homeBtn.tintColor = hideMenuBtn ? .black : CustomAppColor.buttonActionColor
        homeBtn.layer.cornerRadius = homeBtn.frame.height/2
        homeBtn.backgroundColor = .white
        topMenu.addSubview(homeBtn)
      }
      
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
  
  func hideMenuBar(isHidden: Bool){
    self.topMenu.isHidden = isHidden
  }
}

