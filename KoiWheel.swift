//
//  KoiWheel.swift
//  Scratchpad
//
//  Created by Kwabena A. Fordjour Jr. on 2018-10-02.
//  Copyright © 2018 Kwabena A. Fordjour. All rights reserved.
//

import UIKit

@IBDesignable class KoiWheel: UIControl {
  
  var DEBUG = false
  
  func dprint(_ str: String) {
    if DEBUG { print("DEBUG: \(str)") }
  }
  
//  private var _value: Double = 0.0
  
  @IBInspectable var value: Double {
    get {
      let _value = clamp(Double(_cumulatedAngle/(2 * CGFloat.pi)))
      dprint("_cumulatedAngle: \(_cumulatedAngle) \n(2 * .pi): \((2 * CGFloat.pi)) \nvalue: \(_value) \n_cumulatedAngle/(2 * CGFloat.pi): \(_cumulatedAngle/(2 * CGFloat.pi))")
     
      return _value
    }
    set(newValue) {
      let _value = clamp(newValue)
      
      _cumulatedAngle = CGFloat(_value) * (2 * CGFloat.pi)
      dprint("_cumulatedAngle: \(_cumulatedAngle) (#function)")
    }
  }
  @IBInspectable var minimumValue: Double = 0.0
  @IBInspectable var maximumValue: Double = 100.0
  @IBInspectable var angularResistance = 1.0
  
  @IBOutlet var knobRotatingView: UIView?
  // Just used so I can update knob default color when tintColor changes
  // Probably smarter way to do this
  private var isDefaultKnobView = false
  
  private var _midPoint = CGPoint.zero
  private var _last_timestamp: TimeInterval = 0.0
  
  private var _cumulatedAngle: CGFloat = 0.0
  private var cumulatedAngle: CGFloat {
    get { return _cumulatedAngle }
    set(newCumulatedAngle) {
      _cumulatedAngle = newCumulatedAngle
      
      dprint("_cumulatedAngle: \(_cumulatedAngle) **************** set(newCumulatedAngle) ")
      self.sendActions(for: .valueChanged)
    }
  }
  private var _minAngle: CGFloat {
    get { return CGFloat(minimumValue) * (2 * CGFloat.pi) }
  }
  private var _maxAngle: CGFloat {
    get { return CGFloat(maximumValue) * (2 * CGFloat.pi) }
  }
  
  private var _dTheta: CGFloat = 0.0
  private var _angularVelocity: CGFloat = 0.0
  
  private var _innerRadius: CGFloat = 0.0
  private var _outerRadius: CGFloat = 0.0
  
  var knobTransformPollingTimer: Timer?
  var attachmentBehavior: UIAttachmentBehavior?
  var rotationBehaviour: UIDynamicItemBehavior?
  
