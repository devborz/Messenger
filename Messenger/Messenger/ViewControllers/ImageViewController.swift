//
//  ImageViewController.swift
//  Pangea
//
//  Created by Усман Туркаев on 28.08.2021.
//

import UIKit

class ImageViewController: UIViewController {
    
    var image: UIImage?
    
    let scrollView = UIScrollView()
    
    var imageView: UIImageView!
    
    var imageViewHeight: CGFloat = 0
    
    var imageViewWidth: CGFloat = 0
    
    var closeButton: UIButton!
    
    var closeItem: UIBarButtonItem!
    
    var minScale: CGFloat = 0
    
    var didEndTransition = false
    
    var menuHidden = false {
        didSet {
            if menuHidden != oldValue {
                setNeedsStatusBarAppearanceUpdate()
                if !menuHidden {
                    navigationController?.navigationBar.alpha = 1
                }
                UIView.animate(withDuration: 0.4) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.navigationController?.setNavigationBarHidden(strongSelf.menuHidden, animated: true)
                }
            }
        }
    }
    
    var currentAlpha: CGFloat = 1 {
        didSet {
            dimView.alpha = currentAlpha
            if !menuHidden {
                navigationController?.navigationBar.alpha = currentAlpha
            }
        }
    }
    
    var dimView = UIView()
    
    var panGesture: UIPanGestureRecognizer!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return menuHidden
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = "Image"
        
//        setNeedsStatusBarAppearanceUpdate()
        view.tintColor = .white
        view.backgroundColor = .clear
        
        view.addSubview(dimView)
        dimView.backgroundColor = UIColor.init(white: 0.0, alpha: 1)
        dimView.frame = view.bounds
        
        setupImageView()
        
        closeItem = .init(title: "Close", style: .plain, target: self, action: #selector(closeButtonTapped))
        navigationItem.leftBarButtonItem = closeItem
        
        panGesture = .init(target: self, action: #selector(didPan(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    @objc
    func didPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        scrollView.frame.origin = CGPoint(x: 0, y: translation.y)
        
        currentAlpha = calculateAlpha(translation.y)
        
        if gesture.state == .ended {
            let dragVelocity = gesture.velocity(in: view)
            if dragVelocity.y >= 600 {
                self.dismiss(animated: true, completion: nil)
            } else {
                if abs(translation.y) >= 200 {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    UIView.animate(withDuration: 0.3) {
                        self.currentAlpha = 1
                        self.scrollView.frame.origin = .zero
                    }
                }
            }
        }
    }
    
    func calculateAlpha(_ offset: CGFloat) -> CGFloat {
        if abs(offset) <= 200 {
            return (200 - abs(offset)) / 200
        }
        return 0
    }
    
    @objc
    func closeButtonTapped() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func setupImageView() {
        imageView = UIImageView(image: image)
        
        view.addSubview(scrollView)
        
        scrollView.frame = view.bounds
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.delegate = self
        scrollView.addSubview(imageView)
        
        scrollView.contentSize = imageView.bounds.size
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapScrollView))
        scrollView.addGestureRecognizer(gesture)
        
        setZoomScale()
        scrollView.zoomScale = minScale
        centerImageView()
    }
    
    func setZoomScale() {
        let imageSize = imageView.bounds.size
        let heightScale =  scrollView.bounds.size.height / imageSize.height
        let widthScale =  scrollView.bounds.size.width / imageSize.width
        minScale = min(heightScale, widthScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 4
    }
    
    func centerImageView() {
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * CGFloat(0.5), CGFloat(0.0))
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0)
        
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
    }
    
    @objc func didTapScrollView() {
        menuHidden = !menuHidden
    }
}

extension ImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
        
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageView()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if didEndTransition {
            menuHidden = true
        }
    }
}

class ImageNavController: UINavigationController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return topViewController?.prefersStatusBarHidden ?? false
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        view.backgroundColor = .clear
        navigationBar.barTintColor = UIColor.black
        navigationBar.tintColor = UIColor.white
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
