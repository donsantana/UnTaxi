//
//  UITextfield.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/4/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import Foundation
import UIKit

enum TextFieldDataType {
  case movilNomber, password, email
}

extension UITextField {
  func setBottomBorder(borderColor: UIColor) {
    self.layer.masksToBounds = true
    var bottomLine = CALayer()
    bottomLine.frame = CGRect(x: 0.0, y: self.frame.height - 1, width: self.layer.bounds.size.width , height: 1.0)
    bottomLine.backgroundColor = borderColor.cgColor
    self.borderStyle = UITextField.BorderStyle.none
    self.layer.addSublayer(bottomLine)
  }
  enum PaddingSide {
    case left(CGFloat)
    case right(CGFloat)
    case both(CGFloat)
  }
  
  func addPadding(_ padding: PaddingSide) {
    
    self.leftViewMode = .always
    self.layer.masksToBounds = true
    
    switch padding {
      
    case .left(let spacing):
      let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
      self.leftView = paddingView
      self.rightViewMode = .always
      
    case .right(let spacing):
      let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
      self.rightView = paddingView
      self.rightViewMode = .always
      
    case .both(let spacing):
      let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
      // left
      self.leftView = paddingView
      self.leftViewMode = .always
      // right
      self.rightView = paddingView
      self.rightViewMode = .always
    }
  }
  
  func addBorder(color: UIColor){
    self.layer.cornerRadius = 10
    self.layer.borderWidth = 1
    self.layer.borderColor = color.cgColor
  }
  
  func validate(_ type: TextFieldDataType) -> (Bool, String?) {
      guard let text = self.text else {
          return (false, nil)
      }

    switch type {
    case .movilNomber:
      return (text.count == 10 && text.isValidPhoneString, "Número de teléfono incorrecto. Por favor verifíquelo")
    case .password:
      return (true, "Las claves no coinciden")
    case .email:
      let emailPattern = #"^\S+@\S+\.\S+$"#
      let result = text.range(
          of: emailPattern,
          options: .regularExpression
      )
      return (result != nil, "Por favor teclee un correo electrónico válido.")
    default:
      return (text.count > 0, "This field cannot be empty.")
    }

      return (text.count > 0, "This field cannot be empty.")
  }
}
