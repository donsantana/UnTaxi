//
//  SolicitudesTableController.swift
//  UnTaxi
//
//  Created by Done Santana on 4/3/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import UIKit

class SolicitudesTableController: UITableViewController {
  
  var solicitudesMostrar = [Solicitud]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.navigationBar.tintColor = UIColor.black
    self.solicitudesMostrar = globalVariables.solpendientes
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return self.solicitudesMostrar.count
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    //let cell = tableView.dequeueReusableCell(withIdentifier: "Solicitudes", for: indexPath)
    let cell = Bundle.main.loadNibNamed("SolPendientesCell", owner: self, options: nil)?.first as! SolPendientesViewCell
    cell.initContent(solicitud: self.solicitudesMostrar[indexPath.row])
    //cell.textLabel?.text = self.solicitudesMostrar[indexPath.row].fechaHora
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let vc = R.storyboard.main.solDetalles()
    //vc.solicitudPendiente = self.solicitudesMostrar[indexPath.row]
    vc!.solicitudIndex = indexPath.row
    self.navigationController?.show(vc!, sender: nil)
  }
}
