//
//  SettingsEditiorViewController.swift
//  SteadyFit
//
//  Created by Dickson Chum on 2018-11-04.
//  Copyright © 2018 Daycar. All rights reserved.
//
//  Team Daycar
//  Edited by: Alexa Chen, Yimin Long
//  List of Changes: User can edit their profile
//
//  Edited by: Dickson Chum
//  List of Changes: implemented logout feature with Firebase
//
//  SettingsEditiorViewController.swift is corresponding to Edit Profile section in Settings.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SettingsEditiorViewController: EmergencyButtonViewController, UITextFieldDelegate {
    // Variables and objects declaration
    var ref:DatabaseReference?
    var refHandle:DatabaseHandle?
    let currentuserID = (Auth.auth().currentUser?.uid)!
    var currentUserCity: String?
    var currentUserProvince: String?
    var currentUserActivityLevel: String?
    var currentUserGender: String?
    var currentUserBio: String?
    var currentUserBirthday: String?
    let datePicker = UIDatePicker()
    
    @IBAction func BioTextField(_ sender: UITextField) {}
    @IBAction func GenderTextField(_ sender: UITextField) {}
    @IBAction func BirthdayTextField(_ sender: UITextField) {}
    @IBAction func CityTextField(_ sender: UITextField) {}
    @IBAction func ProvinceTextField(_ sender: UITextField) {}
    @IBAction func ActivityLevelTextField(_ sender: UITextField) {}
    @IBOutlet var editProfileDatePicker: UITextField!
    @IBOutlet weak var provinceTextBox: UITextField!
    @IBOutlet weak var nameLabel: UIStackView!
    
    @IBOutlet weak var cityTextBox: UITextField!
    let cityList = ["", "Vancouver", "Burnaby", "Coquitlam", "Surrey", "Richmond"]
    var selectCity: String?
    let cityPicker = UIPickerView()
    
    @IBOutlet weak var bioTextBox: UITextField!
    let provinceList = ["", "BC"]
    var selectProvince: String?
    let provincePicker = UIPickerView()
    
    @IBOutlet weak var activityLevelTextBox: UITextField!
    let levelList = ["", "Very light", "Light", "Moderate", "Intense", "Very intense"]
    var selectLevel: String?
    let levelPicker = UIPickerView()
    
    @IBOutlet weak var genderTextBox: UITextField!
    let genderList = ["", "Male", "Female", "Prefer not to say"]
    var selectGender: String?
    let genderPicker = UIPickerView()
    
    // Logout action when logoutButton is clicked, present loginViewController when user is logged out
    @IBAction func logoutButton(_ sender: UIButton) {
        print("Before logout, User is ", Auth.auth().currentUser as Any)
        do{
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        print("After logout, User is ", Auth.auth().currentUser as Any)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        self.present(loginViewController, animated: true, completion: nil)
    }
    
    // Load view
    override func viewDidLoad() {
        super.viewDidLoad()
        createDatePicker()
        createCityPicker()
        createCityToolBar()
        createProvincePicker()
        createLevelPicker()
        createGenderPicker()
        self.bioTextBox.delegate = self
        ref = Database.database().reference()
        
        self.ref!.child("Users").child(currentuserID).observeSingleEvent(of: .value, with: {(snapshot) in
            let userDictionary = snapshot.value as? [String: AnyObject]
            print (snapshot)
            if userDictionary != nil{
                self.currentUserCity = userDictionary!["city"] as? String
                self.currentUserProvince = userDictionary!["province"] as? String
                self.currentUserActivityLevel = userDictionary!["activitylevel"] as? String
                self.currentUserGender = userDictionary!["gender"] as? String
                self.currentUserBio = userDictionary!["description"] as? String
                self.currentUserBirthday = userDictionary!["birthdate"] as? String
            }
            DispatchQueue.main.async{
                self.cityTextBox.text = self.currentUserCity
                self.provinceTextBox.text = self.currentUserProvince
                self.activityLevelTextBox.text = self.currentUserActivityLevel
                self.genderTextBox.text = self.currentUserGender
                self.bioTextBox.text = self.currentUserBio
                self.editProfileDatePicker.text = self.currentUserBirthday
            }
        })
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        // Save button action upon click
        if cityTextBox.text != nil && editProfileDatePicker.text != nil && provinceTextBox.text != nil && activityLevelTextBox.text != nil && genderTextBox.text != nil && bioTextBox.text != nil{
            let newUserInfo = ["/Users/\(currentuserID)/birthdate": editProfileDatePicker.text!,
                               "/Users/\(currentuserID)/city": cityTextBox.text!,
                               "/Users/\(currentuserID)/province": provinceTextBox.text!,
                               "/Users/\(currentuserID)/activitylevel": activityLevelTextBox.text!,
                               "/Users/\(currentuserID)/gender": genderTextBox.text!,
                               "/Users/\(currentuserID)/description": bioTextBox.text!
                ] as [String:Any]
            ref?.updateChildValues(newUserInfo)
            navigationController?.popViewController(animated: true)
        }
    }
    
    // Birthday date picker
    func createDatePicker()
    {
        editProfileDatePicker.inputView = datePicker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneClick))
        toolbar.setItems([doneButton], animated: true)
        editProfileDatePicker.inputAccessoryView = toolbar
        datePicker.datePickerMode = .date
    }
    
    // Date picker done button and format for date
    @objc func doneClick()
    {
        let editDateFormatter = DateFormatter()
        editDateFormatter.dateFormat = "yyyy-MM-dd"
        editProfileDatePicker.text = editDateFormatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    
    // City picker
    func createCityPicker()
    {
        cityPicker.delegate = self
        cityTextBox.inputView = cityPicker
    }
    
    // Province picker
    func createProvincePicker()
    {
        provincePicker.delegate = self
        provinceTextBox.inputView = provincePicker
    }
    
    // Activity level picker
    func createLevelPicker()
    {
        levelPicker.delegate = self
        activityLevelTextBox.inputView = levelPicker
    }
    
    // Gender picker
    func createGenderPicker()
    {
        genderPicker.delegate = self
        genderTextBox.inputView = genderPicker
    }
    
    // Click return button on keyboard would hide keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // Done button for city, province, gender, level pickers
    func createCityToolBar()
    {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(SettingsEditiorViewController.dismissKeyboard))
        
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        cityTextBox.inputAccessoryView = toolBar
        provinceTextBox.inputAccessoryView = toolBar
        activityLevelTextBox.inputAccessoryView = toolBar
        genderTextBox.inputAccessoryView = toolBar
    }
    
    // Hide keyboard after editing text
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}

