//
//  OfertasController.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 7/26/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import UIKit
import MapKit

class OfertasController: BaseController{
  var socketService = SocketService()
  let progress = Progress(totalUnitCount: 80)
  var progressTimer = Timer()
  var ofertaSeleccionada: Oferta!
  var solicitud: Solicitud!
  
  @IBOutlet weak var ofertasTableView: UITableView!
  @IBOutlet weak var progressTimeBar: UIProgressView!
  @IBOutlet weak var ofertaAceptadaEffect: UIVisualEffectView!
  @IBOutlet weak var ofertaBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var ofertaFooterView: UIView!
  @IBOutlet weak var ofertaTableTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var titleText: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //self.navigationController?.navigationBar.tintColor = UIColor.black
    self.mapView.centerCoordinate = solicitud.origenCoord
    self.mapView.showsUserLocation = true
    self.socketService.delegate = self
    self.socketService.initListenEventos()
    let regionRadius: CLLocationDistance = 1000
    let coordinateRegion = MKCoordinateRegion(center: solicitud.origenCoord,
                                              latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
    self.mapView.setRegion(coordinateRegion, animated: true)
    
    self.ofertaFooterView.addShadow()
    //self.titleText.titleBlueStyle()
    self.ofertasTableView.delegate = self
    self.ofertasTableView.backgroundColor = .clear
    
    // 1
    self.progressTimeBar.progress = 0.0
    progress.completedUnitCount = 0
    self.ofertaBottomConstraint.constant = Responsive().heightFloatPercent(percent: 20)
    self.ofertaTableTopConstraint.constant = super.getTopMenuBottom()
    // 2
    self.progressTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
      guard self.progress.isFinished == false else {
        let alertaDos = UIAlertController (title: "Ofertas no Aceptadas", message: "El tiempo para aceptar alguna oferta ha concluido. Por favor vuelva a enviar su solicitud.", preferredStyle: UIAlertController.Style.alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          self.CancelarSolicitud("")
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
  
  override func viewDidDisappear(_ animated: Bool) {
    //globalVariables.ofertasList.removeAll()
  }
  
  func MostrarMotivoCancelacion(){
    let motivoAlerta = UIAlertController(title: "¿Por qué cancela el viaje?", message: "", preferredStyle: .actionSheet)
    
    let titleAttributes = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 20)!, NSAttributedString.Key.foregroundColor: UIColor.black]
    let titleString = NSAttributedString(string: "¿Por qué cancela el viaje?", attributes: titleAttributes)
    motivoAlerta.setValue(titleString, forKey: "attributedTitle")
    
    for i in 0...Customization.motivosCancelacion.count - 1{
      if i == Customization.motivosCancelacion.count - 1{
        motivoAlerta.addAction(UIAlertAction(title: Customization.motivosCancelacion[i], style: .default, handler: { action in
          let ac = UIAlertController(title: Customization.motivosCancelacion[i], message: nil, preferredStyle: .alert)
          ac.addTextField()
          
          let submitAction = UIAlertAction(title: "Enviar", style: .default) { [unowned ac] _ in
            if !ac.textFields![0].text!.isEmpty{
              self.CancelarSolicitud(ac.textFields![0].text!)
            }
          }
          
          ac.addAction(submitAction)
          
          self.present(ac, animated: true)
        }))
      }else{
        motivoAlerta.addAction(UIAlertAction(title: Customization.motivosCancelacion[i], style: .default, handler: { action in
          self.CancelarSolicitud(Customization.motivosCancelacion[i])
        }))
      }
    }
    
//    motivoAlerta.addAction(UIAlertAction(title: "Mucho tiempo de espera", style: .default, handler: { action in
//      self.CancelarSolicitud("Mucho tiempo de espera")
//    }))
//    motivoAlerta.addAction(UIAlertAction(title: "El taxi no se mueve", style: .default, handler: { action in
//      self.CancelarSolicitud("El taxi no se mueve")
//    }))
//    motivoAlerta.addAction(UIAlertAction(title: "El conductor se fue a una dirección equivocada", style: .default, handler: { action in
//      self.CancelarSolicitud("El conductor se fue a una dirección equivocada")
//    }))
//    motivoAlerta.addAction(UIAlertAction(title: "Ubicación incorrecta", style: .default, handler: { action in
//      self.CancelarSolicitud("Ubicación incorrecta")
//    }))
//    motivoAlerta.addAction(UIAlertAction(title: "Otro", style: .default, handler: { action in
//      let ac = UIAlertController(title: "Entre el motivo", message: nil, preferredStyle: .alert)
//      ac.addTextField()
//
//      let submitAction = UIAlertAction(title: "Enviar", style: .default) { [unowned ac] _ in
//        if !ac.textFields![0].text!.isEmpty{
//          self.CancelarSolicitud(ac.textFields![0].text!)
//        }
//      }
//
//      ac.addAction(submitAction)
//
//      self.present(ac, animated: true)
//    }))
    motivoAlerta.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { action in
    }))
    
    self.present(motivoAlerta, animated: true, completion: nil)
  }
  
  func CancelarSolicitud(_ motivo: String){
    //#Cancelarsolicitud, id, idTaxi, motivo, "# \n"
    globalVariables.solpendientes.removeAll{$0.id == self.solicitud.id}
    let datos = solicitud.crearTramaCancelar(motivo: motivo)
    self.socketService.socketEmit("cancelarservicio", datos: datos)
  }
  
  @IBAction func cancelarSolicitud(_ sender: Any) {
    let alertaDos = UIAlertController (title: "Aviso Importante", message: "Estimado usuario, la cancelación frecuente del servicio puede ser motivo de un bloqueo temporal de la aplicación.", preferredStyle: .alert)
    
    let titleAttributes = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 20)!, NSAttributedString.Key.foregroundColor: UIColor.red]
    let titleString = NSAttributedString(string: "Aviso Importante", attributes: titleAttributes)
    alertaDos.setValue(titleString, forKey: "attributedTitle")
    
    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { [self]alerAction in
      self.MostrarMotivoCancelacion()
    }))
    
    self.present(alertaDos, animated: true, completion: nil)
  }

}
