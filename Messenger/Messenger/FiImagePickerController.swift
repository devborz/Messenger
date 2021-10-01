//
//  FiImagePickerController.swift
//  FiImagePicker
//
//  Created by Усман Туркаев on 04.08.2021.
//

import UIKit
import Photos

private let reuseIdentifier = "Cell"

protocol FiImagePickerControllerDelegate: NSObject {
    func didSelect(_ controller: FiImagePickerController, images: [UIImage])
}

final class FiImagePickerController: UICollectionViewController {
    
    weak var delegate: FiImagePickerControllerDelegate?
    
    var rightButtonName = "Next"
    
    var rightButton: UIBarButtonItem!
    
    var cancelButton: UIBarButtonItem!
    
    var croppingImageIndexPath: IndexPath?
    
    var selectedIndexPaths: [IndexPath] = []
    
    var croppedImages: [IndexPath : UIImage] = [:]
    
    var assets: PHFetchResult<PHAsset>?
    
    var maxLimit: UInt?
    
    var minLimit: UInt
    
    var needToCrop: Bool
    
    init(_ minLimit: UInt, maxLimit: UInt?, needToCrop: Bool = true) {
        self.minLimit = minLimit
        self.maxLimit = maxLimit
        self.needToCrop = needToCrop
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Select images", comment: "")
        navigationItem.backButtonTitle = " "
        navigationItem.largeTitleDisplayMode = .never
        collectionView.backgroundColor = .systemBackground
        
        rightButton = UIBarButtonItem(title: NSLocalizedString(rightButtonName, comment: ""), style: .done, target: self, action: #selector(rightButtonTapped))
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        
        navigationItem.rightBarButtonItem = rightButton
        if navigationController?.viewControllers[0] == self {
            navigationItem.leftBarButtonItem = cancelButton
        }
        navigationItem.leftItemsSupplementBackButton = true
        
        if minLimit > 0 {
            rightButton.isEnabled = false
        }
        
        collectionView.register(AssetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.allowsMultipleSelection = true
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
    func rightButtonTapped() {
        var images: [UIImage] = []
        for index in self.selectedIndexPaths {
            if let image = croppedImages[index] {
                images.append(image)
            }
        }
        delegate?.didSelect(self, images: images)
    }
    
    @objc
    func cancelButtonTapped() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! AssetCell
        guard let assets = assets else {
            return UICollectionViewCell()
        }
        if let index = selectedIndexPaths.firstIndex(of: indexPath) {
            cell.setup(assets.object(at: assets.count - indexPath.item - 1), selectionIndex: index + 1)
        } else {
            cell.setup(assets.object(at: assets.count - indexPath.item - 1), selectionIndex: 0)
        }
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let assets = assets else { return }
        let index = assets.count - indexPath.item - 1
        if let maxLimit = maxLimit {
            guard selectedIndexPaths.count < maxLimit else {
                collectionView.deselectItem(at: indexPath, animated: false)
                return
            }
        }
        if needToCrop {
            let cropVC = CropViewController()
            let navC = UINavigationController(rootViewController: cropVC)
            cropVC.asset = assets.object(at: index)
            cropVC.delegate = self
            navC.modalPresentationStyle = .fullScreen
            navC.modalTransitionStyle = .coverVertical
            croppingImageIndexPath = indexPath
            self.present(navC, animated: true, completion: nil)
        } else {
            let asset = assets.object(at: index)
            let options = PHImageRequestOptions()
            options.resizeMode = .exact
            options.deliveryMode = .highQualityFormat
            options.isSynchronous = false
            options.isNetworkAccessAllowed = true
            PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: options) { [weak self] image, data in
                guard let strongSelf = self else { return }
                strongSelf.croppingImageIndexPath = nil
                strongSelf.selectedIndexPaths.append(indexPath)
                strongSelf.croppedImages[indexPath] = image
                if strongSelf.selectedIndexPaths.count == strongSelf.minLimit {
                    strongSelf.rightButton.isEnabled = true
                }
                let cell = collectionView.cellForItem(at: indexPath) as! AssetCell
                
                var imageName: String!
                if strongSelf.maxLimit == 1 {
                    imageName = "checkmark.circle.fill"
                } else {
                    imageName = "\(strongSelf.selectedIndexPaths.count).circle.fill"
                }
                cell.selectionIndicator.image = UIImage(systemName: imageName, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectedIndexPaths.removeAll { value in
            indexPath == value
        }
        croppedImages[indexPath] = nil
        if selectedIndexPaths.count < minLimit {
            rightButton.isEnabled = false
        }
        if let cell = collectionView.cellForItem(at: indexPath) as? AssetCell {
            let imageName = "circle"
            cell.selectionIndicator.image = UIImage(systemName: imageName, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
        }
        for (i, indexPath) in selectedIndexPaths.enumerated() {
            if let cell = collectionView.cellForItem(at: indexPath) as? AssetCell {
                let imageName = "\(i + 1).circle.fill"
                cell.selectionIndicator.image = UIImage(systemName: imageName, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
            }
        }
    }
}

extension FiImagePickerController: UICollectionViewDelegateFlowLayout {
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

extension FiImagePickerController: CropViewControllerDelegate {
    func didCrop(_ controller: CropViewController, image: UIImage) {
        guard let indexPath = croppingImageIndexPath else { return }
        croppingImageIndexPath = nil
        selectedIndexPaths.append(indexPath)
        croppedImages[indexPath] = image
        if selectedIndexPaths.count == minLimit {
            rightButton.isEnabled = true
        }
        let cell = collectionView.cellForItem(at: indexPath) as! AssetCell
        let imageName = "\(self.selectedIndexPaths.count).circle.fill"
        cell.selectionIndicator.image = UIImage(systemName: imageName, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
        controller.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func didCancel(_ controller: CropViewController) {
        guard let indexPath = croppingImageIndexPath else { return }
        croppingImageIndexPath = nil
        collectionView.deselectItem(at: indexPath, animated: true)
        controller.navigationController?.dismiss(animated: true, completion: nil)
    }
    
}
