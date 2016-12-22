//
//  ViewController.swift
//  MemeMe
//
//  Created by Frank on 2016. 12. 22..
//  Copyright © 2016년 Bluermind Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func selectImage(_ sender: Any) {
        let controller = UIImagePickerController()
        present(controller, animated: true, completion: nil)
    }

}

