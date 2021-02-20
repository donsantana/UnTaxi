//
//  SolDetallesMapExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 12/16/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import Mapbox
import MapboxSearch
import MapboxSearchUI

//Mapbox
extension SolPendController{
  func showAnnotation(_ annotations: [MGLAnnotation]) {
    guard !annotations.isEmpty else { return }

    if let existingAnnotations = mapView.annotations {
      mapView.removeAnnotations(existingAnnotations)
    }
    mapView.addAnnotations(annotations)

    if annotations.count == 1, let annotation = annotations.first {
      mapView.setCenter(annotation.coordinate, zoomLevel: 15, animated: true)
    } else {
      mapView.showAnnotations(annotations, animated: true)
    }
  }
}

extension SolPendController: MGLMapViewDelegate{
  
  //  // MARK: - MGLMapViewDelegate methods
  //
  //  // This delegate method is where you tell the map to load a view for a specific annotation. To load a static MGLAnnotationImage, you would use `-mapView:imageForAnnotation:`.
  @nonobjc func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
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
  
  func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
    return Customization.buttonActionColor
  }
  
  func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
    return 10.0
  }

  func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
    //self.loadGeoJson()
  }
}

