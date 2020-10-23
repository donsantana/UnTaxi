//
//  ChangePasswordView.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 10/22/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit

class PassController: BaseController {
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    self.tableView.delegate = self
    super.viewDidLoad()
  }
  
  
}

extension PassController: UITableViewDelegate, UITableViewDataSource{
  func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return 1
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = Bundle.main.loadNibNamed("Perfil3ViewCell", owner: self, options: nil)?.first as! Perfil3ViewCell
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 210
  }
}
