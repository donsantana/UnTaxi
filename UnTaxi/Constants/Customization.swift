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
  static var usaVoucher: Bool = true
  static var motivosCancelacion = ["Mucho tiempo de espera","Me solicitó el conductor","El conductor no se comunica","Ubicación incorrecta","Ya no lo necesito","Solo probaba la aplición","otro"]
}

struct CustomAppColor {
  static var primaryColor: UIColor = .white //#1f1f1f
  static var secundaryColor: UIColor = UIColor(red: 255/255, green: 221/255, blue: 0/255, alpha: 1)
  static var viewBackgroundColor: UIColor = UIColor(red: 7/255, green: 9/255, blue: 24/255, alpha: 1)
  static var lightTextColor: UIColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
  static var textColor: UIColor = .black
  static var iconColor: UIColor = .lightGray
  static var buttonActionColor: UIColor = secundaryColor
  static var buttonsTitleColor: UIColor = .black//primaryColor
  static var menuBackgroundColor: UIColor = primaryColor
  static var menuTextColor = secundaryColor
  static var starColor = secundaryColor
  static var textFieldBackColor: UIColor = UIColor(red: 235/255, green: 238/255, blue: 245/255, alpha: 1)
  static var customBlueColor: UIColor = UIColor(red: 14/255, green: 37/255, blue: 92/255, alpha: 1)
  static var bottomBorderColor: UIColor = .lightGray
  static var tabItemBorderColor: UIColor = secundaryColor
  static var activityIndicatorColor = buttonActionColor
}

struct CustomAppFont {
  static var appFontFamily = "HelveticaNeue"
  static var appBoldFontFamily = "HelveticaNeue-Bold"
  static var appMediumFontFamily = "HelveticaNeue-Medium"
  static var bigFont = UIFont(name: appBoldFontFamily, size: globalVariables.responsive.heightFloatPercent(percent: 3.5))
  static var titleFont = UIFont(name: appBoldFontFamily, size: globalVariables.responsive.heightFloatPercent(percent: 2.2))
  static var inputTextFont = UIFont(name: appFontFamily, size: globalVariables.responsive.heightFloatPercent(percent: 1.7))
  static var subtitleFont = UIFont(name: appMediumFontFamily, size: globalVariables.responsive.heightFloatPercent(percent: 2.0))
  static var buttonActionFont = UIFont(name: appMediumFontFamily, size: globalVariables.responsive.heightFloatPercent(percent: 2.5))
  static var normalFont = UIFont(name: appFontFamily, size: globalVariables.responsive.heightFloatPercent(percent: 1.8))
  static var smallFont = UIFont(name: appFontFamily, size: globalVariables.responsive.heightFloatPercent(percent: 1.6))
}


