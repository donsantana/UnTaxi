//
//  ConfigMessages.swift
//  UnTaxi
//
//  Created by Done Santana on 6/22/23.
//  Copyright © 2023 Done Santana. All rights reserved.
//

import Foundation


struct ConfigMessage {
    var key: String
    var value: String
    
    init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}
