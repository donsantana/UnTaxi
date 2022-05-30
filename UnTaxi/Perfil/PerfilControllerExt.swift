//
//  PerfilControllerExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/5/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import Foundation
import UIKit

extension PerfilController: UITextFieldDelegate{
  //CONTROL DE TECLADO VIRTUAL
  //Funciones para mover los elementos para que no queden detrás del teclado
  func textFieldDidBeginEditing(_ textField: UITextField) {
    animateViewMoving(true, moveValue: 180, view: self.view)
//    if textField.isEqual(emailText){
//      animateViewMoving(true, moveValue: 180, view: self.view)
//    }
  }
  
  func textFieldDidEndEditing(_ textfield: UITextField) {
    animateViewMoving(false, moveValue: 180, view: self.view)
//    if textfield.isEqual(emailText){
//      animateViewMoving(false, moveValue: 180, view: self.view)
//    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    switch textField {
    case nombreApellidosText:
      emailText.becomeFirstResponder()
    case emailText:
      let (valid, message) = textField.validate(.email)
      print("valid \(valid)")
      if !valid && !textField.text!.isEmpty{
        let alertaDos = UIAlertController (title: "Error en el formulario", message: message, preferredStyle: .alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          self.emailText.becomeFirstResponder()
        }))
        self.present(alertaDos, animated: true, completion: nil)
      } else {
        self.EnviarActualizacion()
      }
     
    default:
      textField.endEditing(true)
    }
    return true
  }
  
  func animateViewMoving (_ up:Bool, moveValue :CGFloat, view : UIView){
    let movementDuration:TimeInterval = 0.3
    let movement:CGFloat = ( up ? -moveValue : moveValue)
    UIView.beginAnimations( "animateView", context: nil)
    UIView.setAnimationBeginsFromCurrentState(true)
    UIView.setAnimationDuration(movementDuration)
    view.frame = view.frame.offsetBy(dx: 0,  dy: movement)
    UIView.commitAnimations()
  }
  
  func keyboardNotification(notification: NSNotification){
    if let userInfo = notification.userInfo{
      let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
      let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
      let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
      let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
      let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
      if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
        animateViewMoving(false, moveValue: 180, view: self.view)//self.keyboardHeightLayoutConstraint?.constant = 0.0
      } else {
        animateViewMoving(true, moveValue: 180, view: self.view)//self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
      }
      UIView.animate(withDuration: duration,
                     delay: TimeInterval(0),
                     options: animationCurve,
                     animations: { self.view.layoutIfNeeded() },
                     completion: nil)
    }
    //animateViewMoving(true, moveValue: 135, view: self.view)
  }
}

extension PerfilController: ApiServiceDelegate{
	func apiRequest(_ controller: ApiService, updatedProfileAPI data: [String: Any]) {
		DispatchQueue.main.async {
			self.waitingView.isHidden = true
			globalVariables.cliente.updateProfile(jsonData: data["datos"] as! [String: Any])
			let alertaDos = UIAlertController (title: "Perfil Actualizado", message: data["msg"] as! String, preferredStyle: UIAlertController.Style.alert)
			alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
				self.goToInicioView()
			}))
			
			self.present(alertaDos, animated: true, completion: nil)
		}
	}
	
	
  func apiRequest(_ controller: ApiService, updatedProfileError msg: String) {
    let alertaDos = UIAlertController (title: "Error de Perfil", message: msg, preferredStyle: UIAlertController.Style.alert)
    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
      DispatchQueue.main.async {
        self.goToInicioView()
      }
    }))
    
    self.present(alertaDos, animated: true, completion: nil)
  }
  
  func apiRequest(_ controller: ApiService, getAPIError msg: String) {
    DispatchQueue.main.async {
      let alertaDos = UIAlertController (title: "Error", message: msg, preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        self.waitingView.isHidden = true
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
}

extension PerfilController: UINavigationControllerDelegate, UIImagePickerControllerDelegate{
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    // Local variable inserted by Swift 4.2 migrator.
    let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

    if camaraController.cameraDevice == .front{
      //let stringType = type as String
      self.camaraController.dismiss(animated: true, completion: nil)
      let photoPreview = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
      self.userPerfilPhoto.image = photoPreview?.scalePreservingAspectRatio(targetSize: CGSize(width: 200, height: 200))
      globalVariables.cliente.updatePhoto(newPhoto: self.userPerfilPhoto.image!)
      self.isPhotoUpdated = true
    } else {
      self.camaraController.dismiss(animated: true, completion: nil)
      let EditPhoto = UIAlertController (title: NSLocalizedString("Error",comment:"Cambiar la foto de perfil"), message: NSLocalizedString("The profile only accepts selfies photo.", comment:""), preferredStyle: UIAlertController.Style.alert)
      
      EditPhoto.addAction(UIAlertAction(title: NSLocalizedString("Take a picture again", comment:"Yes"), style: UIAlertAction.Style.default, handler: {alerAction in
        self.camaraController.sourceType = .camera
        self.camaraController.cameraCaptureMode = .photo
        self.camaraController.cameraDevice = .front
        self.present(self.camaraController, animated: true, completion: nil)
      }))
      EditPhoto.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment:"Cancelar"), style: UIAlertAction.Style.destructive, handler: { action in
      }))
      self.present(EditPhoto, animated: true, completion: nil)
    }
  }
  
  
  //RENDER IMAGEN
  func saveImageToFile(_ image: UIImage) -> URL
  {
    let filemgr = FileManager.default
    
    let dirPaths = filemgr.urls(for: .documentDirectory,
                                in: .userDomainMask)
    
    let fileURL = dirPaths[0].appendingPathComponent(image.description)
    
    if let renderedJPEGData =
      image.jpegData(compressionQuality: 0.5) {
      try! renderedJPEGData.write(to: fileURL)
    }
    
    return fileURL
  }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
  return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
  return input.rawValue
}
