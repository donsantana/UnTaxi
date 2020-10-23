//
//  CardViewCell.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 6/29/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit

class CardViewCell: UITableViewCell {
  var paymentService = ApiService()
  var card: Card!
  
  @IBOutlet weak var elementsView: UIView!
  @IBOutlet weak var carImage: UIImageView!
  @IBOutlet weak var cardNumberText: UILabel!
  @IBOutlet weak var cardHolderText: UILabel!
  
  func initContent(card: Card){
    self.card = card
    self.carImage.image = UIImage(named: card.type) ?? UIImage(named: "card")
    self.cardNumberText.text = "XXXX XXXX XXXX \(card.cardNumber)"
    self.cardHolderText.text = card.carHolder
  }
  
  @IBAction func removeCard(_ sender: Any) {
    print("here removing card")
    self.paymentService.removeCardsAPIService(cardToken: self.card.token)
  }
  
}


