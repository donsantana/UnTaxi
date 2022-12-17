//
//  PagoController.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 10/16/22.
//  Copyright © 2022 Done Santana. All rights reserved.
//

import UIKit
import WebKit

protocol PagoControllerDelegate: AnyObject {
	func pagoConTarjeta(_ controller: PagoController, pagoSuccess: Bool)
}

class PagoController: UIViewController {
	var pagoApiService = PagoApiService.shared
	var socketService = SocketService.shared
	var solicitudPendiente: Solicitud?
	var isFromMenu = false
	weak var delegate: PagoControllerDelegate?
	var cardList:[Card] = []
	

	@IBOutlet weak var tarjetasTableView: UITableView!
	@IBOutlet weak var tarjetaWebView: WKWebView!
	@IBOutlet weak var headerTitle: UILabel!
	@IBOutlet weak var waitingView: UIVisualEffectView!
	
	override func viewDidLoad() {
		self.pagoApiService.delegate = self
		socketService.delegate = self
		tarjetasTableView.delegate = self
		tarjetaWebView.navigationDelegate = self
		waitingView.addStandardConfig()
		pagoApiService.listCardsAPIService()
		socketService.initPagoEvents()
		
		let addCardBtn = UIButton(type: UIButton.ButtonType.system)
		addCardBtn.frame = CGRect(x: 10, y: 15, width: 45, height: 45)
		addCardBtn.setTitle("Registrar Nueva Tarjeta", for: .normal)
		addCardBtn.addTarget(self, action: #selector(openRegisterCardView), for: .touchUpInside)
		tarjetasTableView.tableFooterView = addCardBtn
		
		tarjetasTableView.allowsSelection = solicitudPendiente != nil
		headerTitle.isHidden = !tarjetasTableView.allowsSelection
	}
	
	@IBAction func closeCardsView(_ sender: Any) {
		goToInicioView()
	}
}
