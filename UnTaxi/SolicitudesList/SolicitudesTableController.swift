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
    //self.navigationController?.navigationBar.tintColor = UIColor.black
    self.solicitudesMostrar = globalVariables.solpendientes
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    
    let view = UIView.init(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 60))
    let headerView = UIView()
    headerView.frame = CGRect(x: 15, y: 5, width: view.frame.width - 30, height: 50)
    headerView.layer.cornerRadius = 10
    headerView.addShadow()
    //headerView.backgroundColor = Customization.primaryColor//UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
    headerView.tintColor = Customization.textColor
    
    let sectionTitle: UILabel = UILabel.init(frame: CGRect(x: headerView.frame.width / 2 - 60, y: 15, width: self.tableView.frame.width/3, height: 20))
    sectionTitle.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
    sectionTitle.textAlignment = .center
    sectionTitle.textColor = Customization.textColor
    sectionTitle.text = "Solicitudes"
    
    
    let backBtn = UIButton()
    backBtn.frame = CGRect(x: 10, y: 10, width: 30, height: 30)
    backBtn.setTitleColor(Customization.textColor, for: .normal)
    //backBtn.setTitleColor(.black, for: .normal)
    //      backBtn.setTitle("<", for: .normal)
    //      backBtn.titleLabel?.font = UIFont(name: "Helvetica", size: 35.0)
    //nextBtn.addBorder()
    backBtn.setImage(UIImage(named: "backIcon")?.imageWithColor(color1: Customization.textColor), for: UIControl.State())
    backBtn.addTarget(self, action: #selector(backBtnAction), for: .touchUpInside)
    
    headerView.addSubview(sectionTitle)
    headerView.addSubview(backBtn)
    
    view.addSubview(headerView)
    self.tableView.tableHeaderView = view
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @objc func backBtnAction(){
    let vc = R.storyboard.main.inicioView()
    self.navigationController?.pushViewController(vc!, animated: true)
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
