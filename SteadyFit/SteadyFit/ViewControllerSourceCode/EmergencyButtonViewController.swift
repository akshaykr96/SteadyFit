//
//  EmergencyButtonViewController.swift
//  SteadyFit
//
//  Created by Raheem Mian on 2018-11-19.
//  Copyright © 2018 Daycar. All rights reserved.
//
//  Team Daycar
//  Edited by: Raheem Mian
//  Implemented to get current location and bring up iPhone build-in messaging app.
//
//  Edited by: Dickson Chum
//  Resolved unwrapping nil error
//
//  This is a subclass for the emergency button, so all of the emergency buttons on other ViewControllers
//  will inherit the methods from this class to check.
//
//  The emergency button is implemented to obtain iPhone's GPS location and bring up iPhone's messaging app with default or customize message.
//

import UIKit
import MessageUI
import MapKit
import CoreLocation
import FirebaseAuth
import FirebaseDatabase

class EmergencyButtonViewController: UIViewController, MFMessageComposeViewControllerDelegate, CLLocationManagerDelegate {
    var personalref:DatabaseReference?
    var personalrefHandle:DatabaseHandle?
    let personalcurrentuserID = (Auth.auth().currentUser?.uid)!
    var currentUserEmergencyNum: String?
    var emergencyMessage: String?
    var locationManager = CLLocationManager()
    @IBOutlet weak var emergencyButton: UIButton!
    
    @IBAction func emergencyButtonPressed(){
        /*this is called everytime the emergency button from any view controller is pressed*/
        personalref = Database.database().reference()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        self.personalref!.child("Users").child(personalcurrentuserID).observeSingleEvent(of: .value, with: {(snapshot) in
            let userDictionary = snapshot.value as? [String: AnyObject]
            if userDictionary != nil{
                self.currentUserEmergencyNum = userDictionary!["emergencycontact"] as? String
                self.emergencyMessage = userDictionary!["emergencymessage"] as? String
            }
            self.sendText()
        })
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        /*The message controller is dismissed once the message is either sent or the cancel button is pressed. It segues back
         to the screen where the emergency button was pressed*/
        controller.dismiss(animated: true, completion: nil)
    }
    
    func sendText() {
        /*This function is for bringing up the messsage controller once the emergency button is pressed
         and automatically putting a custom message and current location*/
        let composeVC = MFMessageComposeViewController()
        if(CLLocationManager.locationServicesEnabled()){
            /*get the coordinates for the person and put into a google link */
            locationManager.startUpdatingLocation()
            let locValue:CLLocationCoordinate2D = locationManager.location!.coordinate
            let gpsMessage = " This is my current location: " + "http://maps.google.com/maps?q=\(locValue.latitude),\(locValue.longitude)&ll=\(locValue.latitude),\(locValue.longitude)&z=17"
            /*if the emeregency message is set or not */
            if self.emergencyMessage != nil {
                composeVC.body = self.emergencyMessage! + gpsMessage
            }
            else{
                composeVC.body = "I need help!" + gpsMessage
            }
        }
        else{
            /*if location services is not enabled*/
            composeVC.body = "I need help!"
        }
        composeVC.messageComposeDelegate = self
        composeVC.recipients = [self.currentUserEmergencyNum] as? [String]
        if MFMessageComposeViewController.canSendText() {
            /*if the message view controller is available then send the text*/
            self.present(composeVC, animated: true, completion: nil)
        } else {
            print("Can't send messages.")
        }
    }
}
