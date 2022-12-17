//
//  MapView.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 10/30/22.
//  Copyright © 2022 Done Santana. All rights reserved.
//

import Foundation
import MapboxMaps

extension MapView {

	func showAnnotations(_ annotations: [MyMapAnnotation], pointAnnotationManager: PointAnnotationManager, animated: Bool? = false) {
		pointAnnotationManager.annotations = annotations.map({$0.annotation})
	}
	
	func removeAnnotations(_ annotation: MyMapAnnotation? = nil, pointAnnotationManager: PointAnnotationManager) {
		if let annotation = annotation {
			pointAnnotationManager.annotations.removeAll(where: {$0.id == annotation.annotation.id})
		} else {
			pointAnnotationManager.annotations.removeAll()
		}
		self.annotations.removeAnnotationManager(withId: pointAnnotationManager.id)
	}
	
	func addAnnotation(_ annotation: MyMapAnnotation, pointAnnotationManager: PointAnnotationManager) {
		pointAnnotationManager.annotations.append(annotation.annotation)
	}
	
	func setCenter(_ center: CLLocationCoordinate2D, zoomLevel: CGFloat? = 15, animated: Bool? = false) {
		let end = CameraOptions(center: center,
														zoom: zoomLevel,
														bearing: 0,
														pitch: 50)
		
		_ = self.camera.fly(to: end,duration: 0) {_ in
			print("Camera fly-to finished")
		}
	}
	
	func addPolyline(origin: MyMapAnnotation, destiny: MyMapAnnotation) {
		var lineAnnotation = PolylineAnnotation(lineCoordinates: [origin.coordinates, destiny.coordinates])
		lineAnnotation.lineColor = StyleColor(.gray)

		// Create the `PolylineAnnotationManager` which will be responsible for handling this annotation
		let lineAnnnotationManager = self.annotations.makePolylineAnnotationManager()

		// Add the annotation to the manager.
		lineAnnnotationManager.annotations = [lineAnnotation]
	}
}
