//
//  Display.swift
//  primeFinderApp
//
//  Created by Yasin TURKOGLU on 11.10.2017.
//  Copyright © 2017 Yasin TURKOGLU. All rights reserved.
//

import UIKit

enum Modes: Int {
    case MValidator = 0
    case MNext1 = 1
    case MNext10 = 2
    case MNext100 = 3
    case MPrev1 = 4
    case MPrev10 = 5
    case MPrev100 = 6
}

enum PrimeIndicator: Int {
    case PINull = 0
    case PIPrime = 1
    case PINotPrime = 2
}

enum CalculationIndicator: Int {
    case CINull = 0
    case CI0 = 1
    case CI10 = 2
    case CI20 = 3
    case CI30 = 4
    case CI40 = 5
    case CI50 = 6
    case CI60 = 7
    case CI70 = 8
    case CI80 = 9
    case CI90 = 10
    case CI100 = 11
}

private typealias Number = (num : Int, hasFloatingPoint : Bool, hasDecimalMark : Bool)


extension String {
    mutating func applyDecimal(seperator: Character) {
        var aString = self
        var offset = [Int]()
        var decimalPointsAmount:Int = 0
        let charactersCount = aString.characters.count
        if charactersCount > 0 {
            decimalPointsAmount = Int(floor(Double(charactersCount - 1) / 3.0))
        }
        for i in 1..<decimalPointsAmount + 1 {
            offset.append((charactersCount - (i * 3)) + (decimalPointsAmount - i))
        }
        offset.reversed().forEach { (i) in
            aString.insert(seperator, at: aString.index(aString.startIndex, offsetBy: i))
        }
        self = aString
    }
}

class Display: UIView {

