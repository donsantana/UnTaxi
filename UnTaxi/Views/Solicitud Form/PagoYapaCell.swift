//
//  YapaCell.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 10/9/22.
//  Copyright © 2022 Done Santana. All rights reserved.
//

import UIKit

class PagoYapaCell: UITableViewCell {
	@IBOutlet weak var yapaValue: UILabel!
	@IBOutlet weak var pagarYapaSwitch: UISwitch!
	
	func initContent() {
		self.pagarYapaSwitch.isOn = false
		self.yapaValue.text = ("Pagar con Yapa,\r$\(String(format: "%.2f", globalVariables.cliente.yapa))")
		pagarYapaSwitch.isEnabled = globalVariables.cliente.yapa >= globalVariables.appConfig.uso_yapa || globalVariables.appConfig.cardpay
	}
}
