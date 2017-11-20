//
//  Taptics.swift
//  primeFinderApp
//
//  Created by Yasin TURKOGLU on 11.10.2017.
//  Copyright © 2017 Yasin TURKOGLU. All rights reserved.
//

import UIKit

class Taptics {

    static let sharedInstance = Taptics()
    private init() {}
    
    private var impactFeedbackGeneratorTouchDown:Any! = {
        if #available(iOS 10.0, *) {
            let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
            impactFeedbackGenerator.prepare()
            return impactFeedbackGenerator
        } else {
            return nil
        }
    }()
    
    private var impactFeedbackGeneratorTouchUp:Any! = {
        if #available(iOS 10.0, *) {
            let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            impactFeedbackGenerator.prepare()
            return impactFeedbackGenerator
        } else {
            return nil
        }
    }()
    
    private var impactFeedbackGeneratorErrorStimulation:Any! = {
        if #available(iOS 10.0, *) {
            let impactFeedbackGenerator = UINotificationFeedbackGenerator()
            impactFeedbackGenerator.prepare()
            return impactFeedbackGenerator
        } else {
            return nil
        }
    }()
    
    func makeTouchDownImpact() {
        if #available(iOS 10.0, *) {
            if let castedImpactFeedbackGenerator = self.impactFeedbackGeneratorTouchDown as? UIImpactFeedbackGenerator {
                castedImpactFeedbackGenerator.impactOccurred()
            }
        }
    }
    
    func makeTouchUpImpact() {
        if #available(iOS 10.0, *) {
            if let castedImpactFeedbackGenerator = self.impactFeedbackGeneratorTouchUp as? UIImpactFeedbackGenerator {
                castedImpactFeedbackGenerator.impactOccurred()
            }
        }
    }
    
    func makeErrorStimulationImpact() {
        if #available(iOS 10.0, *) {
            if let castedImpactFeedbackGenerator = self.impactFeedbackGeneratorErrorStimulation as? UINotificationFeedbackGenerator {
                castedImpactFeedbackGenerator.notificationOccurred(UINotificationFeedbackType.error)
            }
        }
    }
    
}
