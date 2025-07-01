//
//  AddressService.swift
//  EasyCar
//
//  Created by Done Santana on 2/11/25.
//  Copyright © 2025 Done Santana. All rights reserved.
//

import Foundation


class AddressService {
    
    static let shared = AddressService()
    
//    func apiPOSTRequest(url: String, params: Dictionary<String, String>) -> URLRequest{
//        var token = ""
//        
//        var request = URLRequest(url: URL(string: url)!)
//        request.httpMethod = "POST"
//        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("Bearer token", forHTTPHeaderField: "Authorization")
//        
//        return request
//    }
//    
//    internal func parseResponse(_ data: Data?, _ response: URLResponse?,_ error: Error?) -> Result<Any, APIError> {
//        if let error = error {
//            return .failure(.serverError(message: error.localizedDescription))
//        }
//        
//        do {
//            let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
//            
//            print("json \(json["msg"] as! String)")
//            
//            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
//                return .failure(.invalidResponse(message: json["msg"] as? String ?? "Error no especificado"))
//            }
//            return .success(json["msg"] as? String ?? "Success")
//        } catch {
//            return .failure(.invalidData)
//        }
//    }
    
    func searchAddress(searchQuery: String, lat: Double, lon: Double, completion: @escaping (Result<[AddressOptionItem], APIError>) -> Void) {
        //&lon=-79.89725013269098&lat=-2.1363502421557943
        let country = globalVariables.cliente.annotation.address
        let searchQueryText = searchQuery.replacingOccurrences(of: " ", with: "%20")
        //let urlString = "\(GlobalConstants.searchAddressUrl)\(searchQueryText.replacingOccurrences(of: "ñ", with: "n"))"
        let urlString = "\(GlobalConstants.searchAddressUrl)"
        //    let urlString = "\(GlobalConstants.searchAddressUrl)\(searchQueryText.replacingOccurrences(of: "ñ", with: "n")),Ecuador&lon=-79.89725013269098&lat=-2.1363502421557943"
        print("urlString: \(urlString)")
        print("accessToken: \(UserDefaults.standard.value(forKey: "accessToken") as! String)")
        print("country: \(country)")
        //let accessToken = UserDefaults.standard.value(forKey: "accessToken") as! String
        let params: Dictionary<String, Any> = [
            "lng": lon,
            "lat": lat,
            "limit": 15,
            "query": searchQueryText,
            "country": country,
            "radius": 10000
        ]
        var request = URLRequest(url: (URL(string: "\(urlString)") ?? URL(string: "\(GlobalConstants.searchAddressUrl)"))!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.standard.value(forKey: "accessToken") as! String)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if let error = error {
                completion(.failure(.serverError(message: error.localizedDescription)))
            }
            
            do {
                guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    completion(.failure(.invalidResponse(message: GlobalStrings.errorGenericoMessage)))
                    return
                }
                guard let data = data else {
                    completion(.failure(.invalidData))
                    return
                }
                let addressOptionsList = try JSONDecoder().decode(AddressOptionsList.self, from: data)
                completion(.success(addressOptionsList.list))
            } catch {
                completion(.failure(.invalidData))
            }
        })
        
        task.resume()
    }
    
    func searchAddressPoint(placeId: String, completion: @escaping (Result<Coordinates, APIError>) -> Void) {
        //&lon=-79.89725013269098&lat=-2.1363502421557943
        let urlString = "\(GlobalConstants.addressCoordinateUrl)"
        //    let urlString = "\(GlobalConstants.searchAddressUrl)\(searchQueryText.replacingOccurrences(of: "ñ", with: "n")),Ecuador&lon=-79.89725013269098&lat=-2.1363502421557943"
        //let accessToken = UserDefaults.standard.value(forKey: "accessToken") as! String
        let params: Dictionary<String, Any> = [
            "id": placeId
        ]
        var request = URLRequest(url: (URL(string: "\(urlString)") ?? URL(string: "\(GlobalConstants.searchAddressUrl)"))!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.standard.value(forKey: "accessToken") as! String)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if let error = error {
                completion(.failure(.serverError(message: error.localizedDescription)))
            }
            
            do {
                guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    completion(.failure(.invalidResponse(message: GlobalStrings.errorGenericoMessage)))
                    return
                }
                guard let data = data else {
                    completion(.failure(.invalidData))
                    return
                }
                let coordinates = try JSONDecoder().decode(Coordinates.self, from: data)
                completion(.success(coordinates))
            } catch {
                completion(.failure(.invalidData))
            }
        })
        
        task.resume()
    }
    
    
}
