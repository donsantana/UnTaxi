//
//  PublicidadService.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 6/14/21.
//  Copyright © 2021 Done Santana. All rights reserved.
//

import UIKit

struct Publicidad {
  var idpublicidad: Int
  var img: String
  var time: Int
  var title: String
  var url: String

  
  init(publicidad: [String: Any]) {
    self.idpublicidad = publicidad["idpublicidad"] as! Int
    self.img = publicidad["img"] as! String
    self.time = publicidad["time"] as! Int
    self.title = publicidad["title"] as! String
    self.url = publicidad["url"] as! String
  }
}

class PublicidadService {
/*{
   "images":[
     {"img":"image1.png","title":"Publicidad 1","url":"http://116.203.92.189:9007/image1.png", "time":3},
     {"img":"image2.png","title":"Publicidad 2","url":"http://116.203.92.189:9007/image2.png", "time":3},
     {"img":"image3.png","title":"Publicidad 3","url":"http://116.203.92.189:9007/image3.png", "time":3},
     {"img":"image4.png","title":"Publicidad 4","url":"http://116.203.92.189:9007/image4.png", "time":3},
     {"img":"image5.png","title":"Publicidad 5","url":"http://116.203.92.189:9007/image5.png", "time":3}
   ]
}*/
  var publicidadesArray: [Publicidad] = []
  var publicidadTimer = Timer()
  var showTime = 3
  var publicidadToShow: Publicidad
  var socketService = SocketService()
  
  init(publicidades:[[String: Any]]) {
    for publicidad in publicidades{
      let newPublicidad = Publicidad(publicidad: publicidad)
      publicidadesArray.append(newPublicidad)
    }
//    publicidadesArray.append(Publicidad(publicidad: [
//      "idpublicidad":600,
//      "img":"2brice",
//      "time":6,
//      "title":"Publicidad 2brice",
//      "url":"https://apps.apple.com/us/app/2brice/id1290022053"
//  ]))
    self.publicidadToShow = publicidadesArray.first!
  }
  
  func showPublicidad(bannerView: UIView){
    self.publicidadesArray.shuffle()
    var countSeg = 0
    var i = 0
    self.publicidadToShow = self.publicidadesArray.first!
    self.updateBannerViem(bannerView: bannerView)
    self.publicidadTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self] timer in
      
      if countSeg == publicidadToShow.time{
        countSeg = 0
        i = i == publicidadesArray.count - 1 ? 0 : i + 1
        publicidadToShow = self.publicidadesArray[i]
        self.updateBannerViem(bannerView: bannerView)
      }else{
        countSeg += 1
      }
    }
  }
  
  func updateBannerViem(bannerView: UIView){
    //if publicidadToShow.img != "2brice"{
      self.socketService.socketEmit("visualizapublicidad", datos: [
                                      "idpublicidad": self.publicidadToShow.idpublicidad,
                                      "idcliente": globalVariables.cliente.id!,])
      let url = URL(string:"\(publicidadToShow.img)")
      let task = URLSession.shared.dataTask(with: url!) { data, response, error in
        guard let data = data, error == nil else { return }
        DispatchQueue.main.sync() {
          let backImage = UIImageView(image: UIImage(data: data))
          backImage.frame = CGRect(x: 0, y: 0, width: bannerView.bounds.width, height: bannerView.bounds.height)
          backImage.contentMode = .scaleToFill
          //backImage.translatesAutoresizingMaskIntoConstraints = false
          bannerView.addSubview(backImage)
          
          //        bannerView.backgroundColor = UIColor(patternImage: UIImage(data: data)!.resizableImage(withCapInsets: bannerView.safeAreaInsets))
        }
      }
      task.resume()
//    }else{
//      let backImage = UIImageView(image: UIImage(named: "publicidadBanner"))
//      backImage.frame = CGRect(x: 0, y: 0, width: bannerView.bounds.width, height: bannerView.bounds.height)
//      backImage.contentMode = .scaleToFill
//      bannerView.addSubview(backImage)
//    }
  }
  
  func goToPublicidad(){
    if let url = URL(string: self.publicidadToShow.url) {
      self.socketService.socketEmit("accedeapublicidad", datos: [
                                      "idpublicidad": self.publicidadToShow.idpublicidad])
      UIApplication.shared.open(url)
    }
    //return self.publicidadToShow.url
  }
  
  func stopPublicidad(){
    print("Finishing Publicidad")
    self.publicidadTimer.invalidate()
  }
  
}
