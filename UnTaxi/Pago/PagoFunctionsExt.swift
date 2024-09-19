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
        guard let url = URL(string: "\(GlobalConstants.addCardsUrl)\(accessToken)") else {
            return
        }
		let requestObj = URLRequest(url: url)
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
		//let accessToken = globalVariables.userDefaults.value(forKey: "accessToken") as! String
		let datos:[String: Any] = [
			"toke": tokenCard,
			"idsolicitud": idSolicitud,
            "idcliente": globalVariables.cliente.id as Any
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
                guard let inicioController = inicioVC.first else {
                    return
                }
				self.navigationController?.popToViewController(inicioController, animated: false)
			} else {
				print("No hay inicio")
                guard let vc = R.storyboard.main.inicioView() else {
                    return
                }
				self.navigationController?.show(vc, sender: self)
			}
		}
	}
    
    func listCardAPIService() {
        PagoApiService.shared.listCardsAPIService(completion: { result in
            switch result {
            case .success(let cardList):
                self.cardList = cardList
                DispatchQueue.main.async {
                    self.tarjetasTableView.reloadData()
                }
            case .failure(let _):
                self.cardList = []
                let registrarAction = UIAlertAction(title: "Registrar", style: .default, handler: {alerAction in
                    self.waitingView.isHidden = false
                    self.openRegisterCardView()
                })
                let cancelarAction = UIAlertAction(title: "Cancelar", style: .default, handler: {alerAction in
                    self.goToInicioView()
                })
                
                Alert.showBasic(title: GlobalStrings.noCardsTiTle, message: GlobalStrings.noCardsMessage, vc: self, withActions: [registrarAction, cancelarAction])
            }
        })
    }
    
    func removeCard(cardId: Int) {
        PagoApiService.shared.removeCardsAPIService(cardId: cardId, completion: { result in
            var message: String
            switch result {
            case .success(let _):
                message = GlobalStrings.tarjetaEliminadaSucess
            case .failure(let error):
                message = error.localizedDescription
            }
            
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: {alerAction in
                self.goToInicioView()
             })
            
            Alert.showBasic(title: GlobalStrings.tarjetaEliminadaTitle, message: message, vc: self, withActions: [okAction])
        })
    }
}
