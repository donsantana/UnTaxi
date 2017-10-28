//
//  TarifarioController.swift
//  UnTaxi
//
//  Created by Done Santana on 27/2/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import UIKit
import GoogleMaps

class TarifarioController: UIViewController, CLLocationManagerDelegate, UITextViewDelegate, GMSMapViewDelegate {
    
    
    var OrigenTarifario = GMSMarker()
    var DestinoTarifario = GMSMarker()
    var tarifario = CTarifario()
    var tarifas = [CTarifa]()
    
    
    //MASK:- VARIABLES INTERFAZ
    
    @IBOutlet weak var origenIcono: UIImageView!
    @IBOutlet weak var ExplicacionView: UIView!
    @IBOutlet weak var ExplicacionText: UILabel!
    
    
    @IBOutlet weak var MapaTarifario: GMSMapView!
    @IBOutlet weak var DestinoTarifarioBtn: UIButton!
    @IBOutlet weak var CalcularTarifarioBtn: UIButton!    
    @IBOutlet weak var ReinciarTarifarioBtn: UIButton!
    
    @IBOutlet weak var DetallesCarreraView: UIView!
    @IBOutlet weak var DistanciaText: UILabel!
    @IBOutlet weak var DuracionText: UILabel!
    @IBOutlet weak var CostoText: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.MapaTarifario.delegate = self
        MapaTarifario.camera = GMSCameraPosition.camera(withLatitude: -2.137072,longitude:-79.903454,zoom: 15)
        // Do any additional setup after loading the view.
    }

  
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {

    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        origenIcono.isHidden = true
        
        if DestinoTarifarioBtn.isHidden == false {
            OrigenTarifario = GMSMarker(position: MapaTarifario.camera.target)
            OrigenTarifario.icon = UIImage(named: "origen")
            OrigenTarifario.map = MapaTarifario
            //GeolocalizandoView.isHidden = false
        }
        else{
            if CalcularTarifarioBtn.isHidden == false{
                DestinoTarifario = GMSMarker(position: MapaTarifario.camera.target)
                DestinoTarifario.icon = UIImage(named: "destino")
                DestinoTarifario.map = MapaTarifario
            }
        }
    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if ReinciarTarifarioBtn.isHidden == true{
            origenIcono.isHidden = false
            if DestinoTarifarioBtn.isHidden == false {
                OrigenTarifario.map = nil
                ExplicacionText.text = "Localice el origen en el mapa"
            }
            else{
                DestinoTarifario.map = nil
                ExplicacionText.text = "Localice el destino en el mapa"
            }
        }
    }


    //MASK:- FUNCIONES PROPIAS
    
    //MOSTRAR TODOS LOS MARCADORES EN PANTALLA
    func fitAllMarkers(_ markers: [GMSMarker]) {
        var bounds = GMSCoordinateBounds()
        for marcador in markers{
            bounds = bounds.includingCoordinate(marcador.position)
        }
        MapaTarifario.animate(with: GMSCameraUpdate.fit(bounds))
    }

    // MARK: - BOTONES
    //BOTONES DEL TARIFARIO
    @IBAction func DestinoTarifario(_ sender: AnyObject) {
        self.OrigenTarifario = GMSMarker(position: self.MapaTarifario.camera.target)
        self.tarifario.InsertarOrigen(OrigenTarifario.position)
        OrigenTarifario.icon = UIImage(named: "origen")
        OrigenTarifario.map = MapaTarifario
        origenIcono.image = UIImage(named: "destino2@2x")
        ExplicacionText.text = "Localice el destino"
        DestinoTarifarioBtn.isHidden = true
        CalcularTarifarioBtn.isHidden = false
    }
    
    @IBAction func CalcularTarifario(_ sender: AnyObject) {
        self.DestinoTarifario = GMSMarker(position: self.MapaTarifario.camera.target)
        self.tarifario.InsertarDestino(DestinoTarifario.position)
        DestinoTarifario.icon = UIImage(named: "destino")
        DestinoTarifario.map = MapaTarifario
        self.fitAllMarkers([self.OrigenTarifario, self.DestinoTarifario])
        origenIcono.isHidden = true
        ExplicacionView.isHidden = true
        ReinciarTarifarioBtn.isHidden = false
        CalcularTarifarioBtn.isHidden = true
        //let temporal = self.tarifario.CalcularTarifa(tarifas)
        DetallesCarreraView.isHidden = false
        let lines = self.tarifario.CalcularRuta()
        lines.strokeWidth = 5
        lines.map = self.MapaTarifario
        lines.strokeColor = UIColor.green
        //DistanciaText.text = temporal[0] + " KM"
        //DuracionText.text = temporal[1]
        //CostoText.text = "$" + temporal[2]
        
    }
    
    @IBAction func ReiniciarTarifario(_ sender: AnyObject) {
        MapaTarifario.clear()
        ExplicacionView.isHidden = false
        DetallesCarreraView.isHidden = true
        ReinciarTarifarioBtn.isHidden = true
        DestinoTarifarioBtn.isHidden = false
        self.OrigenTarifario = GMSMarker(position: self.MapaTarifario.camera.target)
        OrigenTarifario.icon = UIImage(named: "origen")
        OrigenTarifario.map = MapaTarifario
        ExplicacionText.text = "Localice el origen en el mapa"
    }



}
