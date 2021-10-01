//
//  LibraryImageCell.swift
//  FiImagePicker
//
//  Created by Усман Туркаев on 04.08.2021.
//

import UIKit
import Photos

final class AssetCell: UICollectionViewCell {
    
    var asset: PHAsset?
    
    let imageView = UIImageView()
    
    let dimView = UIView()
    
    let selectionIndicator = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .secondarySystemBackground
        
        imageView.clipsToBounds = true
        
        selectionIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(selectionIndicator)
        selectionIndicator.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        selectionIndicator.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
        selectionIndicator.heightAnchor.constraint(equalToConstant: 25).isActive = true
        selectionIndicator.widthAnchor.constraint(equalTo: selectionIndicator.heightAnchor).isActive = true
        
        selectionIndicator.tintColor = .white
        selectionIndicator.backgroundColor = .clear
        selectionIndicator.layer.shadowOpacity = 0.4
        selectionIndicator.layer.shadowRadius = 5
        selectionIndicator.layer.shadowColor = UIColor.black.cgColor
        selectionIndicator.layer.masksToBounds = false
        
        selectionIndicator.image = UIImage(systemName: "circle", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
        selectionIndicator.contentMode = .scaleAspectFit
        
        dimView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dimView)
        dimView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        dimView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        dimView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        dimView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        dimView.clipsToBounds = true
        dimView.backgroundColor = .init(white: 1, alpha: 0.3)
        dimView.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        asset = nil
        imageView.image = nil
    }
    
    func setup(_ asset: PHAsset?, selectionIndex: Int) {
        guard let asset = asset else {
            return
        }
        let options = PHImageRequestOptions()
        options.resizeMode = .exact
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true
        let size = CGSize(width: bounds.size.height * 2, height: bounds.size.height * 2)
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options) { [weak self] image, data in
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }
        self.dimView.isHidden = !self.isSelected
        if selectionIndex > 0 {
            let imageName = "\(selectionIndex).circle.fill"
            self.selectionIndicator.image = UIImage(systemName: imageName, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
        } else {
            let imageName = "circle"
            self.selectionIndicator.image = UIImage(systemName: imageName, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
        }
    }
    
    
    func setupUnique(_ asset: PHAsset?) {
        guard let asset = asset else {
            return
        }
        let options = PHImageRequestOptions()
        options.resizeMode = .exact
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true
        let size = CGSize(width: bounds.size.height * 2, height: bounds.size.height * 2)
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options) { [weak self] image, data in
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }
        selectionIndicator.image = nil
    }
}
