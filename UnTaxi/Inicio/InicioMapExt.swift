//
//  InicioMapExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/8/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import MapboxMaps

//Mapbox
extension InicioController {
  func initMapView() {
		print("Init Map")
		let myResourceOptions = ResourceOptions(accessToken: "pk.eyJ1IjoiZG9uZWxreXMiLCJhIjoiY2tha2h0M2piMG54ajJ5bW42Nmh3ODVxZyJ9.l9q-_04bUOhy7Gnwdfdx5g")
		let myMapInitOptions = MapInitOptions(resourceOptions: myResourceOptions)
		mapView = MapView(frame: mapViewParent.bounds, mapInitOptions: myMapInitOptions)
		mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		mapViewParent.addSubview(mapView)
		pointAnnotationManager = mapView.annotations.makePointAnnotationManager()
		
    var annotationsToShow = [globalVariables.cliente.annotation!]
    if self.origenAnnotation.coordinates.latitude != 0.0 {
      annotationsToShow = [self.origenAnnotation]
    }
		
    self.locationIcono.image = UIImage(named: "origen")
    self.locationIcono.isHidden = true
		
		if self.tabBar.selectedItem != self.pactadaItem {
      self.getReverseAddressXoaAPI(annotationsToShow.first!)
    }
		
		self.showAnnotations(annotationsToShow)
		initMapInterations()
  }
	
	func initMapInterations() {
		mapView.gestures.delegate = self
		getTaxisCercanos()
	}
	
	func updateMapFocus() {
		mapView.setCenter(globalVariables.cliente.annotation.coordinates, zoomLevel: 15, animated: true)
	}
  
  func showAnnotations(_ annotations: [MyMapAnnotation]) {
		guard !annotations.isEmpty else { return }
		
		if annotations.count == 1, let annotation = annotations.first {
			mapView.setCenter(annotation.coordinates, zoomLevel: 15, animated: true)
		} else {
			let bounds = CoordinateBounds(southwest: annotations.first!.coordinates,
																		northeast: annotations.last!.coordinates)
			// Center the camera on the bounds
			let camera = mapView.mapboxMap.camera(for: bounds, padding: .init(top: 100, left: 40, bottom: 60, right: 40), bearing: 0, pitch: 0)
			mapView.mapboxMap.setCamera(to: camera)
		}

		pointAnnotationManager.annotations = annotations.map({$0.annotation})
  }
}

extension InicioController: GestureManagerDelegate {
	public func gestureManager(_ gestureManager: GestureManager, didBegin gestureType: GestureType) {
		print("\(gestureType) didBegin")
		if let navigationController = navigationController, !navigationController.isNavigationBarHidden {
			print("moving map")
			pointAnnotationManager.annotations.removeAll()
			self.coreLocationManager.stopUpdatingLocation()
			self.locationIcono.image = UIImage(named: searchingAddress)
			self.locationIcono.isHidden = false
			self.panelController.removeContainer()
		}
	}
	
	public func gestureManager(_ gestureManager: GestureManager, didEnd gestureType: GestureType, willAnimate: Bool) {
		print("\(gestureType) didEnd")
		if let navigationController = navigationController, !navigationController.isNavigationBarHidden {
			locationIcono.isHidden = true

			if searchingAddress == "origen" {
				origenAnnotation.coordinates = (mapView.cameraState.center)
				origenAnnotation.type = searchingAddress
				getReverseAddressXoaAPI(origenAnnotation)

				pointAnnotationManager.annotations = [origenAnnotation.annotation]
				getTaxisCercanos()
			} else {
				destinoAnnotation.coordinates = (mapView.cameraState.center)
				destinoAnnotation.type = searchingAddress
				getReverseAddressXoaAPI(destinoAnnotation)

				pointAnnotationManager.annotations = [destinoAnnotation.annotation]
			}
		}
	}
	
	public func gestureManager(_ gestureManager: GestureManager, didEndAnimatingFor gestureType: GestureType) {
		print("didEndAnimatingFor \(gestureType)")
	}
}

