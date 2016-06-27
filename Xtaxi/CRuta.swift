//
//  CRuta.swift
//  Xtaxi
//
//  Created by usuario on 15/3/16.
//  Copyright © 2016 Done Santana. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

class CRuta{
    
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    var selectedRoute: Dictionary<NSObject, AnyObject>!
    var overviewPolyline: Dictionary<NSObject, AnyObject>!
    var originCoordinate: CLLocationCoordinate2D!
    var destinationCoordinate: CLLocationCoordinate2D!
    var originAddress: String!
    var destinationAddress: String!
    var totalDistanceInMeters: UInt = 0
    var totalDistance: String!
    var totalDurationInSeconds: UInt = 0
    var totalDuration: String!
    
    init(){
    
    }
    init(origin: String, destination: String){
        
        var directionsURLString = baseURLDirections + "origin=" + origin + "&destination=" + destination
        
        directionsURLString = directionsURLString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        let directionsURL = NSURL(string: directionsURLString)
        var dictionary: Dictionary<NSObject, AnyObject> = Dictionary()
        
        //dispatch_async(dispatch_get_main_queue(), {() -> Void in
            let directionsData = NSData(contentsOfURL: directionsURL!)
            
            do {
                dictionary = try NSJSONSerialization.JSONObjectWithData(directionsData!, options: NSJSONReadingOptions.MutableContainers) as! Dictionary
            } catch{
                print(error)
            }
            let status = dictionary["status"] as! String
            if status == "OK"{
                
                self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<NSObject, AnyObject>>)[0]
                self.overviewPolyline = self.selectedRoute["overview_polyline"] as! Dictionary<NSObject, AnyObject>
                
                let legs = self.selectedRoute["legs"] as! Array<Dictionary<NSObject, AnyObject>>
                
                let startLocationDictionary = legs[0]["start_location"] as! Dictionary<NSObject, AnyObject>
                self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
                
                let endLocationDictionary = legs[legs.count - 1]["end_location"] as! Dictionary<NSObject, AnyObject>
                self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)
                
                self.originAddress = legs[0]["start_address"] as! String
                self.destinationAddress = legs[legs.count - 1]["end_address"] as! String
                
                self.calculateTotalDistanceAndDuration()
            }
    }
    
    func calculateTotalDistanceAndDuration() {
        let legs = self.selectedRoute["legs"] as! Array<Dictionary<NSObject, AnyObject>>
        
        totalDistanceInMeters = 0
        totalDurationInSeconds = 0
        
        for leg in legs {
            totalDistanceInMeters += (leg["distance"] as! Dictionary<NSObject, AnyObject>)["value"] as! UInt
            totalDurationInSeconds += (leg["duration"] as! Dictionary<NSObject, AnyObject>)["value"] as! UInt
        }
        
        let distanceInKilometers: Double = Double(totalDistanceInMeters / 1000)
        self.totalDistance = "\(distanceInKilometers)"
        
        
        let mins = totalDurationInSeconds / 60
        let hours = mins / 60
       //let days = hours / 24
        let remainingHours = hours % 24
        let remainingMins = mins % 60
        let remainingSecs = totalDurationInSeconds % 60
        
        self.totalDuration = "\(remainingHours)h:\(remainingMins)m:\(remainingSecs)s"
    }
    
    func displayRouteInfo() ->[String]{
        return [self.totalDistance,self.totalDuration]
    }
    
    func drawRoute()->GMSPath{
        let route = self.overviewPolyline["points"] as! String
        return GMSPath(fromEncodedPath: route)        
    }
    
}