//
//  PanicoController.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 12/7/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit

class PanicoController: UIViewController {
  
  @IBOutlet weak var contentView: UIView!
  
  override func viewDidLoad() {
    self.contentView.addShadow()
  }
  
  @IBAction func closePanicoView(_ sender: Any) {
    self.removeContainer()
  }
  
  @IBAction func llamar911(_ sender: Any) {
    if let url = URL(string: "tel://911") {
      UIApplication.shared.open(url)
    }
    self.removeContainer()
  }
  
}
