//
//  FriendsTableViewController.swift
//  Swift_Course_Egorov_VKFriends
//
//  Created by Илья Егоров on 17.11.16.
//  Copyright © 2016 Ilya Egorov. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class FriendsTableViewController: UITableViewController, ChooseUserDelegate {

    fileprivate let friendsInRequest = 20
    fileprivate var friends: [User] = []
    
    var currentUser: User?
    
    fileprivate var allDownloaded = false
    
    override func viewDidLoad() {

        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(FriendsTableViewController.refresh), for: UIControlEvents.valueChanged)
        tableView.refreshControl = refresh
        
        if let user = currentUser {
            navigationItem.title = user.fullName
            getFriends()
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "ChooseUserViewController") as? ChooseUserViewController {
                vc.delegate = self
                navigationController?.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func refresh() {
        friends.removeAll()
        getFriends()
    }
    
    // MARK: ChooseUserDelegate
    
    func didChooseID(_ userId: NSNumber) {
        ServerManager.getUserInfoFor(userId, completion: { [weak self] (success, user) in
            if let user = user {
                guard let strongSelf = self else {
                    return
                }
                strongSelf.currentUser = user
                strongSelf.navigationItem.title = user.fullName
                strongSelf.getFriends()
            }
            })
    }
    
    // MARK: Функции получения данных
    
    func getFriends() {
        if let user = currentUser, let userId = user.userId {
            ServerManager.getFriendsFor(userId, offset: friends.count, count: friendsInRequest, completion: {[weak self] (success, newFriends) in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.allDownloaded = newFriends.count < strongSelf.friendsInRequest
                strongSelf.friends.append(contentsOf: newFriends)
                strongSelf.tableView.reloadData()
                if let refresh = strongSelf.tableView.refreshControl {
                    refresh.endRefreshing()
                }
            })
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath)

        if let userCell = cell as? UserTableViewCell {

            guard indexPath.row < friends.count else {
                tableView.reloadData()
                return cell
            }
            let user = friends[indexPath.row]
            
            userCell.userNameLabel.text = user.fullName
            
            if let imagePath = user.avatarImageURLString {
                if userCell.imagePath != imagePath {
                    userCell.avatarImageView.image = nil
                    userCell.imagePath = imagePath
                    Alamofire.request(imagePath).responseImage { response in
                        guard let image = response.result.value else {
                            return
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                            if imagePath == userCell.imagePath {
                                userCell.avatarImageView.image = image.af_imageRounded(withCornerRadius: 4)
                            }
                        }
                    }
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == friends.count - 1 && !allDownloaded {
            getFriends()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "FriendsTableViewController") as? FriendsTableViewController {
            let user = friends[indexPath.row];
            vc.currentUser = user
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
