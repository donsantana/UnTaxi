//
//  YapaController.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 12/1/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit
import FloatingPanel

struct YapaMenu {
  var icon: UIImage
  var title: String
  var subtitle: String
  
  init (iconName: String, title: String, subtitle: String){
    self.icon = UIImage(named: iconName)!
    self.title = title
    self.subtitle = subtitle
  }
}

class YapaController: BaseController{

  let yapaPanel = FloatingPanelController()
  let yapaActionsArray = [YapaMenu(iconName: "yapaIcon", title: "Pasa YAPA", subtitle: "Pasa tu YAPA a otros contactos"), YapaMenu(iconName: "yapaCodeIcon", title: "Código promocional", subtitle:"Ingresa el código promocional")]
  lazy var contentPanel = storyboard?.instantiateViewController(withIdentifier: "YapaPanel") as? YapaPanel
  
  @IBOutlet weak var titleText: UILabel!
  @IBOutlet weak var subtitleText: UILabel!
  @IBOutlet weak var yapaText: UILabel!
  @IBOutlet weak var explicacionText: UITextView!
  @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var yapaMenuTable: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
//    self.titleText.font = CustomAppFont.titleFont
//    self.subtitleText.font = CustomAppFont.subtitleFont
//    self.yapaText.font = CustomAppFont.bigFont
    self.yapaMenuTable.delegate = self
    self.yapaText.text = "$\(String(format: "%.2f", globalVariables.cliente.yapa))"
    self.yapaText.addBorder(color: CustomAppColor.buttonActionColor)
    self.imageHeightConstraint.constant = Responsive().heightFloatPercent(percent: 25)
//    self.explicacionText.font = CustomAppFont.titleFont
    
    //MARK:- PANEL DEFINITION
    yapaPanel.delegate = self
    yapaPanel.isRemovalInteractionEnabled = true
    yapaPanel.contentMode = .fitToBounds

//    guard let contentPanel = storyboard?.instantiateViewController(withIdentifier: "YapaPanel") as? YapaPanel else{
//      return
//    }
    
    //yapaPanel.track(scrollView: contentPanel!.activeCodigoView as! UIScrollView)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
 
  func expandPanel(isExpanded: Bool){
    yapaPanel.set(contentViewController: contentPanel)
    yapaPanel.addPanel(toParent: self)
    yapaPanel.move(to: .full, animated: true)
  }

}

extension YapaController: UITextFieldDelegate{
  //Funciones para mover los elementos para que no queden detrás del teclado
  func textFieldDidBeginEditing(_ textField: UITextField) {
    textField.text?.removeAll()
    animateViewMoving(true, moveValue: 160, view: (self.view)!)
  }
  
  func textFieldDidEndEditing(_ textfield: UITextField) {
    self.animateViewMoving(false, moveValue: 160, view: (self.view)!)
  }
  
//  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//    socketService.socketEmit("recargaryapa", datos: [
//      "idcliente": globalVariables.cliente.id!,
//      "codigo": self.codigoText.text!
//    ])
//    return true
//  }
  
  func animateViewMoving (_ up:Bool, moveValue :CGFloat, view : UIView){
    let movementDuration:TimeInterval = 0.3
    let movement:CGFloat = ( up ? -moveValue : moveValue)
    UIView.beginAnimations( "animateView", context: nil)
    UIView.setAnimationBeginsFromCurrentState(true)
    UIView.setAnimationDuration(movementDuration)
    view.frame = view.frame.offsetBy(dx: 0,  dy: movement)
    UIView.commitAnimations()
  }
}

extension YapaController: FloatingPanelControllerDelegate{
  func floatingPanelDidMove(_ fpc: FloatingPanelController) {
    print(fpc.state)
    self.yapaText.text = "$\(String(format: "%.2f", globalVariables.cliente.yapa))"
  }
}
