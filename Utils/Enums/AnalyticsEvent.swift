//
//  AnalyticsEvent.swift
//  UnTaxi
//
//  Created by Done Santana on 9/9/24.
//  Copyright © 2024 Done Santana. All rights reserved.
//

import Foundation

enum AnalyticsEvent {
    case login
    case register
    case recoverPassword
    case servicioOferta
    case servicioTaximetro
    case servicioPorhoras
    case servicioPactadas
    case otraPersonaSelected
    case otraPersonaFilled
    case pagoYapa
    case showMenu
    case callCenter
    case callCenterUsed
    
    var name: String {
        switch self {
        case .login:
            return "login"
        case .register:
            return "register"
        case .recoverPassword:
            return "register_password"
        case .servicioOferta:
            return "servicio_oferta"
        case .servicioTaximetro:
            return "servicio_taximetro"
        case .servicioPorhoras:
            return "servicio_porhoras"
        case .servicioPactadas:
            return "servicio_pactadas"
        case .otraPersonaSelected:
            return "otra_persona_selected"
        case .otraPersonaFilled:
            return "otra_persona_filled"
        case .pagoYapa:
            return "pago_yapa"
        case .showMenu:
            return "show_menu"
        case .callCenter:
            return "call_center"
        case .callCenterUsed:
            return "call_center_used"
        }
    }
}
