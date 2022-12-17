//
//  Alert.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 11/22/22.
//  Copyright © 2022 Done Santana. All rights reserved.
//

import UIKit

struct Alert {
	
	 static internal func show(title: String, message: String, vc: UIViewController, withActions actions: [UIAlertAction]?) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		if let actions = actions {
			for action in actions {
				alert.addAction(action)
			}
		} else {
			let action = UIAlertAction(title: GlobalStrings.okButtonTitle, style: .default) { _ in
			
			}
			alert.addAction(action)
		}
		
		DispatchQueue.main.async {
			vc.present(alert, animated: true, completion: nil)
		}
	}
	
	static func showBasic(title: String, message: String, vc: UIViewController, withActions actions: [UIAlertAction]?) {
		show(title: title, message: message, vc: vc, withActions: actions)
	}
	
	static func showFormIncomplete(vc: UIViewController, withMessage message: String) {
		show(title: GlobalStrings.formIncompleteTitle, message: message, vc: vc, withActions: nil)
	}
	
	static func showFormError(vc: UIViewController, withMessage message: String) {
		show(title: GlobalStrings.formErrorTitle, message: message, vc: vc, withActions: nil)
	}
	
	static func showLocationAutorizationError(on vc: UIViewController) {
		let okButton = UIAlertAction(title: GlobalStrings.autorizarButtonTitle, style: .default, handler: {alerAction in
			let settingsURL = URL(string: UIApplication.openSettingsURLString)!
			UIApplication.shared.open(settingsURL, options: [:], completionHandler: { success in
				exit(0)
			})
		})
		let cancelButton = UIAlertAction(title: GlobalStrings.closeAppButtonTitle, style: .default, handler: {alerAction in
			exit(0)
		})
		
		show(title: GlobalStrings.locationErrorTitle, message: GlobalStrings.locationErrorMessage, vc: vc, withActions: [okButton, cancelButton])
	}
	
	static func showSettingsAutorizationError(on vc: UIViewController, title: String, message: String, isRequired: Bool = false) {
		var actionButtons: [UIAlertAction] = []
		actionButtons.append(UIAlertAction(title: GlobalStrings.autorizarButtonTitle, style: .default, handler: {alerAction in
			let settingsURL = URL(string: UIApplication.openSettingsURLString)!
			UIApplication.shared.open(settingsURL, options: [:], completionHandler: { success in
				exit(0)
			})
		}))
		if isRequired {
			actionButtons.append(UIAlertAction(title: GlobalStrings.closeAppButtonTitle, style: .default, handler: {alerAction in
				exit(0)
			}))
		} else {
			actionButtons.append(UIAlertAction(title: GlobalStrings.cancelarButtonTitle, style: .default, handler: {alerAction in

			}))
		}

		show(title: title, message: message, vc: vc, withActions: actionButtons)
	}
	
}
