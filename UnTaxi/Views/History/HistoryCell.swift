//
//  HistoryCell.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 11/3/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {
	
  @IBOutlet weak var dataView: UIView!
  @IBOutlet weak var fechaText: UILabel!
  @IBOutlet weak var origenText: UILabel!
  @IBOutlet weak var destinoText: UILabel!
  @IBOutlet weak var importeText: UILabel!
  @IBOutlet weak var statusText: UILabel!
  @IBOutlet weak var origenIcon: UIImageView!
	@IBOutlet weak var tipoPagoImg: UIImageView!
	
  func initContent(solicitud: SolicitudHistorial){
    
		var tipoPagoImageName: String {
			if solicitud.tarjeta {
				return "tarjetaIcon"
			} else if solicitud.tipoVoucher != "" {
				return "voucherIcon"
			} else {
				return "ofertaIcon"
			}
		}
		
		var tipoPagoName: String {
			if solicitud.tarjeta {
				return "Tarjeta"
			} else if solicitud.tipoVoucher != "" {
				return "Voucher"
			} else {
				return "Efectivo"
			}
		}
		
    self.dataView.addShadow()
    //UILabel.appearance().font = CustomAppFont.normalFont
    origenIcon.addCustomTintColor(customColor: CustomAppColor.buttonActionColor)
    self.fechaText.text = solicitud.fechaHora.dateTimeToShow()
    self.origenText.text = solicitud.dirOrigen
    self.destinoText.text = solicitud.dirDestino
    self.importeText.text = "$\(solicitud.importe), \(tipoPagoName)"
    self.statusText.text = solicitud.solicitudStado().uppercased()
		tipoPagoImg.image = UIImage(named: tipoPagoImageName)
  }

}
