//
//  ScheduleCell.swift
//  Tracker
//
//  Created by Galina evdokimova on 25.03.2025.
//

import UIKit

final class ScheduleCell: UITableViewCell {
    static let cellIdentifier = "scheduleCell"
    var selectedSwitcher = false
    
    private lazy var switcher: UISwitch = {
        let swit = UISwitch()
        swit.onTintColor = .ypBlue
        swit.addTarget(self, action: #selector(switcherTapped), for: .touchUpInside)
        swit.translatesAutoresizingMaskIntoConstraints = false
        return swit
    } ()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(switcher)
        self.accessoryView = switcher
        backgroundColor = .ypBackgroundDay
        clipsToBounds = true
        
        NSLayoutConstraint.activate([
            switcher.centerYAnchor.constraint(equalTo: centerYAnchor),
            switcher.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) wasn't implemented")
    }
    
    @objc
    private func switcherTapped(_ sender: UISwitch) {
        self.selectedSwitcher = sender.isOn
    }
}
