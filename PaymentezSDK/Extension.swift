//
//  Extension.swift
//  PaymentezSDK
//
//  Created by Gustavo Sotelo on 05/09/17.
//  Copyright © 2017 Paymentez. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle(for: PaymentezCard.self), value: "", comment: "")
    }
}

