//
//  OfertaViewCell.swift
//  Conaitor
//
//  Created by Donelkys Santana on 12/4/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import UIKit


class OfertaDataViewCell: UITableViewCell {
  var valueData: [Double] = []
  var valorOferta: Double = 0.0
  var increseValue = 0.05
  
  @IBOutlet weak var detallesText: UITextField!
  @IBOutlet weak var ofertaValuePicker: UIPickerView!
  
  func initContent(precioInicial: Double){
    print(precioInicial)
    self.valorOferta = precioInicial
    var rangoOferta = precioInicial
    self.ofertaValuePicker.delegate = self
    self.ofertaValuePicker.dataSource = self

    self.detallesText.setBottomBorder(borderColor: .gray)
    
    while rangoOferta <= 200.0{
      valueData.append(rangoOferta)
      rangoOferta += self.increseValue
    }
  }
}

extension OfertaDataViewCell: UIPickerViewDelegate, UIPickerViewDataSource{
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return self.valueData.count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return "$\(String(format: "%.2f", self.valueData[row]))"
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    self.valorOferta = self.valueData[row]
  }
}
