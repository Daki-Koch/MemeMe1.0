//
//  ViewController.swift
//  MemeMe1.0
//
//  Created by David Koch on 15.09.22.
//

import UIKit

class EditMemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
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

        #if targetEnvironment(simulator)
        cameraButton.isEnabled = false;
        #else
        cameraButton.isEnabled = true;
        #endif
        
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
        pickImage(.photoLibrary)
        
    }
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        pickImage(.camera)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.image = image
            shareButton.isEnabled = true
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func pickImage(_ sourceType: UIImagePickerController.SourceType){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
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
        activityVC.completionWithItemsHandler = { (activity, completed, items, error) in
            if (completed) {
                self.save()
                self.dismiss(animated: true, completion: nil)
                
            }
        }
        self.present(activityVC, animated: true)
        
        
    }
    @IBAction func cancel(_ sender: Any) {
        configureText(textField: bottomTextField, text: "BOTTOM")
        configureText(textField: topTextField, text: "TOP")
        imagePickerView.image = nil
        shareButton.isEnabled = false
        self.dismiss(animated: true)
    }
    
    func save() {
        
        // Create the meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: generateMemedImage())
        
        // Add meme to array in App delegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
        
        
        
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
    
    func configureText(textField: UITextField, text: String){
        
        // Alows user to drag Text Field to a desired location once edited.
        textField.isUserInteractionEnabled = true
        textField.autocapitalizationType = .allCharacters
        textField.text = text
        textField.defaultTextAttributes = memeTextAttributes
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        
    }
}



