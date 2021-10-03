//
//  AccountViewController.swift
//  Messenger
//
//  Created by Усман Туркаев on 03.10.2021.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Settings"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        setupCells()
    }
    
    func setupCells() {
        tableView.register(UINib(nibName: "CurrentAccountCell", bundle: nil), forCellReuseIdentifier: "account")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "account", for: indexPath) as! CurrentAccountCell
            cell.setup()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            var config = cell.defaultContentConfiguration()
            config.text = "Sign Out"
            config.textProperties.color = .red
            cell.contentConfiguration = config
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            signOut()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 120
        }
        return 40
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let vc = LoginViewController()
        let navigationController = UINavigationController(rootViewController: vc)
        
        guard let window = appDelegate.window else { return }
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        UIView.transition(with: window,
                              duration: 0.3,
                              options: .transitionCrossDissolve,
                              animations: nil,
                              completion: nil)
    }

}
