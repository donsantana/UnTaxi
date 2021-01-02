//
//  Double.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 12/14/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import Foundation
extension FloatingPoint {
    func rounded(to value: Self, roundingRule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> Self {
       (self / value).rounded(roundingRule) * value
    }
}
