//
//  SoundViewController.swift
//  SoundBoard
//
//  Created by Jose Falconi on 5/20/22.
//  Copyright © 2022 empresa. All rights reserved.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {

    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    @IBOutlet weak var tiempoTranscurrido: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    
    var timer:Timer = Timer()
    
    var grabarAudio:AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioURL:URL?
    var grabando:Bool = false

    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording {
            grabando = false
            grabarAudio?.stop()
            timer.invalidate()
            grabarButton.setTitle("GRABAR", for: .normal)
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
        }
        else {
            grabando = true
            grabarAudio?.record()
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(duracion), userInfo: nil, repeats: true)
            grabarButton.setTitle("DETENER", for: .normal)
            reproducirButton.isEnabled = false
//            let tmp = Double(grabarAudio!.currentTime)*60
//            print("timepo -> \(String(tmp))")
//            tiempoTranscurrido?.text = String(tmp)
        }
    }
    
    @objc func duracion() -> Void {
        let timeDuration = Int(grabarAudio!.currentTime)
        let horas = timeDuration / 3600
        let minutos = (timeDuration % 3600)/60
        let segundos = (timeDuration % 3600) % 60
        var tiempo = ""
        tiempo += String(format: "%02d", horas)
        tiempo += ":"
        tiempo += String(format: "%02d", minutos)
        tiempo += ":"
        tiempo += String(format: "%02d", segundos)
        tiempoTranscurrido.text = tiempo
    }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do {
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio!.play()
        }
        catch {
        }
    }
    
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
        grabacion.duracion = tiempoTranscurrido.text
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController?.popViewController(animated: true)
    }
    
    func configurarGrabacion(){
        do {
            //creando sesion de audio
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default,options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            //creando direccion para el archivo de audio
            let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            //impresion de ruta donde guardan los archivos
            print("*****************")
            print(audioURL!)
            print("*****************")
            
            //crear opciones para el grabador de audio
            var settings:[String:AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            //crear el objeto de grabacion de audio
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio!.prepareToRecord()
        }
        catch let error as NSError {
            print(error)
        }
    }
    
    @IBAction func controlVolumen(_ sender: Any) {
        reproducirAudio?.stop()
        reproducirAudio?.volume = slider.value
        reproducirAudio?.prepareToPlay()
        reproducirAudio?.play()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
        tiempoTranscurrido.text = "0.0"
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
