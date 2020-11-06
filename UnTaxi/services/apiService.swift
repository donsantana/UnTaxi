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
  func apiRequest(_ controller: ApiService, changeClaveAPI msg: String)
  func apiRequest(_ controller: ApiService, updatedProfileAPI status: Bool)
  func apiRequest(_ controller: ApiService, getLoginToken token: String)
  func apiRequest(_ controller: ApiService, getLoginData data: [String: Any])
  func apiRequest(_ controller: ApiService, getServerData serverData: String)
  func apiRequest(_ controller: ApiService, fileUploaded isSuccess: Bool)
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
  
  func changeClaveAPI(params: Dictionary<String, String>){
    var request = URLRequest(url: URL(string: GlobalConstants.passChangeUrl)!)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer \(globalVariables.userDefaults.value(forKey: "accessToken") as! String)", forHTTPHeaderField: "Authorization")
    request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
    
    let session = URLSession.shared
    let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
      let response = response as! HTTPURLResponse
      print("heree \(error) \(response.statusCode)")
      if error == nil && response.statusCode == 200{
        do {
          let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
          self.delegate?.apiRequest(self, changeClaveAPI: json["msg"] as! String)
        } catch {
          self.delegate?.apiRequest(self, changeClaveAPI: "Se produjo un error al intentar cambiar su clave, si no recuerda su clave actual puede cerrar sesión y utilizar la opción de Olvidé mi clave")
          print("error")
        }
      }else{
        self.delegate?.apiRequest(self, changeClaveAPI: "Se produjo un error al intentar cambiar su clave, si no recuerda su clave actual puede cerrar sesión y utilizar la opción de Olvidé mi clave")
        self.handlerExceptions(error: "API error")
      }
    })
    
    task.resume()
  }
  
  func updateProfileAPI(parameters: [String: AnyObject]){
    print(globalVariables.cliente.user)
    //let recordedFilePath = NSHomeDirectory() + "/Library/Caches/Image"
    let mimetype = "image/jpeg"
    
    var request : NSMutableURLRequest = NSMutableURLRequest()
    let body = NSMutableData()
    let boundary = "--------14737809831466499882746641449----"
    //Add extra parameters
    
    for (key, value) in parameters {
      body.append(("--\(boundary)\r\n").data(using: .utf8)!)
      body.append(("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n").data(using: .utf8)!)
      body.append(("\(value)\r\n").data(using: .utf8)!)
    }
    
    request = URLRequest(url: URL(string: GlobalConstants.updateProfileUrl)!) as! NSMutableURLRequest
    request.httpMethod = "POST"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer \(globalVariables.userDefaults.value(forKey: "accessToken") as! String)", forHTTPHeaderField: "Authorization")
    
    let fileData: Data = globalVariables.cliente.fotoImage.jpegData(compressionQuality: 1.0)!
    
    //Add File to body
    
    body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
    body.append("Content-Disposition:form-data; name=\"file\"\r\n\r\n".data(using: .utf8)!)
    body.append("hi\r\n".data(using: String.Encoding.utf8)!)
    body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
    body.append("Content-Disposition:form-data; name=\"file\"; filename=\"\(globalVariables.cliente.idUsuario).png\"\r\n".data(using: .utf8)!)
    body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
    body.append(fileData)
    body.append("\r\n".data(using: String.Encoding.utf8)!)
    body.append("--\(boundary)--\r\n".data(using: .utf8)!)

    request.httpBody = body as Data
    
    let session = URLSession.shared
    let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
      let statusCode = (response as? HTTPURLResponse)?.statusCode
      if error == nil && statusCode == 200{
          self.delegate?.apiRequest(self, updatedProfileAPI: true)
        print("file uploaded")
      }else{
        self.delegate?.apiRequest(self, updatedProfileAPI: false)
        print("error uploading file")
      }
    }
    task.resume()
  }
  
  func loginToAPIService(user: String, password: String){
    let params = ["user": user, "password": password, "version": "1.0.0"] as Dictionary<String, String>
    
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
          self.delegate?.apiRequest(self, getLoginData: json as [String: Any])
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
  
  func uploadFile(serverUrl: String, parameters: [String: AnyObject]?,localFilePath: String, fileName: String, mimetype: String){
    var request : NSMutableURLRequest = NSMutableURLRequest()
    let body = NSMutableData()
    let boundary = "--------14737809831466499882746641449----"
    //Add extra parameters
    if parameters != nil {
      for (key, value) in parameters! {
        body.append(("--\(boundary)\r\n").data(using: .utf8)!)
        body.append(("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n").data(using: .utf8)!)
        body.append(("\(value)\r\n").data(using: .utf8)!)
      }
    }
    
    request = URLRequest(url: URL(string: serverUrl)!) as! NSMutableURLRequest
    request.httpMethod = "POST"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer \(globalVariables.userDefaults.value(forKey: "accessToken") as! String)", forHTTPHeaderField: "Authorization")
    
    let recordedFilePath = localFilePath + fileName
    let recordedFileURL = URL(fileURLWithPath: recordedFilePath)
    let fileData: Data? = try? Data(contentsOf: recordedFileURL)
    
    //Add File to body
    
    body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
    body.append("Content-Disposition:form-data; name=\"file\"\r\n\r\n".data(using: .utf8)!)
    body.append("hi\r\n".data(using: String.Encoding.utf8)!)
    body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
    body.append("Content-Disposition:form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
    body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
    body.append(fileData!)
    body.append("\r\n".data(using: String.Encoding.utf8)!)
    body.append("--\(boundary)--\r\n".data(using: .utf8)!)

    request.httpBody = body as Data
    
    let session = URLSession.shared
    let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
      let statusCode = (response as? HTTPURLResponse)?.statusCode
      if error == nil && statusCode == 200{
        if mimetype == "image/jpeg" {
          self.delegate?.apiRequest(self, updatedProfileAPI: true)
        }else{
          self.delegate?.apiRequest(self, fileUploaded: statusCode == 200)
        }
        print("file uploaded")
      }else{
        if mimetype == "image/jpeg" {
          self.delegate?.apiRequest(self, updatedProfileAPI: false)
        }else{
          self.delegate?.apiRequest(self, fileUploaded: false)
        }
        print("error uploading file")
      }
    }
    task.resume()
  }
  
  
  //CODIGO PARA SUBIR ARCHIVOS CON APIS
  func subirAudioAPIService(solicitud: Solicitud, name: String){
    let recordedFilePath = NSHomeDirectory() + "/Library/Caches/Audio"
    let mimetype = "audio/x-m4a"
    let parameters = ["idsolicitud": solicitud.id, "idtaxi": solicitud.taxi.id] as [String: AnyObject]
    
    self.uploadFile(serverUrl: GlobalConstants.subiraudioUrl, parameters: parameters, localFilePath: recordedFilePath, fileName: name, mimetype: mimetype)
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
  func apiRequest(_ controller: ApiService, changeClaveAPI msg: String){}
  func apiRequest(_ controller: ApiService, updatedProfileAPI status: Bool){}
  func apiRequest(_ controller: ApiService, getServerData serverData: String){}
  func apiRequest(_ controller: ApiService, fileUploaded isSuccess: Bool){}
  func apiRequest(_ controller: ApiService, getCardsList data: [[String: Any]]){}
  func apiRequest(_ controller: ApiService, cardRemoved result: String?){}
  func apiRequest(_ controller: ApiService, getLoginError msg: String){}
}