// Pickers view extension
extension SettingsEditiorViewController: UIPickerViewDelegate, UIPickerViewDataSource
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        
        if (pickerView === cityPicker)
        {
            return cityList.count
        }
            
        else if(pickerView === provincePicker)
        {
            return provinceList.count
        }
            
        else if(pickerView === levelPicker)
        {
            return levelList.count
        }
            
        else if(pickerView === genderPicker)
        {
            return genderList.count
        }
        else
        {
            return 2
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        if (pickerView === cityPicker)
        {
            return cityList[row]
        }
        else if(pickerView === provincePicker)
        {
            return provinceList[row]
        }
        else if(pickerView === levelPicker)
        {
            return levelList[row]
        }
        else if(pickerView === genderPicker)
        {
            return genderList[row]
        }
        else
        {
            return "N"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if (pickerView === cityPicker)
        {
            selectCity = cityList[row]
            cityTextBox.text = selectCity
        }
        else if(pickerView === provincePicker)
        {
            selectProvince = provinceList[row]
            provinceTextBox.text = selectProvince
        }
        else if(pickerView === levelPicker)
        {
            selectLevel = levelList[row]
            activityLevelTextBox.text = selectLevel
        }
            
        else if(pickerView === genderPicker)
        {
            selectGender = genderList[row]
            genderTextBox.text = selectGender
        }
    }
}
