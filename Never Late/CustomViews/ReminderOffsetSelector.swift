//
//  ReminderOffsetSelector.swift
//  Never Late
//
//  Created by parker amundsen on 4/11/20.
//  Copyright © 2020 Parker Buhler Amundsen. All rights reserved.
//

import Foundation
import UIKit

class ReminderOffsetSelector : UISlider {
    var valueLabel: UILabel = {
        let label = UILabel()
        label.text = "0 min"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public func setUp() {
        self.addTarget(self, action: #selector(selectorPanned), for: .valueChanged)
        self.minimumTrackTintColor = #colorLiteral(red: 0.7450980392, green: 0.7058823529, blue: 0.5647058824, alpha: 1)
        self.thumbTintColor = #colorLiteral(red: 0.7450980392, green: 0.7058823529, blue: 0.5647058824, alpha: 1)
        self.maximumValue = 60
        self.minimumValue = 0
        addSubViews()
        addConstraints()
    }
    
    @objc func selectorPanned() {
        self.valueLabel.text = "\(Int(self.value.rounded())) min"
    }
    
    private func addSubViews() {
        self.addSubview(valueLabel)
    }
    
    private func addConstraints() {
        valueLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        valueLabel.bottomAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
    }
}
