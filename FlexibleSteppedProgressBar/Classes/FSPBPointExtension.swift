//
//  ABPointExtension.swift
//  ABSteppedProgressBar
//
//  Created by Antonin Biret on 23/02/15.
//  Copyright (c) 2015 Antonin Biret. All rights reserved.
//

import UIKit


extension CGPoint {
    
    func distanceWith(p: CGPoint) -> CGFloat {
        return sqrt(pow(self.x - p.x, 2) + pow(self.y - p.y, 2))
    }

}