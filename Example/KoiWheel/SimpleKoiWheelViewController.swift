//
//  SimpleKoiWheelViewController.swift
//  Scratchpad
//
//  Created by Kwabena A. Fordjour Jr. on 2018-10-05.
//  Copyright © 2018 Kwabena A. Fordjour. All rights reserved.
//

import UIKit

class SimpleKoiWheelViewController: UIViewController {
  
  
  @IBOutlet weak var wheelValueLabel: UILabel!
  @IBOutlet weak var wheel: KoiWheel!
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    updateColors(value: wheel.value)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    wheelValueLabel.text = String.localizedStringWithFormat("%.3f", wheel.value)
    
  }
  
  @IBAction func onWheelValueChanged(_ sender: KoiWheel) {
    wheelValueLabel.text = String.localizedStringWithFormat("%.3f", sender.value)
    
    updateColors(value: sender.value)
  }
  
  fileprivate func updateColors(value: Double) {
    // Fun Color Setting
    let r = CGFloat((sin(value) + 1.0)/2)
    let g = CGFloat((sin(value * 2) + 1.0)/2)
    let b = CGFloat((sin(value * 0.5) + 1.0)/2)
    
    view.tintColor = UIColor.init(displayP3Red: normalize(value:r, weight:0.6),
                                  green: normalize(value:g, weight:0.6),
                                  blue: normalize(value:b, weight:0.6),
                                  alpha: 1.0)
    
    view.backgroundColor = UIColor.init(displayP3Red: normalize(value: r, weight: 0.2),
                                        green: normalize(value: g, weight: 0.2),
                                        blue: normalize(value: b, weight: 0.2),
                                        alpha: 1.0)
  }
  
  func normalize(value: CGFloat, weight: CGFloat) -> CGFloat {
    return (value * weight) + (1 - weight)
  }
  
}

