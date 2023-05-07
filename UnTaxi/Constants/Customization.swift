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
    static var appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
    static var nameShowed: String = appName
    static var logo: UIImage!
    static var usaVoucher: Bool = true
    static var motivosCancelacion = ["Mucho tiempo de espera","Me solicitó el conductor","El conductor no se comunica","Ubicación incorrecta","Ya no lo necesito","Solo probaba la aplición","otro"]
}

struct CustomAppColor {
    static let bundleId: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as! String
    
    static var primaryColor: UIColor {
        switch bundleId {
        case "com.donelkys.Conaitor":
          return UIColor(red: 7/255, green: 9/255, blue: 24/255, alpha: 1)
        default:
          return .white
        }
    }
    static var secundaryColor: UIColor {
        switch bundleId{
        case "com.xoait.condorcar":
          return UIColor(red: 26/255, green: 155/255, blue: 162/255, alpha: 1)
        case "com.xoait.logisticfastcar":
          return UIColor(red: 0/255, green: 0/255, blue: 2/255, alpha: 1)
        case "com.donelkys.VipCar":
          return UIColor(red: 60/255, green: 97/255, blue: 167/255, alpha: 1)
        case "com.donelkys.AndyTaxi":
          return UIColor(red: 47/255, green: 47/255, blue: 47/255, alpha: 1)
        case "com.xoait.Jipicar":
          return UIColor(red: 8/255, green: 138/255, blue: 48/255, alpha: 1)
        case "com.xoait.Jipitaxi":
          return UIColor(red: 47/255, green: 47/255, blue: 47/255, alpha: 1)
        case "com.xoait.OrientExpress":
          return UIColor(red: 3/255, green: 40/255, blue: 85/255, alpha: 1)
        case "com.donelkys.Conaitor":
          return UIColor(red: 255/255, green: 175/255, blue: 0/255, alpha: 1)
        case "com.xoait.llamadafacil":
          return UIColor(red: 94/255, green: 168/255, blue: 11/255, alpha: 1)
            case "com.xoait.ellasdrive":
                return UIColor(red: 97/255, green: 36/255, blue: 139/255, alpha: 1)
            case "com.xoait.9deabril":
                return UIColor(red: 247/255, green: 221/255, blue: 14/255, alpha: 1)
            case "com.xoait.taxisgap":
                return UIColor(red: 239/255, green: 191/255, blue: 45/255, alpha: 1)
        default:
          return UIColor(red: 30/255, green: 9/255, blue: 64/255, alpha: 1)
        }
    }//= UIColor(red: 255/255, green: 221/255, blue: 0/255, alpha: 1)
    static var viewBackgroundColor: UIColor = UIColor(red: 7/255, green: 9/255, blue: 24/255, alpha: 1)
    static var lightTextColor: UIColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
    static var textColor: UIColor = .black
    static var iconColor: UIColor = .lightGray
    static var buttonActionColor: UIColor {
        switch bundleId{
        case "com.donelkys.Conaitor":
          return primaryColor
        default:
          return secundaryColor
        }
    }
    static var buttonsTitleColor: UIColor {
        switch bundleId{
        case "com.donelkys.Conaitor":
          return secundaryColor
            case "com.xoait.9deabril":
                return .black
            case "com.xoait.taxisgap":
                return .black
        default:
          return primaryColor
        }
    }
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


