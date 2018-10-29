//
//  ConfigurableViewController.swift
//  KoiWheel_Example
//
//  Created by Kwabena A. Fordjour Jr. on 2018-10-10.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class ConfigurableViewController: UIViewController {
  @IBOutlet weak var wheel: KoiWheel!
  
  @IBOutlet weak var resistanceValueLabel: UILabel!
  
  @IBOutlet weak var wheelValueLabel: UILabel!
  
  @IBOutlet weak var minTextField: UITextField!
  @IBOutlet weak var maxTextField: UITextField!
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    minTextField.text = "\(wheel.minimumValue)"
    maxTextField.text = "\(wheel.maximumValue)"
    
    wheelValueLabel.text = String.localizedStringWithFormat("%.3f", wheel.value)
  }
  
  // MARK: Wheel Configuration Functions
  
  @IBAction func onResistanceChanged(_ sender: UISlider) {
    resistanceValueLabel.text = String.localizedStringWithFormat("%.1f", sender.value)
    wheel.angularResistance = Double(sender.value)
  }
  
  @IBAction func onWheelValueChanged(_ sender: KoiWheel) {
    wheelValueLabel.text = String.localizedStringWithFormat("%.3f", sender.value)
  }
  
  
  @IBAction func onSwitchChanged(_ sender: UISegmentedControl) {
    
    wheel.value = wheel.minimumValue
    
    switch sender.selectedSegmentIndex {
    case 0: // Image
      wheel.knobImage = UIImage(named: "record@3x.png")
      wheel.knobOverlayImage = UIImage(named: "record_glare@3x.png")
      wheel.tintColor = UIColor.clear
      break
    case 1: // Default
      wheel.knobImage = nil
      wheel.knobOverlayImage = nil
      wheel.tintColor = view.tintColor
      break
    default:
      break
    }
  }
}

