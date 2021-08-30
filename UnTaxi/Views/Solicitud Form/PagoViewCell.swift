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
}

class PagoViewCell: UITableViewCell {
  
  weak var delegate: PagoCellDelegate?
  
  @IBOutlet weak var referenciaText: UITextField!
  @IBOutlet weak var formaPagoSwitch: UISegmentedControl!
  @IBOutlet weak var formaPagoImg: UIImageView!
  @IBOutlet weak var yapaValue: UILabel!
  @IBOutlet weak var pagarYapaSwitch: UISwitch!
  @IBOutlet weak var formaPagoSwitchWidth: NSLayoutConstraint!
  @IBOutlet weak var efectivoText: UILabel!
  
  func initContent(isCorporativo: Bool){
    self.formaPagoSwitch.customColor()
    self.referenciaText.setBottomBorder(borderColor: CustomAppColor.bottomBorderColor)
    pagarYapaSwitch.isEnabled = globalVariables.cliente.yapa >= globalVariables.appConfig.uso_yapa
    self.pagarYapaSwitch.isOn = false
    if globalVariables.cliente.empresa != "" && isCorporativo{
      //self.formaPagoSwitch.insertSegment(withTitle: "Voucher", at: 2, animated: false)
      self.formaPagoSwitch.selectedSegmentIndex = 1
      self.formaPagoImg.image = UIImage(named: "voucherIcon")
      self.delegate?.voucherSwitch(self, voucherSelected: true)
    }
    //self.showHidePagoYapa(isHidden: self.formaPagoSwitch.selectedSegmentIndex == 1)
  }
  
  func updateVoucherOption(useVoucher: Bool){
    print("voucher \(useVoucher)")

    self.formaPagoSwitch.isHidden = !useVoucher || globalVariables.cliente.empresa == ""
    self.showHidePagoYapa(isHidden: !self.formaPagoSwitch.isHidden && self.formaPagoSwitch.selectedSegmentIndex == 1)
    self.formaPagoImg.image = UIImage(named: useVoucher && self.formaPagoSwitch.selectedSegmentIndex != 0 ? "voucherIcon" : "ofertaIcon")
    self.yapaValue.text = ("Pagar con Yapa,\r$\(String(format: "%.2f", globalVariables.cliente.yapa))")
    self.formaPagoSwitchWidth.constant = CGFloat(70 * self.formaPagoSwitch.numberOfSegments)
  }
  
  @IBAction func didChanged(_ sender: Any) {
    switch self.formaPagoSwitch.selectedSegmentIndex {
    case 0:
      formaPagoImg.image = UIImage(named: "ofertaIcon")
      self.showHidePagoYapa(isHidden: false)
      self.delegate?.voucherSwitch(self, voucherSelected: false)
    case 1:
      self.formaPagoImg.image = UIImage(named: "voucherIcon")
      self.showHidePagoYapa(isHidden: true)
      self.delegate?.voucherSwitch(self, voucherSelected: true)
    case 2:
      self.formaPagoImg.image = UIImage(named: "tarjetaIcon")
      self.delegate?.voucherSwitch(self, voucherSelected: false)
    default:
      break
    }
  }
  
  func showHidePagoYapa(isHidden: Bool){
    print("YAPA \(isHidden)")
    self.pagarYapaSwitch.isHidden = isHidden
    self.yapaValue.isHidden = isHidden
  }
}
