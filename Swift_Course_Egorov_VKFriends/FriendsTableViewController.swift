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
		super.viewDidLoad()
		
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(FriendsTableViewController.refresh), for: .valueChanged)
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
    
    @objc func refresh() {
        friends.removeAll()
        getFriends()
    }
    
    // MARK: ChooseUserDelegate
    
    func didChooseID(_ userId: NSNumber) {
        ServerManager.getUserInfoFor(userId, completion: { [weak self] (success, user, error) in
			if let error = error {
				let alert = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
				self?.present(alert, animated: true, completion: nil)
				return
			}
			guard let user = user else {
				return
			}
			self?.currentUser = user
			self?.navigationItem.title = user.fullName
			self?.getFriends()
		})
    }
    
    // MARK: Функции получения данных
    
    func getFriends() {
		guard let user = currentUser, let userId = user.userId else { return }
		ServerManager.getFriendsFor(userId, offset: friends.count, count: friendsInRequest, completion: {[weak self] (success, newFriends) in
			self?.allDownloaded = newFriends.count < (self?.friendsInRequest ?? 0)
			self?.friends.append(contentsOf: newFriends)
			self?.tableView.reloadData()
			if let refresh = self?.tableView.refreshControl {
				refresh.endRefreshing()
			}
		})
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath) as? UserTableViewCell else { return UITableViewCell() }

		guard indexPath.row < friends.count else {
			tableView.reloadData()
			return cell
		}
		
		let user = friends[indexPath.row]
		
		cell.userNameLabel.text = user.fullName
		
		guard let imagePath = user.avatarImageURLString, cell.imagePath != imagePath else { return cell }
		cell.avatarImageView.image = nil
		cell.imagePath = imagePath
		Alamofire.request(imagePath).responseImage { response in
			guard let image = response.result.value else {
				return
			}
			DispatchQueue.main.asyncAfter(deadline: .now()) {
				if imagePath == cell.imagePath {
					cell.avatarImageView.image = image.af_imageRounded(withCornerRadius: 4)
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
