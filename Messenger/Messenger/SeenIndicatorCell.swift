//
//  SeenIndicatorCell.swift
//  Pangea
//
//  Created by Усман Туркаев on 27.08.2021.
//

import UIKit

class SeenIndicatorCell: UITableViewCell {

    let label = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        label.translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        addSubview(label)
        
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14)
        label.text = NSLocalizedString("Seen", comment: "")
        label.textAlignment = .left
        
        label.topAnchor.constraint(equalTo: topAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant:  20).isActive = true
        label.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        label.heightAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
