//
//  LoginControllerSocketExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/5/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation


extension LoginController: SocketServiceDelegate{
  func socketResponse(_ controller: SocketService, startEvent result: [String : Any]) {
    print("rwult \(result)")
    switch result["code"] as! Int{
    case 1:
      self.initClientData(datos: result["datos"] as! [String: Any])
    default:
      self.initConnectionError(message: result["msg"] as! String)
    }
  }
}

