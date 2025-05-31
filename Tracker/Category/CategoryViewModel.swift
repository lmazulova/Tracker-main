//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Galina evdokimova on 25.05.2025.
//

import Combine

final class CategoryViewModel {
    private var trackerCategoryStore = TrackerCategoryStore()
    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            onCategoriesUpdated?()
        }
    }
    
    var selectedCategory: TrackerCategory? {
        didSet {
            onCategorySelected?(selectedCategory)
        }
    }
    
    var onCategoriesUpdated: (() -> Void)?
    var onCategorySelected: ((TrackerCategory?) -> Void)?
    
    init() {
        trackerCategoryStore.delegate = self
        self.categories = trackerCategoryStore.trackerCategories
    }
    
    func addCategory(_ name: String) {
        do {
            try self.trackerCategoryStore.addCategory(TrackerCategory(title: name, trackers: []))
        } catch {
            print("Error add category: \(error.localizedDescription)")
        }
    }
    
    func addNewTrackerToCategory(to title: String?, tracker: Tracker) {
            do {
                try trackerCategoryStore.addNewTrackerToCategory(to: title, tracker: tracker)
            } catch {
                print("Error adding new tracker to category: \(error.localizedDescription)")
            }
        }
    
    func selectCategory(_ index: Int) {
        guard index < categories.count else { return }
        selectedCategory = categories[index]
    }
}

extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func categoryStore() {
        self.categories = trackerCategoryStore.trackerCategories
    }
}

