//
//  apiService.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 4/12/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//


import Foundation
import UIKit

enum APIError: Error {
    case invalidURL
    case invalidResponse(message: String)
    case invalidData
    case serverError(message: String)
}

protocol ApiServiceDelegate: AnyObject {
    func apiRequest(_ controller: ApiService, apiPOSTRequest response: Dictionary<String, AnyObject>)
    func apiRequest(_ controller: ApiService, registerUserAPI success: Bool, msg: String)
    func apiRequest(_ controller: ApiService, newRegisterUserAPI success: Bool, msg: String)
    func apiRequest(_ controller: ApiService, validateRegisterCodeAPI success: Bool, msg: String)
    func apiRequest(_ controller: ApiService, removeClientAPI success: Bool, msg: String)
    func apiRequest(_ controller: ApiService, recoverUserClaveAPI success: Bool, msg: String)
    func apiRequest(_ controller: ApiService, createNewClaveAPI success: Bool, msg: String)
    //  func apiRequest(_ controller: ApiService, changeClaveAPI success: Bool, msg: String)
    //  func apiRequest(_ controller: ApiService, updatedProfileAPI data: [String: Any])
    func apiRequest(_ controller: ApiService, updatedProfileError msg: String)
    func apiRequest(_ controller: ApiService, getLoginToken token: String)
    func apiRequest(_ controller: ApiService, getLoginData data: [String: Any])
    func apiRequest(_ controller: ApiService, getServerData serverData: String)
    func apiRequest(_ controller: ApiService, fileUploaded isSuccess: Bool)
    //  func apiRequest(_ controller: ApiService, getAddressList data: [Address])
    func apiRequest(_ controller: ApiService, getReverseAddressList data: [Address])
    func apiRequest(_ controller: ApiService, getLoginError msg: String)
    
    func apiRequest(_ controller: ApiService, getAPIError msg: String)
}

final class ApiService {
    
    static let shared = ApiService()
    
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
    
    internal func parseResponse(_ data: Data?, _ response: URLResponse?,_ error: Error?) -> Result<Any, APIError> {
        if let error = error {
            return .failure(.serverError(message: error.localizedDescription))
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
            
            print("json \(json["msg"] as! String)")
            
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                return .failure(.invalidResponse(message: json["msg"] as? String ?? "Error no especificado"))
            }
            return .success(json["msg"] as? String ?? "Success")
        } catch {
            return .failure(.invalidData)
        }
    }
    
    func registerUserAPI(url: String, params: Dictionary<String, String>, completion: @escaping (Result<String, APIError>) -> Void) {
        print("register URL: \(url)")
        let request = self.apiPOSTRequest(url: url, params: params)
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            //
            //        let apiResult = self.parseResponse(data,response,error)
            //        completion(apiResult)
            if let error = error {
                completion(.failure(.serverError(message: error.localizedDescription)))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                
                print("json \(json["msg"] as! String)")
                
                guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    completion(.failure(.invalidResponse(message: json["msg"] as? String ?? "Error no especificado")))
                    //self.delegate?.apiRequest(self, registerUserAPI: false, msg: json["msg"] as! String)
                    return
                }
                completion(.success(json["msg"] as? String ?? "Success"))
                //self.delegate?.apiRequest(self, registerUserAPI: true, msg: json["msg"] as! String)
            } catch {
                completion(.failure(.invalidData))
                //self.handlerError(error: "Ha ocurrido un error en el servidor. Por favor, intentelo otra vez.")
            }
        })
        task.resume()
    }
    
    func newRegisterUserAPI(url: String, params: Dictionary<String, String>, completion: @escaping (Result<Dictionary<String, AnyObject>, APIError>) -> Void) {
        print("register URL: \(url)")
        print(params)
        let request = self.apiPOSTRequest(url: url, params: params)
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if let error = error {
                completion(.failure(.serverError(message: error.localizedDescription)))
                return
            }
            
            do {
                var json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
              
                print("json \(json["msg"] as! String)")
                
                guard let response = response as? HTTPURLResponse, (200...410).contains(response.statusCode) else {
                    completion(.failure(.invalidResponse(message: json["msg"] as? String ?? "")))
                    return
                }
                json["statusCode"] = response.statusCode as AnyObject
                completion(.success(json))
            } catch {
                completion(.failure(.invalidData))
            }
        })
        task.resume()
    }
    
