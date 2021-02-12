//
//  InicioSearchExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 2/9/21.
//  Copyright © 2021 Done Santana. All rights reserved.
//

import Foundation
import Mapbox
import MapboxSearch
import MapboxSearchUI

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
      self.initMapView()
    }else{
      annotation.subtitle = "destino"
      self.destinoAnnotation = annotation
      self.mapView.removeAnnotations(self.mapView.annotations!)
      self.mapView.addAnnotations([self.origenAnnotation,self.destinoAnnotation])
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
      self.initMapView()
    }else{
      annotation.subtitle = "destino"
      self.destinoAnnotation = annotation
      self.mapView.removeAnnotations(self.mapView.annotations!)
      self.mapView.addAnnotations([self.origenAnnotation,self.destinoAnnotation])
      self.getDestinoFromSearch(annotation: annotation)
    }
    self.hideSearchPanel()
  }

}

extension InicioController: SearchEngineDelegate {
  func resultsUpdated(searchEngine: SearchEngine) {
    print("Number of search results: \(searchEngine.items.count)")
    print(searchEngine.query)

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
