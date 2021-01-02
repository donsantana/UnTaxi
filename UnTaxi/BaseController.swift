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
      //self.topMenu.backgroundColor = Customization.primaryColor//UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
      self.topMenu.tintColor = Customization.textColor//.white
      self.topMenu.addShadow()
      
//      let baseTitle = UILabel()
//      baseTitle.frame = CGRect(x: screenBounds.width/2 - 100, y: 20, width: 220, height: 21)
//      baseTitle.font = UIFont(name: "HelveticaNeue-Bold", size: 25)
//      baseTitle.textColor = Customization.textColor//.white
//      baseTitle.text = self.barTitle
//      topMenu.addSubview(baseTitle)
      if !hideCloseBtn {
        let closeBtn = UIButton(type: UIButton.ButtonType.system)
        closeBtn.frame = CGRect(x: topMenu.frame.width - 60, y: 15, width: 45, height: 45)
        let closeImage = UIImage(named: "panicoBtn")?.withRenderingMode(.alwaysOriginal)
        closeBtn.setImage(closeImage, for: UIControl.State())
        closeBtn.addTarget(self, action: #selector(closeBtnAction), for: .touchUpInside)
        closeBtn.layer.cornerRadius = 20
        //closeBtn.backgroundColor = .white
        //closeBtn.tintColor = Customization.buttonsTitleColor
        closeBtn.addShadow()
        topMenu.addSubview(closeBtn)
      }
      
      let homeBtn = UIButton(type: UIButton.ButtonType.system)
      homeBtn.frame = CGRect(x: 10, y: 15, width: 45, height: 45)
      let homeImage = UIImage(named: hideMenuBtn ? "backIcon" : "menu")?.withRenderingMode(.alwaysTemplate)
      homeBtn.setImage(homeImage, for: UIControl.State())
      homeBtn.addTarget(self, action: #selector(homeBtnAction), for: .touchUpInside)
      homeBtn.tintColor = Customization.buttonActionColor
      homeBtn.layer.cornerRadius = homeBtn.frame.height/2
      homeBtn.backgroundColor = .white
      topMenu.addSubview(homeBtn)
      
      
      self.view.addSubview(topMenu)
    }
    
    
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
      let vc = R.storyboard.main.inicioView()
      self.navigationController?.show(vc!, sender: nil)
    }
  }
  
  func getTopMenuBottom() -> CGFloat{
    return (screenBounds.origin.y + 100)
  }
  
  func hideMenuBar(isHidden: Bool){
    self.topMenu.isHidden = isHidden
  }
}

