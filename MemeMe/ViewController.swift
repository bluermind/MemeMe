//
//  ViewController.swift
//  MemeMe
//
//  Created by Frank on 2016. 12. 22..
//  Copyright © 2016 Bluermind Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // MARK: Properties
    let _defaultTopText:String = "TOP"
    let _defaultBottomText:String = "BOTTOM"
    // with help from http://stackoverflow.com/questions/30955277/nsforegroundcolorattributename-doesnt-work-in-swift
    let memeTextAttributes:[String:Any] = [
        NSStrokeColorAttributeName: UIColor.black,
        NSForegroundColorAttributeName: UIColor.white,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 20)!,
        NSStrokeWidthAttributeName: -1.0
    ]
    let maxLength = 30
    
    // MARK: Outlets
    @IBOutlet weak var pickedImage: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!

    // MARK: Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            pickedImage.image = image
            topTextField.isHidden = false
            bottomTextField.isHidden = false
            resetTextField()
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Text Field Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == topTextField, textField.text == _defaultTopText {
            textField.text = ""
        }
        else if textField == bottomTextField, textField.text == _defaultBottomText {
            textField.text = ""
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == topTextField, textField.text == "" {
            textField.text = _defaultTopText
        }
        else if textField == bottomTextField, textField.text == "" {
            textField.text = _defaultBottomText
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Character max length referenced from https://grokswift.com/uitextfield/
        let startingLength = textField.text?.characters.count ?? 0
        let lengthToAdd = string.characters.count
        let lengthToReplace = range.length
        let newLength = startingLength + lengthToAdd - lengthToReplace
        return newLength <= maxLength
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Top Text
        topTextField.delegate = self
        topTextField.text = _defaultTopText
        topTextField.isHidden = true
        // Bottom Text
        bottomTextField.delegate = self
        bottomTextField.text = _defaultBottomText
        bottomTextField.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        // The center alignment is not working from storyboard attributes pane.
        topTextField.textAlignment = .center
        bottomTextField.textAlignment = .center
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    // MARK: Custom Functions
    func resetTextField() {
        topTextField.text = _defaultTopText
        bottomTextField.text = _defaultBottomText
    }
    
    // MARK: Actions
    @IBAction func pickImageFromAlbum(_ sender: Any) {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = .photoLibrary
        present(controller, animated: true, completion: nil)
    }
    @IBAction func pickImageFromCamera(_ sender: Any) {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = .camera
        present(controller, animated: true, completion: nil)
    }

}

