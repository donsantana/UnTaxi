//
//  UIButton.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 8/12/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import UIKit

extension UIButton{
  func addBorder(color: UIColor) {
    self.layer.borderWidth = 1
    self.layer.cornerRadius = 10
    self.layer.borderColor = color.cgColor
  }
  
  func addUnderline() {
    guard let text = self.titleLabel?.text else { return }
    
    let attributedString = NSMutableAttributedString(string: text)
    attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))
    
    self.setAttributedTitle(attributedString, for: .normal)
  }
  
  func addCustomColors(titleColor: UIColor?, backgroundColor: UIColor?) {
    self.layer.cornerRadius = 10
    self.titleLabel?.font = CustomAppFont.buttonActionFont
    self.backgroundColor = backgroundColor != nil ? backgroundColor : CustomAppColor.buttonActionColor
    self.setTitleColor(titleColor != nil ? titleColor : CustomAppColor.buttonsTitleColor, for: .normal)
  }
  
  func addCustomImageColor(tintColor: UIColor, backgroundColor: UIColor?){
    self.backgroundColor = backgroundColor != nil ? backgroundColor : .white
    self.setImage(self.currentImage?.withRenderingMode(.alwaysTemplate), for: .normal)
    self.tintColor = tintColor
  }
  
  func addCustomMenuBtnsColors(image: UIImage, tintColor: UIColor, backgroundColor: UIColor?) {
    let closeImage = image.withRenderingMode(.alwaysTemplate)
    self.setImage(closeImage, for: UIControl.State())
    self.layer.cornerRadius = self.frame.height/2
    self.addCustomImageColor(tintColor: tintColor, backgroundColor: backgroundColor)
    self.addShadow()
  }
  
  func addCustomActionBtnsColors() {
    self.backgroundColor = CustomAppColor.buttonActionColor
    self.setTitleColor(CustomAppColor.buttonsTitleColor, for: .normal)
    self.setTitle(self.titleLabel?.text?.uppercased(), for: .normal)
    self.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 20)
    self.addShadow()
    self.layer.cornerRadius = 5
  }
	
	func moveImageLeftTextCenter(imagePadding: CGFloat = 30.0) {
			guard let imageViewWidth = self.imageView?.frame.width else{return}
			guard let titleLabelWidth = self.titleLabel?.intrinsicContentSize.width else{return}
			self.contentHorizontalAlignment = .left
			imageEdgeInsets = UIEdgeInsets(top: 0.0, left: imagePadding - imageViewWidth / 2, bottom: 0.0, right: 0.0)
			titleEdgeInsets = UIEdgeInsets(top: 0.0, left: imageViewWidth + 5, bottom: 0.0, right: 0.0)
	}
  
}
