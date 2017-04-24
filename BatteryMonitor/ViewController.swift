//
//  ViewController.swift
//  BatteryMonitor
//
//  Created by Carlos Alberto Rodrigues Pereira Neto on 4/15/17.
//  Copyright © 2017 Carlos Pereira. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

class ViewController: UIViewController {

    @IBOutlet weak var batteryStatus: UILabel!
    
    var batteryLevel: Float {
        return UIDevice.current.batteryLevel
    }
    
    @IBOutlet weak var tempoAteCarga: UILabel!
    
    var minutoAnterior: Int = 0
    var bateriaAjustado: String = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.batteryLevelChanged),
            name: .UIDeviceBatteryLevelDidChange,
            object: nil)
        atualizaStatusDaBateria()
        
    }

    func batteryLevelChanged(notification: NSNotification)
    {
        atualizaStatusDaBateria()
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        let diferencaDeMinutos = minutes - minutoAnterior
        print(diferencaDeMinutos)
        minutoAnterior = minutes
        print("hours = \(hour):\(minutes):\(seconds)")
        
        let tempoAteCargaTotal = String((((1.00 - batteryLevel) * 100.0) * Float(diferencaDeMinutos)))
        
        tempoAteCarga.text =  String(tempoAteCargaTotal.replacingOccurrences(of: ".0", with: "")) + " Minutos"
        
        if bateriaAjustado == "100%"
        {
            AudioServicesPlayAlertSound(SystemSoundID(1005))
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }

    func atualizaStatusDaBateria()
    {
        let bateria = ((String(batteryLevel*100)))
        bateriaAjustado = bateria.replacingOccurrences(of: ".0", with: "") + "%"
        batteryStatus.text = bateriaAjustado
        print(bateriaAjustado)
    }
}

