//
//  SolDetallesMapExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 12/16/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import MapboxMaps

//Mapbox
extension SolPendController{
  func showAnnotations(_ annotations: [MyMapAnnotation]) {
    guard !annotations.isEmpty else { return }
		
		if annotations.count == 1, let annotation = annotations.first {
			mapView.setCenter(annotation.coordinates, zoomLevel: 15, animated: true)
		} else {
			let bounds = CoordinateBounds(southwest: annotations.first!.coordinates,
																		northeast: annotations.last!.coordinates)
            let boundsNew = Geometry(bounds as! GeometryConvertible)
			// Center the camera on the bounds
			let camera = mapView.mapboxMap.camera(for: boundsNew, padding: .init(top: 100, left: 40, bottom: 60, right: 40), bearing: 10, pitch: 0)
			mapView.mapboxMap.setCamera(to: camera)
		}

		pointAnnotationManager.annotations = annotations.map({$0.annotation})
  }
}

