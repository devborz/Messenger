//
//  ChatController.swift
//  Pangea
//
//  Created by  AdamRouss🐺 on 22.02.2021.
//
import UIKit

final class ChatController: UIViewController {
    
    var node: ChatNode
    
    var tableView: FiTableView<ChatContent>!
    
    var inputBar = InputBarView()
    
    var inputBarBottomConstraint: NSLayoutConstraint!
    
    var keyboardIsShown = false
    
    var firstLoad = true
    
    var titleView: UsernameTitleView!
    
    var titleViewModel: UsernameTitleViewModel!
    
    var avatarItem: UIBarButtonItem!
    
    var avatarView: ChatTopAvatarView!
    
    var avatarViewModel: ChatTopAvatarViewModel!
    
    var selectedImageMessageID: String!
    
    var selectedImageCell: PhotoMessageCell!
    
    var imageAnimator: ImageShowAnimator!
    
    init(_ node: ChatNode) {
        self.node = node
        super.init(nibName: nil, bundle: nil)
        node.delegate = self
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        node.delegate = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        navigationItem.backButtonTitle = " "
        navigationItem.largeTitleDisplayMode = .never
        setupTableView()
        setupGestures()
        setupNavBar()
        setupInputBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addKeyboardObservers()
        node.startReading()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideKeyboard()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        node.endReading()
        removeKeyboardObservers()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        hideKeyboard()
        inputBarBottomConstraint.constant = 0
    }
    
    func setupNavBar() {
        let user = node.otherUser
        titleViewModel = .init(user)
        titleView = .init(titleViewModel)
        titleView.delegate = self
        
        navigationItem.titleView = titleView
    }
    
