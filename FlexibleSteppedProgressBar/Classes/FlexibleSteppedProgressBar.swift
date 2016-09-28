//
//  ABSteppedProgressBar.swift
//  ABSteppedProgressBar
//
//  Created by Antonin Biret on 17/02/15.
//  Copyright (c) 2015 Antonin Biret. All rights reserved.
//

import UIKit
import Foundation
import CoreGraphics

@objc public protocol FlexibleSteppedProgressBarDelegate {
    
    optional func progressBar(progressBar: FlexibleSteppedProgressBar,
                              willSelectItemAtIndex index: Int)
    
    optional func progressBar(progressBar: FlexibleSteppedProgressBar,
                              didSelectItemAtIndex index: Int)
    
    optional func progressBar(progressBar: FlexibleSteppedProgressBar,
                              canSelectItemAtIndex index: Int) -> Bool
    
    optional func progressBar(progressBar: FlexibleSteppedProgressBar,
                              textAtIndex index: Int, position: FlexibleSteppedProgressBarTextLocation) -> String
    
}

@IBDesignable public class FlexibleSteppedProgressBar: UIView {
    
    //MARK: - Public properties
    
    /// The number of displayed points in the component
    @IBInspectable public var numberOfPoints: Int = 3 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /// The current selected index
    public var currentIndex: Int = 0 {
        willSet(newValue){
            if let delegate = self.delegate {
                delegate.progressBar?(self, willSelectItemAtIndex: newValue)
            }
        }
        didSet {
//            animationRendering = true
            self.setNeedsDisplay()
        }
    }
    
