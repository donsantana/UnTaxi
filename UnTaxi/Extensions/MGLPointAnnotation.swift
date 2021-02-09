//
//  MGLPointAnnotation.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 12/30/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import Foundation
import CoreLocation
import Mapbox
import MapboxGeocoder

extension MGLPointAnnotation{
  
  func updateAnnotation(newCoordinate: CLLocationCoordinate2D, newTitle: String){
    self.coordinate = newCoordinate
    self.title = newTitle
  }
  
  func coordinatesToAddress(){
    let geocoder = Geocoder.shared
    let options = ReverseGeocodeOptions(coordinate: self.coordinate)
    // Or perhaps: ReverseGeocodeOptions(location: locationManager.location)

    let task = geocoder.geocode(options) { (placemarks, attribution, error) in
        guard let placemark = placemarks?.first else {
            return
        }
      print("address \(placemark)")
      self.title = placemark.name
//        print(placemark.imageName ?? "")
//            // telephone
//        print(placemark.genres?.joined(separator: ", ") ?? "")
//            // computer, electronic
//        print(placemark.administrativeRegion?.name ?? "")
//            // New York
//        print(placemark.administrativeRegion?.code ?? "")
//            // US-NY
//        print(placemark.place?.wikidataItemIdentifier ?? "")
//            // Q60
    }
  }
}
