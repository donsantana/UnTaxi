//
//  Card.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 6/27/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import Foundation


//struct Card {
//  var carHolder,cardNumber,cvc, token: String
//  var expiryMonth,expiryYear: String
//  var status,type: String
//
//  init(carHolder: String, cardNumber: String, cvc: String, expiryMonth: String, expiryYear: String, status: String, type: String, token: String) {
//    self.carHolder = carHolder
//    self.cardNumber = cardNumber
//    self.cvc = cvc
//    self.expiryMonth = expiryMonth
//    self.expiryYear = expiryYear
//    self.status = "valid"
//    self.type = type
//    self.token = token
//  }
//
//  init(data: [String: Any]) {
//    self.carHolder = data["holder_name"] as! String
//    self.cardNumber = data["number"] as! String
//    self.cvc = "000"
//    self.expiryMonth = data["expiry_month"] as! String
//    self.expiryYear = data["expiry_year"] as! String
//    self.status = data["status"] as! String
//    self.type = data["type"] as! String
//    self.token = data["token"] as! String
//  }
//}

struct CardResponseData: Decodable, Identifiable {
	var id = UUID()
	var cards: [Card]
	var result_size: Int
	
	private enum CodingKeys: String, CodingKey{
		case cards
		case result_size
	}
}

struct Card: Decodable {
	var idtarjeta, idcliente, transactionid: Int
	var descripcion, token, number, bin, brand, type, holder_name, fecha, document, email, phonenumber, currency: String
	var aprobada: Bool
}