    public var completedTillIndex: Int = -1 {
        willSet(newValue){

        }
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public var currentSelectedCenterColor: UIColor = UIColor.blackColor()
    public var currentSelectedTextColor: UIColor!
    public var viewBackgroundColor: UIColor = UIColor.whiteColor()
    public var selectedOuterCircleStrokeColor: UIColor!
    public var lastStateOuterCircleStrokeColor: UIColor!
    public var lastStateCenterColor: UIColor!
    public var centerLayerTextColor: UIColor!
    public var centerLayerDarkBackgroundTextColor: UIColor = UIColor.whiteColor()
    
    public var useLastState: Bool = false {
        didSet {
            if useLastState {
                self.layer.addSublayer(self.clearLastStateLayer)
                self.layer.addSublayer(self.lastStateLayer)
                self.layer.addSublayer(self.lastStateCenterLayer)
            }
            self.setNeedsDisplay()
        }
    }
    
    /// The line height between points
    @IBInspectable public var lineHeight: CGFloat = 0.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public var selectedOuterCircleLineWidth: CGFloat = 3.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public var lastStateOuterCircleLineWidth: CGFloat = 5.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public var textDistance: CGFloat = 20.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    private var _lineHeight: CGFloat {
        get {
            if(lineHeight == 0.0 || lineHeight > self.bounds.height) {
                return self.bounds.height * 0.4
            }
            return lineHeight
        }
    }
    
    /// The point's radius
    @IBInspectable public var radius: CGFloat = 0.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    private var _radius: CGFloat {
        get{
            if(radius == 0.0 || radius > self.bounds.height / 2.0) {
                return self.bounds.height / 2.0
            }
            return radius
        }
    }
    
    /// The progress points's raduis
    @IBInspectable public var progressRadius: CGFloat = 0.0 {
        didSet {
            maskLayer.cornerRadius = progressRadius
            self.setNeedsDisplay()
        }
    }


    private var _progressRadius: CGFloat {
        get {
            if(progressRadius == 0.0 || progressRadius > self.bounds.height / 2.0) {
                return self.bounds.height / 2.0
            }
            return progressRadius
        }
    }
    
    /// The progress line height between points
    @IBInspectable public var progressLineHeight: CGFloat = 0.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    private var _progressLineHeight: CGFloat {
        get {
            if(progressLineHeight == 0.0 || progressLineHeight > _lineHeight) {
                return _lineHeight
            }
            return progressLineHeight
        }
    }
    
    /// The selection animation duration
    @IBInspectable public var stepAnimationDuration: CFTimeInterval = 0.4
    
    /// True if some text should be rendered in the step points. The text value is provided by the delegate
    @IBInspectable public var displayStepText: Bool = true {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /// The text font in the step points
    public var stepTextFont: UIFont? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /// The text color in the step points
    public var stepTextColor: UIColor? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    
    /// The component's background color
    @IBInspectable public var backgroundShapeColor: UIColor = UIColor(red: 238.0/255.0, green: 238.0/255.0, blue: 238.0/255.0, alpha: 0.8) {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /// The component selected background color
    @IBInspectable public var selectedBackgoundColor: UIColor = UIColor(red: 251.0/255.0, green: 167.0/255.0, blue: 51.0/255.0, alpha: 1.0) {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /// The component's delegate
    public weak var delegate: FlexibleSteppedProgressBarDelegate?
    
    
    //MARK: - Private properties
    
    private var backgroundLayer = CAShapeLayer()
    
    private var progressLayer = CAShapeLayer()
    
    private var selectionLayer = CAShapeLayer()
    
    private var clearSelectionLayer = CAShapeLayer()
    
    private var clearLastStateLayer = CAShapeLayer()
    
    private var lastStateLayer = CAShapeLayer()
    
    private var lastStateCenterLayer = CAShapeLayer()
    
    private var selectionCenterLayer = CAShapeLayer()
    
    private var roadToSelectionLayer = CAShapeLayer()
    
    private var clearCentersLayer = CAShapeLayer()
    
    private var maskLayer = CAShapeLayer()
    
    private var centerPoints = [CGPoint]()
    
    private var _textLayers = [Int:CATextLayer]()
    
    private var _topTextLayers = [Int:CATextLayer]()
    
    private var _bottomTextLayers = [Int:CATextLayer]()
    
    private var previousIndex: Int = 0
    
    private var animationRendering = false
    
    //MARK: - Life cycle
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
        self.backgroundColor = UIColor.clearColor()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    convenience init() {
        self.init(frame:CGRectZero)
    }
    
    func commonInit() {
        if currentSelectedTextColor == nil {
            currentSelectedTextColor = selectedBackgoundColor
        }
        
        if lastStateCenterColor == nil {
            lastStateCenterColor = backgroundShapeColor
        }
        
        if stepTextColor == nil {
            stepTextColor = UIColor.blackColor()
        }
        
        if selectedOuterCircleStrokeColor == nil {
            selectedOuterCircleStrokeColor = selectedBackgoundColor
        }
        
        if lastStateOuterCircleStrokeColor == nil {
            lastStateOuterCircleStrokeColor = selectedBackgoundColor
        }
        
        if stepTextFont == nil {
            stepTextFont = UIFont(name: "HelveticaNeue-Medium", size: 14.0)
        }
        
        if centerLayerTextColor == nil {
            centerLayerTextColor = stepTextColor
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FlexibleSteppedProgressBar.gestureAction(_:)))
        let swipeGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(FlexibleSteppedProgressBar.gestureAction(_:)))
        self.addGestureRecognizer(tapGestureRecognizer)
        self.addGestureRecognizer(swipeGestureRecognizer)
        
        self.layer.addSublayer(self.clearCentersLayer)

        self.layer.addSublayer(self.backgroundLayer)
        self.layer.addSublayer(self.progressLayer)
        self.layer.addSublayer(self.clearSelectionLayer)
        self.layer.addSublayer(self.selectionCenterLayer)
        self.layer.addSublayer(self.selectionLayer)

        self.layer.addSublayer(self.roadToSelectionLayer)
        self.progressLayer.mask = self.maskLayer
        
        self.contentMode = UIViewContentMode.Redraw
    }
    
    override public func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        if !useLastState {
            completedTillIndex = currentIndex
        }
        
        self.centerPoints.removeAll()
        
        let largerRadius = fmax(_radius, _progressRadius)
        
        let distanceBetweenCircles = (self.bounds.width - (CGFloat(numberOfPoints) * 2 * largerRadius)) / CGFloat(numberOfPoints - 1)
        
        var xCursor: CGFloat = largerRadius
        
        for _ in 0...(numberOfPoints - 1) {
            centerPoints.append(CGPointMake(xCursor, bounds.height / 2))
            xCursor += 2 * largerRadius + distanceBetweenCircles
        }
        
        let largerLineWidth = fmax(selectedOuterCircleLineWidth, lastStateOuterCircleLineWidth)
        
        if(!animationRendering) {
            
            let clearCentersPath = self._shapePath(self.centerPoints, aRadius: largerRadius + largerLineWidth, aLineHeight: _lineHeight)
            clearCentersLayer.path = clearCentersPath.CGPath
            clearCentersLayer.fillColor = viewBackgroundColor.CGColor
            
            let bgPath = self._shapePath(self.centerPoints, aRadius: _radius, aLineHeight: _lineHeight)
            backgroundLayer.path = bgPath.CGPath
            backgroundLayer.fillColor = backgroundShapeColor.CGColor
            
            let progressPath = self._shapePath(self.centerPoints, aRadius: _progressRadius, aLineHeight: _progressLineHeight)
            progressLayer.path = progressPath.CGPath
            progressLayer.fillColor = selectedBackgoundColor.CGColor
            
            let clearSelectedRadius = fmax(_progressRadius, _progressRadius + selectedOuterCircleLineWidth)
            let clearSelectedPath = self._shapePathForSelected(self.centerPoints[currentIndex], aRadius: clearSelectedRadius)
            clearSelectionLayer.path = clearSelectedPath.CGPath
            clearSelectionLayer.fillColor = viewBackgroundColor.CGColor
            
            let selectedPath = self._shapePathForSelected(self.centerPoints[currentIndex], aRadius: _radius)
            selectionLayer.path = selectedPath.CGPath
            selectionLayer.fillColor = currentSelectedCenterColor.CGColor

            if !useLastState {
                let selectedPathCenter = self._shapePathForSelectedPathCenter(self.centerPoints[currentIndex], aRadius: _progressRadius)
                selectionCenterLayer.path = selectedPathCenter.CGPath
                selectionCenterLayer.strokeColor = selectedOuterCircleStrokeColor.CGColor
                selectionCenterLayer.fillColor = UIColor.clearColor().CGColor
                selectionCenterLayer.lineWidth = selectedOuterCircleLineWidth
                selectionCenterLayer.strokeEnd = 1.0
            } else {
                let selectedPathCenter = self._shapePathForSelectedPathCenter(self.centerPoints[currentIndex], aRadius: _progressRadius + selectedOuterCircleLineWidth)
                selectionCenterLayer.path = selectedPathCenter.CGPath
                selectionCenterLayer.strokeColor = selectedOuterCircleStrokeColor.CGColor
                selectionCenterLayer.fillColor = UIColor.clearColor().CGColor
                selectionCenterLayer.lineWidth = selectedOuterCircleLineWidth
                
                if completedTillIndex >= 0 {
                    
                    let lastStateLayerPath = self._shapePathForLastState(self.centerPoints[completedTillIndex])
                    lastStateLayer.path = lastStateLayerPath.CGPath
                    lastStateLayer.strokeColor = lastStateOuterCircleStrokeColor.CGColor
                    lastStateLayer.fillColor = viewBackgroundColor.CGColor
                    lastStateLayer.lineWidth = lastStateOuterCircleLineWidth
                    
                    let lastStateCenterLayerPath = self._shapePathForSelected(self.centerPoints[completedTillIndex], aRadius: _radius)
                    lastStateCenterLayer.path = lastStateCenterLayerPath.CGPath
                    lastStateCenterLayer.fillColor = lastStateCenterColor.CGColor
                }
                if currentIndex > 0 {
                    let lastPoint = centerPoints[currentIndex-1]
                    let centerCurrent = centerPoints[currentIndex]
                    let xCursor = centerCurrent.x - progressRadius - _radius
                    let routeToSelectedPath = UIBezierPath()
                    
                    routeToSelectedPath.moveToPoint(CGPointMake(lastPoint.x + progressRadius + selectedOuterCircleLineWidth, lastPoint.y))
                    routeToSelectedPath.addLineToPoint(CGPointMake(xCursor, centerCurrent.y))
                    roadToSelectionLayer.path = routeToSelectedPath.CGPath
                    roadToSelectionLayer.strokeColor = selectedBackgoundColor.CGColor
                    roadToSelectionLayer.lineWidth = progressLineHeight
                }

            }
        }
        self.renderTopTextIndexes()
        self.renderBottomTextIndexes()
        self.renderTextIndexes()
        
        let progressCenterPoints = Array<CGPoint>(centerPoints[0..<(completedTillIndex+1)])
        
        if let currentProgressCenterPoint = progressCenterPoints.last {
            
            let maskPath = self._maskPath(currentProgressCenterPoint)
            maskLayer.path = maskPath.CGPath
            
            CATransaction.begin()
            let progressAnimation = CABasicAnimation(keyPath: "path")
            progressAnimation.duration = stepAnimationDuration * CFTimeInterval(abs(completedTillIndex - previousIndex))
            progressAnimation.toValue = maskPath
            progressAnimation.removedOnCompletion = false
            progressAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            
            
            CATransaction.setCompletionBlock { () -> Void in
                if(self.animationRendering) {
                    if let delegate = self.delegate {
                        delegate.progressBar?(self, didSelectItemAtIndex: self.currentIndex)
                    }
                    self.animationRendering = false
                }
            }
            
            maskLayer.addAnimation(progressAnimation, forKey: "progressAnimation")
            CATransaction.commit()
        }
        self.previousIndex = self.currentIndex
    }
    
    /**
     Render the text indexes
     */
    private func renderTextIndexes() {
        
        for i in 0...(numberOfPoints - 1) {
            let centerPoint = centerPoints[i]
            
            let textLayer = self._textLayer(atIndex: i)
            
            let textLayerFont = UIFont.boldSystemFontOfSize(15)
            textLayer.contentsScale = UIScreen.mainScreen().scale
            
            textLayer.font = CTFontCreateWithName(textLayerFont.fontName as CFStringRef, textLayerFont.pointSize, nil)
            textLayer.fontSize = textLayerFont.pointSize
            
            if i == currentIndex || i == completedTillIndex {
                textLayer.foregroundColor = centerLayerDarkBackgroundTextColor.CGColor
            } else {
                textLayer.foregroundColor = centerLayerTextColor?.CGColor
            }
            
            if let text = self.delegate?.progressBar?(self, textAtIndex: i, position: FlexibleSteppedProgressBarTextLocation.CENTER) {
                textLayer.string = text
            } else {
                textLayer.string = "\(i)"
            }
            
            textLayer.sizeWidthToFit()
            
            textLayer.frame = CGRectMake(centerPoint.x - textLayer.bounds.width/2, centerPoint.y - textLayer.bounds.height/2, textLayer.bounds.width, textLayer.bounds.height)
        }
    }
    
    /**
     Render the text indexes
     */
    private func renderTopTextIndexes() {
        
        for i in 0...(numberOfPoints - 1) {
            let centerPoint = centerPoints[i]
            
            let textLayer = self._topTextLayer(atIndex: i)
            
            textLayer.contentsScale = UIScreen.mainScreen().scale
            
            
            textLayer.font = stepTextFont
            textLayer.fontSize = (stepTextFont?.pointSize)!
            
            
            if i == currentIndex {
                textLayer.foregroundColor = currentSelectedTextColor.CGColor
            } else {
                textLayer.foregroundColor = stepTextColor!.CGColor
            }
            
            
            if let text = self.delegate?.progressBar?(self, textAtIndex: i, position: FlexibleSteppedProgressBarTextLocation.TOP) {
                textLayer.string = text
            } else {
                textLayer.string = "\(i)"
            }
            
            textLayer.sizeWidthToFit()
            
            textLayer.frame = CGRectMake(centerPoint.x - textLayer.bounds.width/2, centerPoint.y - textLayer.bounds.height/2 - _progressRadius - textDistance, textLayer.bounds.width, textLayer.bounds.height)
        }
    }
    
    private func renderBottomTextIndexes() {
        
        for i in 0...(numberOfPoints - 1) {
            let centerPoint = centerPoints[i]
            
            let textLayer = self._bottomTextLayer(atIndex: i)
            
            textLayer.contentsScale = UIScreen.mainScreen().scale
            
            textLayer.font = stepTextFont
            textLayer.fontSize = (stepTextFont?.pointSize)!
            
            if i == currentIndex {
                textLayer.foregroundColor = currentSelectedTextColor.CGColor
            } else {
                textLayer.foregroundColor = stepTextColor!.CGColor
            }
            
            if let text = self.delegate?.progressBar?(self, textAtIndex: i, position: FlexibleSteppedProgressBarTextLocation.BOTTOM) {
                textLayer.string = text
            } else {
                textLayer.string = "\(i)"
            }
            
            textLayer.sizeWidthToFit()
            
            textLayer.frame = CGRectMake(centerPoint.x - textLayer.bounds.width/2, centerPoint.y - textLayer.bounds.height/2 + _progressRadius + textDistance, textLayer.bounds.width, textLayer.bounds.height)
        }
    }
    
    /**
     Provide a text layer for the given index. If it's not in cache, it'll be instanciated.
     
     - parameter index: The index where the layer will be used
     
     - returns: The text layer
     */
    private func _topTextLayer(atIndex index: Int) -> CATextLayer {
        
        var textLayer: CATextLayer
        if let _textLayer = self._topTextLayers[index] {
            textLayer = _textLayer
        } else {
            textLayer = CATextLayer()
            self._topTextLayers[index] = textLayer
        }
        self.layer.addSublayer(textLayer)
        
        return textLayer
    }
    
    /**
     Provide a text layer for the given index. If it's not in cache, it'll be instanciated.
     
     - parameter index: The index where the layer will be used
     
     - returns: The text layer
     */
    private func _bottomTextLayer(atIndex index: Int) -> CATextLayer {
        
        var textLayer: CATextLayer
        if let _textLayer = self._bottomTextLayers[index] {
            textLayer = _textLayer
        } else {
            textLayer = CATextLayer()
            self._bottomTextLayers[index] = textLayer
        }
        self.layer.addSublayer(textLayer)
        
        return textLayer
    }
    
    /**
     Provide a text layer for the given index. If it's not in cache, it'll be instanciated.
     
     - parameter index: The index where the layer will be used
     
     - returns: The text layer
     */
    private func _textLayer(atIndex index: Int) -> CATextLayer {
        
        var textLayer: CATextLayer
        if let _textLayer = self._textLayers[index] {
            textLayer = _textLayer
        } else {
            textLayer = CATextLayer()
            self._textLayers[index] = textLayer
        }
        self.layer.addSublayer(textLayer)
        
        return textLayer
    }
    
    /**
     Compte a progress path
     
     - parameter centerPoints: The center points corresponding to the indexes
     - parameter aRadius:      The index radius
     - parameter aLineHeight:  The line height between each index
     
     - returns: The computed path
     */
    private func _shapePath(centerPoints: Array<CGPoint>, aRadius: CGFloat, aLineHeight: CGFloat) -> UIBezierPath {
        
        let nbPoint = centerPoints.count
        
        let path = UIBezierPath()
        
        var distanceBetweenCircles: CGFloat = 0
        
        if let first = centerPoints.first where nbPoint > 2 {
            let second = centerPoints[1]
            distanceBetweenCircles = second.x - first.x - 2 * aRadius
        }
        
        let angle = aLineHeight / 2.0 / aRadius;
        
        var xCursor: CGFloat = 0
        
        
        for i in 0...(2 * nbPoint - 1) {
            
            var index = i
            if(index >= nbPoint) {
                index = (nbPoint - 1) - (i - nbPoint)
            }
            
            let centerPoint = centerPoints[index]
            
            var startAngle: CGFloat = 0
            var endAngle: CGFloat = 0
            
            if(i == 0) {
                
                xCursor = centerPoint.x
                
                startAngle = CGFloat(M_PI)
                endAngle = -angle
                
            } else if(i < nbPoint - 1) {
                
                startAngle = CGFloat(M_PI) + angle
                endAngle = -angle
                
            } else if(i == (nbPoint - 1)){
                
                startAngle = CGFloat(M_PI) + angle
                endAngle = 0
                
            } else if(i == nbPoint) {
                
                startAngle = 0
                endAngle = CGFloat(M_PI) - angle
                
            } else if (i < (2 * nbPoint - 1)) {
                
                startAngle = angle
                endAngle = CGFloat(M_PI) - angle
                
            } else {
                
                startAngle = angle
                endAngle = CGFloat(M_PI)
                
            }
            
            path.addArcWithCenter(CGPointMake(centerPoint.x, centerPoint.y), radius: aRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            
            if(i < nbPoint - 1) {
                xCursor += aRadius + distanceBetweenCircles
                path.addLineToPoint(CGPointMake(xCursor, centerPoint.y - aLineHeight / 2.0))
                xCursor += aRadius
            } else if (i < (2 * nbPoint - 1) && i >= nbPoint) {
                xCursor -= aRadius + distanceBetweenCircles
                path.addLineToPoint(CGPointMake(xCursor, centerPoint.y + aLineHeight / 2.0))
                xCursor -= aRadius
            }
        }
        return path
    }

    private func _shapePathForSelected(centerPoint: CGPoint, aRadius: CGFloat) -> UIBezierPath {
        return UIBezierPath(roundedRect: CGRectMake(centerPoint.x - aRadius, centerPoint.y - aRadius, 2.0 * aRadius, 2.0 * aRadius), cornerRadius: aRadius)
    }
    
    private func _shapePathForLastState(center: CGPoint) -> UIBezierPath {
//        let angle = CGFloat(M_PI)/4
        let path = UIBezierPath()
//        path.addArcWithCenter(center, radius: self._progressRadius + _radius, startAngle: angle, endAngle: 2*CGFloat(M_PI) + CGFloat(M_PI)/4, clockwise: true)
        path.addArcWithCenter(center, radius: self._progressRadius + lastStateOuterCircleLineWidth, startAngle: 0, endAngle: 4*CGFloat(M_PI), clockwise: true)
        return path
    }
    
    private func _shapePathForSelectedPathCenter(centerPoint: CGPoint, aRadius: CGFloat) -> UIBezierPath {
        return UIBezierPath(roundedRect: CGRectMake(centerPoint.x - aRadius, centerPoint.y - aRadius, 2.0 * aRadius, 2.0 * aRadius), cornerRadius: aRadius)
    }

    /**
     Compute the mask path
     
     - parameter currentProgressCenterPoint: The current progress index's center point
     
     - returns: The computed mask path
     */
    private func _maskPath(currentProgressCenterPoint: CGPoint) -> UIBezierPath {
        
        let angle = self._progressLineHeight / 2.0 / self._progressRadius;
        let xOffset = cos(angle) * self._progressRadius
        
        let maskPath = UIBezierPath()
        
        maskPath.moveToPoint(CGPointMake(0.0, 0.0))
        
        maskPath.addLineToPoint(CGPointMake(currentProgressCenterPoint.x + xOffset, 0.0))
        
        maskPath.addLineToPoint(CGPointMake(currentProgressCenterPoint.x + xOffset, currentProgressCenterPoint.y - self._progressLineHeight))
        
        maskPath.addArcWithCenter(currentProgressCenterPoint, radius: self._progressRadius, startAngle: -angle, endAngle: angle, clockwise: true)

        
        maskPath.addLineToPoint(CGPointMake(currentProgressCenterPoint.x + xOffset, self.bounds.height))
        
        maskPath.addLineToPoint(CGPointMake(0.0, self.bounds.height))
        
        
        maskPath.closePath()
        
        return maskPath
    }
    
    /**
     Respond to the user action
     
     - parameter gestureRecognizer: The gesture recognizer responsible for the action
     */
    func gestureAction(gestureRecognizer: UIGestureRecognizer) {
        if(gestureRecognizer.state == UIGestureRecognizerState.Ended ||
            gestureRecognizer.state == UIGestureRecognizerState.Changed ) {
            
            let touchPoint = gestureRecognizer.locationInView(self)
            
            var smallestDistance = CGFloat(Float.infinity)
            
            var selectedIndex = 0
            
            for (index, point) in self.centerPoints.enumerate() {
                let distance = touchPoint.distanceWith(point)
                if(distance < smallestDistance) {
                    smallestDistance = distance
                    selectedIndex = index
                }
            }
            
            
            
            if(self.currentIndex != selectedIndex) {
                if let canSelect = self.delegate?.progressBar?(self, canSelectItemAtIndex: selectedIndex) {
                    if (canSelect) {
                        if (selectedIndex > completedTillIndex) {
                            completedTillIndex = selectedIndex
                        }
                        self.currentIndex = selectedIndex
                        self.animationRendering = true
                    }
                }
            }
        }
    }
    
}
