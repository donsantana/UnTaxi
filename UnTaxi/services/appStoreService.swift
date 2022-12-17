//
//  appStoreService.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 10/29/22.
//  Copyright © 2022 Done Santana. All rights reserved.
//

import Foundation

class AppStoreService {
	static let shared = AppStoreService()
	
	func checkNewVersionAvailable() {
		var request = URLRequest(url: URL(string: GlobalConstants.storeInfoURL)!)
		request.httpMethod = "GET"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		
		let session = URLSession.shared
		let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
			
			guard let data = data else {
				print(String(describing: error))
				return
			}
			
			let appInfo = ItunesAppInfo(data: data)
			let appStoreVersion = appInfo?.results?.first?.version ?? "0.0"
			if let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {
				if appStoreVersion > currentVersion {
					globalVariables.newVersionAvailable = true
				}
			}
			
			print(String(data: data, encoding: .utf8)!)

//			if let error = error {
//				print(error.localizedDescription)
//				return
//			}
//
//			do {
//				let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
//				let elements = json["results"]
//				print(json)
//				guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
//
//					return
//				}
//			} catch {
//				print("Ha ocurrido un error en el servidor. Por favor, intentelo otra vez.")
//			}
		})
		
		task.resume()
		
//		let storeInfoURL: String = GlobalConstants.storeInfoURL
//		//var upgradeAvailable = false
//		
//		// Get the main bundle of the app so that we can determine the app's version number
//		let bundle = Bundle.main
//		if let infoDictionary = bundle.infoDictionary {
//			// The URL for this app on the iTunes store uses the Apple ID for the  This never changes, so it is a constant
//			let urlOnAppStore = URL(string: storeInfoURL)
//			if let dataInJSON = try? Data(contentsOf: urlOnAppStore!) {
//				// Try to deserialize the JSON that we got
//				if let lookupResults = try? JSONSerialization.jsonObject(with: dataInJSON, options: JSONSerialization.ReadingOptions()) as? Dictionary<String, Any>{
//					// Determine how many results we got. There should be exactly one, but will be zero if the URL was wrong
//					if let resultCount = lookupResults["resultCount"] as? Int {
//						if resultCount == 1 {
//							// Get the version number of the version in the App Store
//							//self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<String, AnyObject>>)[0]
//							if let appStoreVersion = (lookupResults["results"]as! Array<Dictionary<String, AnyObject>>)[0]["version"] as? String {
//								// Get the version number of the current version
//								if let currentVersion = infoDictionary["CFBundleShortVersionString"] as? String {
//									// Check if they are the same. If not, an upgrade is available.
//									if appStoreVersion > currentVersion {
//										globalVariables.newVersionAvailable = true
//									}
//								}
//							}
//						}
//					}
//				}
//			}
//		}
	}
}
