//  Converted to Swift 5.1 by Swiftify v5.1.31847 - https://swiftify.com/
//
//  ASValueTrackingSlider.swift
//  ValueTrackingSlider
//
//  Created by Alan Skipp on 19/10/2013.
//  Copyright (c) 2013 Alan Skipp. All rights reserved.
//

import UIKit

class ASValueTrackingSlider: UISlider, ASValuePopUpViewDelegate {
       // supply entirely customized strings for slider values using the datasource protocol - see below
       weak var dataSource: ASValueTrackingSliderDataSource?
       // delegate is only needed when used with a TableView or CollectionView - see below
       weak var delegate: ASValueTrackingSliderDelegate?
       private var popUpView: ASValuePopUpView?
       private var popUpViewAlwaysOn = false
    // default is NO
    private var keyTimes: [AnyHashable]?
    private var valueRange: CGFloat = 0.0

    // present the popUpView manually, without touch event.
    func showPopUpView(animated: Bool) {
        popUpViewAlwaysOn = true
        _showPopUpView(animated: animated)
    }

    // the popUpView will not hide again until you call 'hidePopUpViewAnimated:'
    func hidePopUpView(animated: Bool) {
        popUpViewAlwaysOn = false
        _hidePopUpView(animated: animated)
    }


    private var _textColor: UIColor?
    var textColor: UIColor? {
        get {
            _textColor
        }
        set(color) {
            _textColor = color
            popUpView?.setTextColor(color)
        }
    }
    // font can not be nil, it must be a valid UIFont
    // default is ‘boldSystemFontOfSize:22.0’

    private var _font: UIFont?
    var font: UIFont? {
        get {
            _font
        }
        set(font) {
            assert(font != nil, "font can not be nil, it must be a valid UIFont")
            _font = font
            popUpView?.setFont(font)
        }
    }
    // setting the value of 'popUpViewColor' overrides 'popUpViewAnimatedColors' and vice versa
    // the return value of 'popUpViewColor' is the currently displayed value
    // this will vary if 'popUpViewAnimatedColors' is set (see below)

    private var _popUpViewColor: UIColor?
    var popUpViewColor: UIColor? {
        get {
            return popUpView?.color() ?? _popUpViewColor
        }
        set(color) {
            _popUpViewColor = color
            _popUpViewAnimatedColors = nil // animated colors should be discarded
            popUpView?.setColor(color)

            if _autoAdjustTrackColor {
                super.minimumTrackTintColor = popUpView?.opaqueColor()
            }
        }
    }
    // pass an array of 2 or more UIColors to animate the color change as the slider moves

    private var _popUpViewAnimatedColors: [UIColor]?
    var popUpViewAnimatedColors: [UIColor]? {
        get {
            _popUpViewAnimatedColors
        }
        set(colors) {
            setPopUpViewAnimatedColors(colors , withPositions: nil)
        }
    }

    // the above @property distributes the colors evenly across the slider
    // to specify the exact position of colors on the slider scale, pass an NSArray of NSNumbers
    // if 2 or more colors are present, set animated colors
    // if only 1 color is present then call 'setPopUpViewColor:'
    // if arg is nil then restore previous _popUpViewColor
    func setPopUpViewAnimatedColors(_ colors: [UIColor]?, withPositions positions: [CGFloat]?) {
        if positions != nil {
            assert(colors?.count == positions?.count, "popUpViewAnimatedColors and locations should contain the same number of items")
        }

        _popUpViewAnimatedColors = colors
        keyTimes = self.keyTimesFromSliderPositions(positions: positions)

        if (colors?.count ?? 0) >= 2 {
            popUpView?.setAnimatedColors(colors, withKeyTimes: keyTimes)
        } else {
            popUpViewColor = colors?.last ?? _popUpViewColor
            
        }
    }

    // cornerRadius of the popUpView, default is 4.0

    var popUpViewCornerRadius: CGFloat {
        get {
            return popUpView?.cornerRadius ?? 0.0
        }
        set(radius) {
            popUpView?.cornerRadius = radius
        }
    }
    // arrow height of the popUpView, default is 13.0

    var popUpViewArrowLength: CGFloat {
        get {
            return popUpView?.arrowLength ?? 0.0
        }
        set(length) {
            popUpView?.arrowLength = length
        }
    }
    // width padding factor of the popUpView, default is 1.15

    var popUpViewWidthPaddingFactor: CGFloat {
        get {
            return popUpView?.widthPaddingFactor ?? 0.0
        }
        set(factor) {
            popUpView?.widthPaddingFactor = factor
        }
    }
    // height padding factor of the popUpView, default is 1.1

    var popUpViewHeightPaddingFactor: CGFloat {
        get {
            return popUpView?.heightPaddingFactor ?? 0.0
        }
        set(factor) {
            popUpView?.heightPaddingFactor = factor
        }
    }
    // changes the left handside of the UISlider track to match current popUpView color
    // the track color alpha is always set to 1.0, even if popUpView color is less than 1.0