  var animator: UIDynamicAnimator?
  var snapBehavior: UISnapBehavior?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    initShared()
  }
  
  required init(coder: NSCoder) {
    super.init(coder: coder)!
    
    initShared()
  }
  
  func initShared() {
    _midPoint = self.center // Setting this because it needs to be initialized
    
    animator = UIDynamicAnimator(referenceView: self)
    animator?.delegate = self
    
    if knobRotatingView == nil {
      knobRotatingView = defaultKnobView()
      self.addSubview(knobRotatingView!)
      knobRotatingView?.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
      knobRotatingView?.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    let r = frame
    let size = min(r.size.width, r.size.height)
    
    heightAnchor.constraint(equalToConstant: size).isActive = true
    widthAnchor.constraint(equalToConstant: size).isActive = true
    
    self.layer.cornerRadius = size/2
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()

    guard animator != nil else { return }
    
    knobRotatingView?.isUserInteractionEnabled = false
    
    if let v = knobRotatingView {
      var r = frame
      r.origin = CGPoint.zero
      let size = min(r.size.width, r.size.height)

      _outerRadius  = size/2
      _innerRadius = (6 * _outerRadius)/100
      _midPoint = CGPoint(x: r.size.width/2, y: r.size.height/2)// convert((knobRotatingView?.center)!, to: self)// convert(center, to: superview)

      if attachmentBehavior != nil {
        animator!.removeBehavior(attachmentBehavior!)
      }
      let ab = UIAttachmentBehavior.init(item: v,
                                         offsetFromCenter: UIOffsetMake(0.0, 0.0),
                                         attachedToAnchor: _midPoint)
      ab.damping = 1000
      ab.length = 0
      ab.frequency = 0

      self.animator!.addBehavior(ab)
      
      attachmentBehavior = ab
    }
    
  }
  
// MARK: Sending Actions
  /**
   * https://developer.apple.com/library/ios/documentation/General/Conceptual/Devpedia-CocoaApp/TargetAction.html#//apple_ref/doc/uid/TP40009071-CH3
   **/
  // TODO: The above document is marked as possibly out of date
  // Do we need to do this?
  override func sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
    super.sendAction(action, to: target, for: event)
  }
  
  override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    // TODO: Handle Multiple Touches
    let currentPoint = touch.location(in: self)
    let shouldBeginTracking = validate(point: currentPoint)
    
    if shouldBeginTracking {
      // Stop a spinning knob
      _angularVelocity = 0
      animator?.removeAllBehaviors()
      
//      print("DEBUG: Stop Rotation knob Rotation Angle \(_cumulatedAngle)")
      
      if knobTransformPollingTimer != nil &&
        knobTransformPollingTimer!.isValid {
        knobTransformPollingTimer?.invalidate()
      }
      
      _last_timestamp = event!.timestamp
    }
    
    return shouldBeginTracking
  }
  
  override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    
    guard event != nil else { return false }
    
    let et = event!.timestamp
    // Used in calculating angular velocity
    let elapsed_time = et - _last_timestamp
    _last_timestamp = et
    
    let currentPoint = touch.location(in: self)
    let prevPoint = touch.previousLocation(in: self)
    
    let touchInHitArea = validate(point: currentPoint)
    
    if touchInHitArea {
      // calculate rotation angle between two points
      _dTheta = angleBetweenLinesInRadians(with: _midPoint,
                                           lineAEnd: prevPoint,
                                           lineBStart: _midPoint,
                                           lineBEnd: currentPoint)
      
      // Fix value, if the 12 o'clock position is between prevPoint and currentPoint
      if (_dTheta > .pi) {
        _dTheta -= 2 * .pi
      } else if _dTheta < -.pi {
        _dTheta += 2 * .pi
      }
      
      // Implement spring force when knob is at boundaries
      let _value: Double = Double(_cumulatedAngle/(2 * .pi))
      if _value < minimumValue {
        _dTheta *= min(0.5, 1/pow(_minAngle - _cumulatedAngle, 8))
        dprint("Stretch Scale Min \(1/pow(_minAngle - _cumulatedAngle, 8))")
      } else if maximumValue < _value {
        dprint("Stretch Scale MAX \(1/pow(_maxAngle - _cumulatedAngle, 2))")
        _dTheta *= min(0.5, 1/pow(_maxAngle - _cumulatedAngle, 8))
      }
      
      // Add up the single steps
      cumulatedAngle += _dTheta
      
      // Rotate Knob View
      knobRotatingView?.transform = CGAffineTransform(rotationAngle: CGFloat(_cumulatedAngle))
      
      // Update  Angular Velocity
      _angularVelocity = (_dTheta/CGFloat(elapsed_time))
      
    } else {
      endTracking(touch, with: event)
    }
    
    return touchInHitArea
  }
  
  // Adds Velocity and Animation Behaviours
  override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
    let minVelocity = 1.0
    
    
    if rotationBehaviour != nil {
      animator?.removeBehavior(rotationBehaviour!)
    }
    
    
    if minVelocity < sqrt(pow(Double(_angularVelocity), 2.0)) {
      // TODO: Have Default knobRotatingView
      rotationBehaviour = UIDynamicItemBehavior(items: [knobRotatingView!])
      rotationBehaviour?.allowsRotation = true
      rotationBehaviour?.friction = 0
      rotationBehaviour?.angularResistance = CGFloat(angularResistance)
      rotationBehaviour?.addAngularVelocity(CGFloat(_angularVelocity), for: knobRotatingView!)
      
      animator?.addBehavior(rotationBehaviour!)
      
      if (knobTransformPollingTimer != nil) { knobTransformPollingTimer?.invalidate() }
      knobTransformPollingTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self,
                                                       selector: #selector(animatorUpdateAngleValue),
                                                       userInfo: nil,
                                                       repeats: true)
    }
    
    snapToBoundsIfNeeded()
  }
  
}


// MARK Private Helper Methods
extension KoiWheel {
  
  func clamp(_ _value: Double) -> Double {
    if _value < minimumValue {
      return minimumValue
    } else if maximumValue < _value {
      return maximumValue
    }
    
    return _value
  }
  
  func defaultKnobView() -> UIView {
    let padding = CGFloat(8.0)
    let size = min(frame.width - padding, frame.height - padding)
    var vframe = CGRect()
    vframe.size = CGSize(width: size, height: size) // Not needed
    
    let dView = UIView(frame: vframe)
    
    dView.translatesAutoresizingMaskIntoConstraints = false
    dView.heightAnchor.constraint(equalToConstant: size).isActive = true
    dView.widthAnchor.constraint(equalToConstant: size).isActive = true
    
    let d: CGFloat = 5.0
    
    dView.backgroundColor = tintColor
    dView.layer.cornerRadius = size/2
    
    let orientationMarker = CALayer()
    orientationMarker.backgroundColor = UIColor.white.cgColor
    orientationMarker.cornerRadius = size/(2*d)
    orientationMarker.shadowColor = UIColor.gray.cgColor
    orientationMarker.shadowRadius = CGFloat(3.0)
    orientationMarker.shadowOffset = CGSize(width: 2.0, height: 2.0)
    orientationMarker.shadowOpacity = 0.15
    
    orientationMarker.frame = CGRect(x: size/2 - size/(2 * d), y: size/15, width: size/d, height: size/d)
    
    dView.layer.addSublayer(orientationMarker)
    
    isDefaultKnobView = true
    
    return dView
  }
  
