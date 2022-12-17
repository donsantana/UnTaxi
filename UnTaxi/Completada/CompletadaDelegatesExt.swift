//
//  CompletadaDelegatesExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 10/17/22.
//  Copyright © 2022 Done Santana. All rights reserved.
//

import UIKit

extension CompletadaController: PagoControllerDelegate {
	func pagoConTarjeta(_ controller: PagoController, pagoSuccess: Bool) {
		showPagoConTarjetaView(isHidden: pagoSuccess)
	}
}

extension CompletadaController: SocketServiceDelegate {
	func socketResponse(_ controller: SocketService, pagadaenefectivocliente result: [String : Any]) {
		let code = result["code"] as! Int
		let message = result["msg"] ?? ""
		
		let alertaDos = UIAlertController (title: nil, message: "\(message)", preferredStyle: .alert)
		alertaDos.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: { [self]alerAction in
			showPagoConTarjetaView(isHidden: code == 1)
		}))
		self.present(alertaDos, animated: true, completion: nil)
	}
}
