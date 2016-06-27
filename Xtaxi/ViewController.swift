//
//  ViewController.swift
//  Xtaxi
//
//  Created by Done Santana on 14/10/15.
//  Copyright © 2015 Done Santana. All rights reserved.
//

import UIKit
import Socket_IO_Client_Swift
import Pods




class ViewController: UIViewController, UITextFieldDelegate {
    
    //var cliente : CCliente!
    var alerta : CAlerta!
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
    
    @IBOutlet weak var AlertaView: UIView!
    @IBOutlet weak var Titulo: UILabel!
    @IBOutlet weak var Mensaje: UITextView!
    @IBOutlet weak var AcpetarAlerta: UIButton!
    @IBOutlet weak var CancelarAlerta: UIButton!
    @IBOutlet weak var AceptarSoloAlerta: UIButton!
    @IBOutlet weak var activityview: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.ControlEventos()
        alerta = CAlerta(titulo: Titulo, mensaje: Mensaje, vistaalerta: AlertaView, aceptarbtn: AcpetarAlerta, aceptarsolobtn: AceptarSoloAlerta, cancelarbtn: CancelarAlerta, tipo: 1, esperandoactivity: activityview)
       
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
      myvariables.socket.on("Registro") {data, ack in
           let temporal = String(data).componentsSeparatedByString(",")
        
           if temporal[1] == "registrook"{
               self.alerta.CambiarTitulo("Registro de Usuario")
            self.alerta.CambiarMensaje("Registro Realizado con éxito, puede loguearse en la aplicación, ¿Desea ingresar a la Aplicación?")
            self.alerta.DefinirTipo(1)
            self.AlertaView.hidden = false
            self.RegistroView.hidden = true
            }
            else{
            self.alerta.CambiarTitulo("Registro de Usuario")
            self.alerta.CambiarMensaje("Error al registrar el usuario: " + temporal[2])
            self.alerta.DefinirTipo(10)
            self.AlertaView.hidden = false
            self.RegistroView.hidden = true
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
            let writeString = "#LoginPassword," + self.Usuario.text! + "," + self.Clave.text! + ",# /n"
            //CREAR EL FICHERO DE LOGÍN
            let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
            
            do {
                _ = try writeString.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding)
            } catch {
                
            }
            CambiarPantalla()
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
            var temporal1 = ",Sin correo" + ",# /n"
            if correoText.text != ""{
         temporal1 = "," + correoText.text! + "," + "# /n"
            }
        let datos = "#Registro" + "," + nombreApText.text! + temporal + temporal1
        myvariables.socket.emit("data", datos)
        }
    }
    
    
    @IBAction func CancelRegistro(sender: AnyObject) {
       self.RegistroView.hidden = true
        
    }
    
    //FUNCIÓN CAMBIO DE PANTALLA
    func CambiarPantalla (){
        let nuestroStoryBoard : UIStoryboard = UIStoryboard(name:"Main",bundle: nil)
        let nuestraPantallaInicio = nuestroStoryBoard.instantiateViewControllerWithIdentifier("PI") as! PantallaInicio
        //Para cambiar a otra Pantalla por metodo push (cargar otra vista)
        //self.navigationController!.pushViewController(nuestraPantallaInicio, animated: true)
        //Para cambiar a otra pantalla superponiendo la vista.
        self.presentViewController(nuestraPantallaInicio, animated: true, completion: nil)
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
    
    @IBAction func AceptarAlerta(sender: AnyObject) {
        RegistroView.hidden = true
        let writeString = "#LoginPassword," + self.usuarioText.text! + "," + self.claveText.text! + ",# /n"
        //CREAR EL FICHERO DE LOGÍN
        let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
        
        do {
            _ = try writeString.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding)
        } catch {
            
        }
        CambiarPantalla()
    }
    @IBAction func CancelarAlerta(sender: AnyObject) {
        AlertaView.hidden = true
        RegistroView.hidden = true
    }
    @IBAction func AceptarSolo(sender: AnyObject) {
        AlertaView.hidden = true
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


