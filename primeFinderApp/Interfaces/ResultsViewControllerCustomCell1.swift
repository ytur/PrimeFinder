//
//  ResultsViewControllerCustomCell1.swift
//  primeFinderApp
//
//  Created by Yasin TURKOGLU on 11.10.2017.
//  Copyright © 2017 Yasin TURKOGLU. All rights reserved.
//

import UIKit

class ResultsViewControllerCustomCell1: UITableViewCell {

    @IBOutlet var mainLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.layoutMargins = .zero
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