    func setupTableView() {
        tableView = .init({ [weak self] tableView, indexPath, content in
            guard let self = self else { return nil }
            switch content.type {
            case .message(value: let viewModel):
                switch viewModel.model.attachment {
                case .image:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "image", for: indexPath) as! PhotoMessageCell
                    cell.setup(viewModel)
                    cell.transform = CGAffineTransform(rotationAngle: .pi)
                    cell.selectionStyle = .none
                    cell.delegate = self
                    return cell
                case .location:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "location", for: indexPath) as! LocationMessageCell
                    cell.setup(viewModel)
                    cell.transform = CGAffineTransform(rotationAngle: .pi)
                    cell.selectionStyle = .none
                    cell.delegate = self
                    return cell
                case .event:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "event", for: indexPath) as! EventMessageCell
                    cell.setup(viewModel)
                    cell.transform = CGAffineTransform(rotationAngle: .pi)
                    cell.selectionStyle = .none
                    cell.delegate = self
                    return cell
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "text", for: indexPath) as! TextMessageCell
                    cell.setup(viewModel)
                    cell.transform = CGAffineTransform(rotationAngle: .pi)
                    cell.selectionStyle = .none
                    return cell
                }
            case .header(value: let value):
                let cell = tableView.dequeueReusableCell(withIdentifier: "date", for: indexPath) as! MessagesDateHeaderView
                cell.setup(value.date)
                cell.transform = CGAffineTransform(rotationAngle: .pi)
                cell.selectionStyle = .none
                return cell
            case .seenIndicator(value: let _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "seen", for: indexPath) as! SeenIndicatorCell
                cell.transform = CGAffineTransform(rotationAngle: .pi)
                cell.selectionStyle = .none
                return cell
            }
        })
        
        tableView.delegate = self
        tableView.register(TextMessageCell.self, forCellReuseIdentifier: "text")
        tableView.register(PhotoMessageCell.self, forCellReuseIdentifier: "image")
        tableView.register(LocationMessageCell.self, forCellReuseIdentifier: "location")
        tableView.register(SeenIndicatorCell.self, forCellReuseIdentifier: "seen")
        tableView.register(MessagesDateHeaderView.self, forCellReuseIdentifier: "date")
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        tableView.transform = CGAffineTransform(rotationAngle: .pi)
        
        tableView.verticalScrollIndicatorInsets.right = view.frame.width - 9
        
        tableView.separatorStyle = .none
        
        reloadChat()
    }
    
    func setupInputBar() {
        inputBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputBar)
        inputBar.topAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true
        inputBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        inputBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        inputBarBottomConstraint = inputBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        inputBarBottomConstraint.isActive = true
        
        inputBar.delegate = self
    }
    
    func setupGestures() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.tableView.addGestureRecognizer(gesture)
    }
    
    @objc
    func hideKeyboard() {
        self.inputBar.textView.resignFirstResponder()
    }
    
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    func keyboardWillShow(_ notification: NSNotification) {
        
    }
    
    @objc
    func keyboardWillChange(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }

        guard let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        guard let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else { return }
        
        let bottomBarHeight = view.frame.height - view.safeAreaLayoutGuide.layoutFrame.maxY
        inputBarBottomConstraint.constant = -endFrame.height + bottomBarHeight
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            
        }
    }
    
    @objc
    func keyboardWillHide(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        guard let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else { return }
        
        inputBarBottomConstraint.constant = 0
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            
        }
    }
    
    @objc
    func actionsItemTapped() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let blockAction = UIAlertAction(title: "Block", style: .destructive) { action in
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            
        }
        
        alertController.addAction(blockAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension ChatController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let content = node.chatContent[indexPath.row]
        switch content.type {
        case .message(value: let value):
            let id = "\(indexPath.row)" as NSString
            let config = UIContextMenuConfiguration(identifier: id, previewProvider: nil) { actions in
                var actions: [UIAction] = []
                let deleteAction = UIAction(title: NSLocalizedString("Delete for me", comment: ""), image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                    guard let strongSelf = self else { return }
                    strongSelf.node.deleteMessage(value)
                }
                actions.append(deleteAction)
                return UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: actions)
            }
            return config
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return contextMenuTargetPreview(configuration)
    }
    
    func tableView(_ tableView: UITableView,
        previewForHighlightingContextMenuWithConfiguration
        configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return contextMenuTargetPreview(configuration)
    }
    

    private func contextMenuTargetPreview(_ configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let identifier = configuration.identifier as? String,
              let index = Int(identifier),
              let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) else {
            return nil
        }
        if let photo = cell as? PhotoMessageCell {
            return UITargetedPreview(view: photo.photoImageView)
        } else if let location = cell as? LocationMessageCell {
            return UITargetedPreview(view: location.mapView)
        } else if let message = cell as? MessageCell {
            return UITargetedPreview(view: message.bubbleView)
        } else {
            return nil
        }
    }
}

