//
//  ViewController.swift
//  Xtaxi
//
//  Created by Done Santana on 14/10/15.
//  Copyright © 2015 Done Santana. All rights reserved.
//

import UIKit
import Socket_IO_Client_Swift

struct myvariables {
    static var idusuario : String = ""
    static var solicitud = CSolicitud()
    static var socket : SocketIOClient!
    static var solpendientes = [CSolPendiente]()
    static var prueba = [String]()
}

class ViewController: UIViewController, UITextFieldDelegate {

   
    //var conexionSocket = CSocket()
    
    var idusuario = String()
    var cliente : CCliente! //usuario y contraseña para el login automatico
    //var cliente : CCliente!
    @IBOutlet weak var Usuario: UITextField!
    @IBOutlet weak var Clave: UITextField!
    
    
    
    //Registro Variables
   
    @IBOutlet weak var RegistroView: UIView!
    @IBOutlet weak var telefonoText: UITextField!
    @IBOutlet weak var usuarioText: UITextField!
    
    @IBOutlet weak var nombreApText: UITextField!
    @IBOutlet weak var claveText: UITextField!
    @IBOutlet weak var confirmarClavText: UITextField!
    @IBOutlet weak var correoText: UITextField!
    
    
    @IBOutlet weak var RegistrarBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myvariables.socket = SocketIOClient(socketURL: "104.171.10.34:5800")
        // Do any additional setup after loading the view, typically from a nib.
       self.ControlEventos()
       myvariables.socket.connect()
        //asignar el delegado a los textfield para poder utilizar las funciones propias
       telefonoText.delegate = self
       claveText.delegate = self
       correoText.delegate = self
        Clave.delegate = self
       confirmarClavText.delegate = self
       telefonoText.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
     }   
    
    //Funcion para controlar los eventos del socket
    func ControlEventos(){
        myvariables.socket.on("LoginPassword"){data, ack in
          let temporal = String(data).componentsSeparatedByString(",")
            
            if (temporal[0] == "[#LoginPassword"){
                self.Autenticacion(temporal)
            }
            else{
             self.Usuario.text = "Vacio"
            }
        }
        
       myvariables.socket.on("Registro") {data, ack in
           let temporal = String(data).componentsSeparatedByString(",")
        
           if temporal[1] == "registrook"{
               let alertaDos = UIAlertController (title: "Registro de Usuario", message: "Registro Realizado con éxito, puede loguearse en la aplicación", preferredStyle: UIAlertControllerStyle.Alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default, handler: {alerAction in
                self.RegistroView.hidden = true
                }))
                
                //Para hacer que la alerta se muestre usamos presentViewController, a diferencia de Objective C que como recordaremos se usa [Show Alerta]
                
                self.presentViewController(alertaDos, animated: true, completion: nil)
            }
            else{
                let alertaDos = UIAlertController (title: "Registro de Usuario", message: "Error al registrar el usuario: " + String(temporal[2]), preferredStyle: UIAlertControllerStyle.Alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default, handler: {alerAction in
                    
                }))
                
                //Para hacer que la alerta se muestre usamos presentViewController, a diferencia de Objective C que como recordaremos se usa [Show Alerta]
                
                self.presentViewController(alertaDos, animated: true, completion: nil)
            }
          }
        
    }
     override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    //Boton de Autenticacion
    
    @IBAction func Autenticar(sender: AnyObject) {
        
        if myvariables.socket.status.description == "Reconnecting"
        {
            self.Usuario.text = "Sin Conexión"
        }
        else{
        cliente = CCliente(user: self.Usuario.text!, password: self.Clave.text!)
        let usuario = self.Usuario.text! + ","
        let clave = self.Clave.text! + ","
        let dato = "#LoginPassword," + usuario + clave + "#"
        myvariables.socket.emit("data", dato)
       }
        
    }
       
    func textFieldDidChange(textField: UITextField) {
        self.usuarioText.text = textField.text
    }
    
    @IBAction func Registrarse(sender: UIButton) {
        self.RegistroView.hidden = false
         self.telefonoText.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    
    @IBAction func RegistrarUsuario(sender: UIButton) {
        if (nombreApText.text!.isEmpty || telefonoText.text!.isEmpty || claveText.text!.isEmpty) {
            let alertaDos = UIAlertController (title: "Registro de Usuario", message: "Debe llenar todos los campos del formulario", preferredStyle: UIAlertControllerStyle.Alert)
            alertaDos.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default, handler: {alerAction in
                
            }))
            
            //Para hacer que la alerta se muestre usamos presentViewController, a diferencia de Objective C que como recordaremos se usa [Show Alerta]
            
            self.presentViewController(alertaDos, animated: true, completion: nil)
        }
        else{
        let temporal = "," + telefonoText.text! + "," + usuarioText.text! + "," + claveText.text!
        let temporal1 = "," + correoText.text! + "," + "# /n"
        let datos = "#Registro" + "," + nombreApText.text! + temporal + temporal1
        myvariables.socket.emit("data", datos)
        }
    }
    
    
    @IBAction func CancelRegistro(sender: AnyObject) {
       self.RegistroView.hidden = true
        
    }
    //Funciones de la logica de la aplicacion
   //FUNCION DE AUTENTICACION
    func Autenticacion(resultado: [String]){
       switch resultado[1]{
       case "loginok":
       myvariables.solicitud.DatosCliente(resultado[4], nombreapellidoscliente: resultado[5], movilcliente: self.Usuario.text!)
       self.idusuario = String(resultado[2])
       cliente.CrearSesion()
       if resultado[6] != "0"{
        self.ListSolicitudPendiente(resultado)
       }
       self.CambiarPantalla()
       case "loginerror": self.Usuario.text = "usuario incorrecto"
        default: self.Usuario.text = "Problemas de conexion"
        }
    }
     
    //FUNCIÓN CAMBIO DE PANTALLA
    func CambiarPantalla (){        
        myvariables.idusuario = self.idusuario
        let nuestroStoryBoard : UIStoryboard = UIStoryboard(name:"Main",bundle: nil)
        let nuestraPantallaInicio = nuestroStoryBoard.instantiateViewControllerWithIdentifier("PI") as! PantallaInicio
        //Para cambiar a otra Pantalla por metodo push (cargar otra vista)
        //self.navigationController!.pushViewController(nuestraPantallaInicio, animated: true)
        //Para cambiar a otra pantalla superponiendo la vista.
        self.presentViewController(nuestraPantallaInicio, animated: true, completion: nil)
   }
    
    
    //FUNCION PARA LISTAR SOLICITUDES PENDIENTES
    func ListSolicitudPendiente(listado : [String]){
        var i = 7
        while i < listado.count-10 {
           let solicitud = CSolPendiente(idSolicitud: listado[i], idTaxi: listado[i + 1], codigo: listado[i + 2], FechaHora: listado[i + 3], Latitudtaxi: listado[i + 4], Longitudtaxi: listado[i + 5], Latitudorigen: listado[i + 6], Longitudorigen: listado[i + 7], Latituddestino: listado[i + 8], Longituddestino: listado[i + 9])
           myvariables.solpendientes.append(solicitud)
            i += 10
        }
        //self.Usuario.text = String(myvariables.solpendientes[0].idSolicitud)
    }
    
    
    
    //enviar el id usuario
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldDidEndEditing(textfield: UITextField) {
        if textfield.isEqual(Clave){
            animateViewMoving(false, moveValue: 80)
        }
        else{
        if textfield.isEqual(telefonoText){
            usuarioText.text = textfield.text
            usuarioText.userInteractionEnabled = false
        }
        else{
            if textfield.isEqual(confirmarClavText){
                if textfield.text != claveText.text{
                    textfield.textColor = UIColor.redColor()
                 textfield.text = "Las claves no coinciden"
                    textfield.secureTextEntry = false
                  RegistrarBtn.enabled = false
                }
                else{
                    RegistrarBtn.enabled = true
                }
            }
        animateViewMoving(false, moveValue: 140)
        }
        }
    }
    //OCULTAR TECLACO CON TECLA ENTER
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    //Funciones para mover los elementos para que no queden detrás del teclado
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.isEqual(Clave){
            animateViewMoving(true, moveValue: 80)
        }
        else{
        if textField.isEqual(telefonoText){
       
        }
        else{
             animateViewMoving(true, moveValue: 140)
            if textField.isEqual(confirmarClavText){
                textField.secureTextEntry = true
                textField.textColor = UIColor.blackColor()
            }
        }
        }
    }
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:NSTimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
        UIView.commitAnimations()
    }
   
}


