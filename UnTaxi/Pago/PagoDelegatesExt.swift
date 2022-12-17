//
//  PagoDelegatesExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 10/16/22.
//  Copyright © 2022 Done Santana. All rights reserved.
//

import UIKit
import WebKit


extension PagoController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return cardList.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = Bundle.main.loadNibNamed("CardRow", owner: self, options: nil)?.first as! CardViewCell
		cell.initContent(card: cardList[indexPath.row])
		cell.delegate = self
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: false)
		let cardSelected = cardList[indexPath.row]
		let datos: [String: Any] = [
			"token": cardSelected.token,
			"idsolicitud": solicitudPendiente?.id,
			"idcliente": globalVariables.cliente.id
		]
		socketService.socketEmit("pagarcontarjeta", datos: datos)
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 110
	}
}

extension PagoController: PagoApiServiceDelegate {
	func apiRequest(_ controller: PagoApiService, cardRemoved result: Int?) {
		let okAction = UIAlertAction(title: "Ok", style: .default, handler: {alerAction in
			self.goToInicioView()
		 })
		
		Alert.showBasic(title: GlobalStrings.tarjetaEliminadaTitle, message: GlobalStrings.tarjetaEliminadaSucess, vc: self, withActions: [okAction])
	}
	
	func apiRequest(_ controller: PagoApiService, getAPIError msg: String) {
		
	}
	
	func apiRequest(_ controller: PagoApiService, getCardsList data: [Card]) {
		if data.count > 0 {
			cardList = data
			DispatchQueue.main.async {
				self.tarjetasTableView.reloadData()
			}
		} else {
			cardList = []
			let registrarAction = UIAlertAction(title: "Registrar", style: .default, handler: {alerAction in
				self.waitingView.isHidden = false
				self.openRegisterCardView()
			})
			let cancelarAction = UIAlertAction(title: "Cancelar", style: .default, handler: {alerAction in
				self.goToInicioView()
			})
			
			Alert.showBasic(title: GlobalStrings.noCardsTiTle, message: GlobalStrings.noCardsMessage, vc: self, withActions: [registrarAction, cancelarAction])
		}
		
	}
}

extension PagoController: CarViewCellDelegate {
	func cardViewCell(_ controller: CardViewCell, eliminarCard cardId: Int) {
		let elinimarAction = UIAlertAction(title: "Eliminar", style: .destructive, handler: {alerAction in
			self.pagoApiService.removeCardsAPIService(cardId: cardId)
		})
		
		let cancelAction = UIAlertAction(title: "Cancelar", style: .default, handler: {alerAction in
			
		})
		
		Alert.showBasic(title: GlobalStrings.eliminarTarjetaTitle, message: GlobalStrings.eliminarTarjetaMessage, vc: self, withActions: [elinimarAction, cancelAction])
	}
}

extension PagoController: WKNavigationDelegate {
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		waitingView.isHidden = true
	}
}
