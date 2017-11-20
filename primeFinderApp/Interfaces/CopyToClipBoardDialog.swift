//
//  CopyToClipBoardDialog.swift
//  primeFinderApp
//
//  Created by Yasin TURKOGLU on 11.10.2017.
//  Copyright © 2017 Yasin TURKOGLU. All rights reserved.
//

import UIKit

class CopyToClipBoardDialog: UIView, UIGestureRecognizerDelegate {

    private var tapGestureRecognizer:UITapGestureRecognizer!
    @IBOutlet var clipBoardDialogBox:UIView!
    @IBOutlet var dialogLabel:UILabel!
    private var currentValue:String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        let graidentLayer = CAGradientLayer()
        graidentLayer.bounds = self.clipBoardDialogBox.bounds
        graidentLayer.anchorPoint = .zero
        graidentLayer.colors = [
        UIColor(red: 210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0, alpha: 1.0).cgColor,
        UIColor.white.cgColor
        ]
        graidentLayer.cornerRadius = 20.0
        self.clipBoardDialogBox.layer.insertSublayer(graidentLayer, at: 0)
        
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: nil)
        self.tapGestureRecognizer.delegate = self
        self.addGestureRecognizer(self.tapGestureRecognizer)
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let touchPoint = touch.location(in: self)
        if let aView = self.hitTest(touchPoint, with: nil) {
            if aView.isKind(of: UIView.self) {
                if aView.tag == 1 {
                    removeSelfWith(copy: true)
                } else {
                    removeSelfWith(copy: false)
                }
            }
        }        
        return false
    }
    
    
    private func removeSelfWith(copy: Bool) {
        if copy {
            if self.currentValue != "" {
                UIPasteboard.general.string = self.currentValue
            }
            if let labelFont = UIFont(name: "ArialRoundedMTBold", size: 18) {
                let labelFontAttributes:[NSAttributedStringKey : Any] = [
                    NSAttributedStringKey.font : labelFont,
                    NSAttributedStringKey.foregroundColor : UIColor(red: 27.0/255.0, green: 194.0/255.0, blue: 0.0/255.0, alpha: 1.0)
                ]
                let labelAttributedText = NSAttributedString(string: "Copied", attributes: labelFontAttributes)
                self.dialogLabel.attributedText = labelAttributedText
            }
        } else {
            if let labelFont = UIFont(name: "ArialRoundedMTBold", size: 18) {
                let labelFontAttributes:[NSAttributedStringKey : Any] = [
                    NSAttributedStringKey.font : labelFont,
                    NSAttributedStringKey.foregroundColor : UIColor(red: 240.0/255.0, green: 0.0/255.0, blue: 4.0/255.0, alpha: 1.0)
                ]
                let labelAttributedText = NSAttributedString(string: "Canceled", attributes: labelFontAttributes)
                self.dialogLabel.attributedText = labelAttributedText
            }
        }
        UIView.animate(withDuration: 0.35, delay: 0.35, options: UIViewAnimationOptions.curveLinear, animations: {
            self.alpha = 0.0
        }) { (completed) in
            self.isUserInteractionEnabled = false
            self.dialogLabel.text = ""
        }
    }
    
    
    func initiateDialogWith(string: String) {
        self.currentValue = string
        self.isUserInteractionEnabled = true
        
        
        if let labelFont = UIFont(name: "ArialRoundedMTBold", size: 18) {
            let allString = "Tap here to copy\n\"\(string)\"\nto clipboard"
            let labelFontAttributes:[NSAttributedStringKey : Any] = [
                NSAttributedStringKey.font : labelFont,
                NSAttributedStringKey.foregroundColor : UIColor.darkGray
            ]
            let labelFontMutableAttributes = NSMutableAttributedString(string: allString, attributes: labelFontAttributes)
            
            labelFontMutableAttributes.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(red: 16.0/255.0, green: 140.0/255.0, blue: 194.0/255.0, alpha: 1.0), range: (allString as NSString).range(of: string))
            self.dialogLabel.attributedText = labelFontMutableAttributes
        }
        
        
        
        if self.alpha == 0.0 {
            UIView.animate(withDuration: 0.35, animations: {
                self.alpha = 1.0
            })
        }
    }
    
}
