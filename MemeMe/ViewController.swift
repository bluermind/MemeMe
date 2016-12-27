//
//  ViewController.swift
//  MemeMe
//
//  Created by Frank on 2016. 12. 22..
//  Copyright © 2016 Bluermind Inc. All rights reserved.
//

import UIKit

struct Meme {
    var topText:String
    var bottomText:String
    var originalImage:UIImage
    var memedImage:UIImage
}

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
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var navbar: UINavigationBar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    // MARK: Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            pickedImage.image = image
            topTextField.isHidden = false
            bottomTextField.isHidden = false
            resetTextField()
            shareButton.isEnabled = true
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
        
        subscribeToKeyboardNotifications()
    }
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: Custom Functions
    func resetTextField() {
        topTextField.text = _defaultTopText
        bottomTextField.text = _defaultBottomText
    }
    func save(_ memedImage: UIImage) {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: pickedImage.image!, memedImage: memedImage)
    }
    func generateMemedImage() -> UIImage {
        // Hide toolbar and navbar
        toolbar.isHidden = true
        navbar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        toolbar.isHidden = false
        navbar.isHidden = true
        return memedImage
    }
    
    // MARK: Keyboard notification
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            //view.frame.origin.y -= getKeyboardHeight(notification)
            
            bottomConstraint.constant += getKeyboardHeight(notification)
            self.view.layoutIfNeeded()
        }
    }
    func keyboardWillHide(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            bottomConstraint.constant = 0
        }
    }
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
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
    @IBAction func shareMeme(_ sender: Any) {
        
        let memedImage = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        let _self = self
        controller.completionWithItemsHandler = { (activity, completed, items, error) in
            
            // Return if cancelled
            if (completed) {
                _self.save(memedImage)
            }
            // dismiss controller
            _self.dismiss(animated: true, completion: nil)
        }
        present(controller, animated: true, completion: nil)
        
    }
    
}