    private var _autoAdjustTrackColor = false
    func setAutoAdjustTrackColor(autoAdjust: Bool) {
            if _autoAdjustTrackColor == autoAdjust {
                return
            }

            _autoAdjustTrackColor = autoAdjust

            // setMinimumTrackTintColor has been overridden to also set autoAdjustTrackColor to NO
            // therefore super's implementation must be called to set minimumTrackTintColor
            if autoAdjust == false {
                super.minimumTrackTintColor = nil // sets track to default blue color
            } else {
                super.minimumTrackTintColor = popUpView?.opaqueColor()
            }
    }
 // (default is YES)
    // when setting max FractionDigits the min value is automatically set to the same value
    // this ensures that the PopUpView frame maintains a consistent width
    // set max and min digits to same value to keep string length consistent
    func setMaxFractionDigitsDisplayed(_ maxDigits: Int) {
        numberFormatter?.maximumFractionDigits = maxDigits
        numberFormatter?.minimumFractionDigits = maxDigits
    }

    // take full control of the format dispayed with a custom NSNumberFormatter

    private var _numberFormatter: NumberFormatter?
    var numberFormatter: NumberFormatter? {
        get {
            return _numberFormatter // return a copy to prevent formatter properties changing and causing mayhem
        }
        set(numberFormatter) {
            _numberFormatter = numberFormatter
        }
    }

// MARK: - initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

// MARK: - public

    // return the currently displayed color if possible, otherwise return _popUpViewColor
    // if animated colors are set, the color will change each time the slider value changes
    // when either the min/max value or number formatter changes, recalculate the popUpView width
    override var maximumValue: Float {
        get {
            return super.maximumValue
        }
        set(maximumValue) {
            super.maximumValue = maximumValue
            valueRange = CGFloat(self.maximumValue - minimumValue)
        }
    }

    override var minimumValue: Float {
        get {
            return super.minimumValue
        }
        set(minimumValue) {
            super.minimumValue = minimumValue
            valueRange = CGFloat(maximumValue - self.minimumValue)
        }
    }

// MARK: - ASValuePopUpViewDelegate
    func colorDidUpdate(_ opaqueColor: UIColor?) {
        super.minimumTrackTintColor = opaqueColor
    }

    // returns the current offset of UISlider value in the range 0.0 – 1.0
    func currentValueOffset() -> CGFloat {
        return CGFloat((value - minimumValue)) / valueRange
    }

// MARK: - private
    func setup() {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.roundingMode = .halfUp
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        numberFormatter = formatter

        self.popUpView = ASValuePopUpView(frame: CGRect.zero)
        _autoAdjustTrackColor = true
        popUpViewAlwaysOn = false
        valueRange = CGFloat(maximumValue - minimumValue)
        self.popUpViewColor = UIColor(hue: 0.6, saturation: 0.6, brightness: 0.5, alpha: 0.8)

        popUpView?.alpha = 0.0
        popUpView?.delegate = self
        if let popUpView = popUpView {
            addSubview(popUpView)
        }

        textColor = UIColor.white
        self.font = UIFont.boldSystemFont(ofSize: 22.0)
    }

    // ensure animation restarts if app is closed then becomes active again
    @objc func didBecomeActiveNotification(_ note: Notification?) {
        if _popUpViewAnimatedColors != nil {
            popUpView?.setAnimatedColors(_popUpViewAnimatedColors!, withKeyTimes: keyTimes)
        }
    }

    func updatePopUpView() {
        var valueString: String? // ask dataSource for string, if nil or blank, get string from _numberFormatter
        var popUpViewSize: CGSize
        if (valueString = dataSource?.slider(self, stringForValue: value)) != nil && (valueString?.count ?? 0) != 0 {
            popUpViewSize = popUpView?.popUpSize(for: valueString) ?? CGSize.zero
        } else {
            valueString = numberFormatter?.string(from: NSNumber(value: value))
            popUpViewSize = calculatePopUpViewSize()
        }

        // calculate the popUpView frame
        let thumbRect = self.thumbRect()
        let thumbW = thumbRect.size.width
        let thumbH = thumbRect.size.height

        var popUpRect = thumbRect.insetBy(dx: (thumbW - popUpViewSize.width) / 2, dy: (thumbH - popUpViewSize.height) / 2)
        popUpRect.origin.y = thumbRect.origin.y - popUpViewSize.height

        // determine if popUpRect extends beyond the frame of the progress view
        // if so adjust frame and set the center offset of the PopUpView's arrow
        let minOffsetX = popUpRect.minX
        let maxOffsetX: CGFloat = popUpRect.maxX - bounds.width

        let offset = minOffsetX < 0.0 ? minOffsetX : (maxOffsetX > 0.0 ? maxOffsetX : 0.0)
        popUpRect.origin.x -= offset

        popUpView?.setFrame(popUpRect, arrowOffset: offset, text: valueString)
    }

