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
    //self.NumeroTelefono.textColor = Customization.textColor
    // Initialization code
  }
  
  func initContent(telefono: Telefono){
    self.whatsappBtn.isHidden = !telefono.tienewhatsapp
    self.ImagenOperadora.image = UIImage(named: telefono.operadora)
    self.NumeroTelefono.text = telefono.numero
  }
  
  func openWhatsApp(number : String){
    var fullMob = number
    fullMob = fullMob.replacingOccurrences(of: " ", with: "")
    fullMob = fullMob.replacingOccurrences(of: "+", with: "")
    fullMob = fullMob.replacingOccurrences(of: "-", with: "")
    let urlWhats = "whatsapp://send?phone=\(fullMob)"
    
    if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
      if let whatsappURL = NSURL(string: urlString) {
        if UIApplication.shared.canOpenURL(whatsappURL as URL) {
          UIApplication.shared.open(whatsappURL as URL, options: [:], completionHandler: { (Bool) in
          })
        }
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
