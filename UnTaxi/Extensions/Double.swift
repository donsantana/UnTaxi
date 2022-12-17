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

extension Double {
	func round(to places: Int) -> Double {
		let divisor = pow(10.0, Double(places))
		return (self * divisor).rounded() / divisor
	}
}
