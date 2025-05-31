//
//  HeaderViewCell.swift
//  Tracker
//
//  Created by Galina evdokimova on 30.04.2025.
//

import UIKit

final class HeaderViewCell: UICollectionReusableView {
    static let identifier = "headerCell"
    
    var headerTextLabel: String? {
        didSet {
            titleLabel.text = headerTextLabel
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.textColor = .ypBlackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) wasn't implemented")
    }
}

