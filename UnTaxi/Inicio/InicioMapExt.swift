//
//  InicioMapExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/8/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import Mapbox
import MapboxSearch
import MapboxSearchUI

//Mapbox
extension InicioController{
  func showAnnotation(_ annotations: [MGLPointAnnotation], isPOI: Bool) {
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
    return true
  }
  
  func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
    return UIButton(type: .detailDisclosure)
  }
  
  func mapView(_ mapView: MGLMapView, leftCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
    print("callout \(annotation.subtitle)")
//    if (annotation.subtitle! == "origen") {
//      // Callout height is fixed; width expands to fit its content.
//      let label = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 50))
//      label.textAlignment = .right
//      label.textColor = UIColor(red: 0.81, green: 0.71, blue: 0.23, alpha: 1)
//      label.text = annotation.title!
//      
//      return label
//    }
    
    return nil
  }
  
  //ONLY WHEN YOU ADD MGLANNOTATION NOT MGLANNOTATIONVIEW
  func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
    return MGLAnnotationImage(image: UIImage(named: annotation.title!!)!, reuseIdentifier: annotation.title!!)
  }
  
  func mapView(_ mapView: MGLMapView, regionWillChangeAnimated animated: Bool) {
    
    if self.mapView.annotations != nil{
      self.mapView.removeAnnotations(self.mapView!.annotations!)
    }
    self.origenAnnotation.subtitle = self.searchingAddress
    self.coreLocationManager.stopUpdatingLocation()
    self.locationIcono.image = UIImage(named: searchingAddress)
    self.locationIcono.isHidden = false

//    if searchingAddress == "origen" {
//      if self.mapView.annotations != nil{
//        self.mapView.removeAnnotations(self.mapView!.annotations!)
//      }
//      self.origenAnnotation.subtitle = "origen"
//      self.coreLocationManager.stopUpdatingLocation()
//      self.locationIcono.isHidden = false
//    }
  }
  
  func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
    locationIcono.isHidden = true
    let tempAnnotation = MGLPointAnnotation()
    tempAnnotation.coordinate = (self.mapView.centerCoordinate)
    tempAnnotation.subtitle = self.searchingAddress
    mapView.addAnnotation(tempAnnotation)
    if searchingAddress == "origen"{
      self.origenAnnotation = tempAnnotation
      self.getAddressFromCoordinate(tempAnnotation)
      
    }else{
      
      self.destinoAnnotation = tempAnnotation
      self.getDestinoFromSearch(annotation: tempAnnotation)
    }
//    if SolicitarBtn.isHidden == false {
//      self.origenAnnotation.coordinate = (self.mapView.centerCoordinate)
//      self.origenAnnotation.subtitle = "origen"
//      mapView.addAnnotation(self.origenAnnotation)
//    }
  }
  
  func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
    //self.loadGeoJson()
  }
}

extension InicioController: SearchControllerDelegate {
  func categorySearchResultsReceived(results: [SearchResult]) {
    let annotations = results.map { searchResult -> MGLPointAnnotation in
      let annotation = MGLPointAnnotation()
      annotation.coordinate = searchResult.coordinate
      annotation.title = searchResult.name
      annotation.subtitle = searchResult.address?.formattedAddress(style: .medium)
      return annotation
    }

    //showAnnotation(annotations, isPOI: false)
  }

  func searchResultSelected(_ searchResult: SearchResult) {
    let annotation = MGLPointAnnotation()
    annotation.coordinate = searchResult.coordinate
    annotation.title = searchResult.address?.formattedAddress(style: .medium)
    
    //showAnnotation([self.origenAnnotation, annotation], isPOI: searchResult.type == .POI)
    if searchingAddress == "origen"{
      
      annotation.subtitle = "origen"
      self.origenAnnotation = annotation
    }else{
      
      annotation.subtitle = "destino"
      self.getDestinoFromSearch(annotation: annotation)
    }
    self.hideSearchPanel()
  }

  func userFavoriteSelected(_ userFavorite: FavoriteRecord) {
    let annotation = MGLPointAnnotation()
    annotation.coordinate = userFavorite.coordinate
    annotation.title = userFavorite.name
    annotation.subtitle = userFavorite.address?.formattedAddress(style: .medium)

    //showAnnotation([self.origenAnnotation, annotation], isPOI: true)
    if searchingAddress == "origen"{
      annotation.subtitle = "origen"
      self.origenAnnotation = annotation
    }else{
      print("destino")
      annotation.subtitle = "destino"
      self.getDestinoFromSearch(annotation: annotation)
    }
    self.hideSearchPanel()
  }
  

}

extension InicioController: SearchEngineDelegate {
  func resultsUpdated(searchEngine: SearchEngine) {
    print("Number of search results: \(searchEngine.items.count)")

    /// Simulate user selection with random algorithm
    guard let randomSuggestion: SearchSuggestion = searchEngine.items.randomElement() else {
      print("No available suggestions to select")
      return
    }

    /// Callback to SearchEngine with choosen `SearchSuggestion`
    searchEngine.select(suggestion: randomSuggestion)

    /// We may expect `resolvedResult(result:)` to be called next
    /// or the new round of `resultsUpdated(searchEngine:)` in case if randomSuggestion represents category suggestion (like a 'bar' or 'cafe')
  }

  func resolvedResult(result: SearchResult) {
    /// WooHoo, we retrieved the resolved `SearchResult`
    print("Resolved result: coordinate: \(result.coordinate), address: \(result.address?.formattedAddress(style: .medium) ?? "N/A")")

    print("Dumping resolved result:", dump(result))

  }

  func searchErrorHappened(searchError: SearchError) {
    print("Error during search: \(searchError)")
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
