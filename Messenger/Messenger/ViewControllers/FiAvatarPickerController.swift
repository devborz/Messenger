//
//  FiAvatarPickerController.swift
//  FiImagePicker
//
//  Created by Усман Туркаев on 04.08.2021.
//

import UIKit
import Photos

private let reuseIdentifier = "Cell"

protocol FiAvatarPickerControllerDelegate: NSObject {
    func didSelect(_ controller: FiAvatarPickerController, image: UIImage)
}

final class FiAvatarPickerController: UICollectionViewController {
    
    weak var delegate: FiAvatarPickerControllerDelegate?
    
    var cancelButton: UIBarButtonItem!
    
    var assets: PHFetchResult<PHAsset>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Images", comment: "")
        navigationItem.backButtonTitle = " "
        navigationItem.largeTitleDisplayMode = .never
        collectionView.backgroundColor = .systemBackground
        
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.leftItemsSupplementBackButton = true
        
        collectionView.register(AssetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        checkStatus()
    }
    
    func checkStatus() {
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            reloadAssets()
        } else {
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                if status == .authorized {
                    self?.reloadAssets()
                } else {
                    self?.showMessage()
                }
            }
        }
    }
    
    func reloadAssets() {
        assets = PHAsset.fetchAssets(with: .image, options: nil)
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    func showMessage() {
        
    }
    
    @objc
    func cancelButtonTapped() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! AssetCell
        guard let assets = assets else { return UICollectionViewCell() }
        cell.setupUnique(assets.object(at: assets.count - indexPath.item - 1))
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let assets = assets else { return }
        let index = assets.count - indexPath.item - 1
        collectionView.deselectItem(at: indexPath, animated: true)
        let cropVC = CropAvatarViewController()
        let navC = UINavigationController(rootViewController: cropVC)
        cropVC.asset = assets.object(at: index)
        cropVC.delegate = self
        navC.modalPresentationStyle = .formSheet
        navC.modalTransitionStyle = .coverVertical
        self.present(navC, animated: true, completion: nil)
    }
}

extension FiAvatarPickerController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sideSize = collectionView.bounds.width / 3 - 4 / 3
        return CGSize(width: sideSize, height: sideSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
}

extension FiAvatarPickerController: CropAvatarViewControllerDelegate {
    func didCrop(_ controller: CropAvatarViewController, image: UIImage) {
        self.delegate?.didSelect(self, image: image)
        controller.navigationController?.dismiss(animated: true, completion: { [weak self] in
            self?.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    
    func didCancel(_ controller: CropAvatarViewController) {
        controller.navigationController?.dismiss(animated: true, completion: nil)
    }
}
