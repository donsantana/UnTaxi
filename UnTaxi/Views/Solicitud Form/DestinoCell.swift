//
//  DestinoCell.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/16/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit
import Mapbox

class DestinoCell: UITableViewCell {
  @IBOutlet weak var destinoText: UITextField!

	func initContent(destinoAnnotation: MGLPointAnnotation) {
		if destinoAnnotation.title != "" {
			self.destinoText.text = destinoAnnotation.title
		} else {
			self.destinoText.text?.removeAll()
		}
 
    self.destinoText.setBottomBorder(borderColor: CustomAppColor.bottomBorderColor)
  }

}
