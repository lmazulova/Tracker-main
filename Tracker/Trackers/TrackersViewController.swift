//
//  ViewController.swift
//  Tracker
//
//  Created by Galina evdokimova on 22.03.2025.
//

import UIKit

final class TrackersViewController: UIViewController {
    private var trackerStore = TrackerStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private var trackerRecordStore = TrackerRecordStore()
    private let errorReporting = ErrorReporting()
    private var trackers: [Tracker] = []
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var selectedDay: Int?
    private var filterText: String?
    private let analyticsService = AnalyticsService()
    
    private lazy var datePicker: UIDatePicker = {
        let date = UIDatePicker()
        date.datePickerMode = .date
        date.preferredDatePickerStyle = .compact
        date.calendar.firstWeekday = 2
        date.addTarget(self, action: #selector(dateSelection), for: .valueChanged)
        date.locale = Locale(identifier: "ru_RU")
        date.tintColor = .ypBlue
        date.clipsToBounds = true
        date.translatesAutoresizingMaskIntoConstraints = false
        return date
    }()
    
    private let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Поиск"
        searchController.searchBar.searchTextField.clearButtonMode = .never
        searchController.searchBar.setValue("Отменить", forKey: "cancelButtonText")
        searchController.searchBar.tintColor = .ypBlue
        searchController.hidesNavigationBarDuringPresentation = false
        return searchController
    }()
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .ypWhiteDay
        collectionView.allowsMultipleSelection = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    } ()
    
    private let initialImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Stub tracker")
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let initialLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let searchImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Stub search")
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let searchLabel: UILabel = {
        let label = UILabel()
        label.text = "Ничего не найдено"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        analyticsService.report(event: Event.open, screen: Screen.main)
        addTapGestureRecognizer()
        coreDataSetup()
        reloadVisibleCategories()
        showInitialStub()
        setupNavBar()
        setupTrackersView()
        setupCollectionView()
        setupTrackersViewConstrains()
        dateFiltering()
    }
    
    private func coreDataSetup() {
        trackerStore.delegate = self
        trackers = trackerStore.trackers
        trackerCategoryStore.delegate = self
        categories = trackerCategoryStore.trackerCategories
        trackerRecordStore.delegate = self
        completedTrackers = trackerRecordStore.trackerRecords
    }
    
    private func setupNavBar() {
        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .ypBlackDay
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Add tracker"), style: .plain, target: self, action: #selector(didTapAddTrackerButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.searchController = searchController
        searchController.delegate = self
        searchController.searchResultsUpdater = self
    }
    
    private func setupTrackersView() {
        view.backgroundColor = .ypWhiteDay
        
        view.addSubview(initialImage)
        view.addSubview(initialLabel)
        view.addSubview(searchImage)
        view.addSubview(searchLabel)
        view.addSubview(collectionView)
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCollectionViewCell.self,
                                forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
        collectionView.register(HeaderViewCell.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: HeaderViewCell.identifier)
    }
    
    private func setupTrackersViewConstrains() {
        NSLayoutConstraint.activate([
            initialImage.heightAnchor.constraint(equalToConstant: 80),
            initialImage.widthAnchor.constraint(equalToConstant: 80),
            initialImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            initialImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            initialLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            initialLabel.topAnchor.constraint(equalTo: initialImage.bottomAnchor, constant: 8),
            
            searchImage.heightAnchor.constraint(equalToConstant: 80),
            searchImage.widthAnchor.constraint(equalToConstant: 80),
            searchImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            searchLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchLabel.topAnchor.constraint(equalTo: searchImage.bottomAnchor, constant: 8),
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc
    private func didTapAddTrackerButton() {
        let addTrackerViewController = AddTrackerViewController()
        addTrackerViewController.trackersViewController = self
        present(addTrackerViewController, animated: true, completion: nil)
    }
    
    @objc
    private func dateSelection() {
        dateFiltering()
        filteringTrackers()
    }
    
    private func showInitialStub() {
        let emptyVisibleCategories = visibleCategories.isEmpty
        collectionView.isHidden = emptyVisibleCategories
        searchImage.isHidden = emptyVisibleCategories
        searchLabel.isHidden = emptyVisibleCategories
    }
    
    private func showSearchStub() {
        let emptyVisibleCategories = visibleCategories.isEmpty
        collectionView.isHidden = emptyVisibleCategories
        initialImage.isHidden = emptyVisibleCategories
        initialLabel.isHidden = emptyVisibleCategories
        searchImage.isHidden = !emptyVisibleCategories
        searchLabel.isHidden = !emptyVisibleCategories
    }
    
    private func dateFiltering() {
        let calendar = Calendar.current
        let filterWeekday = calendar.component(.weekday, from: datePicker.date)
        self.selectedDay = filterWeekday
    }
    
    private func filteringTrackers() {
        reloadVisibleCategories()
        showSearchStub()
        collectionView.reloadData()
    }
    
    private func reloadVisibleCategories() {
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let textCondition = (self.filterText ?? "").isEmpty ||
                tracker.title.contains(self.filterText ?? "")
                let dateCondition = tracker.schedule.contains { day in
                    guard let currentDate = self.selectedDay else {
                        return true
                    }
                    return day.rawValue == currentDate
                }
                return textCondition && dateCondition
            }
            
            if trackers.isEmpty {
                return nil
            }
            
            return TrackerCategory(
                title: category.title,
                trackers: trackers
            )
        }
    }
    
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        completedTrackers.contains {
            isSameTrackerRecord(trackerRecord: $0, id: id)
        }
    }
    
    private func isSameTrackerRecord(trackerRecord: TrackerRecord, id: UUID) -> Bool {
        let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
        return trackerRecord.trackerId == id && isSameDay
    }
}

