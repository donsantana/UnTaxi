//
//  String.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 6/10/21.
//  Copyright © 2021 Done Santana. All rights reserved.
//

import Foundation

extension String{
  var digitString: String { filter { ("0"..."9").contains($0) } }
  var isNumeric: Bool {
    return !(self.isEmpty) && self.allSatisfy { $0.isNumber }
  }
  
  var currencyString: String {
    let result = self.contains(".") ? self.digitsAndPeriods : self.replacingOccurrences(of: ",", with: ".").digitsAndPeriods
    return result
  }
}
