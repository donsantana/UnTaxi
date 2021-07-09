//
//  YapaPanelTableExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/24/21.
//  Copyright © 2021 Done Santana. All rights reserved.
//

import UIKit

extension YapaPanel: UITableViewDelegate, UITableViewDataSource{
  
  func numberOfSections(in tableView: UITableView) -> Int {
    // 1.
    // return the number of sections
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // 2.
    // return the number of rows
    return contactService.contacts.count
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath)
    // 3.
    // Configure the cell...
    cell.textLabel?.text = contactService.contacts[indexPath.row].fullName()
    cell.detailTextLabel?.text = contactService.contacts[indexPath.row].telephone
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {    
    self.movilNumberText.text = contactService.contacts[indexPath.row].telephone
    tableView.deselectRow(at: indexPath, animated: false)
    self.contactosView.isHidden = true
    self.isCliente()
  }

}
