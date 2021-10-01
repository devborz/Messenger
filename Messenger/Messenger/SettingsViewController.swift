//
//  SettingsViewController.swift
//  Messenger
//
//  Created by Усман Туркаев on 21.08.2021.
//

import UIKit
import Firebase

class SettingsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Settings"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if indexPath.row == 0 {
            cell.textLabel?.text = "Sign out"
            cell.textLabel?.textColor = .red
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        signOut()
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
