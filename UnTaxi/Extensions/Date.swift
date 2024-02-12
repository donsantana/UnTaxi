//
//  Date.swift
//  UnTaxi
//
//  Created by Done Santana on 8/22/23.
//  Copyright © 2023 Done Santana. All rights reserved.
//

import Foundation

extension Date {
    static let date = Date()
    static var isTimeBriceAd: Bool {
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: date)
        let hour = myCalendar.component(.hour, from: date)
        print("weekDay \(weekDay)")
        return ((weekDay == 5 || weekDay == 6 || weekDay == 7) && hour >= 20)
    }
}
