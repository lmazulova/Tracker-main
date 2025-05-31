//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Galina evdokimova on 27.03.2025.
//

import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func completeTracker(id: UUID, at indexPath: IndexPath)
    func uncompleteTracker(id: UUID, at indexPath: IndexPath)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    static let identifier = "trackerCell"
    weak var delegate: TrackerCollectionViewCellDelegate?
    private var isCompletedToday: Bool = false
    private var trackerId: UUID?
    private var indexPath: IndexPath?
    
    private let trackerCard: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emojiBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhiteDay.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var pinTrackerButton: UIButton = {
        guard let image = UIImage(named: "Pin") else { return UIButton() }
        
        let button = UIButton.systemButton(
            with: image,
            target: self,
            action: #selector(pinTrackerButtonTapped))
        button.tintColor = .ypWhiteDay
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let trackerDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypWhiteDay
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let numberOfDaysLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let plusButtonImage: UIImage = {
        let image = UIImage(systemName: "plus")!
        return image
    }()
    
    private let doneButtonImage: UIImage = {
        let image = UIImage(named: "Done")!
        return image
    }()
    
    private lazy var plusTrackerButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 17
        button.tintColor = .ypWhiteDay
        button.addTarget(self,
                         action: #selector(plusTrackerButtonTapped),
                         for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupTrackerCollectionView()
        setupTrackerCollectionViewConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) wasn't implemented")
    }
    
    @objc
    private func pinTrackerButtonTapped() {
    }
    
    @objc
    private func plusTrackerButtonTapped() {
        guard let trackerId = trackerId, let indexPath = indexPath else {
            assertionFailure("no trackerId")
            return }
        if isCompletedToday {
            delegate?.uncompleteTracker(id: trackerId, at: indexPath)
        } else {
            delegate?.completeTracker(id: trackerId, at: indexPath)
        }
    }
    
    func updateTrackerDetail(
        tracker: Tracker,
        isCompletedToday: Bool,
        completedDays: Int,
        indexPath: IndexPath
    ) {
        self.trackerId = tracker.id
        self.isCompletedToday = isCompletedToday
        self.indexPath = indexPath
        trackerCard.backgroundColor = tracker.color
        trackerDescriptionLabel.text = tracker.title
        emojiLabel.text = tracker.emoji
        pinTrackerButton.isHidden = true
        numberOfDaysLabel.text = formattedDays(completedDays)
        plusButtonSettings()
    }
    
    private func plusButtonSettings() {
        plusTrackerButton.backgroundColor = trackerCard.backgroundColor
        
        let plusTrackerButtonOpacity: Float = isCompletedToday ? 0.3 : 1
        plusTrackerButton.layer.opacity = plusTrackerButtonOpacity
        
        let image = isCompletedToday ? doneButtonImage : plusButtonImage
        plusTrackerButton.setImage(image, for: .normal)
    }
    
    private func formattedDays(_ completedDays: Int) -> String {
        let number = completedDays % 10
        if number == 1 && number != 0 {
            return "\(completedDays) день"
        } else if number <= 4 && number > 1 {
            return "\(completedDays) дня"
        } else {
            return "\(completedDays) дней"
        }
    }
    
    private func setupTrackerCollectionView() {
        contentView.backgroundColor = .ypWhiteDay
        
        contentView.addSubview(trackerCard)
        trackerCard.addSubview(emojiBackgroundView)
        trackerCard.addSubview(emojiLabel)
        trackerCard.addSubview(pinTrackerButton)
        trackerCard.addSubview(trackerDescriptionLabel)
        contentView.addSubview(numberOfDaysLabel)
        contentView.addSubview(plusTrackerButton)
    }
    
    private func setupTrackerCollectionViewConstrains() {
        NSLayoutConstraint.activate([
            trackerCard.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackerCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trackerCard.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.7),
            
            emojiBackgroundView.topAnchor.constraint(equalTo: trackerCard.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: trackerCard.leadingAnchor, constant: 12),
            emojiBackgroundView.trailingAnchor.constraint(lessThanOrEqualTo: trackerCard.trailingAnchor, constant: -12),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            
            pinTrackerButton.trailingAnchor.constraint(equalTo: trackerCard.trailingAnchor, constant: -4),
            pinTrackerButton.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            pinTrackerButton.heightAnchor.constraint(equalToConstant: 24),
            pinTrackerButton.widthAnchor.constraint(equalToConstant: 24),
            
            trackerDescriptionLabel.leadingAnchor.constraint(equalTo: trackerCard.leadingAnchor, constant: 12),
            trackerDescriptionLabel.bottomAnchor.constraint(equalTo: trackerCard.bottomAnchor, constant: -12),
            trackerDescriptionLabel.trailingAnchor.constraint(lessThanOrEqualTo: trackerCard.trailingAnchor, constant: -12),
            
            plusTrackerButton.topAnchor.constraint(equalTo: trackerCard.bottomAnchor, constant: 8),
            plusTrackerButton.trailingAnchor.constraint(equalTo: trackerCard.trailingAnchor, constant: -12),
            plusTrackerButton.heightAnchor.constraint(equalToConstant: 34),
            plusTrackerButton.widthAnchor.constraint(equalToConstant: 34),
            
            numberOfDaysLabel.leadingAnchor.constraint(equalTo: trackerCard.leadingAnchor, constant: 12),
            numberOfDaysLabel.centerYAnchor.constraint(equalTo: plusTrackerButton.centerYAnchor),
            numberOfDaysLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 40)
            
        ])
    }
}
