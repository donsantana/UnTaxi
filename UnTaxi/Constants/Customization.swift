//
//  Customization.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/4/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import Foundation
import UIKit

struct Customization {
  static var serverData: String!
  static var appName: String!
  static var nameShowed: String = "UnTaxi"
  static var logo: UIImage!
  static var primaryColor: UIColor = UIColor(red: 255/255, green: 221/255, blue: 0/255, alpha: 1) //#1f1f1f
  static var lightTextColor: UIColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
  static var textColor: UIColor = UIColor.darkGray
  static var iconColor: UIColor = UIColor.lightGray
  static var buttonActionColor: UIColor = UIColor(red: 252/255, green: 208/255, blue: 23/255, alpha: 1)
  static var textFieldBackColor: UIColor = UIColor(red: 235/255, green: 238/255, blue: 245/255, alpha: 1)
  static var customBlueColor: UIColor = UIColor(red: 14/255, green: 37/255, blue: 92/255, alpha: 1)
  static var bottomBorderColor: UIColor = .lightGray
  static var usaVoucher: Bool = true
  static var buttonsTitleColor = UIColor.black
}

struct CustomAppFont {
  static var appFontFamily = "Muli"
  static var appBoldFontFamily = "Muli-Bold"
  static var appMediumFontFamily = "Muli-MemiBold"
  static var bigFont = UIFont(name: appBoldFontFamily, size: globalVariables.responsive.heightFloatPercent(percent: 3.5))
  static var titleFont = UIFont(name: appBoldFontFamily, size: globalVariables.responsive.heightFloatPercent(percent: 2.2))
  static var inputTextFont = UIFont(name: appFontFamily, size: globalVariables.responsive.heightFloatPercent(percent: 1.7))
  static var subtitleFont = UIFont(name: appMediumFontFamily, size: globalVariables.responsive.heightFloatPercent(percent: 2.0))
  static var buttonFont = UIFont(name: appMediumFontFamily, size: globalVariables.responsive.heightFloatPercent(percent: 2.0))
  static var normalFont = UIFont(name: appFontFamily, size: globalVariables.responsive.heightFloatPercent(percent: 1.8))
  static var smallFont = UIFont(name: appFontFamily, size: globalVariables.responsive.heightFloatPercent(percent: 1.6))
}


