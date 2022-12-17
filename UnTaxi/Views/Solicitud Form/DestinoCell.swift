//
//  DestinoCell.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/16/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit
import MapboxMaps

class DestinoCell: UITableViewCell {
  @IBOutlet weak var destinoText: UITextField!

	func initContent(destinoAnnotation: MyMapAnnotation) {
		if destinoAnnotation.annotation.image?.name != "" {
			self.destinoText.text = destinoAnnotation.address
		} else {
			self.destinoText.text?.removeAll()
		}
 
    self.destinoText.setBottomBorder(borderColor: CustomAppColor.bottomBorderColor)
  }

}
