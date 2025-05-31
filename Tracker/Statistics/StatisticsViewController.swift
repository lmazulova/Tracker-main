//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Galina evdokimova on 24.03.2025.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Статистика"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    } ()
    
    private let statisticsImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Stub statistics")
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let statisticsLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStatisticsView()
        setupStatisticsViewConstrains()
    }
    
    private func setupStatisticsView() {
        view.backgroundColor = .ypWhiteDay
        view.addSubview(titleLabel)
        view.addSubview(statisticsImage)
        view.addSubview(statisticsLabel)
    }
    
    private func setupStatisticsViewConstrains() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            statisticsImage.heightAnchor.constraint(equalToConstant: 80),
            statisticsImage.widthAnchor.constraint(equalToConstant: 80),
            statisticsImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statisticsImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            statisticsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statisticsLabel.topAnchor.constraint(equalTo: statisticsImage.bottomAnchor, constant: 8)
        ])
    }
}
