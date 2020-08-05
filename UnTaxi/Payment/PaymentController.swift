//
//  PaymentController.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 6/27/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit
import PaymentezSDK

class PaymentController: PaymentezAddNativeViewController{
  var apiService = ApiService()
  var responsive = Responsive()
  @IBOutlet weak var cardsTableView: UITableView!
  @IBOutlet weak var homeBtn: UIButton!
  @IBOutlet weak var addCardBtn: UIButton!
  
  override func viewDidLoad() {
    self.cardsTableView.delegate = self
    self.apiService.delegate = self
    let closeImage = UIImage(named: "home")?.withRenderingMode(.alwaysTemplate)
    self.homeBtn.setImage(closeImage, for: UIControl.State())
    self.homeBtn.tintColor = Customization.buttonsTitleColor
    
    let paymentezContainer = UIView()
    paymentezContainer.frame = CGRect(x: responsive.widthPercent(percent: 5), y: responsive.heightPercent(percent: 25), width: responsive.widthPercent(percent: 90), height: responsive.heightPercent(percent: 30))
    //paymentezContainer.addShadow()
    self.view.addSubview(paymentezContainer)
    
//    let addCardBtn = UIButton(type: .system)
//    addCardBtn.frame = CGRect(x: responsive.widthPercent(percent: 35), y: responsive.heightPercent(percent: 45), width: responsive.widthPercent(percent: 40), height: responsive.heightPercent(percent: 7))
//    addCardBtn.setTitle("Agregar Tarjeta", for: .normal)
//    addCardBtn.titleLabel!.font = UIFont(name: "Helvetica", size: 18.0)
//    addCardBtn.setTitleColor(.yellow, for: .normal)
//    addCardBtn.backgroundColor = .black
//    addCardBtn.addBorder()
//    addCardBtn.addTarget(self, action: #selector(addNewCard), for: .touchUpInside)
//    self.view.addSubview(addCardBtn)
    
    if globalVariables.cardList.isEmpty{
      let cardAlert = UIAlertController (title: "Mis tarjeta", message: "Estimado cliente no tiene ninguna tarjeta registrada.", preferredStyle: .alert)
      cardAlert.addAction(UIAlertAction(title: "Agregar una tarejeta", style: .default, handler: {alerAction in
        DispatchQueue.main.async {
          self.addCardBtn.isHidden = false
          let paymentezAddVC = self.addPaymentezWidget(toView: paymentezContainer, delegate: self, uid: "\(globalVariables.cliente.id)", email: globalVariables.cliente.email)

          paymentezAddVC.baseColor = .black
          paymentezAddVC.baseFontColor = .yellow
          paymentezAddVC.nameTitle = "Nombre en la tarjeta"
          paymentezAddVC.cardTitle = "Número de la tarjeta"
          paymentezAddVC.showLogo = false
          paymentezAddVC.baseFont = UIFont(name: "Helvetica", size: 14)!
     
          //self.presentPaymentezViewController(delegate: self, uid: "\(globalVariables.cliente.id)", email: globalVariables.cliente.email)
        }
      }))
      cardAlert.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: {alerAction in
       
      }))
      self.present(cardAlert, animated: true, completion: nil)
    }
  }
  
  @objc func addNewCard(){
    print("adding card")
  }
  
  @IBAction func goToHomeScreen(_ sender: Any) {
    let vc = R.storyboard.main.inicioView()
    self.navigationController?.pushViewController(vc!, animated: true)
  }
  
  @IBAction func showAddCardView(_ sender: Any) {
   // let card = PaymentezCard.createCard(cardHolder: , cardNumber: <#T##String#>, expiryMonth: <#T##NSInteger#>, expiryYear: <#T##NSInteger#>, cvc: <#T##String#>)
  }
  
}

extension PaymentController: PaymentezCardAddedDelegate{
  func cardAdded(_ error: PaymentezSDKError?, _ cardAdded: PaymentezCard?) {
    print("here")
    let cardAlert = UIAlertController (title: "Nueva tarjeta", message: "Estimado cliente la nueva tarjeta ha sido registrada y está disponible para hacer pagos.", preferredStyle: .alert)
    cardAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {alerAction in

    }))
    self.present(cardAlert, animated: true, completion: nil)
  }

  func viewClosed() {
    print("heree")
  }
}

extension PaymentController: ApiServiceDelegate{
  func apiRequest(_ controller: ApiService, cardRemoved result: String?) {
    var title = "Error eliminando tarjeta."
    var message = "La tarjeta no ha sido removida. Por favor intente otra vez."
    if result != nil{
      title = "Tarjeta eliminada"
      message = "La tarjeta ha sido removida."
      globalVariables.cardList.removeAll{$0.token == result}
    }
    
    let cardAlert = UIAlertController (title: title, message: message, preferredStyle: .alert)
    cardAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {alerAction in
      
    }))
    self.present(cardAlert, animated: true, completion: nil)
  }
}
