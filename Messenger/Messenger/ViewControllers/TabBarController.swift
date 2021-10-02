//
//  TabBarController.swift
//  Messenger
//
//  Created by Усман Туркаев on 03.10.2021.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        let searchVC = ViewController()
        searchVC.tabBarItem = searchItem
        let searchNav = UINavigationController(rootViewController: searchVC)
        
        let chatsItem = UITabBarItem(title: "Chats", image: UIImage(systemName: "message"), tag: 1)
        let chatsVC = ChatsListController()
        chatsVC.tabBarItem = chatsItem
        let chatsNav = UINavigationController(rootViewController: chatsVC)
        
        let accountItem = UITabBarItem(title: "Account", image: UIImage(systemName: "person.crop.circle"), tag: 2)
        let accountVC = ViewController()
        accountVC.tabBarItem = accountItem
        let accountNav = UINavigationController(rootViewController: accountVC)
        
        viewControllers = [searchNav, chatsNav, accountNav]

        selectedIndex = 1
    }


}
