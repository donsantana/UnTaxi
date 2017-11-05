//
//  CSocket.swift
//  Xtaxi
//
//  Created by Done Santana on 15/10/15.
//  Copyright © 2015 Done Santana. All rights reserved.
//

import Foundation
import SocketIO

//Clase CSocket

/*class CSocket: XMLParserDelegate {
    
    var ServersData = [String]()
    var ServerParser = XMLParser()
    var recordKey = ""
    let dictionaryKeys = ["cliente","ip","p"]
    
    var results = [[String: String]]()                // the whole array of dictionaries
    var currentDictionary = [String : String]()    // the current dictionary
    var currentValue: String = ""                   // the current value for one of the keys in the dictionary
    
    
    init() {
        var servers = "Vacio"
        let filePath = NSHomeDirectory() + "/Library/Caches/servers.txt"
        do {
            servers = try NSString(contentsOfFile: filePath, encoding: String.Encoding.utf8.rawValue) as String
            
        }catch {
        }
        if servers != "Vacio"{
            self.ServersData = String(describing: servers).components(separatedBy: ",")
            print("CONSTRUCCION")
        }else{
            self.ServerSelect()
        }
    }

    func conectar(){
        var i = 0
        while i < self.ServersData.count && !myvariables.socket.reconnects {
            myvariables.socket = SocketIOClient(socketURL: URL(string: self.ServersData[i])!, config: [.log(false), .forcePolling(true)])
            myvariables.socket.connect()
            i += 1
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        //print("Person str is:: " + self.serverStr)
        //TODO: You have to build your json object from the PersonStr now
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue += string
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "untaxi" {
            print("Encontre la etiqueta")
            self.recordKey = "untaxi"
            self.currentDictionary = [String : String]()
        } else if dictionaryKeys.contains(elementName) {
            self.currentValue = String()
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if  elementName == "cliente"{
            if self.recordKey == "untaxi"{
                print("Voy a salvar la primera")
                self.results.append(self.currentDictionary)
                self.currentDictionary = [String:String]()
                self.recordKey = ""
            }
        } else if dictionaryKeys.contains(elementName) {
            print("Encontre los primeros valores")
            self.currentDictionary[elementName] = currentValue
            self.currentValue = ""
        }
    }
    // Just in case, if there's an error, report it. (We don't want to fly blind here.)
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.currentValue = ""
        self.currentDictionary = [String:String]()
        self.results = [[String:String]]()
    }
    
    func ServerSelect(){
        let url = NSURL(string: "http://www.xoait.com/dirtablesios.xml")
        let ServerXml = XMLParser(contentsOf: url! as URL)
        ServerXml?.delegate = self
        let result = ServerXml?.parse()
        print(results)
        var writeString = "http://www.xoait.com:5803"
        if result!{
            for server in results {
                writeString = server["ip"]!+":"+server["p"]!+","
            }
            let writeString = self.ServersData
            //CREAR EL FICHERO DE LOGÍN
        }
        let filePath = NSHomeDirectory() + "/Library/Caches/servers.txt"
        
        do {
            _ = try writeString.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
            
        } catch {
            
        }
    }
    
}

extension CSocket: XMLParserDelegate {
    func parserDidEndDocument(_ parser: XMLParser) {
        //print("Person str is:: " + self.serverStr)
        //TODO: You have to build your json object from the PersonStr now
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue += string
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "untaxi" {
            self.recordKey = "untaxi"
            self.currentDictionary = [String : String]()
        } else if dictionaryKeys.contains(elementName) {
            self.currentValue = String()
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "cliente"{
            if self.recordKey == "untaxi"{
                print("Entre aquiiiiii")
                self.results.append(self.currentDictionary)
                self.currentDictionary = [String:String]()
                self.recordKey = ""
            }
        } else if dictionaryKeys.contains(elementName) {
            self.currentDictionary[elementName] = currentValue
            self.currentValue = ""
        }
    }
    // Just in case, if there's an error, report it. (We don't want to fly blind here.)
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.currentValue = ""
        self.currentDictionary = [String:String]()
        self.results = [[String:String]]()
    }
    
    func ServerSelect(){
        print("entrando aqui")
        let url = NSURL(string: "http://www.xoait.com/dirtables.xml")
        let ServerXml = XMLParser(contentsOf: url! as URL)
        //print(ServerXml)
        ServerXml?.delegate = self
        let result = ServerXml?.parse()
        
        var writeString = "http://www.xoait.com:5803"
        if result!{
            for server in results {
                writeString = server["ip"]!+":"+server["p"]!+","
            }
            let writeString = self.ServersData
            //CREAR EL FICHERO DE LOGÍN
        }
        let filePath = NSHomeDirectory() + "/Library/Caches/servers.txt"
        
        do {
            _ = try writeString.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
            
        } catch {
            
        }
    }
    func ServerConect(){
        var i = 0
        while i < self.ServersData.count && !myvariables.socket.reconnects {
            myvariables.socket = SocketIOClient(socketURL: URL(string: self.ServersData[i])!, config: [.log(false), .forcePolling(true)])
            myvariables.socket.connect()
            i += 1
        }
    }
}*/
