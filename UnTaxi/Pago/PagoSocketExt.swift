//
//  PagoSocketExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 10/16/22.
//  Copyright © 2022 Done Santana. All rights reserved.
//

import UIKit

extension PagoController: SocketServiceDelegate {
	func socketResponse(_ controller: SocketService, cardAddedSucceed result: Bool) {
		
		let okAction = UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: { [self] alerAction in
			if result {
				tarjetaWebView.isHidden = true
				pagoApiService.listCardsAPIService()
				//tarjetasTableView.reloadData()
			} else {
				tarjetaWebView.isHidden = true
				removeContainer()
			}
		})
		Alert.showBasic(title: result ? "" : GlobalStrings.errorGenericoTitle, message: result ? GlobalStrings.cardRegisteredSuccess : GlobalStrings.cardRegisteredError, vc: self, withActions: [okAction])
	}
	
	func socketResponse(_ controller: SocketService, cardExist result: Bool) {
		let okAction = UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: { [self] alerAction in
			tarjetaWebView.isHidden = true
			removeContainer()
		})
		
		Alert.showBasic(title: GlobalStrings.errorGenericoTitle, message: GlobalStrings.cardRegisteredDuplicated, vc: self, withActions: [okAction])
	}
	
	func socketResponse(_ controller: SocketService, pagoConTarjeta result: [String : Any]) {
		let code = result["code"] as? Int
		let message = result["msg"] as? String
		
		let okAction = UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: { alerAction in
			self.delegate?.pagoConTarjeta(self, pagoSuccess: code == 1)
			self.removeContainer()
		})
		Alert.showBasic(title: code == 1 ? "" : GlobalStrings.errorGenericoTitle, message: message ?? GlobalStrings.errorGenericoMessage, vc: self, withActions: [okAction])
	}
}
