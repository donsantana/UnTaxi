//
//  CSMSVoz.swift
//  Xtaxi
//
//  Created by usuario on 5/5/16.
//  Copyright © 2016 Done Santana. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
class CSMSVoz {
    
    var myPlayer = AVPlayer()
    var myMusica = AVAudioPlayer()
    var myAudioPlayer = AVAudioPlayer()
    var recordingSession = AVAudioSession()
    var audioRecorder: AVAudioRecorder!
    
    init(){
        let myFilePathString = NSBundle.mainBundle().pathForResource("SOLO_TE_AMO_A_TI", ofType: "mp3")
        
        if let myFilePathString = myFilePathString
        {
            let myFilePathURL = NSURL(fileURLWithPath: myFilePathString)
            
            do{
                try myMusica = AVAudioPlayer(contentsOfURL: myFilePathURL)
                myMusica.prepareToPlay()
                myMusica.volume = 1
                
            }catch
            {
                print("error")
            }
        }
        self.record()
    }
 
    // get the path of our file
    
    func directoryURL() -> NSURL? {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectory = urls[0] as NSURL
        let soundURL = documentDirectory.URLByAppendingPathComponent("sound.m4a")
        return soundURL
    }

    //para reproducir audio de internet
    func PlayForInternet(url: String){
        let url = "https://youtu.be/NKjOevP3--U"
        let playerItem = AVPlayerItem(URL: NSURL(string: url)!)
        myPlayer = AVPlayer(playerItem:playerItem)
        myPlayer.rate = 1.0
        myPlayer.play()
    }

    //Funcion para grabar
    func record() {
        //ask for permission
        if (recordingSession.respondsToSelector("requestRecordPermission:")) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                //set category and activate recorder session
                    try! self.recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                    try! self.recordingSession.setActive(true)
                
                    
                    let recordSettings = [AVSampleRateKey : NSNumber(float: Float(44100.0)),
                        AVFormatIDKey : NSNumber(int: Int32(kAudioFormatMPEG4AAC)),
                        AVNumberOfChannelsKey : NSNumber(int: 1),
                        AVEncoderAudioQualityKey : NSNumber(int: Int32(AVAudioQuality.Medium.rawValue))]
                
                    let audioSession = AVAudioSession.sharedInstance()
                    do {
                        try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: .DefaultToSpeaker)
                        try self.audioRecorder = AVAudioRecorder(URL: self.directoryURL()!,
                        settings: recordSettings)
                        self.audioRecorder.prepareToRecord()
                    } catch {
                    
                    }
                
                } else{
                    print("not granted")
                }
            })
        }
    }
    
    func GrabarMensaje(){
        if !audioRecorder.recording {
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setActive(true)
                audioRecorder.record()
            } catch {
            }
        }
    }
    
    func TerminarMensaje(){
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setActive(false)
        } catch {
        }
    }
    
    func ReproducirMensaje(){
        if (!audioRecorder.recording){
            do {
                try myAudioPlayer = AVAudioPlayer(contentsOfURL: audioRecorder.url)
                myAudioPlayer.volume = 1
                myAudioPlayer.play()
            } catch {
            }
        }
    }
    func ReproducirMusica(){
        myMusica.play()
    }
}