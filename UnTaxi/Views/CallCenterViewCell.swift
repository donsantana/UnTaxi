//
//  CallCenterViewCell.swift
//  UnTaxi
//
//  Created by Done Santana on 4/3/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import UIKit

class CallCenterViewCell: UITableViewCell {
  var tieneWhatsapp = false
  
  @IBOutlet weak var ImagenOperadora: UIImageView!
  @IBOutlet weak var NumeroTelefono: UILabel!
  @IBOutlet weak var elementsView: UIView!
  @IBOutlet weak var whatsappBtn: UIButton!
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.elementsView.addShadow()
    //self.NumeroTelefono.textColor = CustomAppColor.textColor
    // Initialization code
  }
  
  func initContent(telefono: Telefono){
    self.whatsappBtn.isHidden = !telefono.tienewhatsapp
    self.ImagenOperadora.image = UIImage(named: telefono.operadora)
    self.NumeroTelefono.text = telefono.numero
  }
  
  func openWhatsApp(number : String){
    print(number)
    var phoneNumber:String = number
    if number.first == "0"{
      phoneNumber.removeFirst()
      phoneNumber = "+593\(phoneNumber)"
    }
    //let phoneNumber = number.first == "0" ? number.replacingOccurrences(of: "0", with: "+593") : number // you need to change this number
    let appURL = URL(string: "https://api.whatsapp.com/send?phone=\(phoneNumber)")!
    //let appURL = URL(string: "https://api.whatsapp.com/send?phone=+593991539359")!
    print(phoneNumber)
    if UIApplication.shared.canOpenURL(appURL) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
        }else {
            UIApplication.shared.openURL(appURL)
        }
    }
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  @IBAction func openWhatsapp(_ sender: Any) {
    self.openWhatsApp(number: self.NumeroTelefono.text!)
  }
  
}
