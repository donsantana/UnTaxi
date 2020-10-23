//
//  OfertasController.swift
//  MovilClub
//
//  Created by Donelkys Santana on 7/26/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import UIKit
import MapKit

class OfertasController: BaseController {
  let progress = Progress(totalUnitCount: 80)
  var progressTimer = Timer()
  let inicioController = R.storyboard.main.inicioView()
  var ofertaSeleccionada: Oferta!
  var solicitud: Solicitud!
  
  @IBOutlet weak var ofertasTableView: UITableView!
  @IBOutlet weak var progressTimeBar: UIProgressView!
  @IBOutlet weak var ofertaAceptadaEffect: UIVisualEffectView!
  @IBOutlet weak var ofertaBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var ofertaFooterView: UIView!
  @IBOutlet weak var ofertaTableTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var mapView: MKMapView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //self.navigationController?.navigationBar.tintColor = UIColor.black
    self.mapView.centerCoordinate = solicitud.origenCoord
    self.mapView.showsUserLocation = true
    let regionRadius: CLLocationDistance = 1000
    let coordinateRegion = MKCoordinateRegion(center: solicitud.origenCoord,
                                              latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
    self.mapView.setRegion(coordinateRegion, animated: true)
    
    self.ofertaFooterView.addShadow()
    self.ofertasTableView.delegate = self
    
    // 1
    self.progressTimeBar.progress = 0.0
    progress.completedUnitCount = 0
    self.ofertaBottomConstraint.constant = Responsive().heightFloatPercent(percent: 20)
    print(super.getTopMenuBottom())
    self.ofertaTableTopConstraint.constant = super.getTopMenuBottom()
    // 2
    self.progressTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
      guard self.progress.isFinished == false else {
        let alertaDos = UIAlertController (title: "Ofertas no Aceptadas", message: "El tiempo para aceptar alguna oferta ha concluido. Por favor vuelva a enviar su solicitud.", preferredStyle: UIAlertController.Style.alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          let vc = R.storyboard.main.inicioView()!
          self.navigationController?.show(vc, sender: nil)
        }))
        self.present(alertaDos, animated: true, completion: nil)
        timer.invalidate()
        return
      }
      
      // 3
      self.progress.completedUnitCount += 1
      self.progressTimeBar.setProgress(Float(self.progress.fractionCompleted), animated: true)
      
      //self.progressLabel.text = "\(Int(self.progress.fractionCompleted * 100)) %"
    }
  }
  
  func MostrarMotivoCancelacion(){
    //["No necesito","Demora el servicio","Tarifa incorrecta","Solo probaba el servicio", "Cancelar"]
    let motivoAlerta = UIAlertController(title: "", message: "Seleccione el motivo de cancelación.", preferredStyle: UIAlertController.Style.actionSheet)
    motivoAlerta.addAction(UIAlertAction(title: "No necesito", style: .default, handler: { action in
      self.CancelarSolicitud("No necesito")
    }))
    motivoAlerta.addAction(UIAlertAction(title: "Demora el servicio", style: .default, handler: { action in
      self.CancelarSolicitud("Demora el servicio")
    }))
    motivoAlerta.addAction(UIAlertAction(title: "Tarifa incorrecta", style: .default, handler: { action in
      self.CancelarSolicitud("Tarifa incorrecta")
    }))
    motivoAlerta.addAction(UIAlertAction(title: "Vehículo en mal estado", style: .default, handler: { action in
      self.CancelarSolicitud("Vehículo en mal estado")
    }))
    motivoAlerta.addAction(UIAlertAction(title: "Solo probaba el servicio", style: .default, handler: { action in
      self.CancelarSolicitud("Solo probaba el servicio")
    }))
    motivoAlerta.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.destructive, handler: { action in
    }))
    
    self.present(motivoAlerta, animated: true, completion: nil)
  }
  
  func CancelarSolicitud(_ motivo: String){
    //#Cancelarsolicitud, id, idTaxi, motivo, "# \n"
    globalVariables.solpendientes.removeAll{$0.id == self.solicitud.id}
    let datos = solicitud.crearTramaCancelar(motivo: motivo)
    let vc = R.storyboard.main.inicioView()!
    vc.socketEmit("cancelarservicio", datos: datos)
    self.navigationController?.show(vc, sender: nil)
  }
  
  @IBAction func cancelarSolicitud(_ sender: Any) {
    self.MostrarMotivoCancelacion()
  }
  
  
}