    func calculatePopUpViewSize() -> CGSize {
        // negative values need more width than positive values
        let minValSize = popUpView?.popUpSize(for: numberFormatter?.string(from: NSNumber(value: minimumValue)))
        let maxValSize = popUpView?.popUpSize(for: numberFormatter?.string(from: NSNumber(value: maximumValue)))

        return (((minValSize?.width ?? 0.0) >= (maxValSize?.width ?? 0.0)) ? minValSize : maxValSize ?? CGSize.zero)!
    }

    // takes an array of NSNumbers in the range self.minimumValue - self.maximumValue
    // returns an array of NSNumbers in the range 0.0 - 1.0
    func keyTimesFromSliderPositions(positions: [AnyHashable]?) -> [AnyHashable]? {
        if positions == nil {
            return nil
        }

        var keyTimes: [AnyHashable] = []
        for num in positions! {
            keyTimes.append( (num as! CGFloat -  CGFloat(self.minimumValue) ) / valueRange)
         }
        return keyTimes
    }

    func thumbRect() -> CGRect {
        return thumbRect(forBounds: bounds, trackRect: trackRect(forBounds: bounds), value: value)
    }

    func _showPopUpView(animated: Bool) {
        if delegate != nil {
            delegate?.sliderWillDisplayPopUpView(self)
        }
        popUpView?.show(animated: animated)
    }

    func _hidePopUpView(animated: Bool) {
        if delegate?.responds(to: #selector(ASValueTrackingSliderDelegate.sliderWillHidePopUpView(_:))) ?? false {
            delegate?.sliderWillHidePopUpView?(self)
        }
        popUpView?.hide(animated: animated, completionBlock: {
            if self.delegate?.responds(to: #selector(ASValueTrackingSliderDelegate.sliderDidHidePopUpView(_:))) ?? false {
                self.delegate?.sliderDidHidePopUpView?(self)
            }
        })
    }

// MARK: - subclassed
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePopUpView()
    }

    override func didMoveToWindow() {
        if window == nil {
            // removed from window - cancel notifications
            NotificationCenter.default.removeObserver(self)
        } else {
            // added to window - register notifications

            if _popUpViewAnimatedColors != nil {
                // restart color animation if needed
                popUpView?.setAnimatedColors(_popUpViewAnimatedColors, withKeyTimes: keyTimes)
            }

            NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotification(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        }
    }

    override var value: Float {
        get {
            return super.value
        }
        set(value) {
            super.value = value
            popUpView?.setAnimationOffset(currentValueOffset(), returnColor: { opaqueReturnColor in
                super.minimumTrackTintColor = opaqueReturnColor
            })
        }
    }

    override func setValue(_ value: Float, animated: Bool) {
        if animated {
            popUpView?.animateBlock({ duration in
                UIView.animate(withDuration: TimeInterval(duration), animations: {
                    super.setValue(value, animated: animated)
                    self.popUpView?.setAnimationOffset(self.currentValueOffset(), returnColor: { opaqueReturnColor in
                        super.minimumTrackTintColor = opaqueReturnColor
                    })
                    self.layoutIfNeeded()
                })
            })
        } else {
            super.setValue(value, animated: animated)
        }
    }

    override var minimumTrackTintColor: UIColor? {
        get {
            return super.minimumTrackTintColor
        }
        set(color) {
            _autoAdjustTrackColor = false // if a custom value is set then prevent auto coloring
            super.minimumTrackTintColor = color
        }
    }

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let begin = super.beginTracking(touch, with: event)
        if begin && !popUpViewAlwaysOn {
            _showPopUpView(animated: true)
        }
        return begin
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let continueTrack = super.continueTracking(touch, with: event)
        if continueTrack {
            popUpView?.setAnimationOffset(currentValueOffset(), returnColor: { opaqueReturnColor in
                super.minimumTrackTintColor = opaqueReturnColor
            })
        }
        return continueTrack
    }

    override func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)
        if popUpViewAlwaysOn == false {
            _hidePopUpView(animated: true)
        }
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        if popUpViewAlwaysOn == false {
            _hidePopUpView(animated: true)
        }
    }
}

// to supply custom text to the popUpView label, implement <ASValueTrackingSliderDataSource>
// the dataSource will be messaged each time the slider value changes
protocol ASValueTrackingSliderDataSource: NSObjectProtocol {
    func slider(_ slider: ASValueTrackingSlider?, stringForValue value: Float) -> String?
}

// when embedding an ASValueTrackingSlider inside a TableView or CollectionView
// you need to ensure that the cell it resides in is brought to the front of the view hierarchy
// to prevent the popUpView from being obscured
@objc protocol ASValueTrackingSliderDelegate: NSObjectProtocol {
    func sliderWillDisplayPopUpView(_ slider: ASValueTrackingSlider?)

    @objc optional func sliderWillHidePopUpView(_ slider: ASValueTrackingSlider?)
    @objc optional func sliderDidHidePopUpView(_ slider: ASValueTrackingSlider?)
}
