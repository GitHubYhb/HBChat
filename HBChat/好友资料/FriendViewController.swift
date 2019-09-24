//
//  FriendViewController.swift
//  HBChat
//
//  Created by 尤鸿斌 on 2019/9/16.
//

import UIKit

class FriendViewController: UIViewController {

    var user_id:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "用户资料"
        view.backgroundColor = .groupTableViewBackground
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.tintColor = .black
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
