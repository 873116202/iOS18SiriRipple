//
//  ViewController.swift
//  iOS18SiriRipple
//
//  Created by be-huge on 2025/6/21.
//

import UIKit
import MetalKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            return;
        }
        
        let rippleView = RippleMetalView(frame: self.view.bounds, device: device);
        rippleView.autoresizingMask = [.flexibleWidth, .flexibleHeight];
        self.view.addSubview(rippleView);
    }


}

