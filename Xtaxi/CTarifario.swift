//
//  CTarifario.swift
//  XTaxi
//
//  Created by Done Santana on 25/6/16.
//  Copyright © 2016 Done Santana. All rights reserved.
//

import Foundation
import GoogleMaps


class CTarifario{
    var origenCoord: String
    var destinoCoord: String
    
    init(){
        self.origenCoord = String()
        self.destinoCoord = String()
    }
    func InsertarOrigen(origen: CLLocationCoordinate2D){
        self.origenCoord = String(origen.latitude) + "," + String(origen.longitude)
    }
    func InsertarDestino(destino: CLLocationCoordinate2D){
        self.destinoCoord = String(destino.latitude) + "," + String(destino.longitude)
    }
    func CalcularTarifa(tarifas: [CTarifa])->[String]{
        let ruta = CRuta(origin: origenCoord, destination: destinoCoord)
        let dateFormatter = NSDateFormatter()
        var costo : Double!
        dateFormatter.dateFormat = "hh"
        let horaActual = dateFormatter.stringFromDate(NSDate())
        var tarifa = Double()
        var distancia = ruta.totalDistance
        for var tarifatemporal in tarifas{
            if (Int(tarifatemporal.horaInicio) <= Int(horaActual)) && (Int(horaActual) <= Int(tarifatemporal.horaFin)){
                tarifa = Double(tarifatemporal.valorKilometro)
            }
            if Double(distancia) >= 1{
                costo = Double(distancia)! * tarifa
            }
            else{
                costo = Double(tarifatemporal.valorMinimo)
            }
        }
        
      
        return [ruta.totalDistance, ruta.totalDuration, String(costo)]
    }
    func CalcularRuta()->GMSPolyline{
        let ruta = CRuta(origin: origenCoord, destination: destinoCoord)
        let routePolyline = ruta.drawRoute()
        let lines = GMSPolyline(path: routePolyline)
        return lines
    }
    
}