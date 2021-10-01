//
//  StartConversationViewController.swift
//  Pangea
//
//  Created by  AdamRouss🐺 on 08.05.2021.
//

import UIKit

class StartConversationViewController: UITableViewController {
    
    weak var delegate: StartConversationViewControllerDelegate?
    
    var viewModel: StartConversationViewModel!
    
    var cancelBarItem: UIBarButtonItem!
    
    var searchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Start conversation", comment: "")
        navigationItem.largeTitleDisplayMode = .never
        
        cancelBarItem = .init(barButtonSystemItem: .cancel, target: self, action: #selector(cancelItemTapped))
        navigationItem.leftBarButtonItem = cancelBarItem
        
        searchController = .init()
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        
        viewModel = .init()
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "PersonCell")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()
        viewModel.presentingUsers.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    @objc
    func cancelItemTapped() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.presentingUsers.value.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell", for: indexPath) as! UserCell
        cell.setup(viewModel.presentingUsers.value[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.dismiss(animated: true) {
            self.delegate?.didSelectedUserWithID(self.viewModel.presentingUsers.value[indexPath.row].user)
        }
    }

}

extension StartConversationViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            viewModel.showAll()
            return
        }
        viewModel.searchStartingWith(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.showAll()
    }
}

class StartConversationViewModel {
    
    var users: [User] = []

    var presentingUsers: PredefinedObservable<[UserCellViewModel]> = PredefinedObservable([])
    
    init() {
        DatabaseManager.shared.getUsers { [weak self] users
            var viewModels: [UserCellViewModel] = []
            for user in users {
                if user.id != DBManager.shared.currentUserID {
                    viewModels.append(.init(with: user))
                }
            }
            self?.users = users
            self?.presentingUsers.value = viewModels
        }
    }
    
    func searchStartingWith(_ text: String) {
        let text = text.lowercased()
        var viewModels: [UserCellViewModel] = []
        for user in users {
            if user.username.contains(text) {
                viewModels.append(.init(with: user))
            }
        }
        self.presentingUsers.value = viewModels
    }
    
    func showAll() {
        var viewModels: [UserCellViewModel] = []
        for user in users {
                viewModels.append(.init(with: user))
        }
        self.presentingUsers.value = viewModels
    }
}

protocol StartConversationViewControllerDelegate: AnyObject {
    func didSelectedUserWithID(_ user: User)
    
}
