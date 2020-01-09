//  Copyright 2020 Hotspring Ventures Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import UIKit

public class TWHud: UIView {
    public struct Configuration {
        let maskImage: UIImage
        let cornerRadius: CGFloat
        let size: CGSize
        let fillUpTime: TimeInterval
        let waitTime: TimeInterval
        let hudBackgroundColour: UIColor
        let containerBackgroundColour: UIColor
        let colours: [UIColor]
        
        /**
         TWHud configuration
         
         - Parameter maskImage: PNG image used as a mask
         - Parameter cornerRadius: Corner radius for HUD
         - Parameter size: Size of HUD
         - Parameter fillUpTime: Fill up animation time
         - Parameter waitTime: Time to wait before next fill up
         - Parameter hudBackgorundColour: Colour of HUD
         - Parameter containerBackgroundColour: Colour used for screen dimming
         - Parameter colours: Array of colours. HUD will be filled with random colours from this array.
        */
        public init(maskImage: UIImage,
             cornerRadius: CGFloat = 10.0,
             size: CGSize = CGSize(width: 100, height: 100),
             fillUpTime: TimeInterval = 0.5,
             waitTime: TimeInterval = 0.1,
             hudBackgroundColour: UIColor = .white,
             containerBackgroundColour: UIColor = UIColor.black.withAlphaComponent(0.4),
             colours: [UIColor])
        {
            self.maskImage = maskImage
            self.cornerRadius = cornerRadius
            self.size = size
            self.fillUpTime = fillUpTime
            self.waitTime = waitTime
            self.hudBackgroundColour = hudBackgroundColour
            self.containerBackgroundColour = containerBackgroundColour
            self.colours = colours
        }
    }
    
    private var container: UIControl?
    private var hud: UIView?
    private var displayLink: CADisplayLink?
    private var previousTimestamp: CFTimeInterval = 0
    private var timePassed: CFTimeInterval = 0
    private var bgFillIdx: Int = 0
    private var fillIdx: Int = 0
    private var fillOrigin: CGPoint = .zero
    
