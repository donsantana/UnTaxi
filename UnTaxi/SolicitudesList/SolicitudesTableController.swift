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
    //sectionTitle.text = "Solicitudes"
    
    
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
  
  func mostrarMotivosCancelacion(solicitud: Solicitud){
    let motivoAlerta = UIAlertController(title: "¿Por qué cancela el viaje?", message: "", preferredStyle: UIAlertController.Style.actionSheet)
//    motivoAlerta.addAction(UIAlertAction(title: "No necesito", style: .default, handler: { action in
//      self.CancelarSolicitud("No necesito", solicitud: solicitud)
//    }))
    motivoAlerta.addAction(UIAlertAction(title: "Mucho tiempo de espera", style: .default, handler: { action in
      self.CancelarSolicitud("Mucho tiempo de espera", solicitud: solicitud)
    }))
    motivoAlerta.addAction(UIAlertAction(title: "El taxi no se mueve", style: .default, handler: { action in
      self.CancelarSolicitud("El taxi no se mueve", solicitud: solicitud)
    }))
    motivoAlerta.addAction(UIAlertAction(title: "El conductor se fue a una dirección equivocada", style: .default, handler: { action in
      self.CancelarSolicitud("El conductor se fue a una dirección equivocada", solicitud: solicitud)
    }))
    motivoAlerta.addAction(UIAlertAction(title: "Ubicación incorrecta", style: .default, handler: { action in
      self.CancelarSolicitud("Ubicación incorrecta", solicitud: solicitud)
    }))
    motivoAlerta.addAction(UIAlertAction(title: "Otro", style: .default, handler: { action in
      let ac = UIAlertController(title: "Entre el motivo", message: nil, preferredStyle: .alert)
      ac.addTextField()
      
      let submitAction = UIAlertAction(title: "Enviar", style: .default) { [unowned ac] _ in
        if !ac.textFields![0].text!.isEmpty{
          self.CancelarSolicitud(ac.textFields![0].text!, solicitud: solicitud)
        }
      }
      
      ac.addAction(submitAction)
      
      self.present(ac, animated: true)
    }))
    motivoAlerta.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { action in
      
    }))
    
    self.present(motivoAlerta, animated: true, completion: nil)
  }
  
  func CancelarSolicitud(_ motivo: String, solicitud: Solicitud){
    //#Cancelarsolicitud, id, idTaxi, motivo, "# \n"
    let datos = solicitud.crearTramaCancelar(motivo: motivo)
    globalVariables.solpendientes.removeAll{$0.id == solicitud.id}
    //EnviarSocket(Datos)
    let vc = R.storyboard.main.inicioView()!
    vc.socketEmit("cancelarservicio", datos: datos)
    self.navigationController?.show(vc, sender: nil)
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
    cell.delegate = self
    cell.initContent(solicitud: self.solicitudesMostrar[indexPath.row])
    //cell.textLabel?.text = self.solicitudesMostrar[indexPath.row].fechaHora
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    let vc = R.storyboard.main.solDetalles()
//    vc!.solicitudPendiente = self.solicitudesMostrar[indexPath.row]
//    self.navigationController?.show(vc!, sender: nil)
    
    let solicitud = self.solicitudesMostrar[indexPath.row]
    if solicitud.taxi.id != 0{
      let vc = R.storyboard.main.solDetalles()
      //vc.solicitudPendiente = self.solicitudesMostrar[indexPath.row]
      vc?.solicitudPendiente = solicitud
      self.navigationController?.show(vc!, sender: nil)
    }else{
      let vc = R.storyboard.main.esperaChildView()
      vc?.solicitud = solicitud
      self.navigationController?.show(vc!, sender: nil)
//      let alertaDos = UIAlertController (title: "Solicitud en proceso", message: "Solicitud enviada a todos los taxis cercanos. Esperando respuesta de un conductor.", preferredStyle: .alert)
//      alertaDos.addAction(UIAlertAction(title: "Esperar respuesta", style: .default, handler: {alerAction in
//        let vc = R.storyboard.main.inicioView()!
//        self.navigationController?.show(vc, sender: nil)
//      }))
//      alertaDos.addAction(UIAlertAction(title: "Cancelar la solicitud", style: .destructive, handler: {alerAction in
//        self.mostrarMotivosCancelacion(solicitud: solicitud)
//      }))
//      self.present(alertaDos, animated: true, completion: nil)
    }
  } 
}

extension SolicitudesTableController: SolPendientesDelegate{
  func cancelRequest(_ controller: SolPendientesViewCell, cancelarSolicitud solicitud: Solicitud) {
    self.mostrarMotivosCancelacion(solicitud: solicitud)
  }
}
