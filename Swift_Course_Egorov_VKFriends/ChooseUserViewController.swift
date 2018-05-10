//
//  ChooseUserViewController.swift
//  Swift_Course_Egorov_VKFriends
//
//  Created by Илья Егоров on 18.11.16.
//  Copyright © 2016 Ilya Egorov. All rights reserved.
//

import UIKit

protocol ChooseUserDelegate: class {
    func didChooseID(_ id: NSNumber);
}

class ChooseUserViewController: UIViewController {

    let key = "kPreviousUserId"
    
    @IBOutlet weak var userIDTextField: UITextField!
    
    @IBAction func didChooseID(_ sender: UIButton) {
        guard let text = userIDTextField.text else {
            return
        }
        if let userId = Int(text) {
            if let delegate = delegate {
                delegate.didChooseID(NSNumber(value:userId))
            }
            UserDefaults.standard.set(text, forKey: key)
            self.dismiss(animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Ошибка", message: "Введите цифры!", preferredStyle: .actionSheet)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    weak var delegate: ChooseUserDelegate?
    
    override func viewDidLoad() {
        if let value = UserDefaults.standard.value(forKey: key) as? String {
            userIDTextField.text = value
        }
    }
}
