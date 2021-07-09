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
}