//    func newRegisterUserAPI(url: String, params: Dictionary<String, String>) {
//        print("register URL: \(url)")
//        print(params)
//        let request = self.apiPOSTRequest(url: url, params: params)
//        let session = URLSession.shared
//        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
//            if let error = error {
//                self.handlerError(error: error.localizedDescription)
//                return
//            }
//            
//            do {
//                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
//                
//                print("json \(json["msg"] as! String)")
//                
//                guard let response = response as? HTTPURLResponse, (201...409).contains(response.statusCode) else {
//                    self.delegate?.apiRequest(self, newRegisterUserAPI: false, msg: json["msg"] as! String)
//                    return
//                }
//                print(response.statusCode)
//                self.delegate?.apiRequest(self, newRegisterUserAPI: true, msg: json["msg"] as! String)
//            } catch {
//                self.handlerError(error: "Ha ocurrido un error en el servidor. Por favor, intentelo otra vez.")
//            }
//        })
//        task.resume()
//    }
    
    func validateRegisterCode(url: String, params: Dictionary<String, String>){
        let request = self.apiPOSTRequest(url: url, params: params)
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            if let error = error {
                self.handlerError(error: error.localizedDescription)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                
                print("json \(json["msg"] as! String)")
                
                guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    self.delegate?.apiRequest(self, validateRegisterCodeAPI: false, msg: json["msg"] as! String)
                    return
                }
                
                self.delegate?.apiRequest(self, validateRegisterCodeAPI: true, msg: json["msg"] as! String)
            } catch {
                self.handlerError(error: "Ha ocurrido un error en el servidor. Por favor, intentelo otra vez.")
            }
        })
        task.resume()
    }
    
    func removeClientAPI(completion: @escaping (Result<String, APIError>) -> Void) {
        let params: Dictionary<String, String> = ["movil": globalVariables.cliente.user]
        var request = URLRequest(url: URL(string: GlobalConstants.removeClient)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.standard.value(forKey: "accessToken") as! String)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            if let error = error {
                completion(.failure(.serverError(message: error.localizedDescription)))
            }
            
            do {
                guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    completion(.failure(.invalidResponse(message: GlobalStrings.usuarioEliminadoError)))
                    return
                }
                
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                completion(.success(json["msg"] as? String ?? GlobalStrings.usuarioEliminadoExito))
            } catch {
                completion(.failure(.invalidData))
            }
        })
        
        task.resume()
    }
    
    func recoverUserClaveAPI(url: String, params: Dictionary<String, String>, completion: @escaping (Result<String,APIError>) -> Void) {
        let request = self.apiPOSTRequest(url: url, params: params)
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if let error = error {
                completion(.failure(.serverError(message: error.localizedDescription)))
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print("json \(json["msg"] as! String)")
                
                guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    completion(.failure(.invalidResponse(message: json["msg"] as? String ?? "")))
                    return
                }
                completion(.success(json["msg"] as? String ?? ""))
            } catch {
                completion(.failure(.invalidData))
            }
        })
        
        task.resume()
    }
    
    func createNewClaveAPI(url: String, params: Dictionary<String, String>, completion: @escaping (Result<String,APIError>) -> Void){
        let request = self.apiPOSTRequest(url: url, params: params)
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            
            if let error = error {
                completion(.failure(.serverError(message: error.localizedDescription)))
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print("json \(json["msg"] as! String)")
                
                guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    completion(.failure(.invalidResponse(message: json["msg"] as? String ?? "")))
                    return
                }
                completion(.success(json["msg"] as? String ?? ""))
            } catch {
                completion(.failure(.invalidData))
            }
        })
        //
        //      let response = response as! HTTPURLResponse
        //      print("heree \(error) \(response.statusCode)")
        //      if error == nil && response.statusCode == 200{
        //        do {
        //          let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
        //          self.delegate?.apiRequest(self, createNewClaveAPI: json["msg"] as! String)
        //        } catch {
        //          print("error")
        //        }
        //      } else {
        //        self.handlerError(error: "API error")
        //      }
        //    })
        
        task.resume()
    }
    
    func changeClaveAPI(params: Dictionary<String, String>, completion: @escaping (Result<String, APIError>) -> Void) {
        var request = URLRequest(url: URL(string: GlobalConstants.passChangeUrl)!)
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
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print("json \(json["msg"] as! String)")
                
                guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    completion(.failure(.invalidResponse(message: json["msg"] as? String ?? GlobalStrings.errorGenericoMessage)))
                    return
                }
                completion(.success(json["msg"] as! String))
            } catch {
                completion(.failure(.invalidData))
            }
        })
        
        task.resume()
    }
    
    func updateProfileAPI(parameters: [String: AnyObject], completion: @escaping (Result<[String: Any], APIError>) -> Void) {
        print(globalVariables.cliente.user)
        //let recordedFilePath = NSHomeDirectory() + "/Library/Caches/Image"
        let mimetype = "image/jpeg"
        
        var request : NSMutableURLRequest = NSMutableURLRequest()
        let body = NSMutableData()
        let boundary = "--------14737809831466499882746641449----"
        //Add extra parameters
        
        
        request = URLRequest(url: URL(string: GlobalConstants.updateProfileUrl)!) as! NSMutableURLRequest
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.standard.value(forKey: "accessToken") as! String)", forHTTPHeaderField: "Authorization")
        
        for (key, value) in parameters {
            body.append(("--\(boundary)\r\n").data(using: .utf8)!)
            body.append(("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n").data(using: .utf8)!)
            body.append(("\(value)\r\n").data(using: .utf8)!)
        }
        
        var fileData: Data = UIImage(named: "chofer")!.jpegData(compressionQuality: 1.0)!
        if globalVariables.cliente.fotoImage != nil {
            fileData = globalVariables.cliente.fotoImage.jpegData(compressionQuality: 1.0)!
        }
        
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
            
            if let error = error {
                completion(.failure(.serverError(message: error.localizedDescription)))
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                
                guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    completion(.failure(.invalidResponse(message: json["msg"] as? String ?? "")))
                    return
                }
                completion(.success(json))
            } catch {
                completion(.failure(.invalidData))
                //self.handlerError(error: "Ha ocurrido un error en el servidor. Por favor, intentelo otra vez.")
            }
            
            //      if error == nil && statusCode == 200{
            //        do{
            //          let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
            //          print("photo \(json)")
            //          self.delegate?.apiRequest(self, updatedProfileAPI: json)
            //        } catch {
            //          self.delegate?.apiRequest(self, updatedProfileError: "Ha ocurrido un error en el servidor. Por favor, intentelo otra vez.")
            //        }
            //        print("file uploaded")
            //      } else {
            //        do{
            //        let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
            //        print("photo \(json)")
            //        self.delegate?.apiRequest(self, updatedProfileError: json["msg"] as! String)
            //        } catch {
            //          self.delegate?.apiRequest(self, updatedProfileError: "Ha ocurrido un error en el servidor. Por favor, intentelo otra vez.")
            //        }
            //        print("error uploading file")
            //      }
        }
        task.resume()
    }
    
    func loginToAPIService(user: String, password: String,completion: @escaping (Result<[String: Any], APIError>)->Void) {
        let params = ["user": user, "password": password, "version": "3.6.0"] as Dictionary<String, String>
        print("URL Login: \(GlobalConstants.apiLoginUrl)")
        print("URL Host: \(GlobalConstants.urlHost)")
        var request = URLRequest(url: URL(string: GlobalConstants.apiLoginUrl)!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            
            if let error = error {
                //self.delegate?.apiRequest(self, getLoginError: error.localizedDescription)
                completion(.failure(.serverError(message: error.localizedDescription)))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
          
                guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    completion(.failure(.invalidResponse(message: json["msg"] as? String ?? GlobalStrings.errorGenericoMessage)))
                    return
                }
                completion(.success(json as [String: Any]))
            } catch {
                completion(.failure(.invalidData))
            }
            
//            guard let response = response as? HTTPURLResponse else {
//                self.delegate?.apiRequest(self, getLoginError: "Ha ocurrido un error en el servidor. Por favor, intentelo otra vez.")
//                return
//            }
//            print("login error \(response.statusCode)")
//            if error == nil && response.statusCode == 200 {
//                print(response)
//                do {
//                    let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
//                    print(json["config"] as! [String: Any])
//                    //self.delegate?.apiRequest(self, getLoginToken: json["token"] as! String)
//                    self.delegate?.apiRequest(self, getLoginData: json as [String: Any])
//                } catch {
//                    self.delegate?.apiRequest(self, getLoginError: "Ha ocurrido un error en el servidor. Por favor, intentelo otra vez.")
//                }
//            } else {
//                do {
//                    let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
//                    self.delegate?.apiRequest(self, getLoginError: json["msg"] as! String)
//                } catch {
//                    self.delegate?.apiRequest(self, getLoginError: "Ha ocurrido un error en el servidor. Por favor, intentelo otra vez.")
//                }
//            }
        })
        
        task.resume()
    }
    
    func uploadFile(serverUrl: String, parameters: [String: AnyObject]?,localFilePath: String, fileName: String, mimetype: String, completion: @escaping (Result<[String: Any], APIError>) -> Void) {
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
        request.addValue("Bearer \(UserDefaults.standard.value(forKey: "accessToken") as! String)", forHTTPHeaderField: "Authorization")
        
        let recordedFilePath = localFilePath + fileName
        print(recordedFilePath)
        let recordedFileURL = URL(fileURLWithPath: recordedFilePath)
        let fileData: Data? = try? Data(contentsOf: recordedFileURL)
        
        //Add File to body
        if fileData != nil{
            body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
            body.append("Content-Disposition:form-data; name=\"file\"\r\n\r\n".data(using: .utf8)!)
            body.append("hi\r\n".data(using: String.Encoding.utf8)!)
            body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
            body.append("Content-Disposition:form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
            body.append(fileData!)
            body.append("\r\n".data(using: String.Encoding.utf8)!)
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        } else {
            print("Errrorrrrr")
        }
        request.httpBody = body as Data
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            if error == nil && statusCode == 200 {
                if mimetype == "image/jpeg" {
                    do{
                        let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                        completion(.success(json))
                        //self.delegate?.apiRequest(self, updatedProfileAPI: json)
                    } catch {
                        completion(.failure(.invalidData))
                        //self.delegate?.apiRequest(self, updatedProfileError: "Ha ocurrido un error en el servidor. Por favor, intentelo otra vez.")
                    }
                } else {
                    completion(.failure(.invalidResponse(message: GlobalStrings.errorGenericoMessage)))
                    //self.delegate?.apiRequest(self, fileUploaded: statusCode == 200)
                }
                print("file uploaded")
            } else {
                if mimetype == "image/jpeg" {
                    do{
                        let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                        completion(.failure(.invalidResponse(message: json["msg"] as! String)))
                        //self.delegate?.apiRequest(self, updatedProfileError: json["msg"] as! String)
                    } catch {
                        completion(.failure(.serverError(message: GlobalStrings.errorGenericoMessage)))
                        //            self.delegate?.apiRequest(self, updatedProfileError: "Ha ocurrido un error en el servidor. Por favor, intentelo otra vez.")
                    }
                } else {
                    completion(.failure(.serverError(message: GlobalStrings.errorGenericoMessage)))
                    //self.delegate?.apiRequest(self, fileUploaded: false)
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
        
        self.uploadFile(serverUrl: GlobalConstants.subiraudioUrl, parameters: parameters, localFilePath: recordedFilePath, fileName: name, mimetype: mimetype) { result in
            switch result {
            case .success(let jsonResponse):
                break
            case .failure(let error):
                break
            }
        }
    }
    
    func searchAddressXoaAPI(searchQuery: String, lat: Double, lon: Double, completion: @escaping (Result<[Address], APIError>) -> Void) {
        //&lon=-79.89725013269098&lat=-2.1363502421557943
        let country = globalVariables.cliente.annotation.address
        let searchQueryText = searchQuery.replacingOccurrences(of: " ", with: "%20")
        //let urlString = "\(GlobalConstants.searchAddressUrl)\(searchQueryText.replacingOccurrences(of: "ñ", with: "n"))"
        let urlString = "\(GlobalConstants.searchAddressUrl)\(searchQueryText.replacingOccurrences(of: "ñ", with: "n")),\(GlobalConstants.countryAddress)&lon=\(lon)&lat=\(lat)"
        //    let urlString = "\(GlobalConstants.searchAddressUrl)\(searchQueryText.replacingOccurrences(of: "ñ", with: "n")),Ecuador&lon=-79.89725013269098&lat=-2.1363502421557943"
        print("urlString: \(urlString)")
        //let accessToken = UserDefaults.standard.value(forKey: "accessToken") as! String
        var request = URLRequest(url: (URL(string: "\(urlString)") ?? URL(string: "\(GlobalConstants.searchAddressUrl)"))!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if let error = error {
                completion(.failure(.serverError(message: error.localizedDescription)))
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    completion(.failure(.invalidResponse(message: GlobalStrings.errorGenericoMessage)))
                    return
                }
                print(json["features"] as! [[String:AnyObject]])
                var addressList: [Address] = []
                for address in json["features"] as! [[String:AnyObject]] {
                    let newAddress = try Address(json: address)
                    if (newAddress.pais == "\(GlobalConstants.countryAddress)" && newAddress.ciudad != "") {
                        addressList.append(newAddress)
                    }
                }
                completion(.success(addressList))
            } catch {
                completion(.failure(.invalidData))
            }
        })
        
        task.resume()
    }
    
    func searchReverseAddressXoaAPI(lat: Double, lon: Double, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let urlString = "\(GlobalConstants.searchReverseAddressUrl)lon=\(lon)&lat=\(lat)"
        print("urlString: \(urlString)")
        var request = URLRequest(url: (URL(string: "\(urlString)") ?? URL(string: "\(GlobalConstants.searchAddressUrl)"))!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            completionHandler(data, response, error)
        })
        
        task.resume()
    }
    func handlerError(error: String) {
        self.delegate?.apiRequest(self, getAPIError: error)
    }
    
}

