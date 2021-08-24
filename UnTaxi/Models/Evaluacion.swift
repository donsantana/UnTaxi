//
//  CEvaluacion.swift
//  Xtaxi
//
//  Created by usuario on 5/4/16.
//  Copyright © 2016 Done Santana. All rights reserved.
//

import Foundation
import UIKit

class CEvaluacion {
  var botones: [UIButton]
  var ptoEvaluacion : Int
  var title: [String] = ["Terrible","Mal servicio","Servicio medio","Buen servicio","Excelente"]
  var subtitle: [String] = ["¿Qué ocurrió?","¿Qué no estuvo bien?","¿Qué mejorarías?","¿Qué mejorarías?","¿Qué estuvo bien?"]
  var comentariosOptions: [[String]] = [["Otro auto","Vehículo mal estado","No llegó","Conducción","Modales"],
                                    ["Otro auto","Vehículo mal estado","No llegó","Conducción","Modales"],
                                    ["Amabilidad","Modales","Vehículo","Conducción","Recogida"],
                                    ["Amabilidad","Ubicación","Vehículo","Conducción","Recogida"],
                                    ["Comodidad","Buena conversación","Buena música","Ruta rápida","Llegó rápido"]]
  
  init(botones: [UIButton]){
    self.botones = botones
    self.ptoEvaluacion = 1
    var i = 0
    while i < 5 {
      self.botones[i].setImage(UIImage(named: "stargris"), for: UIControl.State())
      i += 1
    }
    
  }
  func EvaluarCarrera(_ posicion: Int){
    var i = 0
    while i < 5 {
      if i < posicion{
        self.botones[i].setImage(UIImage(named: "stardorada")?.withRenderingMode(.alwaysTemplate), for: UIControl.State())
        self.botones[i].tintColor = CustomAppColor.starColor
      }
      else{
        self.botones[i].setImage(UIImage(named: "stargris"), for: UIControl.State())
      }
      i += 1
    }
    self.ptoEvaluacion = posicion
  }
  
  func getTitle() -> String {
    return title[ptoEvaluacion - 1]
  }
  
  func getSubtilte() -> String{
    return subtitle[ptoEvaluacion - 1]
  }
  
  func getComentariosOptions()->[String]{
    return comentariosOptions[ptoEvaluacion - 1]
  }
  
}
