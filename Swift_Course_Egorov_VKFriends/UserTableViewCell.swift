//
//  UserTableViewCell.swift
//  Swift_Course_Egorov_VKFriends
//
//  Created by Илья Егоров on 17.11.16.
//  Copyright © 2016 Ilya Egorov. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var imagePath: String?
}
