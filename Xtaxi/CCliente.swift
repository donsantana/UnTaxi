//
//  CCliente.swift
//  Xtaxi
//
//  Created by Done Santana on 14/10/15.
//  Copyright © 2015 Done Santana. All rights reserved.
//

import Foundation

class CCliente{
    var user : String
    var password : String
    let file = "login.txt"
    
    //Constructor
    init(){
        self.user = ""
        self.password = ""
    }
    init(user:String, password:String){
        self.user = user
        self.password = password
    }
    func CrearSesion(){
         //this is the file. we will write to and read from it
        let login = self.user + "," + self.password
        let path = NSHomeDirectory() + "/Library/Caches/login.txt"
        do {
             _ = try login.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
        } catch _ as NSError {
            
        }
    }
    
    func IniciarSesion()->String{
        var login : String!
        let path = NSHomeDirectory() + "/Library/Caches/login.txt"
        do {
            login = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
        } catch _ as NSError {
            
        }
        return login
    }
    
    func CerrarSesion(){
        let login = ""
        let path = NSHomeDirectory() + "/Library/Caches/login.txt"
        do {
            _ = try login.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
        } catch _ as NSError {
            
        }
    }
    func SesionIniciada()->Bool{
        var login : String!
        let path = NSHomeDirectory() + "/Library/Caches/login.txt"
        do {
            login = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
        } catch _ as NSError {
            
        }
        return login == ""
    }

}