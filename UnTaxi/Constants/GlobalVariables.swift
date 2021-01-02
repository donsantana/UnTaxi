//
//  globalVariables.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/4/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import UIKit
import SocketIO

struct globalVariables {
  static var socket: SocketIOClient!
  static var cliente : Cliente!
  static var tarifario: Tarifario!
  static var solicitudesproceso: Bool = false
  static var taximetroActive: Bool = false
  static var solpendientes: [Solicitud] = []
  static var ofertasList: [Oferta] = []
  static var grabando = false
  static var SMSProceso = false
  static var urlSubirVoz:String!
  static var SMSVoz = CSMSVoz()
  static var urlConductor = ""
  static var userDefaults: UserDefaults!
  static var TelefonosCallCenter: [Telefono] = []
  static var tipoSolicitud: Int = 0
  static var cardList:[Card] = []
  static var responsive = Responsive()
  static var appConfig = AppConfig()
  static var direccionesPactadas: [DireccionesPactadas] = []
  static var isBigIphone = UIScreen.main.bounds.height >= 750
  
}
