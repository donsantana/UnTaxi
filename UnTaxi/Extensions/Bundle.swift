//
//  Bundle.swift
//  UnTaxi
//
//  Created by Done Santana on 6/30/25.
//  Copyright © 2025 Done Santana. All rights reserved.
//

import Foundation


extension Bundle {
    var displayName: String {
            let name = object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            return name ?? object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String
        }
}
