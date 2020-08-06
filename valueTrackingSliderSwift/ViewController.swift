//
//  ViewController.swift
//  valueTrackingSliderSwift
//
//  Created by Mohammed on 06/08/2020.
//  Copyright © 2020 Mohammed. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ASValueTrackingSliderDataSource {
    func slider(_ slider: ASValueTrackingSlider?, stringForValue value: Float) -> String? {
        return "\(value)"
    }
    
        @IBOutlet weak var slider2: ASValueTrackingSlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
       // slider2.numberFormatter = formatter
        slider2.popUpViewCornerRadius = 5.0
        slider2.font = UIFont(name: "GillSans-Bold", size: 22)
        slider2.popUpViewColor = UIColor.init(hue: 0.55, saturation: 0.8, brightness: 0.9, alpha: 0.7)
        slider2.textColor = UIColor.init(hue: 0.55, saturation: 1.0, brightness: 0.5, alpha: 1)
        slider2.popUpViewWidthPaddingFactor = 1.0
        slider2.popUpViewAnimatedColors =  [ #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1) ]
        // App crach if popUpViewAnimatedColors is more than 2 colors //
      //  slider2.popUpViewAnimatedColors =  [ UIColor.red, UIColor.white]
        slider2.popUpViewArrowLength = 20.0
        
    }


}
