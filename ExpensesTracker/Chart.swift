//
//  Chart.swift
//  ExpensesTracker
//
//  Created by Max Medvedev on 25/12/2016.
//  Copyright © 2016 medvedev. All rights reserved.
//

import UIKit
import QuartzCore

class Chart: UIControl {
    let pieLayer = PieLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)

        pieLayer.chart = self
        pieLayer.backgroundColor = UIColor.blue.cgColor
        layer.addSublayer(pieLayer)

        updateLayerFrames()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func updateLayerFrames() {
        pieLayer.setNeedsDisplay()
    }

    override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }

}


