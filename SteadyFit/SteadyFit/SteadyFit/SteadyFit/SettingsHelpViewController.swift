//
//  SettingsHelpViewController.swift
//  SteadyFit
//
//  Created by Yimin on 2018-11-27.
//  Copyright © 2018 Daycar. All rights reserved.
//

import UIKit

class SettingsHelpViewController: UIViewController {
    
    @IBOutlet weak var A1view: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var Q1Button: UIButton!
    @IBAction func Q1ButtonPressed(_ sender: Any) {
        if(A1view.isHidden == true)
        {
            A1view.isHidden = false
        }
        else
        {
            A1view.isHidden = true
        }
    }
    
    
    @IBOutlet weak var Q2Button: UIButton!
    @IBAction func Q2ButtonPressed(_ sender: Any) {
    }
    
    @IBOutlet weak var Q3Button: UIButton!
    @IBAction func Q3ButtonPressed(_ sender: Any) {
    }
    
}
