//
//  MemeEditorViewController
//  MemeMe
//
//  Created by Rajat Sharma on 4/8/16.
//  Copyright © 2016 Rajat Sharma. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // MARK: - Outlets

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
    
    
    
  // MARK: - Lifecycle Functions
    
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
        
        
        setupTextField(topText, defaultText: "TOP")
        setupTextField(bottomText, defaultText: "BOTTOM")
    
        
        
        topText.defaultTextAttributes = memeTextAttributes
        bottomText.defaultTextAttributes = memeTextAttributes
        
        topText.textAlignment = .Center
        bottomText.textAlignment = .Center
        
        
        
        
        
        
    }

    override func viewWillAppear(animated: Bool) {
        
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        subscribeToKeyboardNotifications()
        
        if((imagePickerView.image == nil)){
            
            share.enabled = false
        }
        else{
            share.enabled = true
        }
        
        
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        unsubscribeFromKeyboardNotifications()
    }
    
    //MARK: - IBAction Functions
    
    @IBAction func pickAnImage(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        if(sender.tag == 1){
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        else if(sender.tag == 2){
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        }
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
            
            if(completed){
             self.save()
            }
            
            controller.dismissViewControllerAnimated(true, completion: nil)
            
        }
        
    }
    
    
    //MARK: - IMAGE PICKER DELEGATE FUNCTIONS
    
    func imagePickerController(picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]){
        
   
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
                
                imagePickerView.image = image
                imagePickerView.contentMode = UIViewContentMode.ScaleAspectFit
                
                dismissViewControllerAnimated(true, completion:nil)
        }
        
    }
    
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
    
        
        dismissViewControllerAnimated(true, completion:nil)

        
    }
    
    //MARK: - TEXTFIELD DELETAGE FUNCTIONS
    
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        if(textField.text == "TOP" || textField.text == "BOTTOM")
        {
            textField.text = "";
        }
        return true
    }
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        return textField.resignFirstResponder()
    }
    
    
    //// MARK: - Keyboard Functions
    
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        
    }
    
    func keyboardWillShow(notification: NSNotification){
        if(bottomText.isFirstResponder()){
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification){
        
        if(bottomText.isFirstResponder()){
            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
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
    
    //MARK - HELPER FUNCTION
    func setupTextField(textField: UITextField, defaultText: String) {
        
        //Do formatting here
        textField.delegate = self
        textField.text = defaultText
        //etc.
    }

}