extension ChatController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension ChatController: InputBarViewDelegate {
    func sendButtonTapped(_ text: String) {
        if !node.messages.isEmpty {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        node.sendMessage(.text(text: text))
    }
    
    func attachButtonTapped() {
        hideKeyboard()
        let photoAction = UIAlertAction(title: NSLocalizedString("Photo", comment: ""), style: .default) { _ in
            let vc = FiImagePickerController(1, maxLimit: 5, needToCrop: false)
            vc.delegate = self
            vc.rightButtonName = NSLocalizedString("Send", comment: "")
            let navVC = UINavigationController(rootViewController: vc)
            navVC.modalTransitionStyle = .coverVertical
            navVC.modalPresentationStyle = .formSheet
            self.present(navVC, animated: true, completion: nil)
        }
        let geoAction = UIAlertAction(title: NSLocalizedString("Geolocation", comment: ""), style: .default) { _ in
            let vc = LocationPickerController()
            vc.delegate = self
            let navVC = UINavigationController(rootViewController: vc)
            navVC.modalTransitionStyle = .coverVertical
            navVC.modalPresentationStyle = .formSheet
            self.present(navVC, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(photoAction)
        alertController.addAction(geoAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension ChatController: FiImagePickerControllerDelegate {
    func didSelect(_ controller: FiImagePickerController, images: [UIImage]) {
        controller.navigationController?.dismiss(animated: true, completion: nil)
        
        guard !images.isEmpty else { return }
        
        if !node.messages.isEmpty {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
        }
        for image in images {
            node.sendMessage(.image(image: image))
        }
    }
}

extension ChatController: LocationPickerControllerDelegate {
    func didSelectLocation(_ pickerController: LocationPickerController, location: Location) {
        pickerController.navigationController?.dismiss(animated: true, completion: nil)
        
        if !node.messages.isEmpty {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
        }
        node.sendMessage(.location(location: location))
    }
}

extension ChatController: UsernameTitleViewDelegate {
    func titleViewTapped(userID: String) {
//        guard userID != DBManager.shared.currentUserID else { return }
//        let vc = ProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
//        vc.userID = userID
//        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ChatController: MessageCellDelegate {
    func photoWithURLTapped(cell: PhotoMessageCell, url: String) {
        selectedImageMessageID = cell.viewModel.model.id
        selectedImageCell = cell
        imageAnimator = .init()
        let vc = ImageViewController()
        let nav = ImageNavController(rootViewController: vc)
        vc.image = cell.photoImageView.image
        nav.modalPresentationStyle = .custom
        nav.modalPresentationCapturesStatusBarAppearance = true
        nav.transitioningDelegate = self

        self.present(nav, animated: true, completion: nil)
    }
    
    func photoTapped(cell: PhotoMessageCell, image: UIImage) {
        selectedImageMessageID = cell.viewModel.model.id
        selectedImageCell = cell
        imageAnimator = .init()
        let vc = ImageViewController()
        let nav = ImageNavController(rootViewController: vc)
        vc.image = cell.photoImageView.image
        nav.modalPresentationStyle = .custom
        nav.transitioningDelegate = self
        nav.modalPresentationCapturesStatusBarAppearance = true
        self.present(nav, animated: true, completion: nil)
    }
    
    func locationTapped(cell: LocationMessageCell, location: Location) {
        let vc = LocationViewerController()
        vc.location = location
        let navController = UINavigationController(rootViewController: vc)
        navController.modalTransitionStyle = .coverVertical
        navController.modalPresentationStyle = .formSheet
        self.present(navController, animated: true, completion: nil)
    }
}

extension ChatController: UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        imageAnimator.delegate = self
        imageAnimator.presenting = false
        return imageAnimator
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        imageAnimator.delegate = self
        imageAnimator.presenting = true
        return imageAnimator
    }
}

extension ChatController: ImageShowAnimatorDelegate {
    func didStartPresenting() {
    }
    
    func didEndPresenting() {
    }
    
    func hidingTransitionType() -> ImageShowTransitionType {
        guard let viewModel = selectedImageCell?.viewModel,
              viewModel.model.id == selectedImageMessageID  else { return .fade }
        return .expand
    }
    
    func presentTransitionType() -> ImageShowTransitionType {
        return .expand
    }
    
    func didEndPresentationTransition() {
        guard let viewModel = selectedImageCell?.viewModel,
              viewModel.model.id == selectedImageMessageID  else { return }
        if selectedImageCell.frame.minY < tableView.contentOffset.y {
            tableView.scrollRectToVisible(selectedImageCell.frame, animated: false)
        } else if selectedImageCell.frame.maxY > tableView.contentOffset.y + tableView.frame.height {
            tableView.scrollRectToVisible(selectedImageCell.frame, animated: false)
        }
    }
    
    func frameForSelectedImageView() -> CGRect {
        guard let viewModel = selectedImageCell?.viewModel,
              viewModel.model.id == selectedImageMessageID else { return .zero }
        return selectedImageCell.photoImageView.convert(selectedImageCell.photoImageView.frame, to: view)
    }
    
    func selectedImageView() -> UIImageView {
        guard let viewModel = selectedImageCell?.viewModel,
              viewModel.model.id == selectedImageMessageID else { return UIImageView() }
        return selectedImageCell.photoImageView
    }
}

extension ChatController: ChatNodeDelegate {
    func reloadChat() {
        let snapshot: [ChatContent] = node.chatContent
        tableView.reload(snapshot: snapshot)
    }
    
    func updateChat() {
        let snapshot: [ChatContent] = node.chatContent
        tableView.animateDifference(snapshot: snapshot)
    }
}
