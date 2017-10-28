//
//  SolPendController.swift
//  UnTaxi
//
//  Created by Done Santana on 28/2/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import UIKit
import GoogleMaps

class SolPendController: UIViewController, GMSMapViewDelegate, UITextViewDelegate {
    
    var SolicitudPendiente: CSolicitud!
    var OrigenSolicitud = GMSMarker()
    var DestinoSolicitud = GMSMarker()
    var TaxiSolicitud = GMSMarker()
    var evaluacion: CEvaluacion!
    var SMSVoz = CSMSVoz()
    var grabando = false
    var fechahora: String!
    var UrlSubirVoz = String()
    var urlconductor: String!
    var tarifas: [CTarifa]!

    
    //MASK:- VARIABLES INTERFAZ
    @IBOutlet weak var MapaSolPen: GMSMapView!
    @IBOutlet weak var DetallesCarreraView: UIView!
    @IBOutlet weak var DistanciaText: UILabel!
    @IBOutlet weak var DuracionText: UILabel!
    @IBOutlet weak var CostoText: UILabel!
    
    @IBOutlet weak var EvaluarBtn: UIButton!
    @IBOutlet weak var EvaluacionView: UIView!
    @IBOutlet weak var ComentarioEvalua: UIView!
    @IBOutlet weak var PrimeraStart: UIButton!
    @IBOutlet weak var SegundaStar: UIButton!
    @IBOutlet weak var TerceraStar: UIButton!
    @IBOutlet weak var CuartaStar: UIButton!
    @IBOutlet weak var QuintaStar: UIButton!
    @IBOutlet weak var ComentarioText: UITextView!
    
    @IBOutlet weak var MensajesBtn: UIButton!
    @IBOutlet weak var LlamarCondBtn: UIButton!
    @IBOutlet weak var SMSVozBtn: UIButton!
    
    
    @IBOutlet weak var DatosConductor: UIView!
    //datos del conductor a mostrar
    @IBOutlet weak var ImagenCond: UIImageView!
    @IBOutlet weak var NombreCond: UILabel!
    @IBOutlet weak var MovilCond: UILabel!
    @IBOutlet weak var MarcaAut: UILabel!
    @IBOutlet weak var ColorAut: UILabel!
    @IBOutlet weak var MatriculaAut: UILabel!

