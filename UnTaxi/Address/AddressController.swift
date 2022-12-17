//
//  AddressController.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 12/26/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit
import MapboxMaps
import MapboxSearch
import MapboxSearchUI
import MapboxDirections

class AddressController: UIViewController {
  
  var annotationTemp = MyMapAnnotation()
  var startLocation: CLLocationCoordinate2D!
  let searchController = MapboxSearchController()
  var keyboardHeight:CGFloat!
  let openMapBtn = UIButton(type: UIButton.ButtonType.system)
  
  
  @IBOutlet weak var mapView: MapView!
  @IBOutlet weak var searchView: UIView!
  //@IBOutlet weak var openMapViewBottomConstraint: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.setNavigationBarHidden(false, animated: false)
//    mapView.delegate = self
//    mapView.automaticallyAdjustsContentInset = true
    searchController.delegate = self

    let panelController = MapboxPanelController(rootViewController: searchController)
    panelController.setState(.opened)
    self.startLocation = globalVariables.cliente.annotation.coordinates
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    
    openMapBtn.frame = CGRect(x: 0, y: Responsive().heightFloatPercent(percent: 80), width: self.view.bounds.width - 40, height: 40)
    let mapaImage = UIImage(named: "mapLocation")?.withRenderingMode(.alwaysOriginal)
    openMapBtn.setImage(mapaImage, for: UIControl.State())
    openMapBtn.setTitle("Fijar ubicación en el mapa", for: .normal)
    openMapBtn.layer.cornerRadius = 10
    openMapBtn.backgroundColor = .white
    openMapBtn.tintColor = .black
    openMapBtn.addShadow()
    //self.annotationTemp.coordinate = startLocation
    panelController.view.addSubview(openMapBtn)
    addChild(panelController)
    initMapView()
    
  }
  
  func initMapView() {
		let centerCoordinate = CLLocationCoordinate2D(latitude: self.startLocation.latitude, longitude: self.startLocation.longitude)
		let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 8.0))
		mapView = MapView(frame: view.bounds,mapInitOptions: options)//(self.startLocation, zoomLevel: 10, animated: false)
		let pointAnnotationManager = mapView.annotations.makePointAnnotationManager()
		pointAnnotationManager.annotations = [annotationTemp.annotation]
    //self.mapView.addAnnotation(self.annotationTemp)
  }
  
  func goToInicioView(){
    DispatchQueue.main.async {
      let vc = R.storyboard.main.inicioView()!
      if self.annotationTemp.type == "origen" {
        vc.origenAnnotation = self.annotationTemp
      } else {
        vc.destinoAnnotation = self.annotationTemp
      }
      self.dismiss(animated: false, completion: nil)
      //self.present(vc, animated: false, completion: nil)
      //self.navigationController?.show(vc, sender: nil)
    }
  }
  
  @objc func keyboardWillShow(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
      self.openMapBtn.frame = CGRect(x: 0, y: Responsive().heightFloatPercent(percent: 80) - keyboardSize.height, width: self.view.bounds.width - 40, height: 40)
      self.keyboardHeight = keyboardSize.height
    }
  }
  
  @IBAction func closeView(_ sender: Any) {
    self.goToInicioView()
  }
  
  @IBAction func getAddressText(_ sender: Any) {
    
  }
  
}

extension AddressController: SearchEngineDelegate {
	func suggestionsUpdated(suggestions: [MapboxSearch.SearchSuggestion], searchEngine: MapboxSearch.SearchEngine) {
		//<#code#>
	}
	
	func resultResolved(result: MapboxSearch.SearchResult, searchEngine: MapboxSearch.SearchEngine) {
		//<#code#>
	}
	
	func searchErrorHappened(searchError: MapboxSearch.SearchError, searchEngine: MapboxSearch.SearchEngine) {
		//<#code#>
	}
	
  func resultsUpdated(searchEngine: SearchEngine) {
    //print("Number of search results: \(searchEngine.items.count) for query: \(searchEngine.query)")
    //self.searchResultItems = searchEngine.items
    //responseLabel.text = "q: \(searchEngine.query), count: \(searchEngine.items.count)"
  }

  func resolvedResult(result: SearchResult) {
    print("Dumping resolved result:", dump(result))
		var annotationView = MyMapAnnotation(type: self.annotationTemp.type, address: (result.address?.formattedAddress(style: .medium))!, location: result.coordinate, imageName: nil)
    DispatchQueue.main.async {
      let vc = R.storyboard.main.inicioView()!
      vc.destinoAnnotation = annotationView
      self.navigationController?.show(vc, sender: nil)
    }
  }

  func searchErrorHappened(searchError: SearchError) {
    print("Error during search: \(searchError)")
  }
}

extension AddressController: SearchControllerDelegate {
	func categorySearchResultsReceived(category: MapboxSearchUI.SearchCategory, results: [MapboxSearch.SearchResult]) {
		//<#code#>
	}
	
  func searchResultSelected(_ searchResult: SearchResult) {
    //var annotationView = MGLPointAnnotation()
    self.annotationTemp.coordinates = searchResult.coordinate
		self.annotationTemp.address = (searchResult.address?.formattedAddress(style: .medium))!
    self.goToInicioView()
  }

  func categorySearchResultsReceived(results: [SearchResult]) { }
  func userFavoriteSelected(_ userFavorite: FavoriteRecord) { }
}
