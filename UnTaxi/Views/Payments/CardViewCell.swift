//
//  CardViewCell.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 6/29/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit

protocol CarViewCellDelegate: AnyObject {
	func cardViewCell(_ controller: CardViewCell, eliminarCard cardId: Int)
}

class CardViewCell: UITableViewCell {
  var pagoService = PagoApiService.shared
	weak var delegate: CarViewCellDelegate?
  var card: Card!
  
  @IBOutlet weak var elementsView: UIView!
  @IBOutlet weak var cardNumberText: UILabel!
  @IBOutlet weak var cardHolderText: UILabel!
	@IBOutlet weak var brandName: UILabel!
	
  func initContent(card: Card){
		self.elementsView.addShadow()
    self.card = card
		self.brandName.text = card.brand
    self.cardNumberText.text = "XXXX XXXX XXXX \(card.number)"
    self.cardHolderText.text = card.holder_name
  }
  
  @IBAction func removeCard(_ sender: Any) {
		self.delegate?.cardViewCell(self, eliminarCard: card.idtarjeta)
  }
  
}


