//
//  InputBarView.swift
//  Pangea
//
//  Created by Усман Туркаев on 16.08.2021.
//

import UIKit

protocol InputBarViewDelegate: AnyObject {
    func sendButtonTapped(_ text: String)
    
    func attachButtonTapped()
}

class InputBarView: UIView {
    
    weak var delegate: InputBarViewDelegate?

    let textView = UITextView()
    
    let sendButton = UIButton()
    
    let attachButton = UIButton()
    
    let textViewContainer = UIView()
    
    let placeholderLabel = UILabel()
    
    var textViewHeightConstraint: NSLayoutConstraint!
    
    let buttonsContainerView = UIView()
    
    let separatorView = UIView()
    
    let textViewMinHeight: CGFloat = 38
    
    var textViewEmpty = true {
        didSet {
            if textViewEmpty != oldValue {
                if textViewEmpty {
                    placeholderLabel.isHidden = false
                    hideSendButton()
                } else {
                    placeholderLabel.isHidden = true
                    showSendButton()
                }
            }
        }
    }
    
    init() {
        super.init(frame: .zero)
        addSubviews()
        layout()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        textViewContainer.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        attachButton.translatesAutoresizingMaskIntoConstraints = false
        buttonsContainerView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(textViewContainer)
        addSubview(buttonsContainerView)
        addSubview(separatorView)
        
        textViewContainer.addSubview(textView)
        buttonsContainerView.addSubview(attachButton)
    
        textView.addSubview(placeholderLabel)
    }
    
    func layout() {
        textViewContainer.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        textViewContainer.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        textViewContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        textViewContainer.rightAnchor.constraint(equalTo: buttonsContainerView.leftAnchor, constant: 0).isActive = true
        
        buttonsContainerView.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
        buttonsContainerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        buttonsContainerView.heightAnchor.constraint(equalToConstant: textViewMinHeight + 16).isActive = true
        buttonsContainerView.widthAnchor.constraint(equalToConstant: textViewMinHeight + 16).isActive = true
        
        attachButton.centerYAnchor.constraint(equalTo: buttonsContainerView.centerYAnchor).isActive = true
        attachButton.centerXAnchor.constraint(equalTo: buttonsContainerView.centerXAnchor).isActive = true
        attachButton.widthAnchor.constraint(equalTo: buttonsContainerView.widthAnchor).isActive = true
        
        textView.topAnchor.constraint(equalTo: textViewContainer.topAnchor, constant: 3).isActive = true
        textView.leftAnchor.constraint(equalTo: textViewContainer.leftAnchor, constant: 10).isActive = true
        textView.rightAnchor.constraint(equalTo: textViewContainer.rightAnchor, constant: -5).isActive = true
        textView.bottomAnchor.constraint(equalTo: textViewContainer.bottomAnchor, constant: -3).isActive = true
        textViewHeightConstraint = textView.heightAnchor.constraint(equalToConstant: textViewMinHeight)
        textViewHeightConstraint.isActive = true
        
        placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 8).isActive = true
        placeholderLabel.leftAnchor.constraint(equalTo: textView.leftAnchor, constant: 5).isActive = true
        
        separatorView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        separatorView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separatorView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }
    
    func setupViews() {
        backgroundColor = .systemBackground
        
        textViewContainer.backgroundColor = .secondarySystemBackground
        textViewContainer.layer.cornerRadius = 10
        textViewContainer.clipsToBounds = true
        
        textView.font = .systemFont(ofSize: 17)
        textView.textColor = .label
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.delegate = self
        textView.contentInset = .zero
        
        attachButton.setImage(UIImage(systemName: "plus.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 26)), for: .normal)
        attachButton.tintColor = .label
        attachButton.addTarget(self, action: #selector(attachButtonTapped), for: .touchUpInside)
        
        sendButton.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 26)), for: .normal)
        sendButton.tintColor = .systemIndigo
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        
        placeholderLabel.font = .systemFont(ofSize: 17)
        placeholderLabel.textColor = .placeholderText
        placeholderLabel.text = NSLocalizedString("Send message...", comment: "")
        
        separatorView.backgroundColor = .secondarySystemBackground
    }
    
    func addButton(_ button: UIButton) {
        button.removeFromSuperview()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        buttonsContainerView.addSubview(button)
        
        buttonsContainerView.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
        buttonsContainerView.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
        buttonsContainerView.widthAnchor.constraint(equalTo: button.widthAnchor).isActive = true
    }
    
    func showSendButton() {
        addButton(sendButton)
        sendButton.alpha = 1
        sendButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        UIView.animate(withDuration: 0.15) {
            self.sendButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        } completion: { (completed) in
            if completed {
            }
        }
        self.attachButton.alpha = 0
        self.attachButton.removeFromSuperview()
    }
    
    func hideSendButton() {
        addButton(attachButton)
        attachButton.alpha = 1
        attachButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        UIView.animate(withDuration: 0.15) {
            self.attachButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        } completion: { (completed) in
            if completed {
            }
        }
        self.sendButton.alpha = 0
        self.sendButton.removeFromSuperview()
    }
    
    @objc
    func sendButtonTapped() {
        guard !textViewEmpty else { return }
        let text = textView.text
        textView.text = ""
        checkTextView()
        delegate?.sendButtonTapped(text ?? "")
    }
    
    @objc
    func attachButtonTapped() {
        guard textViewEmpty else { return }
        delegate?.attachButtonTapped()
    }
}

extension InputBarView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        checkTextView()
    }
    
    func checkTextView() {
        let currentHeight = textView.frame.height
        if currentHeight < 150 {
            textView.sizeToFit()
        }
        let contentHeight = textView.contentSize.height
        if contentHeight <= textViewMinHeight {
            textViewHeightConstraint.constant = textViewMinHeight
            textView.isScrollEnabled = false
        } else if contentHeight < 150 {
            textViewHeightConstraint.constant = contentHeight
            textView.isScrollEnabled = false
        } else {
            textViewHeightConstraint.constant = 150
            textView.isScrollEnabled = true
        }
        textView.setNeedsUpdateConstraints()
        textViewEmpty = textView.text.isEmpty
    }
}
