//
//  TerminosController.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 11/7/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit


class TerminosController: BaseController {
  
  @IBOutlet weak var topViewConstraint: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.topViewConstraint.constant = super.getTopMenuBottom()
  }
  
}
