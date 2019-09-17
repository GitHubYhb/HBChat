//
//  ViewController.swift
//  HBChat
//
//  Created by 尤鸿斌 on 2019/9/12.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
     
        let hbimgv = HBImageViewer.init(frame: UIScreen.main.bounds)
        
        let window = UIApplication.shared.keyWindow
        window?.addSubview(hbimgv)
        
    }


}

