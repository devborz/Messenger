//
//  SearchViewController.swift
//  Messenger
//
//  Created by Усман Туркаев on 03.10.2021.
//

import UIKit

class SearchViewController: UITableViewController {
    
    let searchController = UISearchController()

    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        navigationItem.title = "Search"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

}
