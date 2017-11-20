//
//  MainViewController.swift
//  primeFinderApp
//
//  Created by Yasin TURKOGLU on 10.10.2017.
//  Copyright © 2017 Yasin TURKOGLU. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, CalculatorViewControllerDelegate, ResultsViewControllerDelegate {

    
    let storyBoard = UIStoryboard(name: "Main", bundle: .main)
    
    @IBOutlet var launchScreenTitle: UIImageView!
    var calculatorViewController:CalculatorViewController!
    var resultsViewController:ResultsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _ = delay(delay: 1) {
            self.addCalculatorViewControllerAsAChildViewController()
            self.rateMe()
        }
    }
    
    
    let minSession:Int = 4
    func rateMe() {
        let userDefaults = UserDefaults.standard
        let neverRate = userDefaults.bool(forKey: "neverRate")
        if !neverRate {
            var numLaunches = userDefaults.integer(forKey: "numLanunches") + 1
            if numLaunches >= self.minSession {
                showRateMe()
                numLaunches = 0
            }
            userDefaults.set(numLaunches, forKey: "numLanunches")
            userDefaults.synchronize()
        }
    }
    
    func showRateMe() {
        let alert = UIAlertController(title: "Rate and review", message: "Do you like \"Prime Finder\"?\nNow, please take a moment to rate and review \"Prime Finder\" on the App Store.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Later", style: UIAlertActionStyle.destructive, handler: { alertAction in
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Rate now", style: UIAlertActionStyle.cancel, handler: { alertAction in
            self.redirectToTheAppStore(completionHandler: { (success) in
                if success {
                    let userDefaults = UserDefaults.standard
                    userDefaults.set(true, forKey: "neverRate")
                    userDefaults.synchronize()
                }
            })
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func redirectToTheAppStore(completionHandler: @escaping(Bool) -> Void) {
        guard let url = URL(string: "itms-apps://itunes.apple.com/app/id1292842032") else {
            completionHandler(false)
            return
        }
        guard #available(iOS 10, *) else {
            completionHandler(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: completionHandler)
    }
    
    
    override var traitCollection: UITraitCollection {
        if UIDevice.current.userInterfaceIdiom == .pad {
            if UIDevice.current.orientation.isLandscape {
                return UITraitCollection(traitsFrom: [
                    UITraitCollection(horizontalSizeClass: .regular),
                    UITraitCollection(verticalSizeClass: .compact)
                    ])
            }
        }
        return super.traitCollection
    }

    
    func addCalculatorViewControllerAsAChildViewController() {
        self.calculatorViewController = self.storyBoard.instantiateViewController(withIdentifier: "calculatorViewController") as! CalculatorViewController
        self.calculatorViewController.delegate = self
        self.calculatorViewController.view.alpha = 0.0
        self.addChildViewController(self.calculatorViewController)
        self.calculatorViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(self.calculatorViewController.view, at: 1)
        self.view.addConstraints([
            NSLayoutConstraint(item: self.calculatorViewController.view, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.calculatorViewController.view, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.calculatorViewController.view, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.calculatorViewController.view, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
            ])
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.35, animations: {
            self.calculatorViewController.view.alpha = 1.0
            self.launchScreenTitle.alpha = 0.0
        }) { (completed) in
            self.launchScreenTitle.removeFromSuperview()
            self.launchScreenTitle = nil
        }
    }
    
    func addResultsViewControllerAsAChildViewController(withResults: CalculationResult) {
        if self.resultsViewController == nil {
            self.resultsViewController = self.storyBoard.instantiateViewController(withIdentifier: "resultsViewController") as! ResultsViewController
            self.resultsViewController.delegate = self
            self.resultsViewController.view.alpha = 0.0
            self.resultsViewController.calculationResults = withResults
            self.addChildViewController(self.resultsViewController)
            self.resultsViewController.view.translatesAutoresizingMaskIntoConstraints = false
            self.view.insertSubview(self.resultsViewController.view, at: 2)
            self.view.addConstraints([
                NSLayoutConstraint(item: self.resultsViewController.view, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: self.resultsViewController.view, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: self.resultsViewController.view, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: self.resultsViewController.view, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
                ])
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.35, animations: {
                self.resultsViewController.view.alpha = 1.0
            })
        }
    }
    
    
    //MARK: CalculatorViewController delegates
    func calculatorViewController(showResults: CalculationResult) {
        addResultsViewControllerAsAChildViewController(withResults: showResults)
        SoundPlayer.sharedInstance.playBell()
    }
    
    //MARK: ResultsViewController delegates
    func resultsViewControllerDismiss() {
        if self.resultsViewController != nil {
            UIView.animate(withDuration: 0.35, animations: {
                self.resultsViewController.view.alpha = 0.0
            }, completion: { (completed) in
                self.resultsViewController.view.removeFromSuperview()
                self.resultsViewController.removeFromParentViewController()
                self.resultsViewController.delegate = nil
                self.resultsViewController = nil
            })
        }
        if let presentedVC = self.presentedViewController {
            if presentedVC.isKind(of: UIActivityViewController.self) {
                presentedVC.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func resultsViewController(initiateActivityVC activtyVC: UIActivityViewController) {
        self.present(activtyVC, animated: true, completion: nil)
    }
    


}
