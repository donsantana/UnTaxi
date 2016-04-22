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
    var Botones: [UIButton]
    var PtoEvaluacion : Int
    
    init(botones: [UIButton]){
        self.Botones = botones
        self.PtoEvaluacion = 0
    }
    func EvaluarCarrera(posicion: Int){
        var i = 0
        while i < 5 {
            if i < posicion{
            self.Botones[i].setImage(UIImage(named: "stardorada"), forState: .Normal)
                
            }
            else{
                self.Botones[i].setImage(UIImage(named: "stargris"), forState: .Normal)
            }
            i++
        }
        self.PtoEvaluacion = posicion
    }
}