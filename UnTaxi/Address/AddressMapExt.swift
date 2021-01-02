//
//  AddressMapExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 12/28/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit
import Mapbox

extension AddressController: MGLMapViewDelegate{
  func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
    // This example is only concerned with point annotations.
    guard annotation is MGLPointAnnotation else {
      return nil
    }
    
    // Use the point annotation’s longitude value (as a string) as the reuse identifier for its view.
    let reuseIdentifier = annotation.subtitle
    
    // For better performance, always try to reuse existing annotations.
    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier!!)
    
    // If there’s no reusable annotation view available, initialize a new one.
    if annotationView == nil {
      annotationView = CustomImageAnnotationView(reuseIdentifier: reuseIdentifier as! String, image: UIImage(named: annotation.subtitle!!)!)
    }
    
    return annotationView
  }
  
  func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
    return true
  }
  
  //ONLY WHEN YOU ADD MGLANNOTATION NOT MGLANNOTATIONVIEW
  func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
    return MGLAnnotationImage(image: UIImage(named: annotation.subtitle!!)!, reuseIdentifier: annotation.subtitle!!)
  }
  
  func mapView(_ mapView: MGLMapView, regionWillChangeAnimated animated: Bool) {
//    if SolicitarBtn.isHidden == false {
//      if self.mapView.annotations != nil{
//        self.mapView.removeAnnotations(self.mapView!.annotations!)
//      }
//      self.origenAnnotation.subtitle = "origen"
//      self.coreLocationManager.stopUpdatingLocation()
//      self.locationIcono.isHidden = false
//      self.locationIcono.isHidden = false
//    }
  }
  
  func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
//    locationIcono.isHidden = true
//    if SolicitarBtn.isHidden == false {
//      self.origenAnnotation.coordinate = (self.mapView.centerCoordinate)
//      self.origenAnnotation.subtitle = "origen"
//      mapView.addAnnotation(self.origenAnnotation)
//    }
  }
}
