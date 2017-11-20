//
//  CalculatorViewController.swift
//  primeFinderApp
//
//  Created by Yasin TURKOGLU on 10.10.2017.
//  Copyright © 2017 Yasin TURKOGLU. All rights reserved.
//

import UIKit

protocol CalculatorViewControllerDelegate:class {
    func calculatorViewController(showResults: CalculationResult)
}

class CalculatorViewController: UIViewController, UIGestureRecognizerDelegate, PrimeEngineDelegate {

    weak var delegate:CalculatorViewControllerDelegate!
    
    @IBOutlet var display: Display!
    @IBOutlet var copyPasteHolder: UIView!
    @IBOutlet var innerHolder: UIView!
    
    var tapGestureRecognizer:UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: nil)
        self.tapGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(self.tapGestureRecognizer)
        PrimeEngine.sharedInstance.delegate = self
        SoundPlayer.sharedInstance.prepareSoundPlayer()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let touchPoint = touch.location(in: self.view)
        var isTouchedToTheDisplay:Bool = false
        if let aView = self.view.hitTest(touchPoint, with: nil) {
            if aView.isKind(of: Display.self) {
                isTouchedToTheDisplay = true
            }
        }
        if isTouchedToTheDisplay {
            if self.copyPasteHolder.isUserInteractionEnabled {
                concelCopypasteHolder()
            } else {
                revealCopyPasteHolder()
            }
        } else {
            concelCopypasteHolder()
        }
        return false
    }
    
    func revealCopyPasteHolder() {
        if !PrimeEngine.sharedInstance.isThereAnyOperationInProgress() && self.innerHolder.isUserInteractionEnabled {
            self.copyPasteHolder.alpha = 1.0
            self.copyPasteHolder.isUserInteractionEnabled = true
        }
    }
    
    func concelCopypasteHolder() {
        UIView.animate(withDuration: 0.35, animations: {
            self.copyPasteHolder.alpha = 0.0
        }) { (completed) in
            self.copyPasteHolder.isUserInteractionEnabled = false
        }
    }
    
    
    @IBAction func copyAction(_ sender: UIButton) {
        let currentValue = self.display.getCurrentValue()
        UIPasteboard.general.string = "\(currentValue)"
    }
    
    @IBAction func pasteAction(_ sender: UIButton) {
        var doesStringMatch:Bool = false
        if let pasteBoardString = UIPasteboard.general.string {
            var trimmedString = pasteBoardString.trimmingCharacters(in: .whitespacesAndNewlines)
            trimmedString = trimmedString.replacingOccurrences(of: " ", with: "")
            if trimmedString.characters.count > 0 {
                let aSet = CharacterSet(charactersIn: "0123456789").inverted
                if trimmedString.rangeOfCharacter(from: aSet) == nil {
                    if trimmedString.characters.count <= self.display.maxDigitCount {
                        self.display.replaceText(trimmedString)
                        doesStringMatch = true
                    }
                }
            }
        }
        if !doesStringMatch {
            errorStimulation()
        }
    }
    
    func errorStimulation() {
        SoundPlayer.sharedInstance.playShake()
        Taptics.sharedInstance.makeErrorStimulationImpact()
        let shakeGap = ceil(self.view.bounds.size.width * 0.025)
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.view.center.x - shakeGap, y: self.view.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.view.center.x + shakeGap, y: self.view.center.y))
        self.view.layer.add(animation, forKey: "position")
    }    
    
    @IBAction func buttonTouhUpInsideOutsideCancel(_ sender: UIButton) {
        SoundPlayer.sharedInstance.playTouchUp()
        Taptics.sharedInstance.makeTouchUpImpact()
        sender.alpha = 1.0
        self.innerHolder.isUserInteractionEnabled = true
    }
    
    
    @IBAction func buttonTouchDownAction(_ sender: UIButton) {
        SoundPlayer.sharedInstance.playTouchDown()
        Taptics.sharedInstance.makeTouchDownImpact()
        sender.alpha = 0.6
        if self.innerHolder.isUserInteractionEnabled {
            self.innerHolder.isUserInteractionEnabled = false
            
            if PrimeEngine.sharedInstance.isThereAnyOperationInProgress() {
                if sender.tag == 10 {
                    PrimeEngine.sharedInstance.cancelCurrentOperation()
                }
            } else {
                if sender.tag >= 0 && sender.tag < 10 {
                    self.display.updatePrimeIndicator(indicator: .PINull)
                    self.display.insertText("\(sender.tag)")
                } else if sender.tag == 10 {
                    self.display.updatePrimeIndicator(indicator: .PINull)
                    self.display.deleteAll()
                } else if sender.tag == 11 {
                    self.display.updatePrimeIndicator(indicator: .PINull)
                    self.display.deleteBackward()
                } else if sender.tag == 12 {
                    if self.display.currentMode.rawValue < 6 {
                        if let nextMode = Modes(rawValue: self.display.currentMode.rawValue + 1) {
                            self.display.currentMode = nextMode
                        }
                    } else {
                       self.display.currentMode = .MValidator
                    }
                    self.display.updateModes(mode: self.display.currentMode)
                } else if sender.tag == 13 {
                    self.display.updatePrimeIndicator(indicator: .PINull)
                    self.display.updateCalculationIndicator(indicator: .CI0)
                    if self.display.currentMode == .MValidator {
                        let currentValueOnDisplay = self.display.getCurrentValue()
                        PrimeEngine.sharedInstance.processWith(type: .PPTIsPrime, start: currentValueOnDisplay, repetetions: 0, completionHandler: { (result) in
                            if let calculationResult = result {
                                if calculationResult.isStartValuePrime {
                                    self.display.updatePrimeIndicator(indicator: .PIPrime)
                                } else {
                                    self.display.updatePrimeIndicator(indicator: .PINotPrime)
                                }
                                self.display.updateCalculationIndicator(indicator: .CINull)
                            }
                        })
                    } else if self.display.currentMode == .MNext1 {
                        let currentValueOnDisplay = self.display.getCurrentValue()
                        PrimeEngine.sharedInstance.processWith(type: .PPTFindNext, start: currentValueOnDisplay, repetetions: 1, completionHandler: { (result) in
                            if let calculationResult = result {
                                var isNextValueAppropriate:Bool = false
                                if let firstValue = calculationResult.calculatedValues.first {
                                    let firstValueInString = "\(firstValue)"
                                    if firstValueInString.characters.count <= self.display.maxDigitCount {
                                        self.display.replaceText(firstValueInString)
                                        self.display.updatePrimeIndicator(indicator: .PIPrime)
                                        isNextValueAppropriate = true
                                    }
                                }
                                if !isNextValueAppropriate {
                                    if calculationResult.isStartValuePrime {
                                        self.display.updatePrimeIndicator(indicator: .PIPrime)
                                    } else {
                                        self.display.updatePrimeIndicator(indicator: .PINotPrime)
                                    }
                                }
                                self.display.updateCalculationIndicator(indicator: .CINull)
                            }
                        })
                    } else if self.display.currentMode == .MNext10 {
                        let currentValueOnDisplay = self.display.getCurrentValue()
                        PrimeEngine.sharedInstance.processWith(type: .PPTFindNext, start: currentValueOnDisplay, repetetions: 10, completionHandler: { (result) in
                            if let calculationResult = result {
                                if calculationResult.isStartValuePrime {
                                    self.display.updatePrimeIndicator(indicator: .PIPrime)
                                } else {
                                    self.display.updatePrimeIndicator(indicator: .PINotPrime)
                                }
                                if calculationResult.calculatedValues.count > 0 {
                                    self.delegate.calculatorViewController(showResults: calculationResult)
                                }
                                self.display.updateCalculationIndicator(indicator: .CINull)
                            }
                        })
                    } else if self.display.currentMode == .MNext100 {
                        let currentValueOnDisplay = self.display.getCurrentValue()
                        PrimeEngine.sharedInstance.processWith(type: .PPTFindNext, start: currentValueOnDisplay, repetetions: 100, completionHandler: { (result) in
                            if let calculationResult = result {
                                if calculationResult.isStartValuePrime {
                                    self.display.updatePrimeIndicator(indicator: .PIPrime)
                                } else {
                                    self.display.updatePrimeIndicator(indicator: .PINotPrime)
                                }
                                if calculationResult.calculatedValues.count > 0 {
                                    self.delegate.calculatorViewController(showResults: calculationResult)
                                }
                                self.display.updateCalculationIndicator(indicator: .CINull)
                            }
                        })
                    } else if self.display.currentMode == .MPrev1 {
                        let currentValueOnDisplay = self.display.getCurrentValue()
                        PrimeEngine.sharedInstance.processWith(type: .PPTFindPrev, start: currentValueOnDisplay, repetetions: 1, completionHandler: { (result) in
                            if let calculationResult = result {
                                if let firstValue = calculationResult.calculatedValues.first {
                                    let firstValueInString = "\(firstValue)"
                                    self.display.replaceText(firstValueInString)
                                    self.display.updatePrimeIndicator(indicator: .PIPrime)
                                } else {
                                    if calculationResult.isStartValuePrime {
                                        self.display.updatePrimeIndicator(indicator: .PIPrime)
                                    } else {
                                        self.display.updatePrimeIndicator(indicator: .PINotPrime)
                                    }
                                }
                                self.display.updateCalculationIndicator(indicator: .CINull)
                            }
                        })
                    } else if self.display.currentMode == .MPrev10 {
                        let currentValueOnDisplay = self.display.getCurrentValue()
                        PrimeEngine.sharedInstance.processWith(type: .PPTFindPrev, start: currentValueOnDisplay, repetetions: 10, completionHandler: { (result) in
                            if let calculationResult = result {
                                if calculationResult.isStartValuePrime {
                                    self.display.updatePrimeIndicator(indicator: .PIPrime)
                                } else {
                                    self.display.updatePrimeIndicator(indicator: .PINotPrime)
                                }
                                if calculationResult.calculatedValues.count > 0 {
                                    if calculationResult.calculatedValues.count < 2 {
                                        if let firstValue = calculationResult.calculatedValues.first {
                                            let firstValueInString = "\(firstValue)"
                                            self.display.replaceText(firstValueInString)
                                            self.display.updatePrimeIndicator(indicator: .PIPrime)
                                        }
                                    } else {
                                        self.delegate.calculatorViewController(showResults: calculationResult)
                                    }
                                }
                                self.display.updateCalculationIndicator(indicator: .CINull)
                            }
                        })
                    } else if self.display.currentMode == .MPrev100 {
                        let currentValueOnDisplay = self.display.getCurrentValue()
                        PrimeEngine.sharedInstance.processWith(type: .PPTFindPrev, start: currentValueOnDisplay, repetetions: 100, completionHandler: { (result) in
                            if let calculationResult = result {
                                if calculationResult.isStartValuePrime {
                                    self.display.updatePrimeIndicator(indicator: .PIPrime)
                                } else {
                                    self.display.updatePrimeIndicator(indicator: .PINotPrime)
                                }
                                if calculationResult.calculatedValues.count > 0 {
                                    if calculationResult.calculatedValues.count < 2 {
                                        if let firstValue = calculationResult.calculatedValues.first {
                                            let firstValueInString = "\(firstValue)"
                                            self.display.replaceText(firstValueInString)
                                            self.display.updatePrimeIndicator(indicator: .PIPrime)
                                        }
                                    } else {
                                        self.delegate.calculatorViewController(showResults: calculationResult)
                                    }
                                }
                                self.display.updateCalculationIndicator(indicator: .CINull)
                            }
                        })
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.display.freeUpTheStacks()
    }
    
    //MARK: PrimeEngine delegates
    func primeEngine(updateUI completed: Int) {
        var calcIndicator:CalculationIndicator = .CI0
        switch completed {
        case 10:
            calcIndicator = .CI10
        case 20:
            calcIndicator = .CI20
        case 30:
            calcIndicator = .CI30
        case 40:
            calcIndicator = .CI40
        case 50:
            calcIndicator = .CI50
        case 60:
            calcIndicator = .CI60
        case 70:
            calcIndicator = .CI70
        case 80:
            calcIndicator = .CI80
        case 90:
            calcIndicator = .CI90
        case 100:
            calcIndicator = .CI100
        default:
            calcIndicator = .CI0
        }
        self.display.updateCalculationIndicator(indicator: calcIndicator)
    }


}
