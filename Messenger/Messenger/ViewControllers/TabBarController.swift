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
        
        let searchItem = UITabBarItem(title: "Search", image: UIImage(systemName: "person.crop.circle"), tag: 0)
        let searchVC = SearchViewController()
        searchVC.tabBarItem = searchItem
        let searchNav = UINavigationController(rootViewController: searchVC)
        
        let chatsItem = UITabBarItem(title: "Chats", image: UIImage(systemName: "message"), tag: 1)
        let chatsVC = ChatsListController()
        chatsVC.tabBarItem = chatsItem
        let chatsNav = UINavigationController(rootViewController: chatsVC)
        
        let settingsItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 2)
        let settingsVC = SettingsViewController(style: .insetGrouped)
        settingsVC.tabBarItem = settingsItem
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        
        viewControllers = [searchNav, chatsNav, settingsNav]

        selectedIndex = 1
        
        tabBar.isTranslucent = true
        tabBar.backgroundColor = .systemBackground
    }


}
