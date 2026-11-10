//
//  ViewController.swift
//  ProgressUI
//
//  Created by Devika on 08/11/2026.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var progressView: CircularProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // CircularProgressView
        progressView.setProgress(to: 1.0, duration: 2.0)
        
        // MultiColorActivityIndicator
        let activityIndicatorObj = MultiColorActivityIndicator()
        activityIndicatorObj.show()
    }
}
