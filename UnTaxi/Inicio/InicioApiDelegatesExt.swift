//
//  InicioApiDelegatesExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 10/9/22.
//  Copyright © 2022 Done Santana. All rights reserved.
//

import UIKit
import WebKit

extension InicioController: ApiServiceDelegate {
	func apiRequest(_ controller: ApiService, getAddressList data: [Address]) {
		self.searchAddressList = data
		DispatchQueue.main.async { [self] in
			self.sinResultadosLabel.isHidden = data.count > 0 || self.searchText.text!.isEmpty
		}
	}
}


extension InicioController: PagoApiServiceDelegate {
	func apiRequest(_ controller: PagoApiService, getCardsList data: [Card]) {
		if data.count > 0 {
			cardList = data
		} else {
			DispatchQueue.main.async {
				let alertaDos = UIAlertController (title: "No tiene Tarjetas Registradas", message: "Por favor debe registrar alguna tarjeta para el pago.", preferredStyle: UIAlertController.Style.alert)
				alertaDos.addAction(UIAlertAction(title: "Registrar", style: .default, handler: {alerAction in
					self.openRegisterCardView()
				}))
				alertaDos.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: {alerAction in
					self.tarjetasView.isHidden = true
					self.pagoCell.resetToEfectivo()
				}))
				self.present(alertaDos, animated: true, completion: nil)
			}
		}
		
	}
	
	func apiRequest(_ controller: PagoApiService, cardRemoved result: String?) {
		DispatchQueue.main.async {
			let alertaDos = UIAlertController (title: "Tarjeta Eliminada", message: "La tarjeta se eliminó correctamente", preferredStyle: UIAlertController.Style.alert)
			alertaDos.addAction(UIAlertAction(title: "Ok", style: .default, handler: {alerAction in
				self.pagoCell.resetToEfectivo()
			}))
			self.present(alertaDos, animated: true, completion: nil)
		}
	}
	
}

extension InicioController: WKNavigationDelegate {
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		waitingView.isHidden = true
	}
}
