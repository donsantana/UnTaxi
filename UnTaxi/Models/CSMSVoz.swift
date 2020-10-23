//
//  CSMSVoz.swift
//  Xtaxi
//
//  Created by usuario on 5/5/16.
//  Copyright © 2016 Done Santana. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit


class CSMSVoz: UIViewController, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, AVAudioPlayerDelegate {
  
  var myPlayer = AVPlayer()
  var myMusica = AVAudioPlayer()
  var myAudioPlayer = AVAudioPlayer()
  //var playSession = AVAudioSession()
  var vozConductor = AVAudioPlayer()
  var recordingSession = AVAudioSession()
  var audioRecorder: AVAudioRecorder!
  var urlSubir: String!
  var responseData = NSMutableData()
  var data: Data!
  var reproduciendo = false
  var apiService = ApiService()
  //var AudioSetCategory: AVAudioSetCategory = AVAudioSetCategory()
  
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    
    let myFilePathString = Bundle.main.path(forResource: "beep", ofType: "wav")
    
    if let myFilePathString = myFilePathString
    {
      let myFilePathURL = URL(fileURLWithPath: myFilePathString)
      
      do{
        try myMusica = AVAudioPlayer(contentsOf: myFilePathURL)
        myMusica.prepareToPlay()
        myMusica.volume = 1
      }catch{
        print("error")
      }
    }
    
  }
  
  func inicializarGrabacion() {
    //INICIALIAR GRABACIÓN
    if (recordingSession.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
      AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
        if granted {
          //set category and activate recorder session
          //self.AudioSetCategory.setAudio(self.recordingSession)
          try! self.recordingSession.setActive(true)
          /*if #available(iOS 10.0, *) {
           try! self.recordingSession.setCategory(.playAndRecord, mode: .default)
           try! self.recordingSession.setActive(true)
           } else {
           // Fallback on earlier versions
           }*/
          
          let recordSettings = [AVSampleRateKey : NSNumber(value: Float(8000.0) as Float),
                                AVFormatIDKey : NSNumber(value: Int32(kAudioFormatMPEG4AAC) as Int32),
                                AVNumberOfChannelsKey : NSNumber(value: 1 as Int32),
                                AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.low.rawValue) as Int32)]
          
          let audioSession = AVAudioSession.sharedInstance()
          do {
            if #available(iOS 10.0, *) {
              try audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            } else {
              audioSession.perform(NSSelectorFromString("setCategory:withOptions:error:"), with: AVAudioSession.Category.playAndRecord)
              try audioSession.overrideOutputAudioPort(.speaker)
            }
            try self.audioRecorder = AVAudioRecorder(url: self.directoryURL()!,settings: recordSettings)
            self.audioRecorder.prepareToRecord()
          } catch {
            
          }
          
        } else{
          print("not granted")
        }
      })
    }
  }
  
  /*func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
   if !flag {
   finishRecording(success: false)
   }
   }*/
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // get the path of our file
  
  func directoryURL() -> URL? {
    let fileManager = FileManager.default
    //var documents: AnyObject = NSSearchPathForDirectoriesInDomains( NSSearchPathDirectory.DocumentDirectory,  NSSearchPathDomainMask.UserDomainMask, true)[0]
    let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
    //let urls = NSHomeDirectory() + "/Library/Caches/audio.m4a"
    let documentDirectory = urls[0] as URL
    let soundURL = documentDirectory.appendingPathComponent("audio.m4a")
    //let soundURL = NSURL.fileURLWithPath(urls as String)
    return soundURL
  }
  
  //para reproducir audio de internet
  func PlayForInternet(_ url: String){
    let url = url
    let playerItem = AVPlayerItem(url: URL(string: url)!)
    myPlayer = AVPlayer(playerItem:playerItem)
    myPlayer.rate = 1.0
    myPlayer.play()
  }
  
  func GrabarMensaje(){
    if !self.reproduciendo{
      self.inicializarGrabacion()
      if !audioRecorder.isRecording{
        let audioSession = AVAudioSession.sharedInstance()
        do {
          try audioSession.setActive(true)
          audioRecorder.record()
        } catch {
        }
      }
    }
  }
  
  func TerminarMensaje(_ name: String, solicitud: Solicitud){
    if !self.reproduciendo{
      audioRecorder.stop()
      let audioSession = AVAudioSession.sharedInstance()
      do {
        try audioSession.setActive(false)
        let filePath = NSHomeDirectory() + "/Library/Caches/Audio" + name
        let audio = try? Data(contentsOf: directoryURL()!)
        //self.apiService.subirAudioAPIService(audioFile: audio!, idsolicitud: solicitud.id, idtaxi: solicitud.taxi.id)
        ((try? audio?.write(to: URL(fileURLWithPath: filePath), options: [.atomic])) as ()??)
        
      } catch {
      }
    }
  }
  
  func ReproducirMensaje(){
    if (!audioRecorder.isRecording){
      do {
        try myAudioPlayer = AVAudioPlayer(contentsOf: audioRecorder.url)
        
        myAudioPlayer.prepareToPlay()
        myAudioPlayer.volume = 1
        myAudioPlayer.play()
      } catch {
      }
    }else{
      
    }
  }
  
  
  func ReproducirVozConductor(_ url: String){
    print("audio recibido \(url)")
    //AUDIOSESSION
    do {
      //self.inicializarGrabacion()
      globalVariables.SMSProceso = true
      let fileURL = NSURL(string:url)
      let soundData = NSData(contentsOf:fileURL! as URL)
      try vozConductor = AVAudioPlayer(data: soundData! as Data)
      self.ReproducirMusica()
      vozConductor.prepareToPlay()
      vozConductor.delegate = self
      vozConductor.volume = 1.0
      vozConductor.play()
      self.reproduciendo = true
    } catch {
      print("Nada de audio")
    }
  }
  
  func ReproducirMusica(){
    myMusica.play()
  }
  
