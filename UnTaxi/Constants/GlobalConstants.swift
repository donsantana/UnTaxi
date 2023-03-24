//
//  GlobalConstants.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/4/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import Foundation

struct GlobalConstants {
  static var enviroment: String = "prod"
  static var urlServer: String = enviroment == "dev" ? "testing-untaxi.xoaserver.com" : "untaxi.xoaserver.com"//"premium.xoait.com" //untaxi.xoaserver.com
  static var urlHost: String = "https://\(urlServer)"//premium.xoait.com" //testing-untaxi.xoaserver.com
  static var socketurlHost: String = "https://client-\(urlServer)" //premium.xoait.com"
  static var paymentsUrl = "https://pay-\(urlServer)"
	static var paymentsUrlTesting = "https://pay-testing-untaxi.xoaserver.com"
  
  static var apiLoginUrl: String = "\(urlHost)/auth/client-login"
  static var passRecoverUrl: String = "\(urlHost)/recover-password"
  static var createPassUrl: String = "\(urlHost)/verify"
  static var passChangeUrl: String = "\(urlHost)/change-password"
  static var updateProfileUrl: String = "\(urlHost)/profile"
  static var registerUrl: String = "\(urlHost)/register"
	static var removeClient: String = "\(urlHost)/removeclient"
  static var subiraudioUrl: String = "\(urlHost)/voz"
  static var searchAddressUrl: String = "https://geosecure.xoaserver.com/api/?q=" //https://geosecure.xoaserver.com/api/?q=el%20dorado,Ecuador&limit=10&lon=-79.89725013269098&lat=-2.1363502421557943
	static var searchReverseAddressUrl: String = "https://geosecure.xoaserver.com/reverse?"
  static var listCardsUrl: String = "\(paymentsUrl)/card"
	static var addCardsUrl: String = "\(paymentsUrl)/card-add?token="
	static var removeCardsUrl: String = "\(paymentsUrl)/card"
  
  
  static var apiUser: String = "oinergb@xoait.com"
  static var apiPassword: String = "kmbz2vCVKzHLNChd"
  
  static var serverData = "173.249.32.181:6027"
  
  static var storeInfoURL: String = "http://itunes.apple.com/lookup?bundleId=com.xoait.UnTaxi"
  static var itunesURL: String = "itms-apps://itunes.apple.com/us/app/apple-store/id1149206387?mt=8"
  
  static var mapBoxToken = "pk.eyJ1IjoiZG9uZWxreXMiLCJhIjoiY2tha2h0M2piMG54ajJ5bW42Nmh3ODVxZyJ9.l9q-_04bUOhy7Gnwdfdx5g"
	
	static var googleAdsID = "ca-app-pub-1778988557303127/2416922071"
  
}
