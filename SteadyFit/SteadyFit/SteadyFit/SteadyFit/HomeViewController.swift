//
//  HomeViewController.swift
//  SteadyFit
//
//  Created by Raheem Mian on 2018-10-23.
//  Copyright © 2018 Daycar. All rights reserved.
//
//  Team Daycar
//  Edited by: Raheem Mian, Akshay Kumar, Dickson Chum
//  List of Changes: added labels, table and arrays for table, created segues for table view, implemented to obtain GPS coordinate from device and bring up iPhone Messages with default message.
//
//  HomeViewController.swift is connected to the first Home Screen of the UI, which shows the User's profile, activity tracker, events and emergency button.
//  The emergency button is implemented to obtain iPhone's GPS location and bring up iPhone's messaging app with a default message.
//  Make sure you test the emergency button when you download the app on your mobile device

import UIKit
import Foundation
import MessageUI
import MapKit
import CoreLocation
import Firebase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate, CLLocationManagerDelegate{
    var ref:DatabaseReference?
    var eventIDs = [String]()
    let currentuserID = (Auth.auth().currentUser?.uid)!
    
    var locationManager = CLLocationManager()
    let homeTableSections = ["Activity Tracker", "Events"]
    var homeTableContents = [ ["Histogram"] , ["Event A", "Event B", "Event C"]]
    @IBAction func emergencyButton(_ sender: Any) {
        sendText()
    }
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profilePictureImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        /*initializing the tables and the locations*/
        myTableView.tableFooterView = UIView(frame: .zero)
        myTableView.delegate = self
        myTableView.dataSource = self
        profilePictureImage.layer.cornerRadius = profilePictureImage.frame.size.width / 2
        profilePictureImage.clipsToBounds = true
            locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        
        ref = Database.database().reference()
        self.ref?.child("Users/\(currentuserID)").observe(DataEventType.value, with: {
            (userSnapshot) in
            if userSnapshot.value != nil{
                let userDictionary = userSnapshot.value as? [String: AnyObject]
                self.name.text = userDictionary!["name"] as? String
                self.city.text = userDictionary!["city"] as? String
            }
        })
        self.ref?.child("Activities_Events").observe(DataEventType.value, with: {
            (snapshot) in
            self.eventIDs.removeAll()
            self.homeTableContents[1].removeAll()
            for sessionSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
                if sessionSnapshot.childSnapshot(forPath: "Participants/\(self.currentuserID)").value != nil{
                    guard let sessionDictionary = sessionSnapshot.value as? [String: AnyObject] else {continue}
                    self.homeTableContents[1].append((sessionDictionary["event_name"] as? String)!)
                    self.eventIDs.append(sessionSnapshot.key)
                }
            }
            DispatchQueue.main.async() {
                self.myTableView.reloadData()
            }
        })
    }
    /*-----------------------------------Location-------------------------------------------------------------*/
    /*-----------------------------------Table----------------------------------------------------------------*/
    func numberOfSections(in tableView: UITableView) -> Int {
        return homeTableSections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        /*return table header name*/
        return homeTableSections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*return the number of rows in for a section*/
        return homeTableContents[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*return the name for the cell*/
        let cell  = tableView.dequeueReusableCell(withIdentifier: "homeTableCell", for:  indexPath)
        cell.textLabel?.text = homeTableContents[indexPath.section][indexPath.row]
        return cell
    }
    
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    /*Go either to the event view controller or the histogram view controller*/
        performSegue(withIdentifier: homeTableSections[indexPath.section], sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*This function provides the header for the navigation bar in the histogram view controller and the
         events view controller based on the name of the cell pressed*/
        var indexPath = self.myTableView.indexPathForSelectedRow!
        if(indexPath.section == 0){
            let destination = segue.destination as! HistogramViewController
            destination.navigationItem.title = homeTableContents[indexPath.section][indexPath.row]
        }
        else{
            let destination = segue.destination as! UserEventsViewController
            destination.navigationItem.title = homeTableContents[indexPath.section][indexPath.row]
            destination.eventId = eventIDs[indexPath.row] // Raheem, if you have a variable called eventId in the UserEventsViewController, just uncomment this line and it will set the variable to the correct value
            
        }
    }
    
   /* func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: tableView.frame.width - 30, height: 50)
        button.setTitle("Open", for: .normal)
        button.backgroundColor = .black
        button.addTarget(self, action: Selector(("SegueToEvents:")), for: UIControl.Event.touchUpInside)
        view.addSubview(button)
        return view
    }
    func SegueToEvents(sender: AnyObject){
        print("Hi")
    }*/
    /*-----------------------------------Messaging----------------------------------------------------------------*/
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
             composeVC.body = "I need help! This is my current location: " + "http://maps.google.com/maps?q=\(locValue.latitude),\(locValue.longitude)&ll=\(locValue.latitude),\(locValue.longitude)&z=17"
        }
        else{
            /*if location services is not enabled*/
            composeVC.body = "I need help!"
        }
        composeVC.messageComposeDelegate = self
        composeVC.recipients = ["7788823644"]
        if MFMessageComposeViewController.canSendText() {
            /*if the message view controller is available then send the text*/
            self.present(composeVC, animated: true, completion: nil)
        } else {
    
            print("Can't send messages.")
        }
    }
     /*-----------------------------------END Messaging----------------------------------------------------------------------*/

}