    @IBOutlet weak var AlertaEsperaView: UIView!
    @IBOutlet weak var MensajeEspera: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.MapaSolPen.delegate = self
        self.ComentarioText.delegate = self
        MapaSolPen.camera = GMSCameraPosition.camera(withLatitude: -2.137072,longitude:-79.903454,zoom: 15)
        // Do any additional setup after loading the view.
        
        
        //MASK:- EVENTOS SOCKET
        myvariables.socket.on("Taxi"){data, ack in
            //"#Taxi,"+nombreconductor+" "+apellidosconductor+","+telefono+","+codigovehiculo+","+gastocombustible+","+marcavehiculo+","+colorvehiculo+","+matriculavehiculo+","+urlfoto+","+idconductor+",# \n";
            
            let datosConductor = String(describing: data).components(separatedBy: ",")
            
            self.NombreCond.text! = "Conductor: " + datosConductor[1]
            self.MarcaAut.text! = "Marca: " + datosConductor[5]
            self.ColorAut.text! = "Color: " + datosConductor[6]
            self.MatriculaAut.text! = "Matrícula: " + datosConductor[7]
            self.MovilCond.text! = "Movil: " + datosConductor[2]
            if datosConductor[9] != "null" && datosConductor[9] != ""{
                URLSession.shared.dataTask(with: URL(string: datosConductor[9])!, completionHandler: { (data, response, error) in
                    DispatchQueue.main.async {
                        _ = UIViewContentMode.scaleAspectFill
                        self.ImagenCond.image = UIImage(data: data!)
                    }
                })
            }else{
                self.ImagenCond.image = UIImage(named: "chofer")
            }
            self.AlertaEsperaView.isHidden = true
            self.DatosConductor.isHidden = false
        }

    }

    
    
    //MASK:- FUNCIONES PROPIAS
    //ENVIAR EVALUACIÓN
    func EnviarEvaluacion(_ evaluacion: Int, comentario: String){
        ComentarioEvalua.isHidden = true
        EvaluacionView.isHidden = true
        ComentarioEvalua.isHidden = true
        let idsolicitud = self.SolicitudPendiente.idSolicitud
        let datos = "#Evaluar," + idsolicitud + "," + String(evaluacion) + "," + comentario + ",# \n"
        EnviarSocket(datos)
    }
    
    //FUNCIÓN ENVIAR AL SOCKET
    func EnviarSocket(_ datos: String){
        if CConexionInternet.isConnectedToNetwork() == true{
            if myvariables.socket.reconnects{
                myvariables.socket.emit("data",datos)
            }
            else{
                let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor intentar otra vez.", preferredStyle: UIAlertControllerStyle.alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                    exit(0)
                }))
                
                //Para hacer que la alerta se muestre usamos presentViewController, a diferencia de Objective C que como recordaremos se usa [Show Alerta]
                alertaDos.view.tintColor = UIColor.black
                let subview = alertaDos.view.subviews.last! as UIView
                let alertContentView = subview.subviews.last! as UIView
                alertContentView.backgroundColor = UIColor(red: 252.0/255.0, green: 238.0/255.0, blue: 129.0/255.0, alpha: 1.0)
                alertContentView.layer.cornerRadius = 5
                let TitleString = NSAttributedString(string: "Sin Conexión", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 19), NSForegroundColorAttributeName : UIColor.black])
                alertaDos.setValue(TitleString, forKey: "attributedTitle")
                //let MessageString = NSAttributedString(string: Message, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15), NSForegroundColorAttributeName : MessageColor])
                
                self.present(alertaDos, animated: true, completion: nil)
            }
        }else{
            self.ErrorConexion()
        }
    }

    func ErrorConexion(){
        let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor revise su conexión a Internet.", preferredStyle: UIAlertControllerStyle.alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
            exit(0)
        }))
        
        //Para hacer que la alerta se muestre usamos presentViewController, a diferencia de Objective C que como recordaremos se usa [Show Alerta]
        alertaDos.view.tintColor = UIColor.black
        let subview = alertaDos.view.subviews.last! as UIView
        let alertContentView = subview.subviews.last! as UIView
        alertContentView.backgroundColor = UIColor(red: 252.0/255.0, green: 238.0/255.0, blue: 129.0/255.0, alpha: 1.0)
        alertContentView.layer.cornerRadius = 5
        let TitleString = NSAttributedString(string: "Sin Conexión", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 19), NSForegroundColorAttributeName : UIColor.black])
        alertaDos.setValue(TitleString, forKey: "attributedTitle")
        //let MessageString = NSAttributedString(string: Message, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15), NSForegroundColorAttributeName : MessageColor])
        
        self.present(alertaDos, animated: true, completion: nil)
    }
    
    func MostrarDetalleSolicitud(){
        
        self.OrigenSolicitud = self.SolicitudPendiente.origenCarrera
        self.OrigenSolicitud.map = self.MapaSolPen

        if self.SolicitudPendiente.idTaxi != "null" && self.SolicitudPendiente.idTaxi != ""{
            self.TaxiSolicitud = self.SolicitudPendiente.taximarker
            self.TaxiSolicitud.map = self.MapaSolPen
        }
        if self.SolicitudPendiente.destinoCarrera.position.latitude != Double("0"){
            self.DestinoSolicitud = self.SolicitudPendiente.destinoCarrera
            self.SolicitudPendiente.DetallesCarrera(tarifas: tarifas)
            DistanciaText.text = String(self.SolicitudPendiente.distancia) + " KM"
            DuracionText.text = self.SolicitudPendiente.tiempo
            CostoText.text = "$" + self.SolicitudPendiente.costo
            DetallesCarreraView.isHidden = false
            self.SMSVozBtn.setImage(UIImage(named:"smsvoz"),for: UIControlState())
            self.DestinoSolicitud.map = self.MapaSolPen

        }
        self.SolicitudPendiente.DibujarRutaSolicitud(mapa: MapaSolPen)
        
    }

    
    //MASK:- ACCIONES DE BOTONES
    //BOTONES PARA EVALUCIÓN DE CARRERA
    @IBAction func EvaluarMapaBtn(_ sender: AnyObject) {
        self.evaluacion = CEvaluacion(botones: [PrimeraStart, SegundaStar,TerceraStar,CuartaStar,QuintaStar])
        EvaluacionView.isHidden = false
    }
    
    @IBAction func Star1(_ sender: AnyObject) {
        self.evaluacion.EvaluarCarrera(1)
    }
    @IBAction func Star2(_ sender: AnyObject) {
        self.evaluacion.EvaluarCarrera(2)
    }
    @IBAction func Star3(_ sender: AnyObject) {
        self.evaluacion.EvaluarCarrera(3)
        //EnviarEvaluacion(self.evaluacion.PtoEvaluacion,comentario: "")
    }
    @IBAction func Star4(_ sender: AnyObject) {
        self.evaluacion.EvaluarCarrera(4)
        //EnviarEvaluacion(self.evaluacion.PtoEvaluacion,comentario: "")
    }
    @IBAction func Star5(_ sender: AnyObject) {
        self.evaluacion.EvaluarCarrera(5)
        //EnviarEvaluacion(self.evaluacion.PtoEvaluacion,comentario: "")
    }
    //Enviar comentario
    @IBAction func AceptarEvalucion(_ sender: AnyObject) {
        EnviarEvaluacion(self.evaluacion.PtoEvaluacion,comentario: self.ComentarioText.text)
        self.ComentarioText.endEditing(true)
    }
    
    //MENSAJES DE VOZ
    @IBAction func VozMensaje(_ sender: AnyObject) {
        if sender.state == .began{
            let dateFormato = DateFormatter()
            dateFormato.dateFormat = "yyMMddhhmmss"
            self.fechahora = dateFormato.string(from: Date())
            let name = self.SolicitudPendiente.idSolicitud + "-" + self.SolicitudPendiente.idTaxi + "-" + fechahora + ".m4a"
            SMSVoz.TerminarMensaje(name)
            self.SMSVozBtn.setImage(UIImage(named:"smsvoz2"), for: UIControlState())
            SMSVoz.ReproducirMusica()
            SMSVoz.SubirAudio(self.UrlSubirVoz, name: name, boton: self.SMSVozBtn)
            grabando = false
        }        
    }
    
    @IBAction func RecordBegin(_ sender: AnyObject) {
        if sender.state == .began{
            SMSVoz.GrabarMensaje()
            SMSVoz.ReproducirMusica()
            grabando = true
        }
    }
    
    //LLAMAR CONDUCTOR
    @IBAction func LLamarConductor(_ sender: AnyObject) {
        if let url = URL(string: "tel://\(self.SolicitudPendiente.movil)") {
            UIApplication.shared.openURL(url)
        }
    }
    @IBAction func ReproducirMensajesCond(_ sender: AnyObject) {
        SMSVoz.ReproducirVozConductor(self.urlconductor)
    }
    
    //MARK:- BOTNES ACTION
    @IBAction func DatosConductor(_ sender: AnyObject) {
        //let datos = "#Taxi," + myvariables.cliente.idUsuario + "," + SolicitudPendiente.idTaxi + ",# \n"
        //self.EnviarSocket(datos)
        MensajeEspera.text = "Procesando..."
        AlertaEsperaView.isHidden = false
        self.DatosConductor.isHidden = false
    }
    
    @IBAction func AceptarCond(_ sender: UIButton) {
        self.DatosConductor.isHidden = true        
    }



    //MARK:- TEXT DELEGATE ACTION
    func textViewDidBeginEditing(_ textView: UITextView) {
     if textView.isEqual(ComentarioText){
        textView.text.removeAll()
        animateViewMoving(true, moveValue: 110, view: self.ComentarioEvalua)
     }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
     if textView.isEqual(ComentarioText){
        animateViewMoving(false, moveValue: 110,view: self.ComentarioEvalua)
     }
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
    

}
