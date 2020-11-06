//
//  UIVisualEffectView.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 11/5/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit

extension UIVisualEffectView{
  func standardConfig(){
    let blur = UIBlurEffect(style: .light)
    self.effect = blur
    self.alpha = 0.7
  }
}