//  func uploadImageToServerFromApp(solicitud: Solicitud, name: String){
//    var request : NSMutableURLRequest = NSMutableURLRequest()
//    request = URLRequest(url: URL(string:GlobalConstants.subiraudioUrl as String)!) as! NSMutableURLRequest
//    request.httpMethod = "POST"
//    let boundary = "--------14737809831466499882746641449----"
//    //define the multipart request type
//    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//    request.addValue("Bearer \(globalVariables.userDefaults.value(forKey: "accessToken") as! String)", forHTTPHeaderField: "Authorization")
//    let currentFilename = name
//    let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//    //let docsDir: AnyObject=dirPaths[0]
//    let recordedFilePath = NSHomeDirectory() + "/Library/Caches/Audio" + name
//    //docsDir.stringByAppendingPathComponent(self.currentFilename)
//    let recordedFileURL = URL(fileURLWithPath: recordedFilePath)
//    let recordedAudio: Data? = try? Data(contentsOf: recordedFileURL)
////    let image_data = UIImage(named: "clave")!.pngData()!
////    if(image_data == nil){
////      return
////    }
//    let body = NSMutableData()
//    let fname = name
//    let mimetype = "audio/x-m4a"
//
//    let header1 = "Content-Disposition: form-data; name=\"idsolicitud\"\r\n\r\n".data(using: .utf8)
//    let header2 = "Content-Disposition: form-data; name=\"idtaxi\"\r\n\r\n".data(using: .utf8)
//
//    //define the data post parameter
//    body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
//    body.append("Content-Disposition:form-data; name=\"file\"\r\n\r\n".data(using: String.Encoding.utf8)!)
//    body.append("hi\r\n".data(using: String.Encoding.utf8)!)
//    body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
//    body.append("Content-Disposition:form-data; name=\"file\"; filename=\"\(fname)\"\r\n".data(using: String.Encoding.utf8)!)
//    body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
//    body.append(recordedAudio!)
//    body.append("\r\n".data(using: String.Encoding.utf8)!)
//
//    body.append(("--\(boundary)\r\n").data(using: .utf8)!)
//    body.append(header1!)
//    body.append(("\(solicitud.id)\r\n").data(using: .utf8)!)
//
//    body.append(("--\(boundary)\r\n").data(using: .utf8)!)
//    body.append(header2!)
//    body.append(("\(solicitud.taxi.id)\r\n").data(using: .utf8)!)
//
//    body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
//    request.httpBody = body as Data
//    print("subiendo audio")
//    let session = URLSession.shared
//    let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
//      print("API \(response as? HTTPURLResponse)")
//      guard let data = data, error == nil else {
//        print("SUbida")
//        // check for fundamental networking error
//        // print("error=\(String(describing: error))")
//        return
//      }
//      if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
//        // print("statusCode should be 200, but is \(httpStatus.statusCode)")
//        print("response = \(String(describing: response))")
//      }
//      //                }else{
//      //                    do {
//      //                        self.responseDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
//      //                        // self.Responsedata = data as NSData
//      //                        //self.responseDictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: AnyObject] as NSDictionary;
//      //
//      //                        self.delegate?.responseReceived()
//      //                    } catch {
//      //                        //print("error serializing JSON: \(error)")
//      //                    }
//      //                }
//    }
//    task.resume()
//  }
//
//  func SubirAudio(_ solicitud: Solicitud, name: String){
//
//    // The variable "recordedFileURL" is defined earlier in the code like this
//
//    globalVariables.SMSProceso = true
//    self.ReproducirMusica()
//
//    let accessToken = globalVariables.userDefaults.value(forKey: "accessToken") as! String
//
//    let currentFilename = name
//    let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//    //let docsDir: AnyObject=dirPaths[0]
//    let recordedFilePath = NSHomeDirectory() + "/Library/Caches/Audio" + name
//    //docsDir.stringByAppendingPathComponent(self.currentFilename)
//    let recordedFileURL = URL(fileURLWithPath: recordedFilePath)
//
//    // "currentFilename", "recordedFilePath" and "recordedFileURL" are all global variables
//
//    // This recording stored at "recordedFileURL" can be played back fine.
//
//    let sendToPath = GlobalConstants.subiraudioUrl//urlSubirVoz
//    let sendToURL = URL(string: sendToPath)
//    let recording: Data? = try? Data(contentsOf: recordedFileURL)
//
//    let boundary = "--------14737809831466499882746641449----"
//    let beginningBoundary = "--\(boundary)"
//    let endingBoundary = "--\(boundary)--"
//    let contentType = "multipart/form-data;boundary=\(boundary)"
//
//    let filename = recordedFilePath ?? currentFilename
//    let header1 = "Content-Disposition: form-data; name=\"idsolicitud\"\r\n".data(using: .utf8)
//    let header2 = "Content-Disposition: form-data; name=\"idtaxi\"\r\n".data(using: .utf8)
//    let header3 = "Content-Disposition: form-data; name=\"file\";filename=\"\(filename)\"\r\n".data(using: .utf8)
//
//    var request = URLRequest(url: sendToURL!)
//    //request.url = sendToURL
//    request.httpMethod = "POST"
//    request.addValue(contentType, forHTTPHeaderField: "Content-Type")
//    request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//    //request.addValue(recId, forHTTPHeaderField: "REC-ID") // recId is defined elsewhere
//
//    var body = Data()
//    body.append(("\(beginningBoundary)\r\n").data(using: .utf8)!)
//    body.append(header1!)
//    body.append(("\(solicitud.id)\r\n").data(using: .utf8)!)
//
//    body.append(("\(beginningBoundary)\r\n").data(using: .utf8)!)
//    body.append(header2!)
//    body.append(("\(solicitud.taxi.id)\r\n").data(using: .utf8)!)
//
//
//    //var data: Data = UIImage(named: "clave")!.pngData()!
//
//    body.append(("\(beginningBoundary)\r\n").data(using: .utf8)!)
//    body.append(header3!)
//    body.append(("Content-Type: var data:NSData = UIImagePNGRepresentation(image)\r\n\r\n").data(using: .utf8)!)
//    body.append(recording!) // adding the recording here
//    body.append(("\r\n\(endingBoundary)\r\n").data(using: .utf8)!)
//    print(body)
//    request.httpBody = body
//
//    let session = URLSession.shared
//
//    let task : URLSessionTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
//      print(error)
//      print(response)
//      let dataStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
//
//    })
//    task.resume()
//    eliminarAudio(name: name)
//  }
  
  func eliminarAudio(name: String) {
    let fileManager = FileManager()
    let filePath = NSHomeDirectory() + "/Library/Caches/Audio" + name
    do {
      try fileManager.removeItem(atPath: filePath)
    }catch{
      
    }
  }
  
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    self.vozConductor.stop()
    self.ReproducirMusica()
    self.reproduciendo = false
    globalVariables.SMSProceso = false
  }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
  return input.rawValue
}



