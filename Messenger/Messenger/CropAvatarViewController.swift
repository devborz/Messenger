//
//  CropAvatarViewController.swift
//  FiImagePicker
//
//  Created by Усман Туркаев on 04.08.2021.
//

import UIKit
import Photos

protocol CropAvatarViewControllerDelegate: NSObject {
    func didCrop(_ controller: CropAvatarViewController, image: UIImage)
    func didCancel(_ controller: CropAvatarViewController)
}

final class CropAvatarViewController: UIViewController {
    
    weak var delegate: CropAvatarViewControllerDelegate?
    
    let scrollView = UIScrollView()
    
    var asset: PHAsset?
    
    var doneButton: UIBarButtonItem!
    
    var cancelButton: UIBarButtonItem!
    
    var image: UIImage! {
        didSet {
            setupImageView()
        }
    }
    
    var gridView: UIView!
    
    var imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Crop image", comment: "")
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .black
        view.addSubview(scrollView)
        
        let yOffset = (view.bounds.height - view.bounds.width) / 2
        let sideSize = view.bounds.width
        scrollView.layer.borderWidth = 1
        scrollView.layer.borderColor = UIColor.white.cgColor
        scrollView.frame = CGRect(x: 0, y: yOffset, width: sideSize, height: sideSize)
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        
        gridView = GridView(frame: scrollView.frame)
        view.addSubview(gridView)
        gridView.isUserInteractionEnabled = false
        
        scrollView.layer.cornerRadius = view.bounds.width / 2
        scrollView.clipsToBounds = true
        gridView.layer.cornerRadius = view.bounds.width / 2
        gridView.clipsToBounds = true

        doneButton = .init(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        cancelButton = .init(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        
        doneButton.isEnabled = false
        
        navigationItem.rightBarButtonItem = doneButton
        navigationItem.leftBarButtonItem = cancelButton
        
        if let asset = asset {
            let options = PHImageRequestOptions()
            options.resizeMode = .exact
            options.deliveryMode = .highQualityFormat
            options.isSynchronous = false
            options.isNetworkAccessAllowed = true
            PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: options) { [weak self] image, data in
                self?.image = image
                self?.doneButton.isEnabled = true
            }
        }
    }
    
    @objc
    func doneButtonTapped() {
        var visibleRect = CGRect()
        let scale = 1.0 / scrollView.zoomScale
        visibleRect.origin.x = scrollView.contentOffset.x * scale
        visibleRect.origin.y = scrollView.contentOffset.y * scale
        visibleRect.size.width = scrollView.bounds.size.width * scale
        visibleRect.size.height = scrollView.bounds.size.height * scale
        
        let imageRef = image.cgImage!.cropping(to: visibleRect)
        let croppedImage = UIImage(cgImage: imageRef!)
        delegate?.didCrop(self, image: croppedImage)
    }
    
    @objc
    func cancelButtonTapped() {
        delegate?.didCancel(self)
    }
    
    func setupImageView() {
        imageView.removeFromSuperview()
        imageView = UIImageView(image: image)
        scrollView.addSubview(imageView)
        
        scrollView.contentSize = imageView.bounds.size
        
        setZoomScale()
        scrollView.zoomScale = scrollView.minimumZoomScale
        centerImageView()
    }
    
    func setZoomScale() {
        let imageSize = imageView.bounds.size
        let heightScale =  scrollView.bounds.size.height / imageSize.height
        let widthScale =  scrollView.bounds.size.width / imageSize.width
        let minScale = max(heightScale, widthScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 4
    }
    
    func centerImageView() {
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * CGFloat(0.5), CGFloat(0.0))
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0)
        
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
    }
}

extension CropAvatarViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
        
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageView()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
}

