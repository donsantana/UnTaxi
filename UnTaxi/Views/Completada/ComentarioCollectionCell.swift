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
    
    func initContent() {
        comentarioText.layer.masksToBounds = true
        self.comentarioText.addBorder(color: CustomAppColor.buttonActionColor)
    }
    
    func updateCommentUI(isSelected: Bool) {
        comentarioText.backgroundColor = isSelected ? CustomAppColor.buttonActionColor : .white
        comentarioText.textColor =  isSelected ? CustomAppColor.buttonsTitleColor : CustomAppColor.textColor
        comentarioText.layer.cornerRadius = 10
        comentarioText.addBorder(color: CustomAppColor.buttonActionColor)
    }
    
    func apiRequest(_ controller: ComentarioCollectionDelegate, didHideUser userId: String){}
    
}
