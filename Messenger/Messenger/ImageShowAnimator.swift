//
//  ShowAnimator.swift
//  Pangea
//
//  Created by Усман Туркаев on 29.08.2021.
//

import UIKit

enum ImageShowTransitionType {
    case expand
    case fade
}

protocol ImageShowAnimatorDelegate: AnyObject {
    func didStartPresenting()
    
    func didEndPresenting()
    
    func frameForSelectedImageView() -> CGRect
    
    func selectedImageView() -> UIImageView
    
    func didEndPresentationTransition()
    
    func hidingTransitionType() -> ImageShowTransitionType
}

class ImageShowAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 0.3
    
    var presenting = true
    
    weak var delegate: ImageShowAnimatorDelegate?
    
    let dimView = UIView()
    
    let transitionImageView = UIImageView()
    
    override init() {
        dimView.backgroundColor = UIColor.init(white: 0.0, alpha: 1)
        dimView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dimView.isUserInteractionEnabled = true
        transitionImageView.backgroundColor = .systemBackground
        transitionImageView.contentMode = .scaleAspectFill
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        let vc = transitionContext.viewController(forKey: presenting ? .to : .from)!
        
        guard let toVC = vc as? ImageNavController else { return }
        guard let imageVC = toVC.viewControllers.first as? ImageViewController else { return }

        let cellFrame = delegate?.frameForSelectedImageView() ?? .zero
        let cellImageView = delegate?.selectedImageView() ?? UIImageView()

        if presenting {
            delegate?.didStartPresenting()
            dimView.alpha = 0
            
            containerView.addSubview(dimView)
            containerView.addSubview(transitionImageView)
            containerView.addSubview(toVC.view)
            
            imageVC.view.isHidden = true
            toVC.view.alpha = 0
            
            dimView.frame = toVC.view.bounds
            transitionImageView.frame = cellFrame

            cellImageView.isHidden = true
            var endFrame = cellFrame
            if let image = cellImageView.image {
                transitionImageView.layer.cornerRadius = 20
                transitionImageView.clipsToBounds = true
                transitionImageView.image = image
                endFrame = calculateZoomInImageFrame(image: image, forView: toVC.view)
            }
            
            UIView.animate(withDuration: duration) { [weak self] in
                self?.transitionImageView.frame = endFrame
                self?.transitionImageView.layer.cornerRadius = 0
                self?.dimView.alpha = 1
                toVC.view.alpha = 1
            } completion: { [weak self] _ in
                self?.transitionImageView.isHidden = true
                self?.dimView.isHidden = true
                imageVC.view.isHidden = false
                imageVC.didEndTransition = true
                self?.delegate?.didEndPresentationTransition()
                transitionContext.completeTransition(true)
            }
        } else {
            let type = delegate?.hidingTransitionType() ?? .fade
            switch type {
            case .expand:
                transitionImageView.alpha = 1
                transitionImageView.frame = imageVC.scrollView.convert(imageVC.imageView.frame, to: toVC.view)
                imageVC.view.isHidden = true
                dimView.alpha = imageVC.currentAlpha
                transitionImageView.isHidden = false
                
                UIView.animate(withDuration: duration) { [weak self] in
                    self?.transitionImageView.frame = cellFrame
                    self?.transitionImageView.layer.cornerRadius = 20
                    self?.dimView.alpha = 0
                    toVC.view.alpha = 0
                } completion: { [weak self] _ in
                    self?.transitionImageView.isHidden = true
                    cellImageView.isHidden = false
                    transitionContext.completeTransition(true)
                }
            case .fade:
                UIView.animate(withDuration: duration) { [weak self] in
                    self?.transitionImageView.frame.origin.y = containerView.frame.height
                } completion: { [weak self] _ in
                    self?.delegate?.didEndPresenting()
                    cellImageView.isHidden = false
                    transitionContext.completeTransition(true)
                }
            }
        }

    }
    
    func animationEnded(_ transitionCompleted: Bool) {
    }
}

func calculateZoomInImageFrame(image: UIImage, forView view: UIView) -> CGRect {
    let viewRatio = view.frame.size.width / view.frame.size.height
    let imageRatio = image.size.width / image.size.height
    let touchesSides = (imageRatio > viewRatio)

    if touchesSides {
        let height = view.frame.width / imageRatio
        let yPoint = view.frame.minY + (view.frame.height - height) / 2
        return CGRect(x: 0, y: yPoint, width: view.frame.width, height: height)
    } else {
        let width = view.frame.height * imageRatio
        let xPoint = view.frame.minX + (view.frame.width - width) / 2
        return CGRect(x: xPoint, y: 0, width: width, height: view.frame.height)
    }
}