//extension InicioController: MGLMapViewDelegate {
//
//  //  // MARK: - MGLMapViewDelegate methods
//  //
//  //  // This delegate method is where you tell the map to load a view for a specific annotation. To load a static MGLAnnotationImage, you would use `-mapView:imageForAnnotation:`.
//  func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
//    // This example is only concerned with point annotations.
//    guard annotation is MGLPointAnnotation else {
//      return nil
//    }
//
//    if annotation.isEqual(self.origenAnnotation) {
//      print("origen Annotation \(self.origenAnnotation.type)")
//    }
//    // Use the point annotation’s longitude value (as a string) as the reuse identifier for its view.
//    let reuseIdentifier = annotation.type
//
//    // For better performance, always try to reuse existing annotations.
//    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier!!)
//
//    // If there’s no reusable annotation view available, initialize a new one.
//    if annotationView == nil {
//      annotationView = CustomImageAnnotationView(reuseIdentifier: reuseIdentifier as! String, image: UIImage(named: annotation.type!!)!)
//      annotationView?.setSelected(true, animated: true)
//    }
//
//    return annotationView
//  }
//
//  func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
//    print("ANNOTATION PING")
//
//    return annotation.responds(to: #selector(getter: MGLAnnotation.address))
//  }
//
//  func mapView(_ mapView: MGLMapView, calloutViewFor annotation: MGLAnnotation) -> MGLCalloutView? {
//  // Instantiate and return our custom callout view.
//    return CustomCalloutView(representedObject: annotation)
//  }
//
//  func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
//    return UIButton(type: .detailDisclosure)
//  }
//
//  func mapView(_ mapView: MGLMapView, leftCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
//    print("callout \(annotation.type)")
////    if (annotation.type! == "origen") {
////      // Callout height is fixed; width expands to fit its content.
////      let label = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 50))
////      label.textAlignment = .right
////      label.textColor = UIColor(red: 0.81, green: 0.71, blue: 0.23, alpha: 1)
////      label.text = annotation.address!
////
////      return label
////    }
//    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 50))
//    label.textAlignment = .right
//    label.textColor = UIColor(red: 0.81, green: 0.71, blue: 0.23, alpha: 1)
//    label.text = "annotation.address!"
//
//    return label
//  }
//
//  //ONLY WHEN YOU ADD MGLANNOTATION NOT MGLANNOTATIONVIEW
//  func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
//    return MGLAnnotationImage(image: UIImage(named: annotation.address!!)!, reuseIdentifier: annotation.address!!)
//  }
//
//  func mapView(_ mapView: MGLMapView, regionWillChangeAnimated animated: Bool) {
//    if let navigationController = navigationController, !navigationController.isNavigationBarHidden {
//      print("moving map")
//      if self.mapView.annotations != nil{
//        self.mapView.removeAnnotations(self.mapView!.annotations!)
//      }
//      self.coreLocationManager.stopUpdatingLocation()
//      self.locationIcono.image = UIImage(named: searchingAddress)
//      self.locationIcono.isHidden = false
//      self.mapView.addAnnotation(self.origenAnnotation)
//      self.panelController.removeContainer()
//    }
//  }
//
//  func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
//		if let navigationController = navigationController, !navigationController.isNavigationBarHidden {
//      locationIcono.isHidden = true
//      let tempAnnotation = MGLPointAnnotation()
//      tempAnnotation.coordinate = (self.mapView.centerCoordinate)
//      tempAnnotation.subtitle = self.searchingAddress
//
//			getReverseAddressXoaAPI(tempAnnotation)
//
//      if searchingAddress == "origen" {
//        mapView.removeAnnotation(self.origenAnnotation)
//        self.origenAnnotation = tempAnnotation
//        mapView.addAnnotation(self.origenAnnotation)
//      } else {
//        self.destinoAnnotation = tempAnnotation
//        mapView.addAnnotation(self.destinoAnnotation)
//      }
//
//    } else {
//			if mapView.zoomLevel == 15, searchingAddress == "origen" {
//				self.getTaxisCercanos()
//			}
//		}
//  }
//
//	func mapViewRegionIsChanging(_ mapView: MGLMapView) {
//		print("Changing")
//	}
//
//  func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
//    //self.loadGeoJson()
//		print("Finished Loading")
//  }
//
//  func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
//    print("Annotation Selected")
//  }
//}
//
//// MGLAnnotationView subclass
//class CustomAnnotationView: MGLAnnotationView {
//  override func layoutSubviews() {
//    super.layoutSubviews()
//
//    // Use CALayer’s corner radius to turn this view into a circle.
//    layer.cornerRadius = bounds.width / 2
//    layer.borderWidth = 2
//    layer.borderColor = UIColor.white.cgColor
//  }
//
//  override func setSelected(_ selected: Bool, animated: Bool) {
//    super.setSelected(selected, animated: animated)
//
//    // Animate the border width in/out, creating an iris effect.
//    let animation = CABasicAnimation(keyPath: "borderWidth")
//    animation.duration = 0.1
//    layer.borderWidth = selected ? bounds.width / 4 : 2
//    layer.add(animation, forKey: "borderWidth")
//  }
//}
//
//class CustomImageAnnotationView: MGLAnnotationView {
//  var imageView: UIImageView!
//
//  required init(reuseIdentifier: String?, image: UIImage) {
//    super.init(reuseIdentifier: reuseIdentifier)
//
//    self.imageView = UIImageView(image: image)
//    self.addSubview(self.imageView)
//    self.frame = self.imageView.frame
//  }
//
//  required init?(coder aDecoder: NSCoder) {
//    fatalError("init(coder:) has not been implemented")
//  }
//
//  override init(frame: CGRect) {
//    super.init(frame: frame)
//  }
//}
