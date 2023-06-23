//
//  InicioFunctionsExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/4/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import MapboxMaps
import MapboxDirections
import MapboxGeocoder
import FloatingPanel

extension InicioController{
	//MARK:- FUNCIONES PROPIAS
	
	func checkForNewVersions() {
		DispatchQueue.main.async {
            if AppStoreService.shared.newVersionAvailable {
				
				let alertaVersion = UIAlertController (title: "Versión de la aplicación", message: "Estimado cliente es necesario que actualice a la última versión de la aplicación disponible en la AppStore. ¿Desea hacerlo en este momento?", preferredStyle: .alert)
				alertaVersion.addAction(UIAlertAction(title: "Si", style: .default, handler: {alerAction in
					
					UIApplication.shared.open(URL(string: GlobalConstants.itunesURL)!)
				}))
				alertaVersion.addAction(UIAlertAction(title: "No", style: .default, handler: {alerAction in
					exit(0)
				}))
				self.present(alertaVersion, animated: true, completion: nil)
			}
		}
	}
	
	func initTipoSolicitudBar(){
		if globalVariables.appConfig.pactadas && globalVariables.cliente.idEmpresa != 0{
			self.tabBar.setItems([self.ofertaItem, self.taximetroItem, self.horasItem, self.pactadaItem],animated: true)
			socketService.socketEmit("direccionespactadas", datos: [
				"idempresa": globalVariables.cliente.idEmpresa!
			] as [String: Any])
		} else {
			self.tabBar.setItems([self.ofertaItem, self.taximetroItem, self.horasItem],animated: true)
		}
		
        for item in self.tabBar.items!{
            if let image = item.image {
                item.image = image.withRenderingMode( .alwaysOriginal)
                item.selectedImage = item.selectedImage?.withRenderingMode(.alwaysOriginal)
            }
        }
		self.tabBar.selectedItem = self.tabBar.items![1] as UITabBarItem
		pagoCell.initContent(tipoServicio: tipoServicio)
		loadFormularioData()
	}
	
