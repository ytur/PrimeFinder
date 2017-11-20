//
//  ResultsViewController.swift
//  primeFinderApp
//
//  Created by Yasin TURKOGLU on 11.10.2017.
//  Copyright © 2017 Yasin TURKOGLU. All rights reserved.
//

import UIKit

protocol ResultsViewControllerDelegate:class {
    func resultsViewControllerDismiss()
    func resultsViewController(initiateActivityVC activtyVC: UIActivityViewController)
}

class ResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    weak var delegate:ResultsViewControllerDelegate!
    @IBOutlet var tableView: UITableView!    
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var copyToClipBoardDialog: CopyToClipBoardDialog!
    
    var calculationResults:CalculationResult!
    var calculatedValues = [UInt64]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorInset = .zero
        self.tableView.separatorStyle = .singleLine
        self.tableView.separatorColor = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let calcRes = self.calculationResults {
            if let navBarTopItem = self.navigationBar.topItem {
                self.calculatedValues = calcRes.calculatedValues
                self.calculatedValues.insert(calcRes.startValue, at: 0)
                var titleText:String = ""
                if calcRes.processType == .PPTFindNext {
                    titleText = "Next"
                } else if calcRes.processType == .PPTFindPrev {
                    titleText = "Previous"
                }
                titleText += " \(calcRes.calculatedValues.count) primes"
                navBarTopItem.title = titleText
            }
            self.tableView.reloadData()
        }
    }

    @IBAction func dismissAction(_ sender: UIBarButtonItem) {
        self.delegate.resultsViewControllerDismiss()        
    }
    
    @IBAction func shareAction(_ sender: UIBarButtonItem) {
        if let calcRes = self.calculationResults {
            var sharingString:String = "Start value is \(calcRes.startValue)\n"
            if calcRes.isStartValuePrime {
                sharingString += "and it's a prime number.\n\n"
            } else {
                sharingString += "and it's not a prime number.\n\n"
            }
            if calcRes.processType == .PPTFindNext {
                sharingString += "Next"
            } else if calcRes.processType == .PPTFindPrev {
                sharingString += "Previous"
            }
            sharingString += " \(calcRes.calculatedValues.count) prime numbers are listed bellow.\n\n"
            for (i, prime) in calcRes.calculatedValues.enumerated() {
                sharingString += "\(i + 1)) \(prime)\n"
            }
            sharingString += "\nCreated by Prime Finder Application\n"
            let activtyVC = UIActivityViewController(activityItems: [sharingString], applicationActivities: nil)
            activtyVC.setValue("Prime numbers", forKey: "subject")
            activtyVC.excludedActivityTypes = [
            UIActivityType.saveToCameraRoll,
            UIActivityType.assignToContact,
            UIActivityType.addToReadingList,
            UIActivityType.openInIBooks,
            UIActivityType.postToFlickr,
            UIActivityType.postToTencentWeibo,
            UIActivityType.postToVimeo,
            UIActivityType.postToWeibo
            ]
            activtyVC.modalPresentationStyle = .popover
            activtyVC.popoverPresentationController?.barButtonItem = sender
            self.delegate.resultsViewController(initiateActivityVC: activtyVC)
            
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.calculatedValues.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row > 0 {
            let calculatedValue = "\(self.calculatedValues[indexPath.row])"
            if self.copyToClipBoardDialog != nil {
                self.copyToClipBoardDialog.initiateDialogWith(string: calculatedValue)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell!
        var calculatedValue = "\(self.calculatedValues[indexPath.row])"
        calculatedValue.applyDecimal(seperator: "'")
        if indexPath.row == 0 {
            if let calcRes = self.calculationResults {
                let cell1 = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as? ResultsViewControllerCustomCell1
                var startNumberCellDetailLabelText:String = "Start value"
                if calcRes.isStartValuePrime {
                    startNumberCellDetailLabelText += " is a prime number"
                    cell1?.backgroundColor = UIColor(red: 12.0/255.0, green: 163.0/255.0, blue: 30.0/255.0, alpha: 1)
                } else {
                    startNumberCellDetailLabelText += " is not a prime number"
                    cell1?.backgroundColor = UIColor(red: 171.0/255.0, green: 20.0/255.0, blue: 9.0/255.0, alpha: 1)
                }
                cell1?.mainLabel?.text = calculatedValue
                cell1?.detailLabel?.text = startNumberCellDetailLabelText
                cell = cell1
            }
        } else {
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as? ResultsViewControllerCustomCell2
            cell2?.orderLabel?.text = "\(indexPath.row))"
            cell2?.valueLabel?.text = calculatedValue
            cell = cell2
        }
        return cell
    }
    
}
