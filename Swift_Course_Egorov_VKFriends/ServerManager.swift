//
//  ServerManager.swift
//  Swift_Course_Egorov_VKFriends
//
//  Created by Илья Егоров on 17.11.16.
//  Copyright © 2016 Ilya Egorov. All rights reserved.
//

import UIKit
import Alamofire

class ServerManager: NSObject {
    
    static func getFriendsFor(_ userID: NSNumber, offset: Int, count: Int, completion: @escaping (_ success: Bool, _ friends: [User]) -> Void) {

        let parameters: [String: Any] = [
            "user_id": userID,
            "order": "name",
            "count": NSNumber(value: count),
            "offset": NSNumber(value: offset),
            "fields": "photo_50, online",
            "name_case": "nom"
        ]
        
        Alamofire.request(getFullURL("friends.get"), method: .get, parameters: parameters, encoding: URLEncoding.default)
            .responseJSON { response in
                guard let json = response.result.value as? [String: AnyObject],
					let dictsArray = json["response"] as? [[String: AnyObject]] else {
                    return completion(false, [])
                }
                
                var usersArray = [User]()
                
                for userInfo in dictsArray {
                    let user = User(userInfo)
                    usersArray.append(user)
                }
                completion(true, usersArray)
        }
    }
    
	static func getUserInfoFor(_ userID: NSNumber, completion: @escaping (_ success: Bool, _ user: User?, _ error: Error?) -> Void) {
        
        let parameters: [String: Any] = [
            "user_id": userID,
            "order": "name",
            "fields": "photo_50, online",
            "name_case": "nom"
        ]
 
        Alamofire.request(getFullURL("users.get"), method: .get, parameters: parameters, encoding: URLEncoding.default)
            .responseJSON { response in
				let error = response.error
                guard let json = response.result.value as? [String: AnyObject] else {
                    return completion(false, nil, error)
                }
                guard let dictsArray = json["response"] as? [[String: AnyObject]] else {
                    return completion(false, nil, error)
                }
                guard let userInfo = dictsArray.first else {
                    return completion(false, nil, error)
                }
                completion(true, User(userInfo), error)
        }
    }
    
    fileprivate static func getFullURL(_ relativeURLString: String) -> String {
        let urlString = "https://api.vk.com/method/" + relativeURLString
        return urlString
    }
}
