//
//  apiService.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 4/12/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import Foundation

protocol ApiServiceDelegate: class {
  func apiRequest(_ controller: ApiService, apiPOSTRequest response: Dictionary<String, AnyObject>)
  func apiRequest(_ controller: ApiService, registerUserAPI msg: String)
  func apiRequest(_ controller: ApiService, recoverUserClaveAPI msg: String)
  func apiRequest(_ controller: ApiService, createNewClaveAPI msg: String)
  func apiRequest(_ controller: ApiService, getLoginToken token: String)
  func apiRequest(_ controller: ApiService, getLoginData data: [String: Any])
  func apiRequest(_ controller: ApiService, getServerData serverData: String)
  func apiRequest(_ controller: ApiService, getCardsList data: [[String: Any]])
  func apiRequest(_ controller: ApiService, cardRemoved result: String?)
  func apiRequest(_ controller: ApiService, getLoginError msg: String)
}

final class ApiService {
  
  weak var delegate: ApiServiceDelegate?
  
  func apiPOSTRequest(url: String, params: Dictionary<String, String>) -> URLRequest{
    var token = ""
    
    var request = URLRequest(url: URL(string: url)!)
    request.httpMethod = "POST"
    request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer token", forHTTPHeaderField: "Authorization") 
    
    return request
  }
  
  func registerUserAPI(url: String, params: Dictionary<String, String>){
    let request = self.apiPOSTRequest(url: url, params: params)
    let session = URLSession.shared
    let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
      let response = response as! HTTPURLResponse
      print("heree \(error) \(response.statusCode)")
      if error == nil && response.statusCode == 201{
        print(response)
        do {
          let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
          self.delegate?.apiRequest(self, registerUserAPI: json["msg"] as! String)
        } catch {
          print("error")
        }
      }else{
        self.handlerExceptions(error: "API error")
      }
    })
    
    task.resume()
  }
  
  func recoverUserClaveAPI(url: String, params: Dictionary<String, String>){
    let request = self.apiPOSTRequest(url: url, params: params)
    let session = URLSession.shared
    let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
      let response = response as! HTTPURLResponse
      print("heree \(error) \(response.statusCode)")
      if error == nil && response.statusCode == 200{
        do {
          let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
          self.delegate?.apiRequest(self, recoverUserClaveAPI: json["msg"] as! String)
        } catch {
          print("error")
        }
      }else{
        self.handlerExceptions(error: "API error")
      }
    })
    
    task.resume()
  }
  
  func createNewClaveAPI(url: String, params: Dictionary<String, String>){
    let request = self.apiPOSTRequest(url: url, params: params)
    let session = URLSession.shared
    let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
      let response = response as! HTTPURLResponse
      print("heree \(error) \(response.statusCode)")
      if error == nil && response.statusCode == 200{
        do {
          let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
          self.delegate?.apiRequest(self, createNewClaveAPI: json["msg"] as! String)
        } catch {
          print("error")
        }
      }else{
        self.handlerExceptions(error: "API error")
      }
    })
    
    task.resume()
  }
  
  func loginToAPIService(user: String, password: String){
    let params = ["user": user, "password": password, "version": "3.0.0"] as Dictionary<String, String>
    
    var request = URLRequest(url: URL(string: GlobalConstants.apiLoginUrl)!)
    request.httpMethod = "POST"
    request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let session = URLSession.shared
    let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
      let response = response as! HTTPURLResponse
      if error == nil && response.statusCode == 200{
        print(response)
        do {
          let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
          print(json["config"] as! [String: Any])
          //self.delegate?.apiRequest(self, getLoginToken: json["token"] as! String)
          self.delegate?.apiRequest(self, getLoginData: json as! [String: Any])
        } catch {
          print("error")
        }
      }else{
        do {
          let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
          self.delegate?.apiRequest(self, getLoginError: json["msg"] as! String)
        } catch {
          print("error")
        }
      }
    })
    
    task.resume()
  }
  
  func listCardsAPIService(){
    let accessToken = globalVariables.userDefaults.value(forKey: "accessToken") as! String
    var request = URLRequest(url: URL(string: GlobalConstants.listCardsUrl)!)
    request.httpMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    
    let session = URLSession.shared
    let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
      if error == nil{
        print(response!)
        
        do {
          let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
          print(json)
          self.delegate?.apiRequest(self, getCardsList: json["cards"] as! [[String:Any]])
        } catch {
          print("error")
        }
      }else{
        //print("error \(error)")
      }
    })
    
    task.resume()
  }
  
  func removeCardsAPIService(cardToken: String){
    let accessToken = globalVariables.userDefaults.value(forKey: "accessToken") as! String
    var request = URLRequest(url: URL(string: "\(GlobalConstants.listCardsUrl)/\(cardToken)")!)
    request.httpMethod = "DELETE"
    //request.httpBody = try? JSONSerialization.data(withJSONObject: ["token": cardToken], options: [])
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    
    let session = URLSession.shared
    let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
      let response = response as! HTTPURLResponse
        print("heree \(error) \(response.statusCode)")
        if error == nil && response.statusCode == 200{
          self.delegate?.apiRequest(self, cardRemoved: cardToken)
        }else{
          self.delegate?.apiRequest(self, cardRemoved: nil)
        }
    })
    
    task.resume()
  }
  
//  func getServerConnectionData(token: String){
//    let header = ["Authorization":"Bearer \(token)"] as Dictionary<String, String>
//    var request = URLRequest(url: URL(string: GlobalConstants.apiServerPortUrl)!)
//    request.httpMethod = "GET"
//    request.allHTTPHeaderFields = header
//    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//    
//    let session = URLSession.shared
//    let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
//      if error == nil{
//        //print("respuesta \(response["cliente"])")
//        do {
//          let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
//          self.delegate?.apiRequest(self, getServerData: "\(json["cliente"]!["ip"] as! String):\(json["cliente"]!["p"] as! String)")
//          //Customization.serverData = "\(json["cliente"]!["ip"] as! String):\(json["cliente"]!["p"] as! String)"
//        } catch {
//          print("error URL")
//        }
//      }else{
//        //print("error \(error)")
//      }
//    })
//    task.resume()
//  }
  
  func handlerExceptions(error: String){
    print(error)
  }
  
}

extension ApiServiceDelegate{
  func apiRequest(_ controller: ApiService, apiPOSTRequest response: Dictionary<String, AnyObject>){}
  func apiRequest(_ controller: ApiService, getLoginToken token: String){}
  func apiRequest(_ controller: ApiService, getLoginData data: [String: Any]){}
  func apiRequest(_ controller: ApiService, registerUserAPI msg: String){}
  func apiRequest(_ controller: ApiService, recoverUserClaveAPI msg: String){}
  func apiRequest(_ controller: ApiService, createNewClaveAPI msg: String){}
  func apiRequest(_ controller: ApiService, getServerData serverData: String){}
  func apiRequest(_ controller: ApiService, getCardsList data: [[String: Any]]){}
  func apiRequest(_ controller: ApiService, cardRemoved result: String?){}
  func apiRequest(_ controller: ApiService, getLoginError msg: String){}
}
