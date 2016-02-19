//
//  PantallaSolic.swift
//  Xtaxi
//
//  Created by Done Santana on 5/2/16.
//  Copyright © 2016 Done Santana. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class PantallaSolic: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var Solicitud: CSolPendiente?
    var coreLocationManager : CLLocationManager!
    var miposicion = CLLocationCoordinate2D()
    var locationMarker = MKPointAnnotation()
    var taxiLocation = MKPointAnnotation()
    var userAnotacion = MKPointAnnotation()
    var origenAnotacion = MKPointAnnotation()
    var destinoAnotacion = MKPointAnnotation()
    var span : MKCoordinateSpan!
    var region : MKCoordinateRegion!
    var puntoOrigen : MKMapItem!
    var puntoDestino : MKMapItem!
    var mapaVista = MKMapView()
    
    
    @IBOutlet weak var Prueba: UILabel!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        self.Prueba.text = Solicitud?.FechaHora
        self.origenAnotacion.coordinate = CLLocationCoordinate2DMake(Double(Solicitud!.Latitudorigen)!, Double(Solicitud!.Longitudorigen)!)
        self.destinoAnotacion.coordinate = CLLocationCoordinate2DMake(Double(Solicitud!.Latituddestino)!, Double(Solicitud!.Longituddestino)!)
        self.taxiLocation.coordinate = CLLocationCoordinate2DMake(Double(Solicitud!.Latitudtaxi)!, Double(Solicitud!.Longitudtaxi)!)
        span = MKCoordinateSpanMake(1.2 , 1.2)
        let region = MKCoordinateRegion(center: origenAnotacion.coordinate, span: span)
        mapaVista.setRegion(region, animated: true)
        
        mapaVista.removeAnnotations(mapaVista.annotations)
        mapaVista.addAnnotation(origenAnotacion)
        mapaVista.addAnnotation(destinoAnotacion)
        mapaVista.addAnnotation(taxiLocation)
        
    }
    
    //Función para personalizar las anotaciones en el mapa, se llama automaticamente cada vez que se dibuja una anotación.
    func mapView(mapaView: MKMapView, viewForAnnotation anotacion: MKAnnotation) -> MKAnnotationView? {
        
        let reusarId = "anotacion"
        var anotacionView = mapaView.dequeueReusableAnnotationViewWithIdentifier(reusarId)
        if anotacionView == nil {
            anotacionView = MKAnnotationView(annotation: anotacion, reuseIdentifier: reusarId)
        }
        else {
            anotacionView!.annotation = anotacion
        }
        if anotacion.isEqual(userAnotacion) {
            anotacionView!.image = UIImage(named:"origen")
        }
        else {
            if anotacion.isEqual(origenAnotacion) {
                anotacionView!.image = UIImage(named:"origen")
            }
            else {
                if anotacion.isEqual(destinoAnotacion){
                    anotacionView!.image = UIImage(named:"destino")
                }
                else {
                    if anotacion.isEqual(taxiLocation){
                        anotacionView!.image = UIImage(named:"taxi_libre")
                    }
                    
                }
            }
        }
        anotacionView!.canShowCallout = true
        
        return anotacionView
        
    }

    
    
}