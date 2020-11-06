//
//  HistorialDetailsController.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 11/5/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit
import MapKit

class HistorialDetailsController: BaseController {
  var solicitud: SolicitudHistorial!

  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.viewTopConstraint.constant = super.getTopMenuBottom()
    
    //self.mapView.centerCoordinate = solicitud.origenCoord
    self.mapView.showsUserLocation = false
    let regionRadius: CLLocationDistance = 1000
    //let coordinateRegion = MKCoordinateRegion(center: solicitud.origenCoord, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
    //self.mapView.setRegion(coordinateRegion, animated: true)
    
  }
}
