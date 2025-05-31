//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Galina evdokimova on 30.04.2025.
//

import UIKit

final class CategoryViewController: UIViewController {
    let categoryViewModel: CategoryViewModel
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlackDay
        label.backgroundColor = .ypWhiteDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var stubImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Stub tracker")
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно\n объединять по смыслу"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlackDay
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var categoryTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .ypWhiteDay
        tableView.layer.cornerRadius = 16
        tableView.rowHeight = UITableView.automaticDimension
        tableView.isScrollEnabled = true
        tableView.allowsMultipleSelection = false
        tableView.separatorStyle = .singleLine
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.tintColor = .ypBlackDay
        button.layer.cornerRadius = 16
        button.backgroundColor = .ypBlackDay
        button.addTarget(self, action: #selector(didTapAddCategoryButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(viewModel: CategoryViewModel = CategoryViewModel()) {
        self.categoryViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryViewModel.categoryStore()
        setupCategoryTableView()
        setupCategoryView()
        setupCategoryViewConstrains()
        showInitialStub()
    }
    
    private func setupBindings() {
        categoryViewModel.onCategoriesUpdated = { [weak self] in
            self?.categoryTableView.reloadData()
            self?.showInitialStub()
        }
        
        categoryViewModel.onCategorySelected = { [weak self] _ in
            self?.dismiss(animated: true)
        }
    }
    
    @objc
    private func didTapAddCategoryButton() {
        let createCategoryViewController = CreateCategoryViewController()
        createCategoryViewController.delegate = self
        present(createCategoryViewController, animated: true)
    }
    
    private func setupCategoryTableView() {
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        categoryTableView.register(CategoryCell.self,
                                   forCellReuseIdentifier: CategoryCell.cellIdentifier)
    }
    
    private func setupCategoryView() {
        view.backgroundColor = .ypWhiteDay
        [titleLabel, stubImage, stubLabel, categoryTableView, addCategoryButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupCategoryViewConstrains() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stubImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            stubImage.heightAnchor.constraint(equalToConstant: 80),
            stubImage.widthAnchor.constraint(equalToConstant: 80),
            
            stubLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubLabel.topAnchor.constraint(equalTo: stubImage.bottomAnchor, constant: 8),
            categoryTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            categoryTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryTableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -16),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func showInitialStub() {
        let emptyCategories = categoryViewModel.categories.isEmpty
        categoryTableView.isHidden = emptyCategories
        stubImage.isHidden = !emptyCategories
        stubLabel.isHidden = !emptyCategories
    }
}

extension CategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        if indexPath.row == categoryViewModel.categories.count - 1 {
            cell.layer.cornerRadius = 16
            cell.layer.masksToBounds = true
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0,
                                               left: 0,
                                               bottom: 0,
                                               right: 500)
        } else {
            cell.layer.cornerRadius = 0
            cell.layer.masksToBounds = false
            cell.separatorInset = UIEdgeInsets(top: 0,
                                               left: 16,
                                               bottom: 0,
                                               right: 16)
        }
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < categoryViewModel.categories.count else {
            return
        }
        if let cell = tableView.cellForRow(at: indexPath) as? CategoryCell {
            cell.accessoryType = .checkmark
            cell.tintColor = .ypBlue
            categoryViewModel.selectCategory(indexPath.row)
            tableView.reloadData()
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return categoryViewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.cellIdentifier,
            for: indexPath) as? CategoryCell else { return UITableViewCell() }
        
        if indexPath.row < categoryViewModel.categories.count {
            let category = categoryViewModel.categories[indexPath.row]
            cell.textLabel?.text = category.title
            cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            cell.textLabel?.textColor = .ypBlackDay
            cell.layer.masksToBounds = true
            
            if category.title == categoryViewModel.selectedCategory?.title {
                cell.accessoryType = .checkmark
                cell.tintColor = .ypBlue
            } else {
                cell.accessoryType = .none
            }
        }
        return cell
    }
}

extension CategoryViewController: CreateCategoryViewControllerDelegate {
    func addNewCategory(category: String) {
        categoryViewModel.addCategory(category)
    }
}


