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
import Foundation

class ViewController: UIViewController {
    
    @IBOutlet weak var tempoMedio: UILabel!
    
    @IBOutlet weak var UltimoPorcento: UILabel!
    
    var timer = Timer()
    
    var timer2 = Timer()

    var ehAprimeiraVez = true
    
    var date = Date()

    var elapsed = 0.0
    
    var arrayDiferencaTotal = [Double]()

    @IBOutlet weak var batteryStatus: UILabel!
    
    var batteryLevel: Float
    {
        return UIDevice.current.batteryLevel
    }
    
    @IBOutlet weak var tempoAteCarga: UILabel!
    
    var minutoAnterior: Int = 0
    var segundosAnterior: Int = 0
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
        self.tempoAteCarga.text = "Calculando"
        self.tempoAteCarga.alpha = 1
        atualizaStatusDaBateria()
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.fadeInFadeOut), userInfo: nil, repeats: true)

    }

    func batteryLevelChanged(notification: NSNotification)
    {
        if ehAprimeiraVez {
        date = Date()
        atualizaStatusDaBateria()
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        segundosAnterior = seconds
        minutoAnterior = minutes
        ehAprimeiraVez = false
        } else {
        atualizaStatusDaBateria()
        date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        let diferencaDeMinutos = minutes - minutoAnterior
        let diferencaSegundos = (diferencaDeMinutos * 60)
        let diferencaTotal = (diferencaSegundos - (segundosAnterior - seconds))
        print("Diferenca \(diferencaTotal)")
        segundosAnterior = seconds
        minutoAnterior = minutes
        print("hours = \(hour):\(minutes):\(seconds)")
        let segundosTotal = Int((((1.00 - batteryLevel) * 100.0) * Float(elapsed)))
        arrayDiferencaTotal.append(Double(diferencaTotal))
        let tempoMedio = average(nums: arrayDiferencaTotal)
        printSecondsToHoursMinutesSeconds3(seconds: Int(tempoMedio))
        printSecondsToHoursMinutesSeconds2(seconds: diferencaTotal)
        let tempoAteCargaTotal = Int((((1.00 - batteryLevel) * 100.0) * Float(tempoMedio)))
        printSecondsToHoursMinutesSeconds(seconds: tempoAteCargaTotal)
        print("Segundos total \(segundosTotal)")
        self.tempoAteCarga.fadeIn(completion: {(finished: Bool) -> Void in})
        self.UltimoPorcento.fadeIn(completion: {(finished: Bool) -> Void in})
        self.tempoMedio.fadeIn(completion: {(finished: Bool) -> Void in})
        timer.invalidate()
        if bateriaAjustado == "100%"
        {
            let alert = UIAlertController(title: "100%", message: "Bateria Cerregada!", preferredStyle: UIAlertControllerStyle.alert)
            self.present(alert, animated: true, completion: nil)
            self.timer2 = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.alarme), userInfo: nil, repeats: true)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in self.timer2.invalidate()}))
        }
        }
    }

    func atualizaStatusDaBateria()
    {
        let bateria = ((String(batteryLevel*100)))
        bateriaAjustado = bateria.replacingOccurrences(of: ".0", with: "") + "%"
        batteryStatus.text = bateriaAjustado
    }
    
    func fadeInFadeOut()
    {
        if self.tempoAteCarga.alpha == 0
        {
            self.tempoAteCarga.fadeIn(completion: {
                (finished: Bool) -> Void in
            })
        } else {
            self.tempoAteCarga.fadeOut()
        }
        if self.UltimoPorcento.alpha == 0
        {
            self.UltimoPorcento.fadeIn(completion: {
                (finished: Bool) -> Void in
            })
        } else {
            self.UltimoPorcento.fadeOut()
        }
        if self.tempoMedio.alpha == 0
        {
            self.tempoMedio.fadeIn(completion: {
                (finished: Bool) -> Void in
            })
        } else {
            self.tempoMedio.fadeOut()
        }
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }

    func printSecondsToHoursMinutesSeconds (seconds:Int) -> () {
        let (h, m, s) = secondsToHoursMinutesSeconds (seconds: seconds)
        print ("\(h) Hours, \(m) Minutes, \(s) Seconds")
        if h == 0
        {
            tempoAteCarga.text = "\(m) Minutos"
        } else {
            tempoAteCarga.text = "\(h) Horas, \(m) Min"
        }
    }

    func printSecondsToHoursMinutesSeconds2 (seconds:Int) -> () {
        let (h, m, s) = secondsToHoursMinutesSeconds (seconds: seconds)
        print ("2 \(h) Hours, \(m) Minutes, \(s) Seconds")
        if m == 0
        {
            UltimoPorcento.text = "\(s) Segundos"
        } else {
            UltimoPorcento.text = "\(m) Minutos e \(s) Segundos"
        }
    }

    func printSecondsToHoursMinutesSeconds3 (seconds:Int) -> () {
        let (h, m, s) = secondsToHoursMinutesSeconds (seconds: seconds)
        print ("2 \(h) Hours, \(m) Minutes, \(s) Seconds")
        if m == 0
        {
            tempoMedio.text = "\(s) Segundos"
        } else {
            tempoMedio.text = "\(m) Minutos e \(s) Segundos"
        }
    }

    
    func average(nums: [Double]) -> Double {
        
        var total = 0.0
        //use the parameter-array instead of the global variable votes
        for vote in nums{
            
            total += Double(vote)
            
        }
        
        let votesTotal = Double(nums.count)
        let average = total/votesTotal
        return average
    }

    func alarme()
    {
        AudioServicesPlayAlertSound(SystemSoundID(1005))
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
}

