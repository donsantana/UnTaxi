//
//  StringConstants.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 6/8/22.
//  Copyright © 2022 Done Santana. All rights reserved.
//

import Foundation


struct GlobalStrings {
	//Alerts
	static let sinConexionTitle: String = NSLocalizedString("Sin Conexión",comment:"")
	static let sinConexionMessage: String = NSLocalizedString("No se puede conectar al servidor por favor intentar otra vez.",comment:"")
	
	static let errorGenericoTitle: String = NSLocalizedString("Error",comment:"")
	static let errorGenericoMessage: String = NSLocalizedString("Ha ocurrido un error en el servidor por favor intentar otra vez.",comment:"")
	
	static let clavesNoCoincidenMessage: String = NSLocalizedString("Las contraseñas no coinciden",comment:"")
	static let audioConductorTitle: String = NSLocalizedString("Mensaje del conductor",comment:"")
	static let audioConductorMessage: String = NSLocalizedString("Ha recibido un mensaje de audio del conductor, para reproducirlo es necesario activar el micrófono de su dispositivo.",comment:"")
	
	static let cardRegisteredError: String = NSLocalizedString("El registro de la tarjeta falló. Por favor intentelo otra vez.",comment:"")
	static let cardRegisteredSuccess: String = NSLocalizedString("La tarejta se registró con éxito.",comment:"")
	static let cardRegisteredDuplicated: String = NSLocalizedString("La tarjeta fue registrada anteriormente. Por favor verífique en su lista de Tarjetas registradas.",comment:"")
	static let eliminarTarjetaTitle: String = NSLocalizedString("Eliminar Tarjeta",comment:"")
	static let eliminarTarjetaMessage: String = NSLocalizedString("¿Está seguro que desea eliminar esta tarjeta?",comment:"")
	static let tarjetaEliminadaTitle: String = NSLocalizedString("Tarjeta Eliminada",comment:"")
	static let tarjetaEliminadaSucess: String = NSLocalizedString("La tarjeta se eliminó correctamente",comment:"")
	static let noCardsTiTle: String = NSLocalizedString("No tiene Tarjetas Registradas",comment:"")
    static let noCardsMessage: String = NSLocalizedString("Por favor debe registrar alguna tarjeta para el pago.",comment:"")
    static let avisoImportanteTitle: String = NSLocalizedString("Aviso Importante",comment:"")
	//static let noCardsMessage: String = NSLocalizedString("Por favor debe registrar alguna tarjeta para el pago.",comment:"")
	
	//Formularios
	static let formErrorTitle: String = NSLocalizedString("Error en el formulario",comment:"")
	static let formErrorMessage: String = NSLocalizedString("Por favor revizar todos los campos del formulario",comment:"")
	static let formIncompleteTitle: String = NSLocalizedString("Formulario incompleto",comment:"")
	static let formIncompleteMessage: String = NSLocalizedString("Debe llenar todos los campos del formulario",comment:"")
	static let passNotMatchMessage: String = NSLocalizedString("Las contraseñas no coinciden.",comment:"")
	static let telefonoNotValidMessage: String = NSLocalizedString("Número de teléfono incorrecto. Por favor verifíquelo",comment:"")
	
	static let emptyFieldMessage: String = NSLocalizedString("Este campo no puede enviarse vacío",comment:"")
	static let registroUsuarioTitle: String = NSLocalizedString("Registro de usuario",comment:"")
	
	
	static let locationErrorTitle: String = NSLocalizedString("Error de Localización",comment:"")
	static let locationErrorMessage: String = NSLocalizedString("La aplicación requiere su ubicacion exacta para buscar los taxis cercanos. Por favor autorice el acceso de la aplición al servicio de localización.",comment:"")
	static let emptyOrigenMessage: String = NSLocalizedString("Por favor debe espeficicar su Origen.",comment:"")
	static let emptyDestinoMessage: String = NSLocalizedString("Debe llenar todos los campos del formulario",comment:"")
	static let wrongTelefonoMessage: String = NSLocalizedString("Si solicita para otra persona debe especificar el nombre y el número teléfono válido.",comment:"")
	static let pactadaTitle: String = NSLocalizedString("Dirección de Pactada",comment:"")
	static let pactadaMessage: String = NSLocalizedString("Su empresa no dispone de direcciones pactadas. Por favor contacte con la dirección de su compañía.",comment:"")
	
