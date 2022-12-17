//
//  OfertaViewCell.swift
//  Conaitor
//
//  Created by Donelkys Santana on 12/4/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import UIKit
import CurrencyTextField


class OfertaDataViewCell: UITableViewCell {
  var valorOferta: Double = 0.0
	private var valorInicial: Double {
		globalVariables.tarifario.valorForDistance(distance: 0.0)
	}

  @IBOutlet weak var valorOfertaText: CurrencyTextField!

  func initContent(){
    valorOfertaText.setBottomBorder(borderColor: CustomAppColor.bottomBorderColor)
  }
	
	func resetValorOferta() {
		valorOfertaText.text = "$\(String(format: "%.2f", 0.0))"
	}
	
	func updateValorOfertaText() {
		valorOfertaText.text = "$\(String(format: "%.2f", valorOferta >= valorInicial ? valorOferta : valorInicial))"
	}
	
	func isValidOferta() -> Bool {
		return Double(valorOfertaText.text!.currencyString)! >= valorInicial && Double(valorOfertaText.text!.currencyString)! >= valorOferta.round(to: 2)
	}
	
	func getBestOferta() -> Double {
		return valorOferta >= valorInicial ? valorOferta : valorInicial
	}
}
 