    /**
     Initialize TWHud instance with given configuration
    
     - Parameter configuration: Configuration struct
    */
    private init(configuration: Configuration) {
        self.configuration = configuration
        
        super.init(frame: CGRect(origin: .zero, size: configuration.size))
        bgFillIdx = Int(arc4random()) % configuration.colours.count
        fillIdx = generateFillIdx()
        fillOrigin = generateFillOrigin()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public code
    
    /// Shared TWHud instance
    public static var shared: TWHud?
    
    /// Configuration currently used
    private(set) var configuration: Configuration!
    
    /**
     Configure TWHud instance. Use this method before calling any other method, e.g. TWHud.show()
     
     - Parameter configuration: Configuration struct
    */
    public static func configure(with configuration: Configuration) {
        shared = TWHud(configuration: configuration)
        
        guard let observer = shared else { return }
        
        NotificationCenter.default.addObserver(
            observer,
            selector: #selector(self.keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            observer,
            selector: #selector(self.keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    /**
     Show shared TWHud if it's not already visible
     
     - Parameter animationDuration: Duration of HUD appearance animation
     */
    @discardableResult public static func show(animationDuration: TimeInterval = 0.35) ->TWHud? {
        if shared?.isVisible == false {
            shared?.showProgress(animationDuration: animationDuration)
        }
        
        return shared
    }
    
    /**
     Show TWHud in provided view
     
     - Parameter view: Container view
     - Parameter configuration: Configuration to use when creating new TWHud instance
     - Parameter animationDuration: Duration of HUD appearance animation
     */
    @discardableResult public static func showIn(
        view: UIView,
        configuration: TWHud.Configuration,
        animationDuration: TimeInterval = 0.35
    ) -> TWHud {
        let hud = TWHud(configuration: configuration)
        hud.showIn(view: view, animationDuration: animationDuration)
        
        return hud
    }
    
    /**
     Dismiss currently visible shared HUD for shared instance
     
     - Parameter animationDuration: Duration of HUD dismissal animation
     */
    public static func dismiss(animationDuration: TimeInterval = 0.2) {
        shared?.dismiss(animationDuration: animationDuration)
    }
    
    /**
     Dismiss currently visible HUD
     
     - Parameter animationDuration: Duration of HUD dismissal animation
     */
    public func dismiss(animationDuration: TimeInterval = 0.2) {
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: .curveEaseInOut, animations: { [weak self] in
            self?.hud?.alpha = 0.0
            self?.container?.alpha = 0.0
        }) { [weak self] finished in
            guard finished else { return }
            
            self?.container?.isHidden = true
            self?.displayLink?.isPaused = true
        }
    }
    
    /**
     Is HUD currently visible or not
     */
    public var isVisible: Bool {
        guard let alpha = hud?.alpha else { return false }
        return alpha != 0
    }
    
    /**
     Validate next fill colour index.
     This is useful to add your own custom logic which colour should be used after current
     
     - Note: Default implementation returns true if next colour index is different from currently used
     - Return: Boolean indicating if proposed next index can be used
     
     # Example #
     ```
     TWHud.shared?.nextFillColourIndexIsValid = { next, previous in
        return next != previous
     }
      ```
     */
    public var nextFillColourIndexIsValid: (_ fillIdx: Int, _ bgFillIdx: Int) -> Bool = { next, previous in
        return next != previous
    }
    
    // MARK: - Private code
    
    private func createHudIn(view: UIView, frame: CGRect) {
        let hud = UIView(frame: CGRect(origin: .zero, size: configuration.size))
        hud.layer.cornerRadius = configuration.cornerRadius
        hud.layer.masksToBounds = true
        hud.backgroundColor = configuration.hudBackgroundColour
        hud.alpha = 0.0
        hud.addSubview(self)
        
        let mask = configuration.maskImage
        let maskLayer = CALayer()
        
        let x = (self.bounds.size.width - mask.size.width) / 2.0
        let y = (self.bounds.size.height - mask.size.height) / 2.0
        maskLayer.frame = CGRect(x: x, y: y, width: mask.size.width, height: mask.size.height)
        maskLayer.contents = mask.cgImage
        layer.mask = maskLayer
        
        self.hud = hud
        
        let container = UIControl(frame: frame)
        container.backgroundColor = configuration.containerBackgroundColour
        
        container.addSubview(hud)
        self.container = container
        
        guard let center = self.superview?.center else { return }
        
        self.center = center
        self.hud?.center = center
        
        view.addSubview(container)
        hud.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        self.container?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private func showIn(view: UIView, animationDuration: TimeInterval) {
        createHudIn(view: view, frame: view.bounds)
        
        positionHud()
        
        hud?.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        hud?.alpha = 0.0
        container?.alpha = 0.0
        UIView.animate(withDuration: animationDuration) { [weak self] in
            self?.container?.alpha = 1.0
            self?.hud?.alpha = 1.0
        }
    }
    
    private func showProgress(animationDuration: TimeInterval) {
        displayLink?.isPaused = false
        
        if container?.superview != nil {
            // Bringing spinner to front of all window subviews, which may have changed during runtime
            guard let container = self.container else { return }
            container.superview?.bringSubviewToFront(container)
            container.isHidden = false
        } else {
            let frontToBackWindows = UIApplication.shared.windows.reversed()
            for window in frontToBackWindows {
                let windowOnMainScreen = window.screen == UIScreen.main
                let windowIsVisible = !window.isHidden && window.alpha > 0
                let windowLevelNormal = window.windowLevel == UIWindow.Level.normal
                
                if windowOnMainScreen && windowIsVisible && windowLevelNormal {
                    createHudIn(view: window, frame: UIScreen.main.bounds)
                    break
                }
            }
        }
        
        positionHud()

        hud?.alpha = 0.0
        container?.alpha = 0.0
        UIView.animate(withDuration: animationDuration) { [weak self] in
            self?.container?.alpha = 1.0
            self?.hud?.alpha = 1.0
        }
    }
    
    private func positionHud(notification: NSNotification? = nil) {
        let keyboardHeight = visibleKeyboardHeight
        
        guard let superview = container?.superview else { return }
        var centerPoint = CGPoint(x: superview.bounds.width / 2.0, y: superview.bounds.height / 2.0)
        
        centerPoint.y -= keyboardHeight / 2.0
        hud?.center = centerPoint
    }
    
    // MARK: - Drawing
    
    public override func didMoveToSuperview() {
        if displayLink == nil {
            displayLink = CADisplayLink.init(target: self, selector: #selector(update))
            displayLink?.add(to: RunLoop.main, forMode: .default)
        }
        backgroundColor = .clear
    }
    
    public override func removeFromSuperview() {
        displayLink?.invalidate()
        timePassed = 0
        previousTimestamp = 0
        super.removeFromSuperview()
    }
    
    @objc private func update() {
        setNeedsDisplay()
    }
    
    private func generateFillIdx() -> Int {
        var fillIdx = 0
        var valid = false
        
        while !valid {
            fillIdx = Int(arc4random()) % configuration.colours.count
            valid = nextFillColourIndexIsValid(fillIdx, bgFillIdx)
        }
        
        return fillIdx
    }
    
    private func generateFillOrigin() -> CGPoint {
        let x: CGFloat = CGFloat(arc4random() % 3) / 2.0
        let y: CGFloat = CGFloat(arc4random() % 3) / 2.0
        
        if x == y && x == 0.5 {
            return generateFillOrigin()
        } else {
            return CGPoint(x: x, y: y)
        }
    }
    
    public override func draw(_ rect: CGRect) {
        guard let displayLink = self.displayLink else {
            return
        }
        
        let duration = displayLink.timestamp - previousTimestamp
        self.previousTimestamp = displayLink.timestamp
        self.timePassed += duration
        let fillY = self.timePassed / configuration.fillUpTime
        
        let context = UIGraphicsGetCurrentContext()
        let bgFillColour = configuration.colours[bgFillIdx]
        if let components = bgFillColour.cgColor.components {
            context?.setFillColor(components)
        }
        context?.fill(rect)
        
        let theFillColor = configuration.colours[fillIdx]
        if let components = theFillColor.cgColor.components {
            context?.setFillColor(components)
        }
        
        let step = CGFloat(80.0 * fillY)
        let x = 14 - step + 72 * fillOrigin.x
        let y = 29 - step + 42 * fillOrigin.y
        
        let rectangle = CGRect(x: x, y: y, width: step * 2, height: step * 2)
        context?.fillEllipse(in: rectangle)
        
        UIGraphicsEndImageContext()
        
        if timePassed >= configuration.fillUpTime + configuration.waitTime {
            bgFillIdx = fillIdx
            fillIdx = generateFillIdx()
            timePassed = 0
            fillOrigin = generateFillOrigin()
        }
    }
    
    // MARK: - Keyboard height changes
    
    private var visibleKeyboardHeight: CGFloat = 0.0
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            visibleKeyboardHeight = keyboardFrame.cgRectValue.size.height
        } else {
            visibleKeyboardHeight = 0.0
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        visibleKeyboardHeight = 0.0
    }
}
