//
//  globalVariables.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/4/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import Foundation
import SocketIO

struct globalVariables {
  static var socket: SocketIOClient!
  static var cliente : Cliente!
  static var solicitudesproceso: Bool = false
  static var taximetroActive: Bool = false
  static var solpendientes: [Solicitud] = []
  static var ofertasList: [Oferta] = []
  static var grabando = false
  static var SMSProceso = false
  static var UrlSubirVoz:String!
  static var SMSVoz = CSMSVoz()
  static var urlconductor = ""
  static var userDefaults: UserDefaults!
  static var TelefonosCallCenter: [Telefono] = []
  static var tipoSolicitud: Int = 0
}
