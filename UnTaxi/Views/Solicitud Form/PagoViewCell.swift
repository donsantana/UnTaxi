//
//  PagoViewCell.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/28/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import UIKit

protocol PagoCellDelegate: AnyObject {
  func voucherSwitch(_ controller: PagoViewCell, voucherSelected isSelected: Bool)
    func formaPagoSwitched(_ controller: PagoViewCell, pagoSelected selected: String)
}

class PagoViewCell: UITableViewCell {
  
  weak var delegate: PagoCellDelegate?
	var formaPagoSelected = "Efectivo"
  
  @IBOutlet weak var referenciaText: UITextField!
  @IBOutlet weak var formaPagoSwitch: UISegmentedControl!
  @IBOutlet weak var formaPagoImg: UIImageView!
  @IBOutlet weak var formaPagoSwitchWidth: NSLayoutConstraint!
  @IBOutlet weak var efectivoText: UILabel!
  
  func initContent(tipoServicio: Int) {
    self.formaPagoSwitch.customColor()
    self.referenciaText.setBottomBorder(borderColor: CustomAppColor.bottomBorderColor)

		formaPagoSwitch.removeAllSegments()
		formaPagoSwitch.insertSegment(withTitle: "Efectivo", at: 0, animated: false)
		self.formaPagoSwitch.selectedSegmentIndex = 0
		
		if globalVariables.cliente.idEmpresa != 0 && tipoServicio != 1 {
			self.formaPagoImg.image = UIImage(named: "voucherIcon")
			self.formaPagoSwitch.insertSegment(withTitle: "Voucher", at: formaPagoSwitch.numberOfSegments, animated: false)
            self.formaPagoSwitch.selectedSegmentIndex = 1
            self.formaPagoSelected = "Voucher"
            self.delegate?.voucherSwitch(self, voucherSelected: true)
		}
		
		if globalVariables.appConfig.cardpay && tipoServicio == 2 {
			self.formaPagoSwitch.insertSegment(withTitle: "Tarjeta", at: formaPagoSwitch.numberOfSegments, animated: false)
		}
		self.formaPagoSwitchWidth.constant = CGFloat(70 * self.formaPagoSwitch.numberOfSegments)
		
		self.formaPagoSwitch.isHidden = formaPagoSwitch.numberOfSegments == 1
  }
  
  func updateVoucherOption() {
		switch formaPagoSelected {
		case "Efectivo":
			formaPagoImg.image = UIImage(named: "ofertaIcon")
			self.formaPagoSwitch.selectedSegmentIndex = 0
		case "Voucher":
			formaPagoImg.image = UIImage(named: "voucherIcon")
			self.formaPagoSwitch.selectedSegmentIndex = 1
		case "Tarjeta":
			formaPagoImg.image = UIImage(named: "tarjetaIcon")
			self.formaPagoSwitch.selectedSegmentIndex = formaPagoSwitch.numberOfSegments - 1
		default:
			break
		}
  }
	
	func resetToEfectivo() {
		formaPagoSelected = "Efectivo"
		formaPagoSwitch.selectedSegmentIndex = 0
		self.delegate?.voucherSwitch(self, voucherSelected: formaPagoSelected != "Efectivo")
	}
  
  @IBAction func didChanged(_ sender: Any) {
		formaPagoSelected = formaPagoSwitch.titleForSegment(at: formaPagoSwitch.selectedSegmentIndex) ?? "Efectivo"
		self.delegate?.voucherSwitch(self, voucherSelected: formaPagoSelected == "Voucher")
      self.delegate?.formaPagoSwitched(self, pagoSelected: formaPagoSelected)
  }
}

extension PagoViewCell {
    func formaPagoSwitched(_ controller: PagoViewCell, pagoSelected selected: String) {}
    func voucherSwitch(_ controller: PagoViewCell, voucherSelected isSelected: Bool) {}
}