extension TrackersViewController: UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
        dateFiltering()
    }
}

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.filterText = searchController.searchBar.searchTextField.text?.description
        filteringTrackers()
    }
}

extension TrackersViewController: TrackerStoreDelegate {
    func store() {
        trackers = trackerStore.trackers
        collectionView.reloadData()
    }
}
// MARK: - TrackerCategoryStoreDelegate
extension TrackersViewController: TrackerCategoryStoreDelegate {
    func categoryStore() {
        categories = trackerCategoryStore.trackerCategories
        collectionView.reloadData()
    }
}
// MARK: - TrackerRecordStoreDelegate
extension TrackersViewController: TrackerRecordStoreDelegate {
    func recordStore() {
        completedTrackers = trackerRecordStore.trackerRecords
        collectionView.reloadData()
    }
}

extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        let currentDate = Date()
        let selectedDate = datePicker.date
        let currentCalendar = Calendar.current
        let trackerRecord = TrackerRecord(trackerId: id, date: selectedDate)
        
        guard currentCalendar.compare(selectedDate,
                                      to: currentDate,
                                      toGranularity: .day
        ) == .orderedDescending else {
            completedTrackers.append(trackerRecord);
            collectionView.reloadItems(at: [indexPath]);
            return
        }
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        completedTrackers.removeAll {
            isSameTrackerRecord(trackerRecord: $0, id: id)
        }
        collectionView.reloadItems(at: [indexPath])
    }
}

extension TrackersViewController: CreateTrackerViewControllerDelegate {
    func createNewTracker(tracker: Tracker, category: String?) {
        guard let newCategory = category else { return }
        let savedCategory = self.categories.first { category in
            category.title == newCategory
        }
        if savedCategory != nil {
            self.categories = self.categories.map { category in
                if (category.title == newCategory) {
                    var updateTrackers = category.trackers
                    updateTrackers.append(tracker)
                    return TrackerCategory(title: category.title, trackers: updateTrackers)
                } else {
                    return TrackerCategory(title: category.title, trackers: category.trackers)
                }
            }
        } else {
            self.categories.append(TrackerCategory(title: newCategory, trackers: [tracker]))
        }
        filteringTrackers()
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCollectionViewCell.identifier,
            for: indexPath
        ) as? TrackerCollectionViewCell else { return UICollectionViewCell() }
        
        cell.prepareForReuse()
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        cell.delegate = self
        
        let isCopletedToday = isTrackerCompletedToday(id: tracker.id)
        let completedDays = completedTrackers.filter {
            $0.trackerId == tracker.id
        }.count
        
        cell.updateTrackerDetail(
            tracker: tracker,
            isCompletedToday: isCopletedToday,
            completedDays: completedDays,
            indexPath: indexPath
        )
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
}

extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String = ""
        if case UICollectionView.elementKindSectionHeader = kind {
            id = HeaderViewCell.identifier
        }
        
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: id,
            for: indexPath) as! HeaderViewCell
        
        guard indexPath.section < visibleCategories.count else {
            return view
        }
        
        let headerText = visibleCategories[indexPath.section].title
        view.headerTextLabel = headerText
        return view
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 9) / 2, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

