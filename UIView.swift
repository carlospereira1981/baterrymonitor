//
//  UIView.swift
//  BatteryMonitor
//
//  Created by Carlos Alberto Rodrigues Pereira Neto on 4/29/17.
//  Copyright © 2017 Carlos Pereira. All rights reserved.
//

import UIKit
import Foundation

    extension UIView{
        func fadeIn(duration: TimeInterval = 1.0, delay: TimeInterval = 0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
            UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.alpha = 1.0
            }, completion: completion)  }
        
        func fadeOut(duration: TimeInterval = 1.0, delay: TimeInterval = 0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
            UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.alpha = 0.0
            }, completion: completion)
        }
    }
