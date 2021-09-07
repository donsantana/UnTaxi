//
//  Character.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 6/9/21.
//  Copyright © 2021 Done Santana. All rights reserved.
//

import Foundation

extension Character {
  var isDecimalOrPeriod: Bool { "0"..."9" ~= self || self == "." }
}

extension RangeReplaceableCollection where Self: StringProtocol {
  var digitsAndPeriods: Self { filter(\.isDecimalOrPeriod) }
}
