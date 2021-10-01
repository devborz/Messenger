//
//  ShowAnimator.swift
//  Pangea
//
//  Created by Усман Туркаев on 29.08.2021.
//

import UIKit

//protocol ImagePresentationDelegate: AnyObject {
//    
//    func frameForSelectedImageView() -> CGRect
//    
//    func selectedImageView() -> UIImageView
//    
//    func didEndPresentationTransition()
//}
//
//
//class ImageShowAnimator: NSObject, UIViewControllerAnimatedTransitioning {
//    
//    let duration = 0.3
//    
//    var presenting = true
//    
//    weak var delegate: ImagePresentationDelegate?
//    
//    let dimView = UIView()
//    
//    let transitionImageView = UIImageView()
//    
//    override init() {
//        dimView.backgroundColor = UIColor.init(white: 0.0, alpha: 1)
//        dimView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        dimView.isUserInteractionEnabled = true
//        transitionImageView.contentMode = .scaleAspectFill
//    }
//    
//    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
//        return duration
//    }
//    
//    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        
//        let containerView = transitionContext.containerView
//        
//        let vc = transitionContext.viewController(forKey: presenting ? .to : .from)!
//        
//        guard let toVC = vc as? ImageNavController else { return }
//        guard let imageVC = toVC.viewControllers.first as? ImageViewController else { return }
//
//        let cellFrame = delegate?.frameForSelectedImageView() ?? .zero
//        let cellImageView = delegate?.selectedImageView() ?? UIImageView()
//
//        if presenting {
//            dimView.alpha = 0
//            
//            containerView.addSubview(dimView)
//            containerView.addSubview(transitionImageView)
//            containerView.addSubview(toVC.view)
//            
//            imageVC.view.isHidden = true
//            toVC.view.alpha = 0
//            
//            dimView.frame = toVC.view.bounds
//            transitionImageView.frame = cellFrame
//
//            cellImageView.isHidden = true
//            var endFrame = cellFrame
//            if let image = cellImageView.image {
//                transitionImageView.layer.cornerRadius = 20
//                transitionImageView.clipsToBounds = true
//                transitionImageView.image = image
//                endFrame = calculateZoomInImageFrame(image: image, forView: toVC.view)
//            }
//            
//            UIView.animate(withDuration: duration) { [weak self] in
//                self?.transitionImageView.frame = endFrame
//                self?.transitionImageView.layer.cornerRadius = 0
//                self?.dimView.alpha = 1
//                toVC.view.alpha = 1
//            } completion: { [weak self] _ in
//                self?.transitionImageView.isHidden = true
//                self?.dimView.isHidden = true
//                imageVC.view.isHidden = false
//                self?.delegate?.didEndPresentationTransition()
//                transitionContext.completeTransition(true)
//            }
//        } else {
//            transitionImageView.alpha = 1
//            transitionImageView.frame = imageVC.scrollView.convert(imageVC.imageView.frame, to: toVC.view)
//            imageVC.view.isHidden = true
//            dimView.alpha = imageVC.currentAlpha
//            transitionImageView.isHidden = false
//            
//            UIView.animate(withDuration: duration) { [weak self] in
//                self?.transitionImageView.frame = cellFrame
//                self?.transitionImageView.layer.cornerRadius = 20
//                self?.dimView.alpha = 0
//                toVC.view.alpha = 0
//            } completion: { [weak self] _ in
//                self?.transitionImageView.isHidden = true
//                cellImageView.isHidden = false
//                transitionContext.completeTransition(true)
//            }
//        }
//
//    }
//    
//    
//}
