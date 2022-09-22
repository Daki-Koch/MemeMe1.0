//
//  ViewController.swift
//  MemeMe1.0
//
//  Created by David Koch on 15.09.22.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var navbar: UINavigationBar!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    var activeTextField = UITextField()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        configureText(textField: bottomTextField, text: "BOTTOM")
        configureText(textField: topTextField, text: "TOP")

        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        if imagePickerView.image != nil {
            shareButton.isEnabled = true
        }
        else {
            shareButton.isEnabled = false
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Subscribe to the keyboard notifications, to allow the view to raise when necessary
        subscribeToKeyboardNotifications()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
    }
    
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
        
    }
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.image = image
            shareButton.isEnabled = true
            picker.dismiss(animated: true, completion: nil)
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardAppearance(_ notification: Notification) {
        
        view.frame.origin.y = -getKeyboardHeight(notification)
    }
    @objc func keyboardDisappearance(_ notification: Notification) {
        view.frame.origin.y = .zero
    }
    func getKeyboardHeight(_ notification: Notification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        if (keyboardSize.cgRectValue.height < activeTextField.frame.origin.y){
            
            return keyboardSize.cgRectValue.height
        }
        else {
            return .zero
        }
    }
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardAppearance(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDisappearance(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func unsubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func share(_ sender: Any) {
        let memedImage = generateMemedImage()
        let activityVC = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        present(activityVC, animated: true) {
            self.save()
        }

        
        
    }
    @IBAction func cancel(_ sender: Any) {
        configureText(textField: bottomTextField, text: "BOTTOM")
        configureText(textField: topTextField, text: "TOP")
        imagePickerView.image = nil
        shareButton.isEnabled = false
    }
    
    func save() {
        
        // Create the meme
        let memedImage = generateMemedImage()
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
        
    }
    
    func generateMemedImage() -> UIImage {
        //Hide navigation and tool bar
        
        toolbar.isHidden = true
        navbar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        toolbar.isHidden = false
        navbar.isHidden = false
        return memedImage
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
    @objc func textFieldIsDragged(_ gesture: UIPanGestureRecognizer){

        let loc = gesture.location(in: self.view)
        self.activeTextField.center = loc


    }
    
    func configureText(textField: UITextField, text: String){
        
        // Alows user to drag Text Field to a desired location once edited.
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(textFieldIsDragged))
        textField.addGestureRecognizer(gesture)
        textField.isUserInteractionEnabled = true
        textField.autocapitalizationType = .allCharacters
        textField.text = text
        textField.defaultTextAttributes = memeTextAttributes
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        
    }
}





let memeTextAttributes: [NSAttributedString.Key: Any] = [
    
    NSAttributedString.Key.foregroundColor: UIColor.white,
    NSAttributedString.Key.strokeColor: UIColor.black,
    NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
    NSAttributedString.Key.strokeWidth: -3,

    
]


struct Meme {
    var topText: String
    var bottomText: String
    var originalImage: UIImage
    var memedImage: UIImage
}

