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
  func showAnnotation(_ annotations: [MGLAnnotation], isPOI: Bool) {
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
    
    // Use the point annotation’s longitude value (as a string) as the reuse identifier for its view.
    let reuseIdentifier = "origen"
    
    // For better performance, always try to reuse existing annotations.
    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
    
    // If there’s no reusable annotation view available, initialize a new one.
    if annotationView == nil {
      annotationView = CustomImageAnnotationView(reuseIdentifier: reuseIdentifier, image: UIImage(named: annotation.title == "origen" ? "origen" : "taxi_libre")!)
    }
    
    return annotationView
  }
  
  func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
    return true
  }
  
  //ONLY WHEN YOU ADD MGLANNOTATION NOT MGLANNOTATIONVIEW
  func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
    let reuseIdentifier = annotation.title == "origen" ? "origen" : "taxi"
    return MGLAnnotationImage(image: UIImage(named: annotation.title == "origen" ? "origen" : "taxi_libre")!, reuseIdentifier: reuseIdentifier)
  }
  
  func mapView(_ mapView: MGLMapView, regionWillChangeAnimated animated: Bool) {
    if SolicitarBtn.isHidden == false {
      if self.mapView.annotations != nil{
        self.mapView.removeAnnotations(self.mapView!.annotations!)
      }
      self.origenAnotacion.title = "origen"
      self.coreLocationManager.stopUpdatingLocation()
      self.origenIcono.isHidden = false
      self.SolPendientesView.isHidden = true
      self.origenIcono.isHidden = false
    }
  }
  
  func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
    origenIcono.isHidden = true
    if SolicitarBtn.isHidden == false {
      self.origenAnotacion.coordinate = (self.mapView.centerCoordinate)
      self.origenAnotacion.title = "origen"
      mapView.addAnnotation(self.origenAnotacion)
    }
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
    
    showAnnotation(annotations, isPOI: false)
  }
  
  func searchResultSelected(_ searchResult: SearchResult) {
    let annotation = MGLPointAnnotation()
    annotation.coordinate = searchResult.coordinate
    annotation.title = searchResult.name
    annotation.subtitle = searchResult.address?.formattedAddress(style: .medium)
    
    showAnnotation([annotation], isPOI: searchResult.type == .POI)
  }
  
  func userFavoriteSelected(_ userFavorite: FavoriteRecord) {
    let annotation = MGLPointAnnotation()
    annotation.coordinate = userFavorite.coordinate
    annotation.title = userFavorite.name
    annotation.subtitle = userFavorite.address?.formattedAddress(style: .medium)
    
    showAnnotation([annotation], isPOI: true)
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
