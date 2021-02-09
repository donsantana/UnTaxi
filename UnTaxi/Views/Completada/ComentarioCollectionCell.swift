//
//  ComentarioCollectionCell.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 1/6/21.
//  Copyright © 2021 Done Santana. All rights reserved.
//

import UIKit

protocol ComentarioCollectionDelegate: class {
  func apiRequest(_ controller: ComentarioCollectionCell, didHideUser userId: String)
}

class ComentarioCollectionCell: UICollectionViewCell, UIGestureRecognizerDelegate{
  weak var delegate: ComentarioCollectionDelegate?
  var pan: UIPanGestureRecognizer!
  
  @IBOutlet weak var comentarioText: UILabel!
  
  func initContent(){
    self.comentarioText.addBorder(color: Customization.buttonActionColor)
  }
  
  func apiRequest(_ controller: ComentarioCollectionDelegate, didHideUser userId: String){}
  
}
