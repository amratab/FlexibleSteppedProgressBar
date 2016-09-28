//
//  ViewController.swift
//  FlexibleSteppedProgressBar
//
//  Created by Amrata Baghel on 09/28/2016.
//  Copyright (c) 2016 Amrata Baghel. All rights reserved.
//

import UIKit
import FlexibleSteppedProgressBar

class ViewController: UIViewController {

    var progressBar: FlexibleSteppedProgressBar!
    var maxIndex = -1
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProgressBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func setupProgressBar() {
        progressBar = FlexibleSteppedProgressBar()
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(progressBar)
        
        // iOS9+ auto layout code
        let horizontalConstraint = progressBar.centerXAnchor.constraintEqualToAnchor(self.view.centerXAnchor)
        let verticalConstraint = progressBar.topAnchor.constraintEqualToAnchor(
            view.topAnchor,
            constant: 80
        )
        let widthConstraint = progressBar.widthAnchor.constraintEqualToAnchor(nil, constant: 800)
        let heightConstraint = progressBar.heightAnchor.constraintEqualToAnchor(nil, constant: 150)
        NSLayoutConstraint.activateConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        
        // Customise the progress bar here
        progressBar.numberOfPoints = 5
        progressBar.lineHeight = 3
        progressBar.radius = 20
        progressBar.progressRadius = 25
        progressBar.progressLineHeight = 3
        progressBar.delegate = self
        progressBar.completedTillIndex = 2
        progressBar.useLastState = true
        progressBar.lastStateCenterColor = UIColor.blueColor()
        
        progressBar.currentIndex = 0
    }
    
    func progressBar(progressBar: FlexibleSteppedProgressBar,
                     didSelectItemAtIndex index: Int) {
        progressBar.currentIndex = index
        if index > maxIndex {
            maxIndex = index
            progressBar.completedTillIndex = maxIndex
        }
    }
    
    func progressBar(progressBar: FlexibleSteppedProgressBar,
                     canSelectItemAtIndex index: Int) -> Bool {
        return true
    }
    
    func progressBar(progressBar: FlexibleSteppedProgressBar,
                     textAtIndex index: Int, position: FlexibleSteppedProgressBarTextLocation) -> String {
        if position == FlexibleSteppedProgressBarTextLocation.TOP {
            switch index {
                
            case 0: return "Choose"
            case 1: return "Click"
            case 2: return "Checkout"
            case 3: return "Buy"
            case 4: return "Pay"
            default: return "Step"
                
            }
        } else if position == FlexibleSteppedProgressBarTextLocation.BOTTOM {
            switch index {
                
            case 0: return "First"
            case 1: return "Second"
            case 2: return "Third"
            case 3: return "Fourth"
            case 4: return "Fifth"
            default: return "Date"
                
            }
            
        } else if position == FlexibleSteppedProgressBarTextLocation.CENTER {
            switch index {
                
            case 0: return "1"
            case 1: return "2"
            case 2: return "3"
            case 3: return "4"
            case 4: return "5"
            default: return "0"
                
            }
        }
        return ""
    }
    

}

