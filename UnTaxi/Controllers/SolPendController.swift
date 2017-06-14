//
//  SolPendController.swift
//  UnTaxi
//
//  Created by Done Santana on 28/2/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import UIKit
import GoogleMaps
import SocketIO

class SolPendController: UIViewController, GMSMapViewDelegate, UITextViewDelegate,URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    
    var SolicitudPendiente: CSolicitud!
    var posicionSolicitud: Int!
    //var OrigenSolicitud = GMSMarker()
    //var DestinoSolicitud = GMSMarker()
    var TaxiSolicitud = GMSMarker()
    
    //var SMSVoz = CSMSVoz()
    var grabando = false
    var fechahora: String!
    var UrlSubirVoz = myvariables.UrlSubirVoz
    //var urlconductor: String!

    
    //MASK:- VARIABLES INTERFAZ
    @IBOutlet weak var MapaSolPen: GMSMapView!
    @IBOutlet weak var DetallesCarreraView: UIView!
    @IBOutlet weak var DistanciaText: UILabel!
    @IBOutlet weak var DuracionText: UILabel!
    
    @IBOutlet weak var EvaluarBtn: UIButton!
    @IBOutlet weak var EvaluacionView: UIView!
    @IBOutlet weak var ComentarioEvalua: UIView!
    
    
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
        self.navigationController?.navigationBar.tintColor = UIColor.black

        self.MapaSolPen.delegate = self
        //self.ComentarioText.delegate = self
        MapaSolPen.camera = GMSCameraPosition.camera(withLatitude: self.SolicitudPendiente.origenCarrera.position.latitude,longitude: self.SolicitudPendiente.origenCarrera.position.longitude,zoom: 15)
        
        
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.normalTap))
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(SolPendController.longTap(_:)))
        longGesture.minimumPressDuration = 0.2
        //tapGesture.numberOfTapsRequired = 1
        //self.SMSVozBtn.addGestureRecognizer(tapGesture)
        self.SMSVozBtn.addGestureRecognizer(longGesture)
        
        let JSONStyle = "[" +
            "  {" +
            "    \"featureType\": \"all\"," +
            "    \"elementType\": \"geometry.fill\"," +
            "    \"stylers\": [" +
            "      {" +
            "        \"weight\": \"2.00\"" +
            "      }" +
            "    ]" +
            "  }," +
            "       {" +
            "           \"featureType\": \"all\"," +
            "           \"elementType\": \"geometry.stroke\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#9c9c9c\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"landscape\"," +
            "           \"elementType\": \"all\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#f2f2f2\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"landscape\"," +
            "           \"elementType\": \"all\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#f2f2f2\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"landscape\"," +
            "           \"elementType\": \"geometry.fill\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#ffffff\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"landscape.man_made\"," +
            "           \"elementType\": \"geometry.fill\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#ffffff\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"poi\"," +
            "           \"elementType\": \"all\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"visibility\": \"off\"" +
            "           }" +
            "           ]" +
            "      }," +
            "       {" +
            "           \"featureType\": \"road\"," +
            "           \"elementType\": \"all\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"saturation\": -100" +
            "           }," +
            "           {" +
            "           \"lightness\": 45" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"road\"," +
            "           \"elementType\": \"geometry.fill\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#e1e2e2\"" +
            "          }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"road\"," +
            "           \"elementType\": \"labels.text.fill\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#232323\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"road\"," +
            "           \"elementType\": \"labels.text.stroke\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#ffffff\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"road.highway\"," +
            "           \"elementType\": \"all\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"visibility\": \"simplified\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "          \"featureType\": \"road.arterial\"," +
            "           \"elementType\": \"labels.icon\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"visibility\": \"off\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"transit\"," +
            "           \"elementType\": \"all\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"visibility\": \"on\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"water\"," +
            "           \"elementType\": \"all\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"9aadb5\"" +
            "           }," +
            "           {" +
            "           \"visibility\": \"on\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"water\"," +
            "           \"elementType\": \"geometry.fill\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#def5fe\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"water\"," +
            "           \"elementType\": \"labels.text.fill\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#070707\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"water\"," +
            "           \"elementType\": \"labels.text.stroke\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#ffffff\"" +
            "           }" +
            "           ]" +
            "       }," +
            
            "  {" +
            "    \"featureType\": \"transit\"," +
            "    \"elementType\": \"labels.icon\"," +
            "    \"stylers\": [" +
            "      {" +
            "        \"visibility\": \"on\"" +
            "      }" +
            "    ]" +
            "  }" +
        "]"
        
        
        do{
            self.MapaSolPen.mapStyle = try GMSMapStyle(jsonString: JSONStyle)
        }catch{
            print("NO PUEDEEEEEEEEEEEEEEEEEEEEEE")
        }


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
        
        myvariables.socket.on("V"){data, ack in
            self.MensajesBtn.isHidden = false
            self.MensajesBtn.setImage(UIImage(named: "mensajesnew"),for: UIControlState())
        }
        
        //GEOPOSICION DE TAXIS
        myvariables.socket.on("Geo"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            if myvariables.solpendientes.count != 0 {
                    if (temporal[2] == self.SolicitudPendiente.idTaxi){
                        self.SolicitudPendiente.taximarker.position = CLLocationCoordinate2DMake(Double(temporal[3])!, Double(temporal[4])!)
                        self.SolicitudPendiente.taximarker.map = nil
                        //self.SolicitudPendiente.taximarker.map = self.MapaSolPen
                        self.MostrarDetalleSolicitud()
                    }
            }
        }
        
        if myvariables.urlconductor != ""{
            self.MensajesBtn.isHidden = false
            self.MensajesBtn.setImage(UIImage(named: "mensajesnew"),for: UIControlState())
        }
        
        self.MostrarDetalleSolicitud()
    }

    
    
    //MASK:- FUNCIONES PROPIAS
    func longTap(_ sender : UILongPressGestureRecognizer){        
      if sender.state == .ended {
        if !myvariables.SMSVoz.reproduciendo && myvariables.grabando{

                let dateFormato = DateFormatter()
                dateFormato.dateFormat = "yyMMddhhmmss"
                self.fechahora = dateFormato.string(from: Date())
                let name = self.SolicitudPendiente.idSolicitud + "-" + self.SolicitudPendiente.idTaxi + "-" + fechahora + ".m4a"
                myvariables.SMSVoz.TerminarMensaje(name)
                print("ando por aqui")
                myvariables.SMSVoz.SubirAudio(myvariables.UrlSubirVoz, name: name)
                myvariables.grabando = false
                myvariables.SMSVoz.ReproducirMusica()

        }
    }else if sender.state == .began {
        if !myvariables.SMSVoz.reproduciendo{
            myvariables.SMSVoz.ReproducirMusica()
                myvariables.SMSVoz.GrabarMensaje()
                myvariables.grabando = true
            }
        }
    }
    
    
    //FUNCIÓN ENVIAR AL SOCKET
    func EnviarSocket(_ datos: String){
        if CConexionInternet.isConnectedToNetwork() == true{
            if myvariables.socket.reconnects{
                myvariables.socket.emit("data",datos)
            }else{
                let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor intentar otra vez.", preferredStyle: UIAlertControllerStyle.alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                    exit(0)
                }))
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
        
        self.present(alertaDos, animated: true, completion: nil)
    }
    
    func MostrarDetalleSolicitud(){
        
        self.SolicitudPendiente.origenCarrera.map = self.MapaSolPen

        if self.SolicitudPendiente.idTaxi != "null" && self.SolicitudPendiente.idTaxi != ""{
            self.SolicitudPendiente.taximarker.map = self.MapaSolPen
            let temporal = self.SolicitudPendiente.TiempoTaxi()
            DistanciaText.text = temporal[0] + " KM"
            DuracionText.text = temporal[1]
            DetallesCarreraView.isHidden = false
            self.SMSVozBtn.setImage(UIImage(named:"smsvoz"),for: UIControlState())
            self.SolicitudPendiente.DibujarRutaSolicitud(mapa: MapaSolPen)
            self.fitAllMarkers(markers: [self.SolicitudPendiente.origenCarrera, self.SolicitudPendiente.taximarker])
        }
    }
    
    //MOSTRAR TODOS LOS MARCADORES EN PANTALLA
    func fitAllMarkers(markers:[GMSMarker]){
        var bounds = GMSCoordinateBounds()
        for marcador in markers{
            bounds = bounds.includingCoordinate(marcador.position)
        }
        MapaSolPen.animate(with: .fit(bounds, withPadding: 100))
    }
    
    //CANCELAR SOLICITUDES
    func MostrarMotivoCancelacion(){
        let motivoAlerta = UIAlertController(title: "", message: "Seleccione el motivo de cancelación.", preferredStyle: UIAlertControllerStyle.actionSheet)
        motivoAlerta.addAction(UIAlertAction(title: "No necesito", style: .default, handler: { action in
            //["No necesito","Demora el servicio","Tarifa incorrecta","Solo probaba el servicio", "Cancelar"]
                self.CancelarSolicitud("No necesito")
        }))
        motivoAlerta.addAction(UIAlertAction(title: "Demora el servicio", style: .default, handler: { action in
            //["No necesito","Demora el servicio","Tarifa incorrecta","Solo probaba el servicio", "Cancelar"]
           self.CancelarSolicitud("Demora el servicio")
        }))
        motivoAlerta.addAction(UIAlertAction(title: "Tarifa incorrecta", style: .default, handler: { action in
            //["No necesito","Demora el servicio","Tarifa incorrecta","Solo probaba el servicio", "Cancelar"]
            self.CancelarSolicitud("Tarifa incorrecta")
        }))
        motivoAlerta.addAction(UIAlertAction(title: "Vehículo en mal estado", style: .default, handler: { action in
            //["No necesito","Demora el servicio","Tarifa incorrecta","Solo probaba el servicio", "Cancelar"]
            self.CancelarSolicitud("Vehículo en mal estado")
        }))
        motivoAlerta.addAction(UIAlertAction(title: "Solo probaba el servicio", style: .default, handler: { action in
            //["No necesito","Demora el servicio","Tarifa incorrecta","Solo probaba el servicio", "Cancelar"]
            self.CancelarSolicitud("Solo probaba el servicio")
        }))
        motivoAlerta.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.destructive, handler: { action in
        }))
        
        self.present(motivoAlerta, animated: true, completion: nil)
    }
    
    func CancelarSolicitud(_ motivo: String){
        //#Cancelarsolicitud, idSolicitud, idTaxi, motivo, "# \n"
        let Datos = "#Cancelarsolicitud" + "," + self.SolicitudPendiente.idSolicitud + "," + self.SolicitudPendiente.idTaxi + "," + motivo + "," + "# \n"
        EnviarSocket(Datos)
        myvariables.solpendientes.remove(at: self.posicionSolicitud)
        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "Inicio") as! InicioController
        self.navigationController?.show(vc, sender: nil)        
    }


    
    //MASK:- ACCIONES DE BOTONES
    
    //LLAMAR CONDUCTOR
    @IBAction func LLamarConductor(_ sender: AnyObject) {
        if let url = URL(string: "tel://\(self.SolicitudPendiente.movil)") {
            UIApplication.shared.openURL(url)
        }
    }
    @IBAction func ReproducirMensajesCond(_ sender: AnyObject) {
        if myvariables.urlconductor != ""{
            myvariables.SMSVoz.ReproducirVozConductor(myvariables.urlconductor)
        }
    }
    
    //MARK:- BOTNES ACTION
    @IBAction func DatosConductor(_ sender: AnyObject) {
        if self.SolicitudPendiente.marcaVehiculo != ""{
            self.NombreCond.text! = "Conductor: " + self.SolicitudPendiente.nombreApellido
            self.MarcaAut.text! = "Marca: " + self.SolicitudPendiente.marcaVehiculo
            self.ColorAut.text! = "Color: " + self.SolicitudPendiente.colorVehiculo
            self.MatriculaAut.text! = "Matrícula: " + self.SolicitudPendiente.matricula
            self.MovilCond.text! = "Movil: " + self.SolicitudPendiente.movil
            if self.SolicitudPendiente.urlFoto != "null" && self.SolicitudPendiente.urlFoto != ""{
                URLSession.shared.dataTask(with: URL(string: self.SolicitudPendiente.urlFoto)!, completionHandler: { (data, response, error) in
                    DispatchQueue.main.async {
                        _ = UIViewContentMode.scaleAspectFill
                        self.ImagenCond.image = UIImage(data: data!)
                    }
                })
            }else{
                self.ImagenCond.image = UIImage(named: "chofer")
            }
            self.DatosConductor.isHidden = false
        }else{
            let datos = "#Taxi," + myvariables.cliente.idUsuario + "," + self.SolicitudPendiente.idTaxi + ",# \n"
            self.EnviarSocket(datos)
            MensajeEspera.text = "Procesando..."
            AlertaEsperaView.isHidden = false
        }
    }
    
    @IBAction func AceptarCond(_ sender: UIButton) {
        self.DatosConductor.isHidden = true        
    }
    
    @IBAction func NuevaSolicitud(_ sender: Any) {
        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "Inicio") as! InicioController
        self.navigationController?.show(vc, sender: nil)
    }
    

    @IBAction func CancelarProcesoSolicitud(_ sender: AnyObject) {
        MostrarMotivoCancelacion()
    }


    

}
