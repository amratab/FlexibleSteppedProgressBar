//
//  ABTextLayerExtension.swift
//  ABSteppedProgressBar
//
//  Created by Antonin Biret on 24/02/15.
//  Copyright (c) 2015 Antonin Biret. All rights reserved.
//

import UIKit


extension CATextLayer {
    
    func sizeWidthToFit() {
        let fontName = CTFontCopyPostScriptName(self.font as! CTFont) as String
        
        let font = UIFont(name: fontName, size: self.fontSize)
        
        let attributes = NSDictionary(object: font!, forKey: NSFontAttributeName)
        
        let attString = NSAttributedString(string: self.string as! String, attributes: attributes as? [String : AnyObject])
        
        var ascent: CGFloat = 0, descent: CGFloat = 0, width: CGFloat = 0
        
        let line = CTLineCreateWithAttributedString(attString)
        
        width = CGFloat(CTLineGetTypographicBounds( line, &ascent, &descent, nil))

        width = ceil(width)
        
        self.bounds = CGRectMake(0, 0, width, ceil(ascent+descent))
    }
}