	//static let canceladaErrorTitle: String = NSLocalizedString("Error de Localización",comment:"")
	static let contactarNombreMessage: String = NSLocalizedString("Debe teclear el nombre de la persona que el conductor debe contactar.",comment:"")
	static let estadoSolicitudTitle: String = NSLocalizedString("Estado de Solicitud",comment:"")
	static let canceladaExitoMessage: String = NSLocalizedString("Su solicitud fue cancelada con éxito.",comment:"")
	static let canceladaErrorMessage: String = NSLocalizedString("Su solicitud fue cancelada con éxito.",comment:"")
	static let canceladaConductorMessage: String = NSLocalizedString("Solicitud cancelada por el conductor.",comment:"")
	
	static let taxiLlegoTitle: String = NSLocalizedString("Su taxi ha llegado.",comment:"")
	static let taxiLlegoMessage: String = NSLocalizedString("Tiene un período de gracia de 5 min.",comment:"")
	
	static let removeClientTitle: String = NSLocalizedString("Eliminar Usuario",comment:"")
	static let removeClientMessage: String = NSLocalizedString("¿Estás seguro que desea eliminar su cuenta?",comment:"")
	static let profileUpdatedTitle: String = NSLocalizedString("Perfil Actualizado",comment:"")
    static let errorTitle: String = NSLocalizedString("Error de Perfil",comment:"")
    static let usuarioEliminadoExito: String = NSLocalizedString("Usuario eliminado con éxito.",comment:"")
	static let usuarioEliminadoError: String = NSLocalizedString("El usuario no pudo ser eliminado. Por favor intente otra vez.",comment:"")

    static let wronCameraMessage = NSLocalizedString("El perfil solo acepta una foto frontal.", comment:"")
    static let codeValidationTitle = NSLocalizedString("Verificación de Usuario", comment:"")
    static let codeValidationMessage = NSLocalizedString("Se le ha enviado un mensaje de Whatsapp con el código de verificación. Por favor cópielo y péguelo aquí.", comment:"")
    static let codeValidationPlaceholder = NSLocalizedString("Código de verificación", comment:"")
	static let maxIntentMessage = NSLocalizedString("Ha consumido los 3 intentos permitidos. Por favor, vuelva a realizar el proceso de registro.", comment:"")
	
	//Forms
	
	//Buttons title
	static let yesButtonTitle: String = NSLocalizedString("Si",comment:"")
	static let noButtonTitle: String = NSLocalizedString("No",comment:"")
	static let okButtonTitle: String = NSLocalizedString("OK",comment:"")
	static let aceptarButtonTitle: String = NSLocalizedString("Aceptar",comment:"")
	static let eliminarButtonTitle: String = NSLocalizedString("Eliminar",comment:"")
	static let cancelarButtonTitle: String = NSLocalizedString("Cancelar",comment:"")
	static let autorizarButtonTitle: String = NSLocalizedString("Autorizar",comment:"")
	static let closeAppButtonTitle: String = NSLocalizedString("Cerrar aplicación",comment:"")
    static let settingsBtnTitle: String = NSLocalizedString("Configuración",comment:"")
	static let verficarBtnTitle: String = NSLocalizedString("Verificar",comment:"")
	
	//Placeholders
	static let enterOrigen: String = NSLocalizedString("Ingrese nuevo origen",comment:"")
	static let enterDestino: String = NSLocalizedString("Ingrese nuevo destino",comment:"")

	
}
