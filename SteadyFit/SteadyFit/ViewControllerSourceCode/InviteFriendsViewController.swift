//
//  InviteFriendsViewController.swift
//  SteadyFit
//
//  Created by Raheem Mian on 2018-11-23.
//  Copyright © 2018 Daycar. All rights reserved.
//
//  Team Daycar
//
//  Edited by: Alexa Chen
//  Read and write from database (load friends who are not in the group, invite friend)
//
//  InviteFriendsViewController.swift allows user to invite his/her friends into a group.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class InviteFriendsViewController: EmergencyButtonViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var inviteUserTableView: UITableView!
    var ref:DatabaseReference? = Database.database().reference()
    var friendsInviteList: [String] = []
    var friendsIdList: [String] = []
    var groupId = ""
    var usersInCurrentGroup: [String] = []
    let currentuserID = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inviteUserTableView.delegate = self
        inviteUserTableView.dataSource = self
        inviteUserTableView.tableFooterView = UIView()
        
        if currentuserID != nil {
            // load friends who are not already in the group
            ref?.child("Users").child(currentuserID!).child("Friends").observe(.value, with: { (snapshot) in
                self.friendsInviteList.removeAll()
                self.friendsIdList.removeAll()
                for rest in snapshot.children.allObjects as! [DataSnapshot]{
                    guard let dictionary = rest.value as? [String: AnyObject] else {continue}
                    let friendName = dictionary["name"] as?String
                    let friendId = rest.key
                    let isUserAlreadyInGroup = self.usersInCurrentGroup.contains(friendId)
                    if (friendName != nil && friendId != "" && !isUserAlreadyInGroup){
                        self.friendsInviteList.append(friendName!)
                        self.friendsIdList.append(friendId)
                    }
                }
                DispatchQueue.main.async() {
                    self.inviteUserTableView.reloadData()
                }
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsInviteList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Creating the plus sign in the table view cell to indicate that a user can be invited
        let cell = inviteUserTableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        let image = UIImage(named: "plus")
        let button = UIButton()
        button.frame = CGRect(x: view.bounds.maxX - 44, y: 0, width: 44, height: 44)
        button.setImage(image, for: .normal)
        button.tag = indexPath.row
        button.addTarget(self, action: #selector(inviteButtonPressed), for: .touchUpInside)
        button.showsTouchWhenHighlighted = true
        cell.textLabel?.text = friendsInviteList[indexPath.row]
        cell.contentView.addSubview(button)
        return cell
    }
    
    @objc func inviteButtonPressed(sender: UIButton!){
        // When the invite button is pressed then the original image
        //of a checkmark is changed to a checkmark and the user is written to the database
        let image = UIImage(named: "checkmark")
        sender.setImage(image, for: .normal)
        let invitedUserId = friendsIdList[sender.tag]
        let invitedUserName = friendsInviteList[sender.tag]
        if (groupId != "" && invitedUserId != "" && invitedUserName != ""){
            let post = [ "/Groups/\(groupId)/users/\(invitedUserId)":
                ["name":invitedUserName, "joined":0]] as [String : Any]
            ref?.updateChildValues(post)
        }
    }
}
