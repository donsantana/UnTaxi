//
//  SolDetallesExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 10/1/22.
//  Copyright © 2022 Done Santana. All rights reserved.
//

import UIKit

extension SolPendController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	//COLLECTION VIEW FUNCTION
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 4
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let sosBtnData = sosBtnArray[indexPath.row]
		
		let sosBtn = UIButton()

		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sosBtn",for: indexPath)
		sosBtn.frame = CGRect(x: 10, y: 10, width: cell.frame.width - 20, height: 45)
		sosBtn.backgroundColor = .red
		sosBtn.layer.cornerRadius = 20
		sosBtn.moveImageLeftTextCenter(imagePadding: 5)
		sosBtn.setImage(sosBtnData.image, for: .normal)
		sosBtn.setTitle(sosBtnData.title, for: .normal)
		sosBtn.setTitleColor(.white, for: .normal)
		sosBtn.isUserInteractionEnabled = false
		cell.addSubview(sosBtn)
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		collectionViewLayout.invalidateLayout()
		let cellWidthSize = UIScreen.main.bounds.width / 2.3
		return CGSize(width: cellWidthSize, height: cellWidthSize / 2.5)
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let trama:[String: Any] = [
			"idcliente": globalVariables.cliente.id!,
			"lat": globalVariables.cliente.annotation.coordinates.latitude,
			"lng": globalVariables.cliente.annotation.coordinates.longitude,
			"idsolicitud": solicitudPendiente.id,
			"tipoalerta": sosBtnArray[indexPath.row].type
		]
		SocketService.shared.socketEmit("alerta", datos: trama)
	}
}