    private var text:String = ""
    private let decimalSeperator:Character = "'"
    private let mainFont:String = "Avenir-HeavyOblique"
    private let digitColor = UIColor(red: 0.0/255, green: 179/255, blue: 177/255, alpha: 1)
    private var holderViewSize:CGSize = .zero
    private var digitHeight:CGFloat = 0
    var maxDigitCount:Int = 12
    private var glowRadius:CGFloat = 0
    private var modeTextHeight:CGFloat = 0
    private var modeImageView:UIImageView!
    private var primeIndicatorImageview:UIImageView!
    private var calculationIndicatorImageview:UIImageView!
    private var digitsImageview:UIImageView!
    private var digitStack = [String:UIImage]()
    private var modesStack = [String:UIImage]()
    private var primeIndicatorStack = [String:UIImage]()
    private var calculationIndicatorStack = [String:UIImage]()
    var currentMode:Modes = .MValidator
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.clipsToBounds = true
        var portraitBoundsOfScreen = UIScreen.main.bounds
        if portraitBoundsOfScreen.size.width > portraitBoundsOfScreen.size.height {
            let reverseBounds = CGRect(x: 0, y: 0, width: portraitBoundsOfScreen.height, height: portraitBoundsOfScreen.width)
            portraitBoundsOfScreen = reverseBounds
        }
        self.digitHeight = floor(portraitBoundsOfScreen.width * 0.1)
        self.glowRadius = ceil(self.digitHeight * 0.14)
        self.modeTextHeight = ceil(self.digitHeight * 0.23)
        self.holderViewSize = CGSize(width: floor(portraitBoundsOfScreen.width * 0.88), height: floor(portraitBoundsOfScreen.width * 0.18))
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.image = #imageLiteral(resourceName: "display")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        self.addConstraints([
            NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
            ])
        let mainHolderView = UIView()
        mainHolderView.translatesAutoresizingMaskIntoConstraints = false
        mainHolderView.isUserInteractionEnabled = false
        self.addSubview(mainHolderView)
        self.addConstraints([
            NSLayoutConstraint(item: mainHolderView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: mainHolderView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: mainHolderView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.holderViewSize.width),
            NSLayoutConstraint(item: mainHolderView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.holderViewSize.height)
            ])
        
        self.layoutIfNeeded()

        if let backgroundImage = createDisplayBackgroundImage() {
            let displayBackgroundImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.holderViewSize.width, height: self.holderViewSize.height))
            displayBackgroundImageView.contentMode = .scaleToFill
            displayBackgroundImageView.image = backgroundImage
            mainHolderView.addSubview(displayBackgroundImageView)
        }
        
        let illuminationLayersHolderView = UIView(frame: CGRect(x: 0, y: 0, width: self.holderViewSize.width, height: self.holderViewSize.height))
        mainHolderView.addSubview(illuminationLayersHolderView)
        
        self.modeImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.holderViewSize.width, height: self.holderViewSize.height))
        self.modeImageView.contentMode = .scaleToFill
        illuminationLayersHolderView.addSubview(self.modeImageView)
        updateModes(mode: self.currentMode)
        
        self.primeIndicatorImageview = UIImageView(frame: CGRect(x: 0, y: 0, width: self.holderViewSize.width, height: self.holderViewSize.height))
        self.primeIndicatorImageview.contentMode = .scaleToFill
        illuminationLayersHolderView.addSubview(self.primeIndicatorImageview)
        
        self.calculationIndicatorImageview = UIImageView(frame: CGRect(x: 0, y: 0, width: self.holderViewSize.width, height: self.holderViewSize.height))
        self.calculationIndicatorImageview.contentMode = .scaleToFill
        illuminationLayersHolderView.addSubview(self.calculationIndicatorImageview)
        
        self.digitsImageview = UIImageView(frame: CGRect(x: 0, y: 0, width: self.holderViewSize.width, height: self.holderViewSize.height))
        self.digitsImageview.contentMode = .scaleToFill
        illuminationLayersHolderView.addSubview(self.digitsImageview)
        numProcessor(text: "0")
        
        if let lineDrawing = lineDrawing(rect: CGRect(x: 0, y: 0, width: self.holderViewSize.width, height: self.holderViewSize.height), scale: UIScreen.main.nativeScale) {
            if let cgImage = lineDrawing.cgImage {
                let maskLayer = CALayer()
                maskLayer.contents = cgImage
                maskLayer.frame = CGRect(x: 0, y: 0, width: self.holderViewSize.width, height: self.holderViewSize.height)
                illuminationLayersHolderView.layer.mask = maskLayer
            }
        }
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        opacityAnimation.duration = 0.03
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = 0.8
        opacityAnimation.autoreverses = true
        opacityAnimation.repeatCount = HUGE
        opacityAnimation.isRemovedOnCompletion = false
        illuminationLayersHolderView.layer.add(opacityAnimation, forKey: nil)
    }
    
    func insertText(_ text: String) {
        if getCurrentCharactersCount() < 12 {
            let combinedText = textCombiner(text: text)
            textProcessor(text: combinedText)
        }
    }
    
    func deleteAll() {
        textProcessor(text: "")
    }
    
    func deleteBackward() {
        var purifiedText = textPurifier(text: self.text)
        if purifiedText.characters.count > 0 {
            purifiedText = String(purifiedText.characters.dropLast(1))
        }
        textProcessor(text: purifiedText)
    }
    
    func replaceText(_ text: String) {
        if text.characters.count <= self.maxDigitCount {
            deleteAll()
            insertText(text)
        }
    }
    
    func getCurrentValue() -> UInt64 {
        var integer:UInt64 = 0
        let purifiedText = textPurifier(text: self.text)
        if let purifiedTexttInDouble = Double(purifiedText) {
            if purifiedTexttInDouble < Double(UInt64.max) {
                if purifiedTexttInDouble == Double(UInt64(purifiedTexttInDouble)) {
                    integer = UInt64(purifiedTexttInDouble)
                }
            }
        }
        return integer
    }
    
    private func getCurrentCharactersCount() -> Int {
        return textPurifier(text: self.text).characters.count
    }
    
    private func textPurifier(text: String) -> String {
        return text.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: String(self.decimalSeperator), with: "")
    }
    
    func updateModes(mode: Modes) {
        if self.modeImageView != nil {
            if let image = createModeImage(mode: mode) {
                self.modeImageView.image = image
            }
        }
    }
    
    func updatePrimeIndicator(indicator: PrimeIndicator) {
        if self.primeIndicatorImageview != nil {
            self.primeIndicatorImageview.image = createPrimeIndicatorImage(indicator: indicator)
        }
    }
    
    func updateCalculationIndicator(indicator: CalculationIndicator) {
        if self.calculationIndicatorImageview != nil {
            self.calculationIndicatorImageview.image = createCalculationIndicatorImage(indicator: indicator)
        }
    }
    
    func freeUpTheStacks() {
        self.modesStack.removeAll()
        self.digitStack.removeAll()
        self.primeIndicatorStack.removeAll()
        self.calculationIndicatorStack.removeAll()
    }
    
    private func textProcessor(text: String) {
        var purifiedText = textPurifier(text: text)
        if purifiedText.characters.count > 0 {
            let aSet = CharacterSet(charactersIn: "0123456789").inverted
            if purifiedText.rangeOfCharacter(from: aSet) == nil {
                var integer:UInt64 = 0
                if let purifiedTexttInDouble = Double(purifiedText) {
                    if purifiedTexttInDouble < Double(UInt64.max) {
                        if purifiedTexttInDouble == Double(UInt64(purifiedTexttInDouble)) {
                            integer = UInt64(purifiedTexttInDouble)
                        }
                    }
                }
                if integer > 0 {
                    purifiedText.applyDecimal(seperator: self.decimalSeperator)
                    numProcessor(text: purifiedText)
                } else {
                    numProcessor(text: "0")
                }
            }
        } else {
            numProcessor(text: "0")
        }
    }
    
    private func textCombiner(text: String) -> String {
        var returningValue:String = ""
        var purifiedText = textPurifier(text: text)
        if purifiedText.characters.count > 0 {
            let aSet = CharacterSet(charactersIn: "0123456789").inverted
            if purifiedText.rangeOfCharacter(from: aSet) == nil {
                var currentText = textPurifier(text: self.text)
                var integer1:UInt64 = 0
                if let currentTextInDouble = Double(currentText) {
                    if currentTextInDouble < Double(UInt64.max) {
                        if currentTextInDouble == Double(UInt64(currentTextInDouble)) {
                            integer1 = UInt64(currentTextInDouble)
                        }
                    }
                }
                if integer1 > 0 {
                    currentText += purifiedText
                    currentText.applyDecimal(seperator: self.decimalSeperator)
                    returningValue = currentText
                } else {
                    
                    var integer2:UInt64 = 0
                    if let purifiedTextInDouble = Double(purifiedText) {
                        if purifiedTextInDouble < Double(UInt64.max) {
                            if purifiedTextInDouble == Double(UInt64(purifiedTextInDouble)) {
                                integer2 = UInt64(purifiedTextInDouble)
                            }
                        }
                    }
                    if integer2 > 0 {
                        currentText = purifiedText
                        currentText.applyDecimal(seperator: self.decimalSeperator)
                        returningValue = currentText
                    }
                }
            }
        }
        return returningValue
    }
    
    
    private func numProcessor(text: String) {
        self.digitsImageview.image = nil
        self.text = text
        createNumber(text: text)
    }
    
    private func createNumber(text: String) {
        var numbers = [Number]()
        var applyDecimalMarkToNextNumber:Bool = false
        for (i, char) in text.characters.enumerated() {
            let charInString = String(char)
            if charInString != String(self.decimalSeperator) {
                if let stringInDouble = Double(charInString) {
                    let integer = Int(stringInDouble)
                    var itHasFloatingPoint:Bool = false
                    if i == text.characters.count - 1 {
                        itHasFloatingPoint = true
                    }
                    let aNumber = Number(num : integer, hasFloatingPoint : itHasFloatingPoint, hasDecimalMark : applyDecimalMarkToNextNumber)
                    applyDecimalMarkToNextNumber = false
                    numbers.append(aNumber)
                }
            } else {
                applyDecimalMarkToNextNumber = true
            }
        }
        var digits = [UIImage]()
        numbers.reversed().forEach { (definition) in
            if let image = generateDigit(number: definition.num, height: self.digitHeight, hasFloatingPoint: definition.hasFloatingPoint, hasDecimalMark: definition.hasDecimalMark) {
                digits.append(image)
            }
        }
        
        if let finalImage = combineDigits(images: digits) {
            if self.digitsImageview != nil {
                self.digitsImageview.alpha = 0.0
                self.digitsImageview.image = finalImage
                UIView.animate(withDuration: 0.07, animations: {
                    self.digitsImageview.alpha = 1.0
                })
            }
        }
    }
    
    
    private func combineDigits(images: [UIImage]) -> UIImage! {
        var returningImage:UIImage!
        if images.count > 0 {
            if let firstImage = images.first {
                UIGraphicsBeginImageContextWithOptions(self.holderViewSize, false, UIScreen.main.nativeScale)
                
                var currentPoint = CGPoint(x: self.holderViewSize.width - (firstImage.size.width + self.glowRadius), y: (self.holderViewSize.height - firstImage.size.height) / 2)
                
                images.forEach({ (image) in
                    image.draw(at: currentPoint)
                    currentPoint.x -= firstImage.size.width
                })
                
                if let imageContext = UIGraphicsGetImageFromCurrentImageContext() {
                    returningImage = applyGlowTo(image: imageContext, glowColor: self.digitColor, glowRadius: self.glowRadius, scale: UIScreen.main.nativeScale)
                }
                
                
                
                
                UIGraphicsEndImageContext()
            }
        }
        return returningImage
    }
    
    
    private func applyGlowTo(image: UIImage, glowColor: UIColor, glowRadius: CGFloat, scale: CGFloat) -> UIImage! {
        var returningImage:UIImage!
        if let cgImage = image.cgImage {
            let scaledRect = CGRect(x: 0, y: 0, width: image.size.width * scale, height: image.size.height * scale)
            if let glowContext = CGContext(data: nil,
                                           width: Int(scaledRect.size.width),
                                           height: Int(scaledRect.size.height),
                                           bitsPerComponent: cgImage.bitsPerComponent,
                                           bytesPerRow: 0,
                                           space: CGColorSpaceCreateDeviceRGB(),
                                           bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {
                glowContext.setShadow(offset: .zero, blur: ceil(glowRadius * scale), color: glowColor.cgColor)
                glowContext.draw(cgImage, in: scaledRect, byTiling: false)
                if let imageFromGlowContext = glowContext.makeImage() {
                    returningImage = UIImage(cgImage: imageFromGlowContext, scale: scale, orientation: .up)
                }
            }
        }
        return returningImage
    }
    
    private func lineDrawing(rect: CGRect, scale: CGFloat) -> UIImage! {
        var returningImage:UIImage!
        UIGraphicsBeginImageContextWithOptions(self.holderViewSize, false, UIScreen.main.nativeScale)
        if let context = UIGraphicsGetCurrentContext() {
            var lineWidth:CGFloat = (floor(rect.size.height * 0.02) / 10)
            if lineWidth == 0 {
                lineWidth = 0.05
            }
            let horizontalLinesAmount = Int(floor(rect.size.height / (lineWidth * 3)))
            var yStartPosition:CGFloat = 0
            for _ in 0..<horizontalLinesAmount {
                let aPath = CGMutablePath()
                aPath.addLines(between: [
                    CGPoint(x: 0, y: yStartPosition),
                    CGPoint(x: rect.size.width, y: yStartPosition)
                    ])
                context.setStrokeColor(UIColor.black.cgColor)
                context.setLineWidth(lineWidth * 8)
                context.addPath(aPath)
                context.strokePath()
                
                context.setStrokeColor(UIColor.black.withAlphaComponent(0.7).cgColor)
                context.setLineWidth(lineWidth * 16)
                context.addPath(aPath)
                context.strokePath()
                yStartPosition += (lineWidth * 14)
            }
            returningImage = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        return returningImage
    }

    private func createModeImage(mode: Modes) -> UIImage! {
        var returningImage:UIImage!
        var text:String = ""
        var point:CGPoint = .zero
        var modeStackKey:String = ""
        switch mode {
        case .MValidator:
            text = "IS PRIME"
            point = CGPoint(x: self.glowRadius, y: (self.holderViewSize.height - self.digitHeight) / 2)
            modeStackKey = "validator"
        case .MNext1:
            text = "NEXT 1"
            point = CGPoint(x: self.glowRadius, y: (self.holderViewSize.height / 2) - (self.modeTextHeight / 2))
            modeStackKey = "next1"
        case .MNext10:
            text = "NEXT 10"
            point = CGPoint(x: self.glowRadius, y: (self.holderViewSize.height / 2) - (self.modeTextHeight / 2))
            modeStackKey = "next10"
        case .MNext100:
            text = "NEXT 100"
            point = CGPoint(x: self.glowRadius, y: (self.holderViewSize.height / 2) - (self.modeTextHeight / 2))
            modeStackKey = "next100"
        case .MPrev1:
            text = "PREV 1"
            point = CGPoint(x: self.glowRadius, y: (((self.holderViewSize.height - self.digitHeight) / 2) + self.digitHeight) - self.modeTextHeight)
            modeStackKey = "prev1"
        case .MPrev10:
            text = "PREV 10"
            point = CGPoint(x: self.glowRadius, y: (((self.holderViewSize.height - self.digitHeight) / 2) + self.digitHeight) - self.modeTextHeight)
            modeStackKey = "prev10"
        case .MPrev100:
            text = "PREV 100"
            point = CGPoint(x: self.glowRadius, y: (((self.holderViewSize.height - self.digitHeight) / 2) + self.digitHeight) - self.modeTextHeight)
            modeStackKey = "prev100"
        }
        let modeImage = self.modesStack.filter({ (aImage: (key: String, value: UIImage)) -> Bool in
            return aImage.key == modeStackKey
        })
        if let filtered = modeImage.first {
            returningImage = filtered.value
        } else {
            UIGraphicsBeginImageContextWithOptions(self.holderViewSize, false, UIScreen.main.nativeScale)
            if let textFont = UIFont(name: self.mainFont, size: self.modeTextHeight) {
                let textFontAttributes:[NSAttributedStringKey : Any] = [
                    NSAttributedStringKey.font : textFont,
                    NSAttributedStringKey.foregroundColor : self.digitColor
                ]
                text.draw(at: point, withAttributes: textFontAttributes)
                
                if let imageFromContext = UIGraphicsGetImageFromCurrentImageContext() {
                    returningImage = applyGlowTo(image: imageFromContext, glowColor: self.digitColor, glowRadius: self.glowRadius, scale: UIScreen.main.nativeScale)
                    self.modesStack[modeStackKey] = returningImage
                }
            }
            UIGraphicsEndImageContext()
        }
        return returningImage
    }
    
    private func createPrimeIndicatorImage(indicator: PrimeIndicator) -> UIImage! {
        var returningImage:UIImage!
        var primeIndicatorStackKey:String = ""
        if indicator != .PINull {
            if indicator == .PINotPrime {
                primeIndicatorStackKey += "not"
            }
            primeIndicatorStackKey += "prime"
        }
        if primeIndicatorStackKey != "" {
            let primeIndicatorImage = self.primeIndicatorStack.filter({ (aImage: (key: String, value: UIImage)) -> Bool in
                return aImage.key == primeIndicatorStackKey
            })
            if let filtered = primeIndicatorImage.first {
                returningImage = filtered.value
            } else {
                var indicatorColor:UIColor = .green
                var notIndicatorImage:UIImage!
                var primeIndicatorImage:UIImage!
                let fontHeight = floor(self.modeTextHeight * 1.2)
                if indicator == .PINotPrime {
                    indicatorColor = .red
                    UIGraphicsBeginImageContextWithOptions(self.holderViewSize, false, UIScreen.main.nativeScale)
                    if let textFont = UIFont(name: self.mainFont, size: fontHeight) {
                        let textFontAttributes:[NSAttributedStringKey : Any] = [
                            NSAttributedStringKey.font : textFont,
                            NSAttributedStringKey.foregroundColor : indicatorColor
                        ]
                        let text1 = "NOT"
                        text1.draw(at: CGPoint(x: ceil(self.holderViewSize.width * 0.8), y: (self.holderViewSize.height - (fontHeight * 1.4))), withAttributes: textFontAttributes)
                    }
                    notIndicatorImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                }
                UIGraphicsBeginImageContextWithOptions(self.holderViewSize, false, UIScreen.main.nativeScale)
                if let textFont = UIFont(name: self.mainFont, size: fontHeight) {
                    let textFontAttributes:[NSAttributedStringKey : Any] = [
                        NSAttributedStringKey.font : textFont,
                        NSAttributedStringKey.foregroundColor : indicatorColor
                    ]
                    let text2 = "PRIME"
                    text2.draw(at: CGPoint(x: ceil(self.holderViewSize.width * 0.88), y: (self.holderViewSize.height - (fontHeight * 1.4))), withAttributes: textFontAttributes)
                }
                primeIndicatorImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                UIGraphicsBeginImageContextWithOptions(self.holderViewSize, false, UIScreen.main.nativeScale)
                if notIndicatorImage != nil {
                    notIndicatorImage.draw(at: .zero)
                }
                if primeIndicatorImage != nil {
                    primeIndicatorImage.draw(at: .zero)
                }
                if let contextImage = UIGraphicsGetImageFromCurrentImageContext() {
                    returningImage = applyGlowTo(image: contextImage, glowColor: indicatorColor, glowRadius: self.glowRadius, scale: UIScreen.main.nativeScale)
                    self.primeIndicatorStack[primeIndicatorStackKey] = returningImage
                }
                UIGraphicsEndImageContext()
            }
        }
        return returningImage
    }
    
    private func createCalculationIndicatorImage(indicator: CalculationIndicator) -> UIImage! {
        var returningImage:UIImage!
        var calculationIndicatorStackKey:String = ""
        var progressBarCoefficient:CGFloat = 0
        switch indicator {
        case .CI0:
            progressBarCoefficient = 0
            calculationIndicatorStackKey = "calc0"
        case .CI10:
            progressBarCoefficient = 0.1
            calculationIndicatorStackKey = "calc10"
        case .CI20:
            progressBarCoefficient = 0.2
            calculationIndicatorStackKey = "calc20"
        case .CI30:
            progressBarCoefficient = 0.3
            calculationIndicatorStackKey = "calc30"
        case .CI40:
            progressBarCoefficient = 0.4
            calculationIndicatorStackKey = "calc40"
        case .CI50:
            progressBarCoefficient = 0.5
            calculationIndicatorStackKey = "calc50"
        case .CI60:
            progressBarCoefficient = 0.6
            calculationIndicatorStackKey = "calc60"
        case .CI70:
            progressBarCoefficient = 0.7
            calculationIndicatorStackKey = "calc70"
        case .CI80:
            progressBarCoefficient = 0.8
            calculationIndicatorStackKey = "calc80"
        case .CI90:
            progressBarCoefficient = 0.9
            calculationIndicatorStackKey = "calc90"
        case .CI100:
            progressBarCoefficient = 1
            calculationIndicatorStackKey = "calc100"
        case .CINull:
            progressBarCoefficient = 0
            calculationIndicatorStackKey = ""
        }
        
        if calculationIndicatorStackKey != "" {
            let calculationIndicatorImage = self.calculationIndicatorStack.filter({ (aImage: (key: String, value: UIImage)) -> Bool in
                return aImage.key == calculationIndicatorStackKey
            })
            if let filtered = calculationIndicatorImage.first {
                returningImage = filtered.value
            } else {
                UIGraphicsBeginImageContextWithOptions(self.holderViewSize, false, UIScreen.main.nativeScale)
                let fontHeight = floor(self.modeTextHeight * 1.2)
                if let textFont = UIFont(name: self.mainFont, size: fontHeight) {
                    let textFontAttributes:[NSAttributedStringKey : Any] = [
                        NSAttributedStringKey.font : textFont,
                        NSAttributedStringKey.foregroundColor : self.digitColor
                    ]
                    let text = "CALCULATING"
                    var approximateStringSize = (text as NSString).size(withAttributes: textFontAttributes)
                    text.draw(at: CGPoint(x: ((self.holderViewSize.width * 0.5) - (approximateStringSize.width * 0.5)), y: (self.holderViewSize.height - (fontHeight * 1.4))), withAttributes: textFontAttributes)
                    if let context = UIGraphicsGetCurrentContext() {
                        approximateStringSize = CGSize(width: approximateStringSize.width + (fontHeight / 2), height: approximateStringSize.height)
                        let lineHeight = ceil(self.modeTextHeight * 0.2)
                        let lineStartPoint = CGPoint(x: (self.holderViewSize.width * 0.5) - (approximateStringSize.width * 0.5), y: self.holderViewSize.height - (lineHeight * 0.5))
                        let lineEndPoint = CGPoint(x: (self.holderViewSize.width * 0.5) + ((approximateStringSize.width * progressBarCoefficient) - (approximateStringSize.width * 0.5)), y: self.holderViewSize.height - (lineHeight * 0.5))
                        context.addLines(between: [lineStartPoint, lineEndPoint])
                        context.setStrokeColor(self.digitColor.cgColor)
                        context.setLineWidth(lineHeight)
                        context.strokePath()
                    }
                }
                if let contextImage = UIGraphicsGetImageFromCurrentImageContext() {
                    returningImage = applyGlowTo(image: contextImage, glowColor: self.digitColor, glowRadius: self.glowRadius, scale: UIScreen.main.nativeScale)
                    self.calculationIndicatorStack[calculationIndicatorStackKey] = returningImage
                }
                UIGraphicsEndImageContext()
            }
        }
        return returningImage
    }
    
    
    private func createDisplayBackgroundImage() -> UIImage! {
        var returningImage:UIImage!
        UIGraphicsBeginImageContextWithOptions(self.holderViewSize, false, UIScreen.main.nativeScale)
        if let textFont = UIFont(name: self.mainFont, size: self.modeTextHeight) {
            let text1 = "IS PRIME"
            let text2 = "NEXT 100"
            let text3 = "PREV 100"
            let textFontAttributes:[NSAttributedStringKey : Any] = [
                NSAttributedStringKey.font : textFont,
                NSAttributedStringKey.foregroundColor : self.digitColor.withAlphaComponent(0.15)
            ]
            text1.draw(at: CGPoint(x: self.glowRadius, y: (self.holderViewSize.height - self.digitHeight) / 2), withAttributes: textFontAttributes)
            text2.draw(at: CGPoint(x: self.glowRadius, y: (self.holderViewSize.height / 2) - (self.modeTextHeight / 2)), withAttributes: textFontAttributes)
            text3.draw(at: CGPoint(x: self.glowRadius, y: (((self.holderViewSize.height - self.digitHeight) / 2) + self.digitHeight) - self.modeTextHeight), withAttributes: textFontAttributes)
        }
        let fontHeight = floor(self.modeTextHeight * 1.2)
        if let textFont = UIFont(name: self.mainFont, size: fontHeight) {
            let text1 = "NOT"
            let text2 = "PRIME"
            let text3 = "CALCULATING"
            let textFontAttributes:[NSAttributedStringKey : Any] = [
                NSAttributedStringKey.font : textFont,
                NSAttributedStringKey.foregroundColor : self.digitColor.withAlphaComponent(0.15)
            ]
            text1.draw(at: CGPoint(x: ceil(self.holderViewSize.width * 0.8), y: (self.holderViewSize.height - (fontHeight * 1.4))), withAttributes: textFontAttributes)
            text2.draw(at: CGPoint(x: ceil(self.holderViewSize.width * 0.88), y: (self.holderViewSize.height - (fontHeight * 1.4))), withAttributes: textFontAttributes)
            var approximateStringSize = (text3 as NSString).size(withAttributes: textFontAttributes)
            text3.draw(at: CGPoint(x: ((self.holderViewSize.width * 0.5) - (approximateStringSize.width * 0.5)), y: (self.holderViewSize.height - (fontHeight * 1.4))), withAttributes: textFontAttributes)
            if let context = UIGraphicsGetCurrentContext() {
                approximateStringSize = CGSize(width: approximateStringSize.width + (fontHeight / 2), height: approximateStringSize.height)
                let lineHeight = ceil(self.modeTextHeight * 0.2)
                let lineStartPoint = CGPoint(x: (self.holderViewSize.width * 0.5) - (approximateStringSize.width * 0.5), y: self.holderViewSize.height - (lineHeight * 0.5))
                let lineEndPoint = CGPoint(x: (self.holderViewSize.width * 0.5) + (approximateStringSize.width * 0.5), y: self.holderViewSize.height - (lineHeight * 0.5))
                context.addLines(between: [lineStartPoint, lineEndPoint])
                context.setStrokeColor(self.digitColor.withAlphaComponent(0.15).cgColor)
                context.setLineWidth(lineHeight)
                context.strokePath()
            }
            
        }
        if let generateBackgroundDigit = generateDigit(number: nil, height: self.digitHeight, hasFloatingPoint: false, hasDecimalMark: false) {
            var xPosition = self.holderViewSize.width - self.glowRadius - generateBackgroundDigit.size.width
            
            for _ in 0..<self.maxDigitCount {
                generateBackgroundDigit.draw(at: CGPoint(x: xPosition, y: (self.holderViewSize.height - self.digitHeight) / 2))
                xPosition -= generateBackgroundDigit.size.width
            }
        }
        returningImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return returningImage
    }
    
    
    
    private func generateDigit(number: Int!, height: CGFloat, hasFloatingPoint: Bool, hasDecimalMark: Bool) -> UIImage! {
        var returningImage:UIImage!
        var digitStackKey:String = ""
        var digitParts = [Int]()
        if number != nil {
            switch number {
            case 0:
                digitStackKey = "digit0"
                digitParts = [3, 4, 5, 7, 8, 9]
            case 1:
                digitStackKey = "digit1"
                digitParts = [5, 8]
            case 2:
                digitStackKey = "digit2"
                digitParts = [3, 5, 6, 7, 9]
            case 3:
                digitStackKey = "digit3"
                digitParts = [3, 5, 6, 8, 9]
            case 4:
                digitStackKey = "digit4"
                digitParts = [4, 5, 6, 8]
            case 5:
                digitStackKey = "digit5"
                digitParts = [3, 4, 6, 8, 9]
            case 6:
                digitStackKey = "digit6"
                digitParts = [3, 4, 6, 7, 8, 9]
            case 7:
                digitStackKey = "digit7"
                digitParts = [3, 5, 8]
            case 8:
                digitStackKey = "digit8"
                digitParts = [3, 4, 5, 6, 7, 8, 9]
            case 9:
                digitStackKey = "digit9"
                digitParts = [3, 4, 5, 6, 8, 9]
            default:
                digitStackKey = "digit0"
                digitParts = [3, 4, 5, 7, 8, 9]
                break
            }
            if hasFloatingPoint {
                digitStackKey += "float"
                digitParts.append(1)
            }
            if hasDecimalMark {
                digitStackKey += "decimal"
                digitParts.append(2)
            }
        } else {
            digitStackKey = "digitHolow"
            digitParts = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        }
        let digitImage = self.digitStack.filter({ (aImage: (key: String, value: UIImage)) -> Bool in
            return aImage.key == digitStackKey
        })
        if let filtered = digitImage.first {
            returningImage = filtered.value
        } else {
            let fontAspectRatio:CGFloat = 0.62
            let cropRatio:CGFloat = 0.0344
            let rect = CGRect(x: 0, y: 0, width: floor(height * fontAspectRatio), height: height)
            let cropSize:CGFloat = height * cropRatio
            let textDrawRect = CGRect(x: -(((height - rect.size.width) / 2) + cropSize), y: -cropSize, width: height + (cropSize * 2), height: height + (cropSize * 2))
            if let textFont = UIFont(name: "digitparts", size: textDrawRect.size.height) {
                UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.nativeScale)
                digitParts.forEach({ (part) in
                    let text:String = "\(part)"
                    var aDigitColor = self.digitColor
                    if digitStackKey == "digitHolow" {
                        aDigitColor = self.digitColor.withAlphaComponent(0.15)
                    }
                    let textFontAttributes:[NSAttributedStringKey : Any] = [
                        NSAttributedStringKey.font : textFont,
                        NSAttributedStringKey.foregroundColor : aDigitColor
                    ]
                    text.draw(in: textDrawRect, withAttributes: textFontAttributes)
                })
                if let imageFromContext = UIGraphicsGetImageFromCurrentImageContext() {
                    returningImage = imageFromContext
                    self.digitStack[digitStackKey] = imageFromContext
                }
                UIGraphicsEndImageContext()
            }
        }
        return returningImage
    }
    

}
