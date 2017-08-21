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
    
    @objc optional func progressBar(_ progressBar: FlexibleSteppedProgressBar,
                              willSelectItemAtIndex index: Int)
    
    @objc optional func progressBar(_ progressBar: FlexibleSteppedProgressBar,
                              didSelectItemAtIndex index: Int)
    
    @objc optional func progressBar(_ progressBar: FlexibleSteppedProgressBar,
                              canSelectItemAtIndex index: Int) -> Bool
    
    @objc optional func progressBar(_ progressBar: FlexibleSteppedProgressBar, textAtIndex index: Int, position: FlexibleSteppedProgressBarTextLocation) -> String
    
    @objc optional func progressBar(_ progressBar: FlexibleSteppedProgressBar, selectedTextAtIndex index: Int, position: FlexibleSteppedProgressBarTextLocation) -> UIImage?
    
}

@IBDesignable open class FlexibleSteppedProgressBar: UIView {
    
    //MARK: - Public properties
    
    /// The number of displayed points in the component
    @IBInspectable open var numberOfPoints: Int = 3 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /// The current selected index
    open var currentIndex: Int = 0 {
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
    
    open var completedTillIndex: Int = -1 {
        willSet(newValue){

        }
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    open var currentSelectedCenterColor: UIColor = UIColor.black
    open var currentSelectedTextColor: UIColor!
    open var currentSelectedCenterTextColor: UIColor! = UIColor.black
    open var viewBackgroundColor: UIColor = UIColor.white
    open var selectedOuterCircleStrokeColor: UIColor!
    open var lastStateOuterCircleStrokeColor: UIColor!
    open var lastStateCenterColor: UIColor!
    open var centerLayerTextColor: UIColor!
    open var centerLayerDarkBackgroundTextColor: UIColor = UIColor.white
    
    open var useLastState: Bool = false {
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
    @IBInspectable open var lineHeight: CGFloat = 0.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    open var selectedOuterCircleLineWidth: CGFloat = 3.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    open var lastStateOuterCircleLineWidth: CGFloat = 5.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    open var textDistance: CGFloat = 20.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    fileprivate var _lineHeight: CGFloat {
        get {
            if(lineHeight == 0.0 || lineHeight > self.bounds.height) {
                return self.bounds.height * 0.4
            }
            return lineHeight
        }
    }
    
    /// The point's radius
    @IBInspectable open var radius: CGFloat = 0.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    fileprivate var _radius: CGFloat {
        get{
            if(radius == 0.0 || radius > self.bounds.height / 2.0) {
                return self.bounds.height / 2.0
            }
            return radius
        }
    }
    
    /// The progress points's raduis
    @IBInspectable open var progressRadius: CGFloat = 0.0 {
        didSet {
            maskLayer.cornerRadius = progressRadius
            self.setNeedsDisplay()
        }
    }


    fileprivate var _progressRadius: CGFloat {
        get {
            if(progressRadius == 0.0 || progressRadius > self.bounds.height / 2.0) {
                return self.bounds.height / 2.0
            }
            return progressRadius
        }
    }
    
    /// The progress line height between points
    @IBInspectable open var progressLineHeight: CGFloat = 0.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    fileprivate var _progressLineHeight: CGFloat {
        get {
            if(progressLineHeight == 0.0 || progressLineHeight > _lineHeight) {
                return _lineHeight
            }
            return progressLineHeight
        }
    }
    
    /// The selection animation duration
    @IBInspectable open var stepAnimationDuration: CFTimeInterval = 0.4
    
    /// True if some text should be rendered in the step points. The text value is provided by the delegate
    @IBInspectable open var displayStepText: Bool = true {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /// The text font in the step points
    open var stepTextFont: UIFont? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /// The text color in the step points
    open var stepTextColor: UIColor? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    
    /// The component's background color
    @IBInspectable open var backgroundShapeColor: UIColor = UIColor(red: 238.0/255.0, green: 238.0/255.0, blue: 238.0/255.0, alpha: 0.8) {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /// The component selected background color
    @IBInspectable open var selectedBackgoundColor: UIColor = UIColor(red: 251.0/255.0, green: 167.0/255.0, blue: 51.0/255.0, alpha: 1.0) {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /// The component's delegate
    open weak var delegate: FlexibleSteppedProgressBarDelegate?
    
    
    //MARK: - Private properties
    
    fileprivate var backgroundLayer = CAShapeLayer()
    
    fileprivate var progressLayer = CAShapeLayer()
    
    fileprivate var selectionLayer = CAShapeLayer()
    
    fileprivate var clearSelectionLayer = CAShapeLayer()
    
    fileprivate var clearLastStateLayer = CAShapeLayer()
    
    fileprivate var lastStateLayer = CAShapeLayer()
    
    fileprivate var lastStateCenterLayer = CAShapeLayer()
    
    fileprivate var selectionCenterLayer = CAShapeLayer()
    
    fileprivate var roadToSelectionLayer = CAShapeLayer()
    
    fileprivate var clearCentersLayer = CAShapeLayer()
    
    fileprivate var maskLayer = CAShapeLayer()
    
    fileprivate var centerPoints = [CGPoint]()
    
    fileprivate var _textLayers = [Int:CATextLayer]()
    
    fileprivate var _topTextLayers = [Int:CATextLayer]()
    
    fileprivate var _bottomTextLayers = [Int:CATextLayer]()
    
    fileprivate var previousIndex: Int = 0
    
    fileprivate var animationRendering = false
    
    //MARK: - Life cycle
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
        self.backgroundColor = UIColor.clear
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    convenience init() {
        self.init(frame:CGRect.zero)
    }
    
    func commonInit() {
        if currentSelectedTextColor == nil {
            currentSelectedTextColor = selectedBackgoundColor
        }
        
        if lastStateCenterColor == nil {
            lastStateCenterColor = backgroundShapeColor
        }
        
        if stepTextColor == nil {
            stepTextColor = UIColor.black
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
        
        self.contentMode = UIViewContentMode.redraw
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if !useLastState {
            completedTillIndex = currentIndex
        }
        
        self.centerPoints.removeAll()
        
        let largerRadius = fmax(_radius, _progressRadius)
        
        let distanceBetweenCircles = (self.bounds.width - (CGFloat(numberOfPoints) * 2 * largerRadius)) / CGFloat(numberOfPoints - 1)
        
        var xCursor: CGFloat = largerRadius
        
        for _ in 0...(numberOfPoints - 1) {
            centerPoints.append(CGPoint(x: xCursor, y: bounds.height / 2))
            xCursor += 2 * largerRadius + distanceBetweenCircles
        }
        
        let largerLineWidth = fmax(selectedOuterCircleLineWidth, lastStateOuterCircleLineWidth)
        
        if(!animationRendering) {
            
            let clearCentersPath = self._shapePath(self.centerPoints, aRadius: largerRadius + largerLineWidth, aLineHeight: _lineHeight)
            clearCentersLayer.path = clearCentersPath.cgPath
            clearCentersLayer.fillColor = viewBackgroundColor.cgColor
            
            let bgPath = self._shapePath(self.centerPoints, aRadius: _radius, aLineHeight: _lineHeight)
            backgroundLayer.path = bgPath.cgPath
            backgroundLayer.fillColor = backgroundShapeColor.cgColor
            
            let progressPath = self._shapePath(self.centerPoints, aRadius: _progressRadius, aLineHeight: _progressLineHeight)
            progressLayer.path = progressPath.cgPath
            progressLayer.fillColor = selectedBackgoundColor.cgColor
            
            let clearSelectedRadius = fmax(_progressRadius, _progressRadius + selectedOuterCircleLineWidth)
            let clearSelectedPath = self._shapePathForSelected(self.centerPoints[currentIndex], aRadius: clearSelectedRadius)
            clearSelectionLayer.path = clearSelectedPath.cgPath
            clearSelectionLayer.fillColor = viewBackgroundColor.cgColor
            
            let selectedPath = self._shapePathForSelected(self.centerPoints[currentIndex], aRadius: _radius)
            selectionLayer.path = selectedPath.cgPath
            selectionLayer.fillColor = currentSelectedCenterColor.cgColor

            if !useLastState {
                let selectedPathCenter = self._shapePathForSelectedPathCenter(self.centerPoints[currentIndex], aRadius: _progressRadius)
                selectionCenterLayer.path = selectedPathCenter.cgPath
                selectionCenterLayer.strokeColor = selectedOuterCircleStrokeColor.cgColor
                selectionCenterLayer.fillColor = UIColor.clear.cgColor
                selectionCenterLayer.lineWidth = selectedOuterCircleLineWidth
                selectionCenterLayer.strokeEnd = 1.0
            } else {
                let selectedPathCenter = self._shapePathForSelectedPathCenter(self.centerPoints[currentIndex], aRadius: _progressRadius + selectedOuterCircleLineWidth)
                selectionCenterLayer.path = selectedPathCenter.cgPath
                selectionCenterLayer.strokeColor = selectedOuterCircleStrokeColor.cgColor
                selectionCenterLayer.fillColor = UIColor.clear.cgColor
                selectionCenterLayer.lineWidth = selectedOuterCircleLineWidth
                
                if completedTillIndex >= 0 {
                    
                    let lastStateLayerPath = self._shapePathForLastState(self.centerPoints[completedTillIndex])
                    lastStateLayer.path = lastStateLayerPath.cgPath
                    lastStateLayer.strokeColor = lastStateOuterCircleStrokeColor.cgColor
                    lastStateLayer.fillColor = viewBackgroundColor.cgColor
                    lastStateLayer.lineWidth = lastStateOuterCircleLineWidth
                    
                    let lastStateCenterLayerPath = self._shapePathForSelected(self.centerPoints[completedTillIndex], aRadius: _radius)
                    lastStateCenterLayer.path = lastStateCenterLayerPath.cgPath
                    lastStateCenterLayer.fillColor = lastStateCenterColor.cgColor
                }
                if currentIndex > 0 {
                    let lastPoint = centerPoints[currentIndex-1]
                    let centerCurrent = centerPoints[currentIndex]
                    let xCursor = centerCurrent.x - progressRadius - _radius
                    let routeToSelectedPath = UIBezierPath()
                    
                    routeToSelectedPath.move(to: CGPoint(x: lastPoint.x + progressRadius + selectedOuterCircleLineWidth, y: lastPoint.y))
                    routeToSelectedPath.addLine(to: CGPoint(x: xCursor, y: centerCurrent.y))
                    roadToSelectionLayer.path = routeToSelectedPath.cgPath
                    roadToSelectionLayer.strokeColor = selectedBackgoundColor.cgColor
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
            maskLayer.path = maskPath.cgPath
            
            CATransaction.begin()
            let progressAnimation = CABasicAnimation(keyPath: "path")
            progressAnimation.duration = stepAnimationDuration * CFTimeInterval(abs(completedTillIndex - previousIndex))
            progressAnimation.toValue = maskPath
            progressAnimation.isRemovedOnCompletion = false
            progressAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            
            
            CATransaction.setCompletionBlock { () -> Void in
                if(self.animationRendering) {
                    if let delegate = self.delegate {
                        delegate.progressBar?(self, didSelectItemAtIndex: self.currentIndex)
                    }
                    self.animationRendering = false
                }
            }
            
            maskLayer.add(progressAnimation, forKey: "progressAnimation")
            CATransaction.commit()
        }
        self.previousIndex = self.currentIndex
    }
    
    /**
     Render the text indexes
     */
    fileprivate func renderTextIndexes() {
        
        for i in 0...(numberOfPoints - 1) {
            let centerPoint = centerPoints[i]
            
            let textLayer = self._textLayer(atIndex: i)
            
            let textLayerFont = UIFont.boldSystemFont(ofSize: 15)
            textLayer.contentsScale = UIScreen.main.scale
            
            textLayer.font = CTFontCreateWithName(textLayerFont.fontName as CFString, textLayerFont.pointSize, nil)
            textLayer.fontSize = textLayerFont.pointSize
            
            if i == currentIndex || i == completedTillIndex {
                textLayer.foregroundColor = centerLayerDarkBackgroundTextColor.cgColor
            } else {
                textLayer.foregroundColor = centerLayerTextColor?.cgColor
            }
            
            if let text = self.delegate?.progressBar?(self, textAtIndex: i, position: FlexibleSteppedProgressBarTextLocation.center) {
                textLayer.string = text
            } else {
                textLayer.string = "\(i)"
            }
            
            if let image = self.delegate?.progressBar?(self, selectedTextAtIndex: i, position: .center), i < currentIndex {
                textLayer.contents = image.cgImage
                textLayer.contentsGravity = kCAGravityResizeAspect
            }
            
            textLayer.sizeWidthToFit()
            
            textLayer.frame = CGRect(x: centerPoint.x - textLayer.bounds.width/2, y: centerPoint.y - textLayer.bounds.height/2, width: textLayer.bounds.width, height: textLayer.bounds.height)
        }
    }
    
    /**
     Render the text indexes
     */
    fileprivate func renderTopTextIndexes() {
        
        for i in 0...(numberOfPoints - 1) {
            let centerPoint = centerPoints[i]
            
            let textLayer = self._topTextLayer(atIndex: i)
            
            textLayer.contentsScale = UIScreen.main.scale
            
            
            textLayer.font = stepTextFont
            textLayer.fontSize = (stepTextFont?.pointSize)!
            
            
            if i == currentIndex {
                textLayer.foregroundColor = currentSelectedTextColor.cgColor
            } else {
                textLayer.foregroundColor = stepTextColor!.cgColor
            }
            
            
            if let text = self.delegate?.progressBar?(self, textAtIndex: i, position: FlexibleSteppedProgressBarTextLocation.top) {
                textLayer.string = text
            } else {
                textLayer.string = "\(i)"
            }
            
            if let image = self.delegate?.progressBar?(self, selectedTextAtIndex: i, position: .top), i < currentIndex {
                textLayer.contents = image.cgImage
                textLayer.contentsGravity = kCAGravityResizeAspect
            }
            
            textLayer.sizeWidthToFit()
            
            textLayer.frame = CGRect(x: centerPoint.x - textLayer.bounds.width/2, y: centerPoint.y - textLayer.bounds.height/2 - _progressRadius - textDistance, width: textLayer.bounds.width, height: textLayer.bounds.height)
        }
    }
    
    fileprivate func renderBottomTextIndexes() {
        
        for i in 0...(numberOfPoints - 1) {
            let centerPoint = centerPoints[i]
            
            let textLayer = self._bottomTextLayer(atIndex: i)
            
            textLayer.contentsScale = UIScreen.main.scale
            
            textLayer.font = stepTextFont
            textLayer.fontSize = (stepTextFont?.pointSize)!
            
            if i == currentIndex {
                textLayer.foregroundColor = currentSelectedTextColor.cgColor
            } else {
                textLayer.foregroundColor = stepTextColor!.cgColor
            }
            
            if let text = self.delegate?.progressBar?(self, textAtIndex: i, position: FlexibleSteppedProgressBarTextLocation.bottom) {
                textLayer.string = text
            } else {
                textLayer.string = "\(i)"
            }
            
            if let image = self.delegate?.progressBar?(self, selectedTextAtIndex: i, position: .bottom), i < currentIndex {
                textLayer.contents = image.cgImage
                textLayer.contentsGravity = kCAGravityResizeAspect
            }
            
            textLayer.sizeWidthToFit()
            
            textLayer.frame = CGRect(x: centerPoint.x - textLayer.bounds.width/2, y: centerPoint.y - textLayer.bounds.height/2 + _progressRadius + textDistance, width: textLayer.bounds.width, height: textLayer.bounds.height)
        }
    }
    
    /**
     Provide a text layer for the given index. If it's not in cache, it'll be instanciated.
     
     - parameter index: The index where the layer will be used
     
     - returns: The text layer
     */
    fileprivate func _topTextLayer(atIndex index: Int) -> CATextLayer {
        
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
    fileprivate func _bottomTextLayer(atIndex index: Int) -> CATextLayer {
        
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
    fileprivate func _textLayer(atIndex index: Int) -> CATextLayer {
        
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
    fileprivate func _shapePath(_ centerPoints: Array<CGPoint>, aRadius: CGFloat, aLineHeight: CGFloat) -> UIBezierPath {
        
        let nbPoint = centerPoints.count
        
        let path = UIBezierPath()
        
        var distanceBetweenCircles: CGFloat = 0
        
        if let first = centerPoints.first , nbPoint > 2 {
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
                
                startAngle = CGFloat(Double.pi)
                endAngle = -angle
                
            } else if(i < nbPoint - 1) {
                
                startAngle = CGFloat(Double.pi) + angle
                endAngle = -angle
                
            } else if(i == (nbPoint - 1)){
                
                startAngle = CGFloat(Double.pi) + angle
                endAngle = 0
                
            } else if(i == nbPoint) {
                
                startAngle = 0
                endAngle = CGFloat(Double.pi) - angle
                
            } else if (i < (2 * nbPoint - 1)) {
                
                startAngle = angle
                endAngle = CGFloat(Double.pi) - angle
                
            } else {
                
                startAngle = angle
                endAngle = CGFloat(Double.pi)
                
            }
            
            path.addArc(withCenter: CGPoint(x: centerPoint.x, y: centerPoint.y), radius: aRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            
            if(i < nbPoint - 1) {
                xCursor += aRadius + distanceBetweenCircles
                path.addLine(to: CGPoint(x: xCursor, y: centerPoint.y - aLineHeight / 2.0))
                xCursor += aRadius
            } else if (i < (2 * nbPoint - 1) && i >= nbPoint) {
                xCursor -= aRadius + distanceBetweenCircles
                path.addLine(to: CGPoint(x: xCursor, y: centerPoint.y + aLineHeight / 2.0))
                xCursor -= aRadius
            }
        }
        return path
    }

    fileprivate func _shapePathForSelected(_ centerPoint: CGPoint, aRadius: CGFloat) -> UIBezierPath {
        return UIBezierPath(roundedRect: CGRect(x: centerPoint.x - aRadius, y: centerPoint.y - aRadius, width: 2.0 * aRadius, height: 2.0 * aRadius), cornerRadius: aRadius)
    }
    
    fileprivate func _shapePathForLastState(_ center: CGPoint) -> UIBezierPath {
//        let angle = CGFloat(M_PI)/4
        let path = UIBezierPath()
//        path.addArcWithCenter(center, radius: self._progressRadius + _radius, startAngle: angle, endAngle: 2*CGFloat(M_PI) + CGFloat(M_PI)/4, clockwise: true)
        path.addArc(withCenter: center, radius: self._progressRadius + lastStateOuterCircleLineWidth, startAngle: 0, endAngle: 4*CGFloat(M_PI), clockwise: true)
        return path
    }
    
    fileprivate func _shapePathForSelectedPathCenter(_ centerPoint: CGPoint, aRadius: CGFloat) -> UIBezierPath {
        return UIBezierPath(roundedRect: CGRect(x: centerPoint.x - aRadius, y: centerPoint.y - aRadius, width: 2.0 * aRadius, height: 2.0 * aRadius), cornerRadius: aRadius)
    }

    /**
     Compute the mask path
     
     - parameter currentProgressCenterPoint: The current progress index's center point
     
     - returns: The computed mask path
     */
    fileprivate func _maskPath(_ currentProgressCenterPoint: CGPoint) -> UIBezierPath {
        
        let angle = self._progressLineHeight / 2.0 / self._progressRadius;
        let xOffset = cos(angle) * self._progressRadius
        
        let maskPath = UIBezierPath()
        
        maskPath.move(to: CGPoint(x: 0.0, y: 0.0))
        
        maskPath.addLine(to: CGPoint(x: currentProgressCenterPoint.x + xOffset, y: 0.0))
        
        maskPath.addLine(to: CGPoint(x: currentProgressCenterPoint.x + xOffset, y: currentProgressCenterPoint.y - self._progressLineHeight))
        
        maskPath.addArc(withCenter: currentProgressCenterPoint, radius: self._progressRadius, startAngle: -angle, endAngle: angle, clockwise: true)

        
        maskPath.addLine(to: CGPoint(x: currentProgressCenterPoint.x + xOffset, y: self.bounds.height))
        
        maskPath.addLine(to: CGPoint(x: 0.0, y: self.bounds.height))
        
        
        maskPath.close()
        
        return maskPath
    }
    
    /**
     Respond to the user action
     
     - parameter gestureRecognizer: The gesture recognizer responsible for the action
     */
    func gestureAction(_ gestureRecognizer: UIGestureRecognizer) {
        if(gestureRecognizer.state == UIGestureRecognizerState.ended ||
            gestureRecognizer.state == UIGestureRecognizerState.changed ) {
            
            let touchPoint = gestureRecognizer.location(in: self)
            
            var smallestDistance = CGFloat(Float.infinity)
            
            var selectedIndex = 0
            
            for (index, point) in self.centerPoints.enumerated() {
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
