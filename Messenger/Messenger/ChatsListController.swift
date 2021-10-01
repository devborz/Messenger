//
//  MessagesController.swift
//  Pangea
//
//  Created by  AdamRouss🐺 on 22.02.2021.
//

import FirebaseFirestore
import UIKit

class ChatsListController: UITableViewController {
    
    var dataSource: ChatsListDiffableDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        ChatsService.shared.delegate = self
        
        navigationItem.title = NSLocalizedString("Chats", comment: "")
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.backButtonTitle = " "
        
        tableView.register(UINib(nibName: "ChatTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.dataSource = nil
        dataSource = .init(tableView: tableView, cellProvider: { tableView, indexPath, viewModel in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ChatTableViewCell
            cell.setup(viewModel)
            return cell
        })
        dataSource?.defaultRowAnimation = .top
        reload()
        setupStartConversation()
    }
    
    func setupStartConversation() {
        let startConversationItem = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(startConversationButtonTapped))
        navigationItem.rightBarButtonItem = startConversationItem
    }
    
    @objc
    func startConversationButtonTapped() {
        let vc = StartConversationViewController()
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .pageSheet
        vc.delegate = self
        self.present(navVC, animated: true, completion: nil)
    }
    
    func checkIfTableViewEmpty(_ contentEmpty: Bool) {
        if ChatsService.shared.didFirstLoad && contentEmpty {
//            let view = EmptyListMessage(frame: tableView.bounds)
//            view.setup(type: .chats)
//            tableView.backgroundView = view
        } else {
            tableView.backgroundView = nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard ChatsService.shared.lastVersion.count > indexPath.row else { return }
        let node = ChatsService.shared.lastVersion[indexPath.row]
        let vc = ChatController(node)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: NSLocalizedString("Delete", comment: ""), handler: { [weak self] _,_,_ in
            let alertVC = UIAlertController(title: nil, message: NSLocalizedString("Delete this chat?", comment: ""), preferredStyle: .actionSheet)
            let deleteAlertAction = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive) { _ in
                ChatsService.shared.deleteChat(indexPath.row)
            }
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
            alertVC.addAction(deleteAlertAction)
            alertVC.addAction(cancelAction)
            self?.present(alertVC, animated: true, completion: nil)
        })

        deleteAction.image = UIImage(systemName: "trash")

        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
}

extension ChatsListController: StartConversationViewControllerDelegate {
    func didSelectedUserWithID(_ user: User) {
        for node in ChatsService.shared.nodes {
            if node.otherUser.id == user.id {
                let vc = ChatController(node)
                navigationController?.pushViewController(vc, animated: true)
                return
            }
        }
        let vc = ChatController(.init(getChatWith: user))
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ChatsListController: ChatsServiceDelegate {
    @objc
    func update() {
        var snapshot = NSDiffableDataSourceSnapshot<ChatsListSection, ChatCellViewModel>()
        snapshot.appendSections([.allChats])
        let viewModels = ChatsService.shared.presentingChats
        snapshot.appendItems(viewModels, toSection: .allChats)
        dataSource?.apply(snapshot, animatingDifferences: true)
        checkIfTableViewEmpty(viewModels.isEmpty)
    }
    
    func reload() {
        var snapshot = NSDiffableDataSourceSnapshot<ChatsListSection, ChatCellViewModel>()
        snapshot.appendSections([.allChats])
        let viewModels = ChatsService.shared.presentingChats
        snapshot.appendItems(viewModels, toSection: .allChats)
        dataSource?.apply(snapshot, animatingDifferences: false)
        checkIfTableViewEmpty(viewModels.isEmpty)
    }
    
}

class ChatsListDiffableDataSource: UITableViewDiffableDataSource<ChatsListSection, ChatCellViewModel> {
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
