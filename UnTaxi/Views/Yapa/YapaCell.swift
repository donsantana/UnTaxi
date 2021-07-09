//
//  YapaCell.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/23/21.
//  Copyright © 2021 Done Santana. All rights reserved.
//

import UIKit

class YapaCell: UITableViewCell {

  @IBOutlet weak var iconImag: UIImageView!
  @IBOutlet weak var titleText: UILabel!
  @IBOutlet weak var subtitleText: UILabel!
  
  func initContent(yapaMenu: YapaMenu){
    self.iconImag.image = yapaMenu.icon
    self.titleText.text = yapaMenu.title
    self.subtitleText.text = yapaMenu.subtitle
  }
  
}
