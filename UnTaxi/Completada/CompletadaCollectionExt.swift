//
//  CompletadaCollectionExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 1/6/21.
//  Copyright © 2021 Done Santana. All rights reserved.
//

import UIKit


extension CompletadaController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
  //COLLECTION VIEW FUNCTION
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.evaluacion.getComentariosOptions().count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ComentarioCell",for: indexPath) as! ComentarioCollectionCell
    //cell.delegate = self
    cell.initContent()
    cell.comentarioText.text = self.evaluacion.getComentariosOptions()[indexPath.row]
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    collectionViewLayout.invalidateLayout()
    let cellWidthSize = UIScreen.main.bounds.width / 2.5
    return CGSize(width: cellWidthSize, height: cellWidthSize/2.5)
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if !self.comentariosSelected.contains(self.evaluacion.getComentariosOptions()[indexPath.row]){
      self.comentariosSelected.append(self.evaluacion.getComentariosOptions()[indexPath.row])
      (collectionView.cellForItem(at: indexPath) as! ComentarioCollectionCell).comentarioText.backgroundColor =  Customization.buttonActionColor
    }else{
      self.comentariosSelected.removeAll{$0 == self.evaluacion.getComentariosOptions()[indexPath.row]}
      (collectionView.cellForItem(at: indexPath) as! ComentarioCollectionCell).comentarioText.backgroundColor =  .white
    }
    
  }
  
//  func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//    (collectionView.cellForItem(at: indexPath) as! ComentarioCollectionCell).comentarioText.backgroundColor = .white
//  }
//
//  func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//    if (collectionView.cellForItem(at: indexPath)!.isSelected){
//      print("hereeeee")
//      collectionView.deselectItem(at: indexPath, animated: false)
//      return false
//    }
//    return true
//  }
  
}
