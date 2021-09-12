//
//  RegistroController.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 8/5/21.
//  Copyright © 2021 Done Santana. All rights reserved.
//

import UIKit
import CountryPicker

class RegistroController: UIViewController {
  var apiService = ApiService.shared
  
  @IBOutlet weak var RegistroView: UIView!
  @IBOutlet weak var nombreApText: UITextField!
  @IBOutlet weak var claveText: UITextField!
  @IBOutlet weak var confirmarClavText: UITextField!
  @IBOutlet weak var correoText: UITextField!
  @IBOutlet weak var telefonoText: UITextField!
  @IBOutlet weak var crearCuentaBtn: UIButton!
  @IBOutlet weak var countryCodeText: UITextField!
  @IBOutlet weak var flagImageView: UIImageView!
  @IBOutlet weak var picker: CountryPicker!
  
  @IBOutlet weak var waitingView: UIVisualEffectView!
  
  @IBOutlet weak var showHideClaveBtn: UIButton!
  @IBOutlet weak var showHideConfirmClaveBtn: UIButton!
  
  //MARK:- CONSTRAINTS DEFINITION
  @IBOutlet weak var textFieldHeight: NSLayoutConstraint!
  @IBOutlet weak var nombreTextBottom: NSLayoutConstraint!
  @IBOutlet weak var telefonoTextBottom: NSLayoutConstraint!
  @IBOutlet weak var claveTextBottom: NSLayoutConstraint!
  @IBOutlet weak var correoTextTop: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //MARK:- DELEGATES
    apiService.delegate = self
    claveText.delegate = self
    telefonoText.delegate = self
    nombreApText.delegate = self
    correoText.delegate = self
    confirmarClavText.delegate = self
    countryCodeText.delegate = self
    
    self.crearCuentaBtn.addCustomActionBtnsColors()
    self.waitingView.addStandardConfig()
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado))
    self.confirmarClavText.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    
    self.RegistroView.addGestureRecognizer(tapGesture)
    
    self.getTextfieldHeight(textFieldHeight: textFieldHeight)
    let spaceBetween = (UIScreen.main.bounds.height - self.textFieldHeight.constant * 9) / 17
    
    self.claveTextBottom.constant = -spaceBetween
    self.telefonoTextBottom.constant = -spaceBetween
    self.nombreTextBottom.constant = -spaceBetween
    
    self.correoTextTop.constant = spaceBetween
    
    let locale = Locale.current
    let code = (locale as NSLocale).object(forKey: NSLocale.Key.countryCode) as! String?
    //init Picker
    //picker.displayOnlyCountriesWithCodes = ["EC"] //display only
    //picker.exeptCountriesWithCodes = ["EC"] //exept country
    let theme = CountryViewTheme(countryCodeTextColor: .white, countryNameTextColor: .white, rowBackgroundColor: .black, showFlagsBorder: false)        //optional for UIPickerView theme changes
    picker.theme = theme //optional for UIPickerView theme changes
    picker.countryPickerDelegate = self
    picker.showPhoneNumbers = true
    picker.setCountry(code!)
  }
  
  @IBAction func EnviarRegistro(_ sender: AnyObject) {
    self.sendNewUserData()
  }
  
  @IBAction func CancelarRegistro(_ sender: AnyObject) {
    self.view.endEditing(true)
    nombreApText.text?.removeAll()
    telefonoText.text?.removeAll()
    claveText.text?.removeAll()
    confirmarClavText.text?.removeAll()
    correoText.text?.removeAll()
    self.goToLoginView()
  }
  
  @IBAction func showHideRegistroClave(_ sender: Any) {
    if self.claveText.isSecureTextEntry{
      self.showHideClaveBtn.setImage(UIImage(named: "hideClave"), for: .normal)
      self.claveText.isSecureTextEntry = false
    }else{
      self.showHideClaveBtn.setImage(UIImage(named: "showClave"), for: .normal)
      self.claveText.isSecureTextEntry = true
    }
  }
  
  @IBAction func showHideConfirmClave(_ sender: Any) {
    if self.confirmarClavText.isSecureTextEntry{
      self.showHideConfirmClaveBtn.setImage(UIImage(named: "hideClave"), for: .normal)
      self.confirmarClavText.isSecureTextEntry = false
    }else{
      self.showHideConfirmClaveBtn.setImage(UIImage(named: "showClave"), for: .normal)
      self.confirmarClavText.isSecureTextEntry = true
    }
  }
}
