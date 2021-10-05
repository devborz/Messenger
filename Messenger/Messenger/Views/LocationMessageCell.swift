//
//  LocationMessageCell.swift
//  Messenger
//
//  Created by Усман Туркаев on 24.08.2021.
//

import UIKit
import MapKit
import RxSwift

final class LocationMessageCell: MessageCell {
    
    let mapView = MKMapView()
    
    private var disposeBag = DisposeBag()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        stateImageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(bubbleView)
        contentView.addSubview(avatarImageView)
        bubbleView.addSubview(mapView)
        bubbleView.addSubview(timeLabel)
        
        mapView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        mapView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: timeLabel.topAnchor, constant: -5).isActive = true
        mapView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        mapView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        timeLabel.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 10).isActive = true
        timeLabel.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -10).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -5).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        timeLabel.font = .systemFont(ofSize: 10)
        timeLabel.textAlignment = .right
        timeLabel.textColor = .secondaryLabel
        
        avatarImageView.backgroundColor = .secondarySystemBackground
        avatarImageView.layer.cornerRadius = 15
        avatarImageView.clipsToBounds = true
        avatarImageView.tintColor = avatarTintColor
        
        bubbleView.clipsToBounds = true
        bubbleView.backgroundColor = .clear
        
        stateImageView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        stateImageView.widthAnchor.constraint(equalToConstant: 15).isActive = true
        stateImageView.backgroundColor = .clear
        stateImageView.contentMode = .scaleAspectFit
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(messageTapped))
        mapView.addGestureRecognizer(gestureRecognizer)
        mapView.isUserInteractionEnabled = true
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.isPitchEnabled = false
        mapView.isRotateEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
        disposeBag = DisposeBag()
    }
    
    @objc
    func messageTapped() {
        switch viewModel.model.attachment {
        case .location(location: let location):
            delegate?.locationTapped(cell: self, location: location)
        default:
            break
        }
    }
    
    func layout() {
        avatarImageView.removeFromSuperview()
        bubbleView.removeFromSuperview()
        stateImageView.removeFromSuperview()
        
        contentView.addSubview(bubbleView)
        contentView.addSubview(avatarImageView)
        
        avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        bubbleView.widthAnchor.constraint(lessThanOrEqualToConstant: frame.width * 0.7).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        
        switch viewModel.type {
        case .incoming:
            avatarImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
            bubbleView.leftAnchor.constraint(equalTo: avatarImageView.rightAnchor, constant: 10).isActive = true
            
        case .outgoing:
            contentView.addSubview(stateImageView)
            
            avatarImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
            bubbleView.rightAnchor.constraint(equalTo: avatarImageView.leftAnchor, constant: -10).isActive = true
            
            stateImageView.rightAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: -15).isActive = true
            stateImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor).isActive = true
        }
    }
    
    func setup(_ viewModel: MessageViewModel) {
        self.viewModel = viewModel
        mapView.layer.cornerRadius = 20
        mapView.clipsToBounds = true
        timeLabel.text = formatMessageTime(viewModel.model.created)
        layout()
        if let location = viewModel.messageLocation {
            mapView.setRegion(MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500), animated: false)
            let annotation = MKPointAnnotation()
            annotation.title = location.name
            annotation.coordinate = location.coordinate
            mapView.addAnnotation(annotation)
        }
        viewModel.senderAvatar.subscribe(onNext: { [weak self] image in
            DispatchQueue.main.async {
                self?.avatarImageView.image = image
            }
        }).disposed(by: disposeBag)
        viewModel.state.subscribe(onNext: { [weak self] state in
            var image: UIImage?
            var tintColor: UIColor = .systemIndigo
            switch state {
            case .normal:
                image = nil
            case .sending:
                image = UIImage(systemName: "clock")
            case .sent:
                image = nil
            case .errorOccured:
                image = UIImage(systemName: "exclamationmark.shield.fill")
                tintColor = .red
            }
            DispatchQueue.main.async {
                self?.stateImageView.image = image
                self?.stateImageView.tintColor = tintColor
            }
            
        }).disposed(by: disposeBag)

    }
}
