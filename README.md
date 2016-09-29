# FlexibleSteppedProgressBar

[![CI Status](https://travis-ci.org/amratab/FlexibleSteppedProgressBar.svg?branch=master)](https://travis-ci.org/Amrata Baghel/FlexibleSteppedProgressBar)
[![Version](https://img.shields.io/cocoapods/v/FlexibleSteppedProgressBar.svg?style=flat)](http://cocoapods.org/pods/FlexibleSteppedProgressBar)
[![License](https://img.shields.io/cocoapods/l/FlexibleSteppedProgressBar.svg?style=flat)](http://cocoapods.org/pods/FlexibleSteppedProgressBar)
[![Platform](https://img.shields.io/cocoapods/p/FlexibleSteppedProgressBar.svg?style=flat)](http://cocoapods.org/pods/FlexibleSteppedProgressBar)

This is a stepped progress bar for IOS. The base code is derived from [ABSteppedProgressBar](https://github.com/antoninbiret/ABSteppedProgressBar). Most of the design is customisable. Text can be positioned inside the circles or on top or bottom of them or if the user wants, at all the three places. Please refer to usage section for more details.

![alt tag](https://github.com/amratab/FlexibleSteppedProgressBar/blob/master/FlexibleGreenThemeDemo.gif)
![alt tag](https://github.com/amratab/FlexibleSteppedProgressBar/blob/master/FlexibleYelloThemeBarDemo.gif)


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

FlexibleSteppedProgressBar is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "FlexibleSteppedProgressBar"
```
## Usage
I made some modifications upon ABSteppedProgressBar because I had an extra state to cater to, Last State. It specifies the last indice user has covered on the progress bar. For example, my use case was to specify properties of a product in a particular oder through progress bar lets say there were Step 1, Step 2 to Step 5. So, if the user has completed till step 3, and he goes back to step 1 to make some modification, progres bar should indicate separately the step 3 as last state and step 1 as selected state. It is completely optional here. If you want to use last state, you can simply state your wish through useLastState parameter and specify completedTillIndex as the last state. Progress bar does not keep track of the last state. 

    There are four states for a progress point:
    1. Unselected and unvisited
    2. Unselected and visited
    3. Currently selected: These will have two concentric circles whose colors can be specified through 
        a) currentSelectedCenterColor: for inner circle fill color
        b) selectedOuterCircleStrokeColor: outer circle stroke color
        c) selectedOuterCircleLineWidth: outer circle line width
    4. Last state: Use of this state is up on the discretion of the implementation. It is by default false and can be changed through useLastState. If present, it will also have two concentric circles whose colors can be modified through:
        a) lastStateCenterColor: for inner circle fill color
        b) lastStateOuterCircleStrokeColor: for outer circle stroke color
        c) lastStateOuterCircleLineWidth: for outer circle line width

    Some general customisation options: 
    a) radius: Radius of circles for unvisited indices.
    b) progressRadius: Radius of circles for visited indices.
    c) lineHeight: Line height of the outer line for complete progress bar.
    d) progressLineHeight: Line height for the inner line with the selected background color that is shown only for the visited indices.
    e) numberOfPoints: It is the number of indices on the progress bar.
    f) stepAnimationDuration: Duration of animation
    g) backgroundShapeColor: This is the color for unselected and unvisited indices.
    h) selectedBackgoundColor: This is the color for unselected but visited indices.
    i) currentIndex: It is the current selected index. Value: 0 to (number of points - 1)
    j) completedTillIndex: It is the last state index. Value: 0 to (number of points - 1)

    CAUTION: If your background view is of any other color than white, please specify it in viewBackgroundColor. Otherwise you will keep seeing white color in between.

    Second reason for this library was text location. I needed flexible position for text. So, here I am providing three locations. 
    a) TOP
    b) CENTER
    c) BOTTOM

    You can specify the text you want to show through delegate method textAtIndex. For customising how text is displayed, specify the following values:
    a) currentSelectedTextColor: This is the text color for the current selected index for top and bottom positions.
    b) centerLayerTextColor: This is the text color for the the indices when it is neither selected nor last state only for center position.
    c) centerLayerDarkBackgroundTextColor: This is the text color for center position when it is either selected or last state.
    d) stepTextColor: This is the text color in the top or bottom positions for all but selected indices.
    e) stepTextFont: This is the font for all the positions and indices.
    
    Also, other customisation options are available through delegate methods.
    
## Author

Amrata Baghel, amrata.baghel@gmail.com

## License

FlexibleSteppedProgressBar is available under the MIT license. See the LICENSE file for more info.
