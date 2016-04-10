//
//  ViewController.swift
//  MemeMe
//
//  Created by Rajat Sharma on 4/8/16.
//  Copyright © 2016 Rajat Sharma. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var topText: UITextField!
    
    @IBOutlet weak var bottomText: UITextField!
    
    @IBOutlet weak var share: UIBarButtonItem!
   
    @IBOutlet weak var topBar: UIToolbar!
    
    @IBOutlet weak var bottomBar: UIToolbar!
    
    
    struct Meme{
        var tText: String
        var bText: String
        var origImage: UIImage
        var memedImage: UIImage
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //imagePickerView.image = UIImage(named: "first.png")
        
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor() ,
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -2.0
        ]
        
        topText.delegate = self
        bottomText.delegate = self
        
        topText.text = "TOP"
        bottomText.text = "BOTTOM"
        
        
        topText.defaultTextAttributes = memeTextAttributes
        bottomText.defaultTextAttributes = memeTextAttributes
        
        topText.textAlignment = .Center
        bottomText.textAlignment = .Center
        
        
        
        
        
        
    }

    override func viewWillAppear(animated: Bool) {
        
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        self.subscribeToKeyboardNotifications()
        
        if((imagePickerView.image == nil)){
            
            share.enabled = false
        }
        else{
            share.enabled = true
        }
        
        
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        self.unsubscribeFromKeyboardNotifications()
    }

    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
   //print("here")
    }
    
    @IBAction func pickAnImageFromCamera(sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        imagePicker.delegate = self
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cancelMeme(sender: AnyObject) {
        
        topText.text = ""
        bottomText.text = ""
        imagePickerView.image = nil
        
    }
    
    @IBAction func shareMeme(sender: AnyObject) {
        
        
        let img: UIImage! = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        self.presentViewController(controller, animated: true, completion: nil)
        controller.completionWithItemsHandler = {
            (activityType, completed:Bool, returnedItems:[AnyObject]?, error: NSError?) in
            
            self.save()
            
            controller.dismissViewControllerAnimated(true, completion: nil)
            
        }
        
    }
    //IMAGE PICKER DELEGATE FUNCTIONS
    
    func imagePickerController(picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]){
        
        //print("here2")
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
                
                imagePickerView.image = image
                imagePickerView.contentMode = UIViewContentMode.ScaleAspectFill
                
                self.dismissViewControllerAnimated(true, completion:nil)
        }
        
    }
    
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
    
        
        self.dismissViewControllerAnimated(true, completion:nil)

        
    }
    
    //TEXTFIELD DELETAGE FUNCTIONS
    
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        if(textField.text == "TOP" || textField.text == "BOTTOM")
        {
            textField.text = "";
        }
        return true
    }
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //self.view.frame.origin.y += getKeyboardHeight
        return textField.resignFirstResponder()
    }
    
    
    //KEYBOARD FUNCTIONS
    
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        
    }
    
    func keyboardWillShow(notification: NSNotification){
        self.view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    func keyboardWillHide(notification: NSNotification){
        self.view.frame.origin.y += getKeyboardHeight(notification)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func unsubscribeFromKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillShowNotification, object:nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillHideNotification, object:nil)

    }
    
    func save() {
        //Create the meme
        let memedImage = generateMemedImage()
        let meme = Meme( tText: topText.text!, bText: bottomText.text!, origImage:
            imagePickerView.image!, memedImage: memedImage)
    }
    
    func generateMemedImage() -> UIImage
    {
        topBar.hidden = true
        bottomBar.hidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame,
                                     afterScreenUpdates: true)
        let memedImage : UIImage =
            UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        topBar.hidden = false
        bottomBar.hidden = false
        
        return memedImage
    }

}

