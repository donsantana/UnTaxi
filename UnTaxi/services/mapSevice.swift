//
//  mapSevice.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/9/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit
import Mapbox
import MapboxGeocoder
import CoreLocation


class mapService{
  var mapView: MGLMapView!
  
  init(mapView: MGLMapView){
    self.mapView = mapView
  }
  
  func updateMapCenter(coord: CLLocationCoordinate2D) {
    mapView.setCenter(CLLocationCoordinate2D(latitude: -2.173714, longitude: -79.921601), zoomLevel: 9, animated: false)
  }
  
  
}
