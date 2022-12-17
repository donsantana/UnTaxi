//
//  PagoFunctionsExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 10/16/22.
//  Copyright © 2022 Done Santana. All rights reserved.
//

import UIKit


extension PagoController {
	@objc func openRegisterCardView() {
		let accessToken = globalVariables.userDefaults.value(forKey: "accessToken") as! String
		print("AddURL \(GlobalConstants.addCardsUrl)\(accessToken)")
		let url = URL(string: "\(GlobalConstants.addCardsUrl)\(accessToken)")
		let requestObj = URLRequest(url: url! as URL)
		tarjetaWebView.load(requestObj)
		tarjetaWebView.isHidden = false
		waitingView.isHidden = false
	}
	
	func cardListView(show: Bool) {
		tarjetasTableView.reloadData()
		let addCardBtn = UIButton(type: UIButton.ButtonType.system)
		addCardBtn.frame = CGRect(x: 10, y: 15, width: 45, height: 45)
		addCardBtn.setTitle("Registrar Nueva Tarjeta", for: .normal)
		addCardBtn.addTarget(self, action: #selector(openRegisterCardView), for: .touchUpInside)
		tarjetasTableView.tableFooterView = addCardBtn
	}
	
	func enviarPagoConTajeta(idSolicitud: String, tokenCard: String) {
		let accessToken = globalVariables.userDefaults.value(forKey: "accessToken") as! String
		let datos:[String: Any] = [
			"toke": tokenCard,
			"idsolicitud": idSolicitud,
			"idcliente": globalVariables.cliente.id
		]
		socketService.socketEmit("pagarcontarjeta", datos: datos)
	}
	
	func goToInicioView() {
		if solicitudPendiente != nil {
			self.removeContainer()
		} else {
			var inicioVC: [UIViewController] = []
			let viewcontrollers = self.navigationController?.viewControllers
			viewcontrollers?.forEach({ (vc) in
				if  let inventoryListVC = vc as? InicioController {
					inicioVC.append(inventoryListVC)
				}
			})
			
			if inicioVC.count != 0 {
				print("Hay inicio")
				self.navigationController?.popToViewController(inicioVC.first!, animated: false)
			} else {
				print("No hay inicio")
				let vc = R.storyboard.main.inicioView()!
				self.navigationController?.show(vc, sender: self)
			}
		}
	}
}