	//RECONECT SOCKET
	@objc func Reconect(){
		if contador <= 5 {
			globalVariables.socket.connect()
			contador += 1
		}
		else{
			let okAction = UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alerAction in
				exit(0)
			})
			Alert.showBasic(title: GlobalStrings.sinConexionTitle, message: GlobalStrings.sinConexionMessage, vc: self, withActions: [okAction])
		}
	}
	
	func loadFormularioData(){

		formularioDataCellList.removeAll()
		origenCell.origenText.text = origenAnnotation.address
		formularioDataCellList.append(self.origenCell)

		destinoCell.initContent(destinoAnnotation: destinoAnnotation)
		removeDestinoFromMap()
        self.formularioSolicitudHeight.constant = globalVariables.responsive.heightFloatPercent(percent: 37).relativeToIphone8Height(shouldUseLimit: false)
		if self.tabBar.selectedItem == self.ofertaItem || self.tabBar.selectedItem == self.pactadaItem {
			formularioDataCellList.append(self.destinoCell)
            self.formularioSolicitudHeight.constant = self.formularioSolicitudHeight.constant + 40
			if self.tabBar.selectedItem == self.ofertaItem {
				ofertaDataCell.initContent()
				self.formularioDataCellList.append(self.ofertaDataCell)
				self.formularioSolicitudHeight.constant = self.formularioSolicitudHeight.constant + 35//globalVariables.responsive.heightFloatPercent(percent: 58).relativeToIphone8Height(shouldUseLimit: false)
			} else {
                self.formularioDataCellList.append(self.pactadaCell)
				pactadaCell.precioText.text = "$\(String(format: "%.0f", 0.0))"
				origenCell.origenText.text?.removeAll()
				destinoAnnotation.address = ""
				destinoCell.destinoText.text?.removeAll()
				ofertaDataCell.resetValorOferta()
				formularioSolicitudHeight.constant = formularioSolicitudHeight.constant + 45//globalVariables.responsive.heightFloatPercent(percent: 49).relativeToIphone8Height(shouldUseLimit: false)
			}
		} else {
			if globalVariables.cliente.idEmpresa != 0 {
				if self.isVoucherSelected {
					self.formularioDataCellList.append(self.destinoCell)
                    formularioSolicitudHeight.constant = formularioSolicitudHeight.constant + 40
				}
			}
		}
		
		if self.tabBar.selectedItem != self.pactadaItem {
            self.pagoCell.updateVoucherOption(useVoucher: self.tabBar.selectedItem != self.ofertaItem)
            self.formularioDataCellList.append(self.pagoCell)
            self.formularioSolicitudHeight.constant = self.formularioSolicitudHeight.constant + 35
		} else {
//			self.pagoCell.updateVoucherOption(useVoucher: self.tabBar.selectedItem != self.ofertaItem)
//			self.formularioDataCellList.append(self.pagoCell)
//            self.formularioSolicitudHeight.constant = self.formularioSolicitudHeight.constant + 35
//			if pagoCell.formaPagoSelected == "Efectivo" {
//				formularioDataCellList.append(pagoYapaCell)
//			} else {
//				self.formularioSolicitudHeight.constant = globalVariables.responsive.heightFloatPercent(percent: 44).relativeToIphone8Height(shouldUseLimit: false)
//			}
		}
        if pagoCell.formaPagoSelected == "Efectivo" {
            formularioDataCellList.append(pagoYapaCell)
            self.formularioSolicitudHeight.constant = self.formularioSolicitudHeight.constant + 35
        }
		
		self.contactoCell.contactoNameText.setBottomBorder(borderColor: UIColor.black)
		self.contactoCell.telefonoText.setBottomBorder(borderColor: UIColor.black)
		self.contactoCell.clearContacto()
		self.formularioDataCellList.append(self.contactoCell)
		self.solicitudFormTable.reloadData()
		
		self.addEnvirSolictudBtn()
		self.addHeaderTitle()
	}
	
	//ADD FOOTER TO SOLICITDFORMTABLE
	func addEnvirSolictudBtn() {
		let enviarBtnView = UIView(frame: CGRect(x: 0, y: 0, width: self.SolicitudView.frame.width, height: 60))
		let button:UIButton = UIButton.init(frame: CGRect(x: 20, y: 10, width: self.SolicitudView.frame.width - 40, height: 50))
		button.setTitle("CONFIRMAR VIAJE", for: .normal)
		button.addTarget(self, action: #selector(self.enviarSolicitud), for: .touchUpInside)
		button.addCustomActionBtnsColors()
		
		enviarBtnView.addSubview(button)
		self.solicitudFormTable.backgroundColor = .none
		self.solicitudFormTable.tableFooterView = enviarBtnView
	}
	
	func addHeaderTitle() {
		let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.SolicitudView.bounds.width, height: 21))
		let baseTitle = UILabel.init(frame: CGRect(x: 40, y: 0, width: self.SolicitudView.bounds.width - 40, height: 21))
		baseTitle.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
		baseTitle.textColor = CustomAppColor.customBlueColor
		baseTitle.text = "Hola, \(globalVariables.cliente.getName())  \(self.pagoCell.formaPagoSwitch.isHidden || pagoCell.formaPagoSwitch.titleForSegment(at: pagoCell.formaPagoSwitch.selectedSegmentIndex) != "Voucher" ? "" : "Empresa: \(globalVariables.cliente.empresa ?? "")")"
		
		headerView.addSubview(baseTitle)
		self.solicitudFormTable.tableHeaderView = headerView
	}
	
	func getTaxisCercanos() {
		let data = [
			"idcliente": globalVariables.cliente.id!,
			"latitud": self.origenAnnotation.coordinates.latitude,
			"longitud": self.origenAnnotation.coordinates.longitude,
			"pilas": true
		] as [String: Any]
		socketService.socketEmit("cargarvehiculoscercanos", datos: data)
	}
	
	func socketEmit(_ eventName: String, datos: [String: Any]) {
		if CConexionInternet.isConnectedToNetwork() == true{
			if globalVariables.socket.status.active{
				globalVariables.socket.emitWithAck(eventName, datos).timingOut(after: 3) {respond in
					if respond[0] as! String == "OK"{
						print(respond)
					} else {
						print("error en socket")
					}
				}
			} else {
				let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor intentar otra vez.", preferredStyle: UIAlertController.Style.alert)
				alertaDos.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alerAction in
					exit(0)
				}))
				self.present(alertaDos, animated: true, completion: nil)
			}
		} else {
			ErrorConexion()
		}
	}
	
	//FUNCIONES ESCUCHAR SOCKET
	func ErrorConexion() {
		let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor revise su conexión a Internet.", preferredStyle: UIAlertController.Style.alert)
		alertaDos.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alerAction in
			exit(0)
		}))
		self.present(alertaDos, animated: true, completion: nil)
	}
	
	func Inicio() {
		initMapView()
		self.view.endEditing(true)
		
		if self.mapView!.annotations != nil {
			pointAnnotationManager.annotations = []
		}
		
		self.hideSolicitudView(isHidden: true)
		self.tabBar.selectedItem = self.ofertaItem
		super.topMenu.isHidden = false
		self.viewDidLoad()
	}
	
	func hideSolicitudView(isHidden: Bool) {
		print("Hidding Solicitud View \(isHidden)")
		self.SolicitudView.isHidden = isHidden
	}
	
	
	//FUNCIÓN BUSCA UNA SOLICITUD DENTRO DEL ARRAY DE SOLICITUDES PENDIENTES DADO SU ID
	//devolver posicion de solicitud
	func BuscarPosSolicitudID(_ id : String)->Int {
		var temporal = 0
		var posicion = -1
		for solicitudpdt in globalVariables.solpendientes{
			if String(solicitudpdt.id) == id{
				posicion = temporal
			}
			temporal += 1
		}
		return posicion
	}
	
	//Respuesta de solicitud
	func ConfirmaSolicitud(_ newSolicitud : [String:Any]) {
		//Trama IN: #Solicitud, ok, idsolicitud, fechahora
		waitingView.isHidden = true
		globalVariables.solpendientes.last!.RegistrarFechaHora(Id: newSolicitud["idsolicitud"] as! Int, FechaHora: newSolicitud["fechahora"]  as! String)
		let vc = R.storyboard.main.esperaChildView()!
		vc.solicitud = globalVariables.solpendientes.last!
		self.navigationController?.show(vc, sender: nil)
	}
	
	//FUncion para mostrar los taxis
	func MostrarTaxi(_ temporal : [String]) {
		//TRAMA IN: #Posicion,idtaxi,lattaxi,lngtaxi
		var i = 2
		var taxiscercanos = [MyMapAnnotation]()
		while i  <= temporal.count - 6{
			let taxiTemp = MyMapAnnotation(type: "taxi", address: temporal[i], location: CLLocationCoordinate2DMake(Double(temporal[i + 2])!, Double(temporal[i + 3])!), imageName: "taxi_libre")
			taxiscercanos.append(taxiTemp)
			i += 6
		}
		DibujarIconos(taxiscercanos)
	}
	
	//CANCELAR SOLICITUDES
	func MostrarMotivoCancelacion(solicitud: Solicitud) {
		let motivoAlerta = UIAlertController(title: "¿Por qué cancela el viaje?", message: "", preferredStyle: UIAlertController.Style.actionSheet)
		
		let titleAttributes = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 20)!, NSAttributedString.Key.foregroundColor: UIColor.black]
		let titleString = NSAttributedString(string: "¿Por qué cancela el viaje?", attributes: titleAttributes)
		motivoAlerta.setValue(titleString, forKey: "attributedTitle")
		
		for i in 0...Customization.motivosCancelacion.count - 1 {
			if i == Customization.motivosCancelacion.count - 1 {
				motivoAlerta.addAction(UIAlertAction(title: Customization.motivosCancelacion[i], style: .default, handler: { action in
					let ac = UIAlertController(title: Customization.motivosCancelacion[i], message: nil, preferredStyle: .alert)
					ac.addTextField()
					
					let submitAction = UIAlertAction(title: "Enviar", style: .default) { [unowned ac] _ in
						if !ac.textFields![0].text!.isEmpty{
							self.CancelarSolicitud(ac.textFields![0].text!, solicitud: solicitud)
						}
					}
					
					ac.addAction(submitAction)
					
					self.present(ac, animated: true)
				}))
			} else {
				motivoAlerta.addAction(UIAlertAction(title: Customization.motivosCancelacion[i], style: .default, handler: { action in
					self.CancelarSolicitud(Customization.motivosCancelacion[i], solicitud: solicitud)
				}))
			}
		}
		motivoAlerta.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { action in
		}))
		
		self.present(motivoAlerta, animated: true, completion: nil)
	}
	
	func CancelarSolicitud(_ motivo: String, solicitud: Solicitud) {
		//#Cancelarsolicitud, id, idTaxi, motivo, "# \n"
		//let temp = (globalVariables.solpendientes.last?.idTaxi)! + "," + motivo + "," + "# \n"
		let datos = solicitud.crearTramaCancelar(motivo: motivo)
		self.socketService.socketEmit("cancelarservicio", datos: datos)
	}
	
	func CloseAPP() {
		let fileAudio = FileManager()
		let AudioPath = NSHomeDirectory() + "/Library/Caches/Audio"
		do {
			try fileAudio.removeItem(atPath: AudioPath)
		} catch {
		}
		print("closing app")
		self.socketService.socketEmit("SocketClose", datos: ["idcliente": globalVariables.cliente.id])
		exit(3)
	}
	
	
	//FUNCION PARA DIBUJAR LAS ANOTACIONES
	
	func DibujarIconos(_ anotaciones: [MyMapAnnotation]){
		if anotaciones.count == 1 {
			pointAnnotationManager.annotations = [self.origenAnnotation.annotation,anotaciones[0].annotation]
		} else {
			for annotation in anotaciones {
				pointAnnotationManager.annotations.append(annotation.annotation)
			}
		}
	}
	
	
	//Validar los formularios
	func SoloLetras(name: String) -> Bool {
		// (1):
		let pat = "[0-9,.!@#$%^&*()_+-]"
		// (2):
		//let testStr = "x.wu@strath.ac.uk, ak123@hotmail.com     e1s59@oxford.ac.uk, ee123@cooleng.co.uk, a.khan@surrey.ac.uk"
		// (3):
		let regex = try! NSRegularExpression(pattern: pat, options: [])
		// (4):
		let matches = regex.matches(in: name, options: [], range: NSRange(location: 0, length: name.count))
		print(matches.count)
		if matches.count == 0{
			return true
		} else {
			return false
		}
	}
	
	func crearTramaSolicitud(_ nuevaSolicitud: Solicitud) {
		//#Solicitud, idcliente, nombrecliente, movilcliente, dirorig, referencia, dirdest,latorig,lngorig, latdest, lngdest, distancia, costo, #
		locationIcono.isHidden = true
		globalVariables.solpendientes.append(nuevaSolicitud)
		socketService.socketEmit("solicitarservicio", datos: nuevaSolicitud.crearTrama())
	}
	
	func crearSolicitud() {
		//#SO,idcliente,nombreapellidos,movil,dirorigen,referencia,dirdestino,latorigen,lngorigen,ladestino,lngdestino,distanciaorigendestino,valor oferta,voucher,detalle oferta,fecha reserva,tipo transporte,#
		
		waitingView.isHidden = false
		
		let origen = self.cleanTextField(textfield: self.origenCell.origenText)
		
		let origenCoord = self.origenAnnotation.coordinates
		
		let referencia = !self.pagoCell.referenciaText.text!.isEmpty ? self.cleanTextField(textfield: self.pagoCell.referenciaText) : "No referencia"
		
		let destino = self.cleanTextField(textfield: self.destinoCell.destinoText)
		
		let destinoCoord = self.destinoAnnotation.coordinates
		
		let voucher = !self.pagoCell.formaPagoSwitch.isHidden && self.pagoCell.formaPagoSwitch.selectedSegmentIndex == 1 ? "1" : "0"

		print("Forma de pago \(self.pagoCell.formaPagoSwitch.selectedSegmentIndex)")
		print("voucher \(voucher)")
		let detalleOferta = "No detalles"
		
		let fechaReserva = ""
		//var valorOferta = self.ofertaDataCell.valorOfertaText.text!.replacingOccurrences(of: ",", with: ".")
		let valorOferta = self.tabBar.selectedItem == self.ofertaItem ? Double((self.ofertaDataCell.valorOfertaText.text!.currencyString))! : self.tabBar.selectedItem == self.pactadaItem ? pactadaCell.importe : 0.0
		
		var tipoServicio = 1
		
		switch self.tabBar.selectedItem {
		case self.taximetroItem:
			tipoServicio = 2
		case self.horasItem:
			tipoServicio = 3
		case self.pactadaItem:
			tipoServicio = 4
		default:
			tipoServicio = 1
		}
		
		let pagoConTarjeta = pagoCell.formaPagoSwitch.titleForSegment(at: pagoCell.formaPagoSwitch.selectedSegmentIndex) == "Tarjeta"
		
		let isYapa = globalVariables.appConfig.yapa ? pagoYapaCell.pagarYapaSwitch.isOn : false
		let nuevaSolicitud = Solicitud(id: 0, fechaHora: "", dirOrigen: origen, referenciaOrigen: referencia, dirDestino: destino, latOrigen: origenCoord.latitude, lngOrigen: origenCoord.longitude, latDestino: destinoCoord.latitude, lngDestino: destinoCoord.longitude, importe: valorOferta, detalleOferta: detalleOferta, fechaReserva: fechaReserva, useVoucher: voucher, tipoServicio: tipoServicio,yapa: isYapa,tarjeta: pagoConTarjeta)
		nuevaSolicitud.DatosCliente(cliente: globalVariables.cliente!)
		
		if !self.contactoCell.telefonoText.text!.isEmpty{
			nuevaSolicitud.DatosOtroCliente(telefono: self.cleanTextField(textfield: self.contactoCell.telefonoText), nombre: self.cleanTextField(textfield: self.contactoCell.contactoNameText))
		}
		
		self.crearTramaSolicitud(nuevaSolicitud)
		view.endEditing(true)
	}
	
	func showFormError() {
		
	}
	
	@objc func enviarSolicitud() {
		if self.origenCell.origenText.text!.isEmpty {
			let alertaDos = UIAlertController (title: "Error en el formulario", message: "Por favor debe espeficicar su Origen.", preferredStyle: UIAlertController.Style.alert)
			alertaDos.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alerAction in
				self.view.endEditing(true)
				self.origenCell.origenText.becomeFirstResponder()
			}))
			self.present(alertaDos, animated: true, completion: nil)
		} else {
			if self.tabBar.selectedItem == self.ofertaItem || self.isVoucherSelected {
				if !(self.destinoCell.destinoText.text!.isEmpty) {
					if !self.ofertaDataCell.isValidOferta() && self.tabBar.selectedItem == self.ofertaItem {
						let alertaDos = UIAlertController (title: "Error en el formulario", message: "El valor de la oferta debe ser igual o superior a: $\(String(format: "%.2f", ofertaDataCell.getBestOferta()))", preferredStyle: .alert)
						alertaDos.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alerAction in
							self.ofertaDataCell.updateValorOfertaText()
						}))
						self.present(alertaDos, animated: true, completion: nil)
					} else {
                        if self.isVoucherSelected && globalVariables.llamadaFacilAlert != nil {
                            showAlertaUsoCorporativo()
                        } else {
                            crearSolicitud()
                        }
					
					}
				} else {
					let alertaDos = UIAlertController (title: "Error en el formulario", message: "Por favor debe espeficicar su destino.", preferredStyle: UIAlertController.Style.alert)
					alertaDos.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alerAction in
						self.view.endEditing(true)
						self.destinoCell.destinoText.becomeFirstResponder()
					}))
					self.present(alertaDos, animated: true, completion: nil)
					
				}
			} else {
				self.crearSolicitud()
			}
			
			if self.contactoCell.contactarSwitch.isOn{
				let (valid,_) = self.contactoCell.telefonoText.validate(.movilNumber)
				if !valid || self.contactoCell.telefonoText.text!.isEmpty{
					let alertaDos = UIAlertController (title: "Error en el formulario", message: "Si solicita para otra persona debe especificar el nombre y el número teléfono.", preferredStyle: .alert)
					alertaDos.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alerAction in
						if self.contactoCell.contactoNameText.text!.isEmpty{
							self.contactoCell.contactoNameText.becomeFirstResponder()
						} else {
							self.contactoCell.telefonoText.becomeFirstResponder()
						}
					}))
					self.present(alertaDos, animated: true, completion: nil)
				} else {
					self.crearSolicitud()
				}
			}
		}
	}
    
    func showAlertaUsoCorporativo() {
        let alertaDos = UIAlertController (title: GlobalStrings.avisoImportanteTitle, message: globalVariables.llamadaFacilAlert?.value, preferredStyle: .actionSheet)
        let titleAttributes = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 20)!, NSAttributedString.Key.foregroundColor: UIColor.red]
        let titleString = NSAttributedString(string: GlobalStrings.avisoImportanteTitle, attributes: titleAttributes)
        alertaDos.setValue(titleString, forKey: "attributedTitle")
        alertaDos.addAction(UIAlertAction(title: GlobalStrings.aceptarButtonTitle, style: .default, handler: {alerAction in
            self.crearSolicitud()
        }))
        alertaDos.addAction(UIAlertAction(title: GlobalStrings.cancelarButtonTitle, style: .cancel, handler: {alerAction in
            
        }))
        self.present(alertaDos, animated: true, completion: nil)
    }
	
	func removeDestinoFromMap() {
		destinoCell.destinoText.text?.removeAll()
		ofertaDataCell.resetValorOferta()
		destinoAnnotation.address = ""
		pointAnnotationManager.annotations.removeAll(where: {$0.id == destinoAnnotation.annotation.id})
		destinoAnnotation = MyMapAnnotation()
	}
	
	func getDestinoFromSearch(annotation: MyMapAnnotation){
		let wp1 = Waypoint(coordinate: self.origenAnnotation.coordinates, name: self.origenAnnotation.address)
		let wp2 = Waypoint(coordinate: annotation.coordinates, name: annotation.address)
		let options = RouteOptions(waypoints: [wp1, wp2])
		options.includesSteps = true
		options.routeShapeResolution = .full
		options.attributeOptions = [.congestionLevel, .maximumSpeedLimit]
		
		self.destinoAnnotation = annotation
		destinoCell.destinoText.text = self.destinoAnnotation.address
		
		Directions.shared.calculate(options) { (session, result) in
			switch result {
			case let .failure(error):
				print("Error calculating directions: \(error)")
			case let .success(response):
				if let route = response.routes?.first, let leg = route.legs.first {
					print("Route via \((route.distance/1000)):")
					let costo = globalVariables.tarifario.valorForDistance(distance: route.distance/1000)
					let valorOferta = costo.rounded(to: 0.05, roundingRule: .up) > globalVariables.tarifario.valorForDistance(distance: 0.0) ? costo.rounded(to: 0.05, roundingRule: .up) : globalVariables.tarifario.valorForDistance(distance: 0.0)
					
					self.ofertaDataCell.valorOfertaText.text = "$\(String(format: "%.2f", valorOferta))"
					self.ofertaDataCell.valorOferta = valorOferta
					self.hideSolicitudView(isHidden: false)
					
					let distanceFormatter = LengthFormatter()
					let formattedDistance = distanceFormatter.string(fromMeters: route.distance)
					
					let travelTimeFormatter = DateComponentsFormatter()
					travelTimeFormatter.unitsStyle = .short
					let formattedTravelTime = travelTimeFormatter.string(from: route.expectedTravelTime)
					
					print("Distance: \(formattedDistance); ETA: \(formattedTravelTime!)")
					
					for step in leg.steps {
						let direction = step.maneuverDirection?.rawValue ?? "none"
						print("\(step.instructions) [\(step.maneuverType) \(direction)]")
						if step.distance > 0 {
							let formattedDistance = distanceFormatter.string(fromMeters: step.distance)
							print("— \(step.transportType) for \(formattedDistance) —")
						}
					}
					
					if var routeCoordinates = route.shape?.coordinates, routeCoordinates.count > 0 {
						// Convert the route’s coordinates into a polyline.
						//TODO: Add route Line
						//let routeLine = MGLPolyline(coordinates: &routeCoordinates, count: UInt(routeCoordinates.count))
						
						// Add the polyline to the map.
						if route.distance > 300 {
							var lineAnnotation = PolylineAnnotation(lineCoordinates: [self.origenAnnotation.coordinates, self.destinoAnnotation.coordinates])
							lineAnnotation.lineColor = StyleColor(.gray)

							// Create the `PolylineAnnotationManager` which will be responsible for handling this annotation
							let lineAnnnotationManager = self.mapView.annotations.makePolylineAnnotationManager()

							// Add the annotation to the manager.
							//lineAnnnotationManager.annotations = [lineAnnotation]
							//self.mapView.addPolyline(origin: self.origenAnnotation, destiny: self.destinoAnnotation)
						}
					}
					self.showAnnotations([self.origenAnnotation, self.destinoAnnotation])
				}
			}
		}
	}
	
	func openSearchAddress(){
		super.hideMenuBar(isHidden: true)
		self.searchAddressView.isHidden = false
		self.searchText.placeholder = self.searchingAddress == "origen" ? "Ingrese nuevo origen" : "Ingrese nuevo destino"
		
		self.navigationController?.setNavigationBarHidden(false, animated: true)
		searchAddressList.removeAll()
		searchText.text?.removeAll()
		
		let mapBtnView = UIView(frame: CGRect(x: 0, y: 0, width: self.addressTableView.frame.width, height: 60))
		mapBtnView.addSubview(openMapBtn)
		addressTableView.tableFooterView = mapBtnView
		
		DispatchQueue.main.async { [self] in
			self.searchText.becomeFirstResponder()
		}
	}
	
	func closeSearchAddress(addressSelected: Address?){
		super.hideMenuBar(isHidden: false)
		self.mapBottomConstraint.constant = 0
		searchText.endEditing(true)
		self.navigationController?.setNavigationBarHidden(true, animated: true)
		self.searchAddressView.isHidden = true
		
		if addressSelected != nil {
			let annotation = MyMapAnnotation()
			annotation.coordinates = addressSelected!.getCoordinates()
			annotation.address = "\(addressSelected!.nombre), \(addressSelected!.distrito)"
			
			if searchingAddress == "origen" {
				annotation.type = "origen"
				origenAnnotation = annotation
				origenCell.origenText.text = annotation.address
				initMapView()
			} else {
				annotation.type = "destino"
				destinoAnnotation = annotation
				pointAnnotationManager.annotations.removeAll()
				pointAnnotationManager.annotations = [self.origenAnnotation.annotation,self.destinoAnnotation.annotation]
				self.getDestinoFromSearch(annotation: destinoAnnotation)
			}
		} else {
			if self.searchingAddress == "origen" {
				origenAnnotation.coordinates = self.origenAnnotation.coordinates
				origenAnnotation.address = self.origenAnnotation.address
			} else {
				destinoAnnotation.coordinates = self.origenAnnotation.coordinates
				destinoAnnotation.address = ""
				removeDestinoFromMap()
			}
		}
	}
	
	@objc func openMapBtnAction(){
		self.addressPreviewText.isHidden = false
		self.view.endEditing(true)
		self.searchAddressView.isHidden = true
		self.mapBottomConstraint.constant = self.formularioSolicitudHeight.constant
	}
	
	//MARK:- CONTROL DE TECLADO VIRTUAL
	//Funciones para mover los elementos para que no queden detrás del teclado
	
	@objc internal func keyboardWillShow(notification: NSNotification) -> Void {
		if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
			if self.navigationController != nil && self.navigationController?.isNavigationBarHidden == false || !tarjetasView.isHidden {
				print("Keyboard height \(keyboardSize.height)")
				//				let bottomOfOpenMapBtn = openMapBtn.convert(openMapBtn.bounds, to: self.view).maxY;
				//				self.openMapBtn.frame = CGRect(x: 20, y: Responsive().heightFloatPercent(percent: 84) - keyboardSize.height, width: self.view.bounds.width - 40, height: 40)
				//						let topOfKeyboard = self.view.frame.height - keyboardSize.height
				//
				//						// if the bottom of Textfield is below the top of keyboard, move up
				//						if bottomOfOpenMapBtn < topOfKeyboard {
				//							self.openMapBtn.frame = CGRect(x: 20, y: Responsive().heightFloatPercent(percent: 80) - keyboardSize.height, width: self.view.bounds.width - 40, height: 40)
				//						}
				
			} else {
				self.view.frame.origin.y = -keyboardSize.height
			}
		}
	}
	
	@objc internal func keyboardWillHide(notification: NSNotification) {
		if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
			if self.navigationController != nil && self.navigationController?.isNavigationBarHidden == false {
				//self.openMapBtn.frame = CGRect(x: 20, y: Responsive().heightFloatPercent(percent: 84), width: self.view.bounds.width - 40, height: 40)
			} else {
				self.view.frame.origin.y = 0
			}
		}
	}
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		animateViewMoving(false, moveValue: 60, view: self.view)
	}
	
	@objc func textViewDidChange(_ textView: UITextView) {
		
	}

	@objc func ocultarTeclado(sender: UITapGestureRecognizer){
		print("ocultar teclado")
		//sender.cancelsTouchesInView = false
		self.SolicitudView.endEditing(true)
	}
	
	//  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
	//    if touch.view?.isDescendant(of: self.TablaDirecciones) == true {
	//      gestureRecognizer.cancelsTouchesInView = false
	//    } else {
	//      self.SolicitudView.endEditing(true)
	//    }
	//    return true
	//  }
	//
	func cleanTextField(textfield: UITextField)->String{
		var cleanedTextField = textfield.text?.uppercased()
		cleanedTextField = cleanedTextField!.replacingOccurrences(of: "Ñ", with: "N",options: .regularExpression, range: nil)
		cleanedTextField = cleanedTextField!.replacingOccurrences(of: "[,.]", with: "-",options: .regularExpression, range: nil)
		cleanedTextField = cleanedTextField!.replacingOccurrences(of: "[\n]", with: "-",options: .regularExpression, range: nil)
		cleanedTextField = cleanedTextField!.replacingOccurrences(of: "[#]", with: "No",options: .regularExpression, range: nil)
		return cleanedTextField!.folding(options: .diacriticInsensitive, locale: .current)
	}
	
	@objc func dismissPicker() {
		view.endEditing(true)
	}
	
	//MARK:- FUNCION DETERMINAR DIRECCIÓN A PARTIR DE COORDENADAS
	func getAddressFromCoordinate(_ annotation: MyMapAnnotation){
		if annotation.coordinates.latitude != 0.0 {
			print("google \(annotation.coordinates)")
			let geocoder = CLGeocoder()
			var address = ""
			
			let temporaLocation = CLLocation(latitude: annotation.coordinates.latitude, longitude: annotation.coordinates.longitude)
			geocoder.reverseGeocodeLocation(temporaLocation, completionHandler: { [self](placemarks, error) -> Void in
				if error != nil {
					print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
					return
				}
				
				if (placemarks?.count)! > 0{
					let placemark = (placemarks?.first)! as CLPlacemark
					
					if let name = placemark.addressDictionary?["Name"] as? String {
						print("google \(name) \(annotation.type)")
						address += name
					}
					
					//            if let locality = placemark.addressDictionary?["City"] as? String {
					//              address += " \(locality)"
					//            }
					//
					//          if let state = placemark.addressDictionary?["State"] as? String {
					//            address += " \(state)"
					//          }
					//
					//          if let country = placemark.country{
					//            address += " \(country)"
					//          }
					annotation.address = address
					annotation.type == "origen" ? (self.origenCell.origenText.text = address) : (self.destinoCell.destinoText.text = address)
					self.addressPreviewText.text = address
					print("direccion \(self.destinoCell.destinoText.text)")
				}else {
					annotation.address = "No disponible"
				}
			})
		}
	}
	
	func getReverseAddressXoaAPI(_ annotation: MyMapAnnotation) {
		apiService.searchReverseAddressXoaAPI(lat: annotation.coordinates.latitude, lon: annotation.coordinates.longitude, completionHandler: { data, response, error in
			annotation.address = "Sin resultado"
			var addressString = ""
			
			if let _ = error {
				return
			}
		
			do {
				let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
				guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
					return
				}
				
				var addressList: [Address] = []
				for address in json["features"] as! [[String:AnyObject]] {
					let newAddress = try Address(json: address)
					addressList.append(newAddress)
				}
				
				if let address = addressList.first {
					if address.nombre != "" {
						addressString += "\(address.nombre)"
					}
					
					if address.distrito != "" {
						addressString += ", \(address.distrito)"
					}
				}
				
				DispatchQueue.main.async {
					annotation.address = addressString
					annotation.type == "origen" ? (self.origenCell.origenText.text = addressString) : (self.destinoCell.destinoText.text = addressString)
					self.addressPreviewText.text = addressString
				}
				
			} catch {
				return
			}
			
		})
	}
	
	@objc func openRegisterCardView() {
		super.hideMenuBar(isHidden: true)
		let accessToken = globalVariables.userDefaults.value(forKey: "accessToken") as! String
		print("AddURL \(GlobalConstants.addCardsUrl)\(accessToken)")
		let url = URL(string: "\(GlobalConstants.addCardsUrl)\(accessToken)")
		let requestObj = URLRequest(url: url! as URL)
		tarjetaWebView.load(requestObj)
		tarjetasView.isHidden = false
		waitingView.isHidden = false
	}
	
	func enviarPagoConTajeta(idSolicitud: String, tokenCard: String) {
		let accessToken = globalVariables.userDefaults.value(forKey: "accessToken") as! String
		let datos:[String: Any] = [
			"toke": tokenCard,
			"idsolicitud": idSolicitud,
			"idcliente": globalVariables.cliente.id
		]
		socketService.socketEmit("pagarcontarjeta", datos: datos)
	}
	
}
