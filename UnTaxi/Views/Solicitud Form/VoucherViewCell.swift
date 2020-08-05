//
//  VoucherViewCell.swift
//  MovilClub
//
//  Created by Donelkys Santana on 5/28/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import UIKit

protocol VoucherCellDelegate: class {
  func voucherSwitch(_ controller: VoucherViewCell, voucherSelected isSelected: Bool)
}

class VoucherViewCell: UITableViewCell {
  
  weak var delegate: VoucherCellDelegate?
  
  @IBOutlet weak var formaPagoSwitch: UISegmentedControl!
  @IBOutlet weak var formaPagoImg: UIImageView!
  
  func initContent(isCorporativo: Bool){
    self.formaPagoSwitch.tintColor = .gray
    if isCorporativo && self.formaPagoSwitch.numberOfSegments == 2{
      //self.formaPagoSwitch.insertSegment(withTitle: "Voucher", at: 2, animated: false)
      self.formaPagoSwitch.selectedSegmentIndex = 1
      self.formaPagoImg.image = UIImage(named: "voucher")
      self.delegate?.voucherSwitch(self, voucherSelected: true)
    }
  }
  
  @IBAction func didChanged(_ sender: Any) {
    switch self.formaPagoSwitch.selectedSegmentIndex {
    case 0:
      formaPagoImg.image = UIImage(named: "bill")
      self.delegate?.voucherSwitch(self, voucherSelected: false)
    case 1:
      self.formaPagoImg.image = UIImage(named: "voucher")
      self.delegate?.voucherSwitch(self, voucherSelected: true)
//      
//    case 2:
//      self.formaPagoImg.image = UIImage(named: "card")
//      self.delegate?.voucherSwitch(self, voucherSelected: false)
    default:
      break
    }
  }
}

extension VoucherViewCell{
  func voucherSwitch(_ controller: VoucherViewCell, voucherSelected isSelected: Bool){}
}

