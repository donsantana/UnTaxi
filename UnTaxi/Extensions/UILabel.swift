//
//  UILable.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 6/16/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit

extension UILabel {
    func addUnderline() {
        if let textString = self.text {
            let attributedString = NSMutableAttributedString(string: textString)
          attributedString.addAttribute(NSAttributedString.Key.underlineStyle,
                                        value: NSUnderlineStyle.single.rawValue,
                                          range: NSRange(location: 0, length: attributedString.length - 1))
            attributedText = attributedString
        }
    }
}
