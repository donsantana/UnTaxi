//
//  BMapAnnotation.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 10/29/22.
//  Copyright © 2022 Done Santana. All rights reserved.
//

import UIKit
import MapboxMaps

class MyMapAnnotation{
	var type: String {
		didSet {
			var imageName: String!
			switch type {
			case "origen":
				imageName = "origen"
			case "destino":
				imageName = "destino"
			case "taxi_libre":
				imageName = "taxi_libre"
			default:
				imageName = "mapLocation"
				
			}
			annotation.image = .init(image: UIImage(named: imageName)!, name: type)
			annotation.iconAnchor = .bottom
		}
	}
	var address: String
	var annotation: PointAnnotation
	
	init() {
		self.type = ""
		self.address = ""
		self.annotation = PointAnnotation(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
		self.annotation.image = .init(image: UIImage(named: "mapLocation")!, name: "")
	}
	
	init(type: String, address: String, location: CLLocationCoordinate2D, imageName: String?) {
		self.type = type
		self.address = address
		self.annotation = PointAnnotation(coordinate: location)
		self.annotation.image = .init(image: UIImage(named: imageName ?? "")!, name: "red_pin")
	}
	
	var coordinates: CLLocationCoordinate2D {
		get {
			annotation.point.coordinates
		}
		set(value) {
			annotation.point = Point(value)
		}
	}
}