extension ApiServiceDelegate {
    func apiRequest(_ controller: ApiService, apiPOSTRequest response: Dictionary<String, AnyObject>){}
    func apiRequest(_ controller: ApiService, getLoginToken token: String){}
    func apiRequest(_ controller: ApiService, getLoginData data: [String: Any]){}
    func apiRequest(_ controller: ApiService, registerUserAPI success: Bool, msg: String){}
    func apiRequest(_ controller: ApiService, newRegisterUserAPI success: Bool, msg: String){}
    func apiRequest(_ controller: ApiService, validateRegisterCodeAPI success: Bool, msg: String){}
    func apiRequest(_ controller: ApiService, removeClientAPI success: Bool, msg: String){}
    func apiRequest(_ controller: ApiService, recoverUserClaveAPI success: Bool, msg: String){}
    func apiRequest(_ controller: ApiService, createNewClaveAPI success: Bool, msg: String){}
    //  func apiRequest(_ controller: ApiService, changeClaveAPI success: Bool, msg: String){}
    //  func apiRequest(_ controller: ApiService, updatedProfileAPI data: [String: Any]){}
    func apiRequest(_ controller: ApiService, updatedProfileError msg: String){}
    func apiRequest(_ controller: ApiService, getServerData serverData: String){}
    func apiRequest(_ controller: ApiService, fileUploaded isSuccess: Bool){}
    //  func apiRequest(_ controller: ApiService, getAddressList data: [Address]){}
    func apiRequest(_ controller: ApiService, getReverseAddressList data: [Address]){}
    func apiRequest(_ controller: ApiService, getLoginError msg: String){}
    func apiRequest(_ controller: ApiService, getAPIError msg: String){}
}