  override func tintColorDidChange() {
    super.tintColorDidChange()
    
    if isDefaultKnobView &&
      knobRotatingView != nil {
      knobRotatingView?.backgroundColor = tintColor
    }
  }
  
  
  func distanceBetween(pointA: CGPoint, pointB: CGPoint) -> CGFloat {
    let dx = pointA.x - pointB.x
    let dy = pointA.y - pointB.y
    return sqrt(dx*dx + dy*dy)
  }
  
  func angleBetweenLinesInRadians(with lineAStart:CGPoint,
                                  lineAEnd:CGPoint,
                                  lineBStart:CGPoint,
                                  lineBEnd:CGPoint) -> CGFloat {
    let a = lineAEnd.x - lineAStart.x
    let b = lineAEnd.y - lineAStart.y
    let c = lineBEnd.x - lineBStart.x
    let d = lineBEnd.y - lineBStart.y
    
    let atanA = atan2(a, b)
    let atanB = atan2(c, d)
    
    
    return atanA - atanB
  }
  
  // MARK: Handling Touches
  override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    return self.validate(point: point)
  }
  
  func validate(point: CGPoint) -> Bool {
    let distance = distanceBetween(pointA: _midPoint, pointB: point)
    return _innerRadius <= distance && distance <= _outerRadius
  
  }
  
  func snapToBoundsIfNeeded() {
    let _value = _cumulatedAngle/(2 * .pi)
    
    if _value < CGFloat(minimumValue)
      || CGFloat(maximumValue) < _value
    {
      if animator != nil &&
        rotationBehaviour != nil  {
         animator?.removeBehavior(rotationBehaviour!)
      }
      
      UIView.animate(withDuration: 0.25, animations: {
        if self._cumulatedAngle < self._minAngle {
          self.knobRotatingView?.transform = CGAffineTransform(rotationAngle: self._minAngle)
        } else if self._maxAngle < self._cumulatedAngle {
          self.knobRotatingView?.transform = CGAffineTransform(rotationAngle: self._maxAngle)
        }

      }) { (complete) in
        if self._cumulatedAngle < self._minAngle {
          self.knobRotatingView?.transform = CGAffineTransform(rotationAngle: self._minAngle)
          self._cumulatedAngle = self._minAngle
        } else if self._maxAngle < self._cumulatedAngle {
          self.knobRotatingView?.transform = CGAffineTransform(rotationAngle: self._maxAngle)
          self._cumulatedAngle = self._maxAngle
        }
      }
    }
  }
  
  @objc func animatorUpdateAngleValue() {
    guard let kt = knobRotatingView?.transform else { return }
    
    let prevTransform = CGAffineTransform(rotationAngle: _cumulatedAngle)
    
    let oldAngle = -atan2(prevTransform.c, prevTransform.a)
    let newAngle = -atan2(kt.c, kt.a)
    
    _dTheta = fixDeltaThetafor(angle: (newAngle - oldAngle) )
    
    if (_cumulatedAngle < _minAngle) {
      snapToBoundsIfNeeded()
      _cumulatedAngle = _minAngle
    } else if (_maxAngle < _cumulatedAngle) {
      snapToBoundsIfNeeded()
      _cumulatedAngle = _maxAngle
    } else {
      if knobTransformPollingTimer != nil {
        _cumulatedAngle += _dTheta
      } else {
        // Rotate Knob View after Value is Changed programmatically
        knobRotatingView?.transform = CGAffineTransform(rotationAngle: CGFloat(_cumulatedAngle))
        print("Rotate Knob View after Value is Changed programmatically \(#line)")
      }
    }
    
    self.sendActions(for: .valueChanged)
//    value = Double(_cumulatedAngle/(2 * .pi))
    dprint("DEBUG: \(#function) \(value)")
    
  }
  
  func fixDeltaThetafor(angle: CGFloat) -> CGFloat {
    var fixedAngle = angle
    
    if angle > .pi {
      fixedAngle -= 2 * .pi
    } else if ( angle < -.pi) {
      fixedAngle += 2 * .pi
    }
    
    return fixedAngle
  }

}


extension KoiWheel: UIDynamicAnimatorDelegate {
  
   func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
    
    guard let kt = knobRotatingView?.transform else { return }
    
    let finalMinKnobAngle = -atan2(kt.c, kt.a)
    let finalMaxKnobAngle = finalMinKnobAngle + _maxAngle
    
    // maxAngle < _cumulatedAngle
    
    if _cumulatedAngle < _minAngle {
      _cumulatedAngle = finalMinKnobAngle
    } else if _maxAngle < _cumulatedAngle {
      _cumulatedAngle = finalMaxKnobAngle
    } else {
      animatorUpdateAngleValue()
    }
  
    // TODO: Send value change actions to targets?
//    value = Double(_cumulatedAngle/(2 * .pi))
    dprint("DEBUG: \(#function) \(value)")
    
    if knobTransformPollingTimer != nil &&
      (knobTransformPollingTimer?.isValid)! {
      knobTransformPollingTimer?.invalidate()
    }
  }
  
  
}


