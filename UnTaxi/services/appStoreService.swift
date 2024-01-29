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
    var newVersionAvailable = false
	
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
                self.newVersionAvailable = appStoreVersion > currentVersion
            }
			
			print(String(data: data, encoding: .utf8)!)
		})
		
		task.resume()
		
	}
}
