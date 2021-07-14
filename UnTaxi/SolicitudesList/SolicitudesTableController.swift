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
    print("SolPendientes \(globalVariables.solpendientes.count)")
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
    //headerView.backgroundColor = CustomAppColor.primaryColor//UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
    headerView.tintColor = CustomAppColor.textColor
    
    let sectionTitle: UILabel = UILabel.init(frame: CGRect(x: headerView.frame.width / 2 - 60, y: 15, width: self.tableView.frame.width/3, height: 20))
    sectionTitle.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
    sectionTitle.textAlignment = .center
    sectionTitle.textColor = CustomAppColor.textColor
    //sectionTitle.text = "Solicitudes"
    
    
    let backBtn = UIButton()
    backBtn.frame = CGRect(x: 10, y: 10, width: 30, height: 30)
    backBtn.setTitleColor(CustomAppColor.textColor, for: .normal)
    //backBtn.setTitleColor(.black, for: .normal)
    //      backBtn.setTitle("<", for: .normal)
    //      backBtn.titleLabel?.font = UIFont(name: "Helvetica", size: 35.0)
    //nextBtn.addBorder()
    backBtn.setImage(UIImage(named: "backIcon")?.imageWithColor(color1: CustomAppColor.textColor), for: UIControl.State())
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
    
    for i in 0...Customization.motivosCancelacion.count - 1{
      if i == Customization.motivosCancelacion.count - 1{
        motivoAlerta.addAction(UIAlertAction(title: Customization.motivosCancelacion[i], style: .default, handler: { action in
          let ac = UIAlertController(title: Customization.motivosCancelacion[i], message: nil, preferredStyle: .alert)
          ac.addTextField()
          
          let submitAction = UIAlertAction(title: "Enviar", style: .default) { [unowned ac] _ in
            if !ac.textFields![0].text!.isEmpty{
              self.CancelarSolicitud(ac.textFields![0].text!, solicitud: solicitud)
            }
          }
          
          ac.addAction(submitAction)
          
          self.present(ac, animated: true)
        }))
      }else{
        motivoAlerta.addAction(UIAlertAction(title: Customization.motivosCancelacion[i], style: .default, handler: { action in
          self.CancelarSolicitud(Customization.motivosCancelacion[i], solicitud: solicitud)
        }))
      }
    }
//    motivoAlerta.addAction(UIAlertAction(title: Customization.motivosCancelacion[0], style: .default, handler: { action in
//      self.CancelarSolicitud(Customization.motivosCancelacion[0], solicitud: solicitud)
//    }))
//    motivoAlerta.addAction(UIAlertAction(title: Customization.motivosCancelacion[1], style: .default, handler: { action in
//      self.CancelarSolicitud(Customization.motivosCancelacion[1], solicitud: solicitud)
//    }))
//    motivoAlerta.addAction(UIAlertAction(title: Customization.motivosCancelacion[2], style: .default, handler: { action in
//      self.CancelarSolicitud(Customization.motivosCancelacion[2], solicitud: solicitud)
//    }))
//    motivoAlerta.addAction(UIAlertAction(title: Customization.motivosCancelacion[3], style: .default, handler: { action in
//      self.CancelarSolicitud(Customization.motivosCancelacion[3], solicitud: solicitud)
//    }))
//
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
    let viewcontrollers = self.navigationController?.viewControllers
    viewcontrollers?.forEach({ (vc) in
      if  let inventoryListVC = vc as? InicioController {
        self.navigationController!.popToViewController(inventoryListVC, animated: true)
      }
    })
    //self.dismiss(animated: false, completion: nil)
//    let vc = R.storyboard.main.inicioView()
//    self.navigationController?.pushViewController(vc!, animated: true)
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
      vc?.solicitudPendiente = solicitud
      self.navigationController?.show(vc!, sender: nil)
    }else{
      let array = globalVariables.ofertasList.map{$0.id}
      if array.contains(solicitud.id){
        print("oferta encontrada")
        let vc = R.storyboard.main.ofertasView()
        vc?.solicitud = solicitud
        self.navigationController?.show(vc!, sender: nil)
      }else{
        print("oferta encontrada")
        let vc = R.storyboard.main.esperaChildView()!
        vc.solicitud = solicitud
        self.navigationController?.show(vc, sender: nil)
      }
//      let vc = R.storyboard.main.esperaChildView()!
//      vc.solicitud = solicitud
//      self.navigationController?.show(vc, sender: nil)
    }
  } 
}

extension SolicitudesTableController: SolPendientesDelegate{
  func cancelRequest(_ controller: SolPendientesViewCell, cancelarSolicitud solicitud: Solicitud) {
    self.mostrarMotivosCancelacion(solicitud: solicitud)
  }
}
