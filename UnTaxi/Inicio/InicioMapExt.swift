//
//  InicioMapExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/8/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import Mapbox

//Mapbox
extension InicioController{
  func initMapView(){
    var annotationsToShow = [globalVariables.cliente.annotation!]
    if self.origenAnnotation.coordinate.latitude != 0.0{
      annotationsToShow = [self.origenAnnotation]
    }
    mapView.setCenter(annotationsToShow.first!.coordinate, zoomLevel: 15, animated: false)
    mapView.styleURL = MGLStyle.lightStyleURL
    self.locationIcono.image = UIImage(named: "origen")
    self.locationIcono.isHidden = true
    self.showAnnotation(annotationsToShow)
    
    if self.tabBar.selectedItem != self.pactadaItem{
      self.getAddressFromCoordinate(annotationsToShow.first!)
    }
  }
  
  func showAnnotation(_ annotations: [MGLPointAnnotation]) {
    print("showing annotations")
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

extension InicioController: MGLMapViewDelegate{
  
  //  // MARK: - MGLMapViewDelegate methods
  //
  //  // This delegate method is where you tell the map to load a view for a specific annotation. To load a static MGLAnnotationImage, you would use `-mapView:imageForAnnotation:`.
  func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
    // This example is only concerned with point annotations.
    guard annotation is MGLPointAnnotation else {
      return nil
    }

    if annotation.isEqual(self.origenAnnotation){
      print("origen Annotation \(self.origenAnnotation.subtitle)")
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
    print("ANNOTATION PING")
    return annotation.responds(to: #selector(getter: MGLAnnotation.title))
  }
  
  func mapView(_ mapView: MGLMapView, calloutViewFor annotation: MGLAnnotation) -> MGLCalloutView? {
  // Instantiate and return our custom callout view.
  return CustomCalloutView(representedObject: annotation)
  }
  
  func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
    return UIButton(type: .detailDisclosure)
  }
  
  func mapView(_ mapView: MGLMapView, leftCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
    print("callout \(annotation.subtitle)")
    if (annotation.subtitle! == "origen") {
      // Callout height is fixed; width expands to fit its content.
      let label = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 50))
      label.textAlignment = .right
      label.textColor = UIColor(red: 0.81, green: 0.71, blue: 0.23, alpha: 1)
      label.text = annotation.title!
      
      return label
    }
    
    return nil
  }
  
  //ONLY WHEN YOU ADD MGLANNOTATION NOT MGLANNOTATIONVIEW
  func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
    return MGLAnnotationImage(image: UIImage(named: annotation.title!!)!, reuseIdentifier: annotation.title!!)
  }
  
  func mapView(_ mapView: MGLMapView, regionWillChangeAnimated animated: Bool) {
    if !self.navigationController!.isNavigationBarHidden{
      print("moving map")
      if self.mapView.annotations != nil{
        self.mapView.removeAnnotations(self.mapView!.annotations!)
      }
      self.coreLocationManager.stopUpdatingLocation()
      self.locationIcono.image = UIImage(named: searchingAddress)
      self.locationIcono.isHidden = false
      self.mapView.addAnnotation(self.origenAnnotation)
      self.panelController.removeContainer()
    }
  }
  
  func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
    if !self.navigationController!.isNavigationBarHidden{
      locationIcono.isHidden = true
      let tempAnnotation = MGLPointAnnotation()
      tempAnnotation.coordinate = (self.mapView.centerCoordinate)
      tempAnnotation.subtitle = self.searchingAddress
      self.getAddressFromCoordinate(tempAnnotation)
      
      if searchingAddress == "origen"{
        mapView.removeAnnotation(self.origenAnnotation)
        self.origenAnnotation = tempAnnotation
        mapView.addAnnotation(self.origenAnnotation)
      }else{
        self.destinoAnnotation = tempAnnotation
        mapView.addAnnotation(self.destinoAnnotation)
        //self.getDestinoFromSearch(annotation: self.destinoAnnotation)
      }
      //mapView.selectAnnotation(tempAnnotation, animated: true, completionHandler: nil)
    }
  }
  
  func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
    //self.loadGeoJson()
  }
  
  func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
    print("Annotation Selected")
  }
}

// MGLAnnotationView subclass
class CustomAnnotationView: MGLAnnotationView {
  override func layoutSubviews() {
    super.layoutSubviews()
    
    // Use CALayer’s corner radius to turn this view into a circle.
    layer.cornerRadius = bounds.width / 2
    layer.borderWidth = 2
    layer.borderColor = UIColor.white.cgColor
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Animate the border width in/out, creating an iris effect.
    let animation = CABasicAnimation(keyPath: "borderWidth")
    animation.duration = 0.1
    layer.borderWidth = selected ? bounds.width / 4 : 2
    layer.add(animation, forKey: "borderWidth")
  }
}

class CustomImageAnnotationView: MGLAnnotationView {
  var imageView: UIImageView!
  
  required init(reuseIdentifier: String?, image: UIImage) {
    super.init(reuseIdentifier: reuseIdentifier)
    
    self.imageView = UIImageView(image: image)
    self.addSubview(self.imageView)
    self.frame = self.imageView.frame
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
}
