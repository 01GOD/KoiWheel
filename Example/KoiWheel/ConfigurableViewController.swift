//
//  ConfigurableViewController.swift
//  KoiWheel_Example
//
//  Created by Kwabena A. Fordjour Jr. on 2018-10-10.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class ConfigurableViewController: UIViewController {
  @IBOutlet weak var koiWheel: KoiWheel!
  
  @IBOutlet weak var resistanceValueLabel: UILabel!
  
  @IBOutlet weak var wheelValueLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
//    koiWheel.knobImage = UIImage(named: "record.png")
    
    // Do any additional setup after loading the view.
  }
  
  // MARK: Wheel Configuration Functions
  
  @IBAction func onResistanceChanged(_ sender: UISlider) {
    resistanceValueLabel.text = String.localizedStringWithFormat("%.1f", sender.value)
    koiWheel.angularResistance = Double(sender.value)
  }
  
  @IBAction func onWheelValueChanged(_ sender: KoiWheel) {
    wheelValueLabel.text = String.localizedStringWithFormat("%.3f", sender.value)
  }
}

