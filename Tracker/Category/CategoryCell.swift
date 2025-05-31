//
//  CategoryCell.swift
//  Tracker
//
//  Created by Galina evdokimova on 25.05.2025.
//

import UIKit

final class CategoryCell: UITableViewCell {
    static let cellIdentifier = "CategoryCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        backgroundColor = .ypBackgroundDay
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) wasn't implemented")
    }
}
