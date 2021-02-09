//
//  AddressController.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 12/26/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit
import Mapbox
import MapboxSearch
import MapboxSearchUI
import MapboxDirections

class AddressController: UIViewController {
  
  var annotationTemp: MGLPointAnnotation!
  var startLocation: CLLocationCoordinate2D!
  let searchController = MapboxSearchController()
  var keyboardHeight:CGFloat!
  let openMapBtn = UIButton(type: UIButton.ButtonType.system)
  
  @IBOutlet weak var mapView: MGLMapView!
  @IBOutlet weak var openMapView: UIView!
  @IBOutlet weak var openMapViewBottomConstraint: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.setNavigationBarHidden(false, animated: false)
    self.mapView.delegate = self
    mapView.automaticallyAdjustsContentInset = true
    searchController.delegate = self
    let panelController = MapboxPanelController(rootViewController: searchController)
    panelController.setState(.opened)
    self.startLocation = globalVariables.cliente.annotation.coordinate
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    
    openMapBtn.frame = CGRect(x: 0, y: Responsive().heightFloatPercent(percent: 80), width: self.view.bounds.width - 40, height: 40)
    let mapaImage = UIImage(named: "mapLocation")?.withRenderingMode(.alwaysOriginal)
    openMapBtn.setImage(mapaImage, for: UIControl.State())
    openMapBtn.setTitle("Fijar ubicación en el mapa", for: .normal)
    //openMapBtn.addTarget(self, action: #selector(openMapBtnAction), for: .touchUpInside)
    openMapBtn.layer.cornerRadius = 10
    //openMapBtn.titleLabel?.font = CustomAppFont.buttonFont
    openMapBtn.backgroundColor = .white
    openMapBtn.tintColor = .black
    openMapBtn.addShadow()
    self.annotationTemp.coordinate = startLocation
    panelController.view.addSubview(openMapBtn)
    addChild(panelController)
    self.initMapView()
    
  }
  
  func initMapView(){
    mapView.setCenter(self.startLocation, zoomLevel: 10, animated: false)
    mapView.styleURL = MGLStyle.lightStyleURL
    //self.locationIcono.image = UIImage(named: self.annotationTemp.title!)
    //self.locationIcono.isHidden = true
    self.mapView.addAnnotation(self.annotationTemp)
  }
  
  func goToInicioView(){
    DispatchQueue.main.async {
      let vc = R.storyboard.main.inicioView()!
      if self.annotationTemp.subtitle == "origen"{
        vc.origenAnnotation = self.annotationTemp
      }else{
        vc.destinoAnnotation = self.annotationTemp
      }
      self.navigationController?.show(vc, sender: nil)
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

//extension AddressController: SearchEngineDelegate {
//  func resultsUpdated(searchEngine: SearchEngine) {
//    print("Number of search results: \(searchEngine.items.count) for query: \(searchEngine.query)")
//    self.searchResultItems = searchEngine.items
//    //responseLabel.text = "q: \(searchEngine.query), count: \(searchEngine.items.count)"
//  }
//
//  func resolvedResult(result: SearchResult) {
//    print("Dumping resolved result:", dump(result))
//    var annotationView = MGLPointAnnotation()
//    annotationView.coordinate = result.coordinate
//    annotationView.subtitle = result.address?.formattedAddress(style: .medium)
//    annotationView.title = self.annotationTemp.title
//    DispatchQueue.main.async {
//      let vc = R.storyboard.main.inicioView()!
//      vc.destinoAnnotation = annotationView
//      self.navigationController?.show(vc, sender: nil)
//    }
//  }
//
//  func searchErrorHappened(searchError: SearchError) {
//    print("Error during search: \(searchError)")
//  }
//}

extension AddressController: SearchControllerDelegate {
  func searchResultSelected(_ searchResult: SearchResult) {
    //var annotationView = MGLPointAnnotation()
    self.annotationTemp.coordinate = searchResult.coordinate
    self.annotationTemp.title = searchResult.address?.formattedAddress(style: .medium)
    self.goToInicioView()
  }
  
  func categorySearchResultsReceived(results: [SearchResult]) { }
  func userFavoriteSelected(_ userFavorite: FavoriteRecord) { }
}
