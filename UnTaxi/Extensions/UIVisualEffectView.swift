//
//  UIVisualEffectView.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 11/5/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit

extension UIVisualEffectView{
  func addStandardConfig(){
    let blur = UIBlurEffect(style: .dark)
    self.effect = blur
    self.alpha = 0.8
  }
}
