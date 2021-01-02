//
//  UILable.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 6/16/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit

extension UILabel {
  func addUnderline() {
    if let textString = self.text {
      let attributedString = NSMutableAttributedString(string: textString)
      attributedString.addAttribute(NSAttributedString.Key.underlineStyle,
                                    value: NSUnderlineStyle.single.rawValue,
                                    range: NSRange(location: 0, length: attributedString.length - 1))
      attributedText = attributedString
    }
  }
  
  func addBorder(color: UIColor){
    self.layer.cornerRadius = 10
    self.layer.borderWidth = 1
    self.layer.borderColor = color.cgColor
  }
  
  func normalTextBlueStyle(){
    self.font = CustomAppFont.normalFont
    self.textColor = Customization.customBlueColor
  }
  
  func titleBlueStyle(){
    self.font = CustomAppFont.titleFont
    self.textColor = Customization.customBlueColor
  }
  
  func subTitleBlueStyle(){
    self.font = CustomAppFont.subtitleFont
    self.textColor = Customization.customBlueColor
  }
  
  func bigTextBlueStyle(){
    self.font = CustomAppFont.bigFont
    self.textColor = Customization.customBlueColor
  }
  
  
}
