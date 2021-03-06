//
//  CreatePrivateGroupViewController.swift
//  SteadyFit
//
//  Created by Raheem Mian on 2018-11-25.
//  Copyright © 2018 Daycar. All rights reserved.
//
//  Team Daycar
//  Edited by: Raheem Mian
//
//  CreatePrivateGroupViewController.swift is linked to the view for creating private group.
//


import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class CreatePrivateGroupViewController: EmergencyButtonViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    // Variables declaration
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var activityLevelTextField: UITextField!
    @IBOutlet weak var groupTypeTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var errorLabel: UILabel!
    var ref:DatabaseReference? = Database.database().reference()
    var refHandle:DatabaseHandle?
    var groupID: String = ""
    var myUserID = (Auth.auth().currentUser?.uid)!
    var myUserName: String = ""
    var picker = UIPickerView()
    var activityLevelArr = ["Very Light","Light", "Moderate", "Intense", "Very Intense"]
    var groupTypeArr = ["Public", "Private"]
    var activeTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextBoxes()
        picker.delegate = self
        picker.dataSource = self
        createPicker()
        activityLevelTextField.inputView = picker
        //get user name
        ref?.child("Users").child(myUserID).child("name").observeSingleEvent(of: .value, with: {(snapshot) in
            self.myUserName = (snapshot.value as? String)!
        })
    }
    
    func setTextBoxes() {
        //initializes all text boxes
        descriptionTextView.text = "Description"
        descriptionTextView.textColor = UIColor.lightGray
        descriptionTextView.layer.borderWidth = 1
        groupNameTextField.layer.borderWidth = 1
        activityLevelTextField.layer.borderWidth = 1
        groupTypeTextField.layer.borderWidth = 1
        groupTypeTextField.isEnabled = false
        groupTypeTextField.text = "Private"
        locationTextField.layer.borderWidth = 1
        descriptionTextView.delegate = self
        groupNameTextField.delegate = self
        activityLevelTextField.delegate = self
        groupTypeTextField.delegate = self
        locationTextField.delegate = self
        errorLabel.textColor = .red
        errorLabel.isHidden = true
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        //checks if any of the fields are left empty
        //if all fields are filled then it posts the information to the database
        //
        if (groupNameTextField.text?.isEmpty)! || (activityLevelTextField.text?.isEmpty)! || (groupTypeTextField.text?.isEmpty)! || (locationTextField.text?.isEmpty)! || (descriptionTextView.text.isEmpty) {errorLabel.isHidden = false}
        else{
            let chatId: String = (ref?.child("Chats").childByAutoId().key)!
            let key: String = (ref?.child("Groups").childByAutoId().key)!
            let post = ["/Groups/\(key)/activitylevel": activityLevelTextField.text!,
                        "/Groups/\(key)/chatid": chatId,
                        "/Groups/\(key)/description": descriptionTextView.text,
                        "/Groups/\(key)/grouptype": groupTypeTextField.text!,
                        "/Groups/\(key)/location": locationTextField.text!,
                        "/Groups/\(key)/name": groupNameTextField.text!,
                        "/Groups/\(key)/users/\(myUserID)": ["joined": 1, "name":myUserName],
                        "/Chats/\(chatId)/groupID" : key,
                        "/Users/\(myUserID)/Groups/\(key)": ["chatid": chatId, "grouptype":groupTypeTextField.text!, "name": groupNameTextField.text!]
                ] as [String : Any]
            ref?.updateChildValues(post)
            navigationController?.popViewController(animated: true)
        }
    }
    
    /*there are two picker views
     one for the different activity levels: very light, light, moderate, intense, very intense
     and one for the different group types : private or public
     below functions just differentiate which one shows up based on the textfield pressed
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return activityLevelArr.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return activityLevelArr[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        activityLevelTextField.text = activityLevelArr[row]
    }
    func createPicker(){
        //creates the picker view toolbar
        //adding a done button to resign the picker view
        let PickerToolBar = UIToolbar()
        PickerToolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneClicked))
        PickerToolBar.setItems([doneButton], animated: true)
        activityLevelTextField.inputAccessoryView = PickerToolBar
    }
    @objc func doneClicked() {
        self.view.endEditing(true)
    }
    
    /*----------------Resign Keyboard--------------------------*/
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        groupNameTextField.resignFirstResponder()
        locationTextField.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
        groupTypeTextField.resignFirstResponder()
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            descriptionTextView.resignFirstResponder()
            return false
        }
        return true
    }
    /*----------------------------------------------------*/

    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    /*add a animation to move the description text view above the keyboard
     therefore keyboard is no longer hiding the text view
     since there are no placeholders for textview
     have text in the colour of placeholder text in the view
     and then the text is nil once the user starts editing the text view*/
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        if(textView == descriptionTextView){
            moveTextView(textView, moveDistance: -250, up: true)
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        moveTextView(textView, moveDistance: -250, up: false)
    }
    
    func moveTextView(_ textView: UITextView, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
}
