//
//  pagoApiService.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 10/8/22.
//  Copyright © 2022 Done Santana. All rights reserved.
//

import Foundation

protocol PagoApiServiceDelegate: AnyObject {
	func apiRequest(_ controller: PagoApiService, getCardsList data: [Card])
	func apiRequest(_ controller: PagoApiService, cardRemoved result: Int?)
	func apiRequest(_ controller: PagoApiService, getAPIError msg: String)
}

final class PagoApiService {
	static let shared = PagoApiService()
		
	weak var delegate: PagoApiServiceDelegate?
	
	func apiPOSTRequest(url: String, params: Dictionary<String, String>) -> URLRequest{
		var token = ""
		
		var request = URLRequest(url: URL(string: url)!)
		request.httpMethod = "POST"
		request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue("Bearer token", forHTTPHeaderField: "Authorization")
		
		return request
	}
	
	func listCardsAPIService(){
		print("List Card URL: \(GlobalConstants.listCardsUrl)")
		let accessToken = globalVariables.userDefaults.value(forKey: "accessToken") as! String
		var request = URLRequest(url: URL(string: GlobalConstants.listCardsUrl)!)
		request.httpMethod = "GET"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
		
		let session = URLSession.shared
		let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
			
			if let error = error {
				self.delegate?.apiRequest(self, getAPIError: error.localizedDescription)
				return
			}
			
			guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
				self.delegate?.apiRequest(self, getAPIError: "Ha ocurrido un error en el servidor. Por favor, intentelo otra vez.")
				return
			}
			if let data = data {
				let decoder = JSONDecoder()
				if let decodedResponse = try? decoder.decode(CardResponseData.self, from: data) {
					print("Response Decoded \(decodedResponse.cards)")
					self.delegate?.apiRequest(self, getCardsList: decodedResponse.cards)
				}else{
					self.delegate?.apiRequest(self, getCardsList: [])
				}
			}
			
		})
		
		task.resume()
	}
	
	func removeCardsAPIService(cardId: Int){
		let accessToken = globalVariables.userDefaults.value(forKey: "accessToken") as! String
		var request = URLRequest(url: URL(string: "\(GlobalConstants.listCardsUrl)/\(cardId)")!)
		request.httpMethod = "DELETE"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
		
		let session = URLSession.shared
		let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
			let response = response as! HTTPURLResponse
				if error == nil && response.statusCode == 200{
					self.delegate?.apiRequest(self, cardRemoved: cardId)
				} else {
					self.delegate?.apiRequest(self, cardRemoved: nil)
				}
		})
		
		task.resume()
	}
}

extension ApiServiceDelegate {
	func apiRequest(_ controller: PagoApiService, getCardsList data: [[String: Any]]){}
	func apiRequest(_ controller: PagoApiService, cardRemoved result: Int?){}
	func apiRequest(_ controller: PagoApiService, getAPIError msg: String){}
}
