//
//  CreateCategoryViewController.swift
//  Tracker
//
//  Created by Galina evdokimova on 25.05.2025.
//

import UIKit

protocol CreateCategoryViewControllerDelegate: AnyObject {
    func addNewCategory(category: String)
}

final class CreateCategoryViewController: UIViewController {
    weak var delegate: CreateCategoryViewControllerDelegate?
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая категория"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlackDay
        label.backgroundColor = .ypWhiteDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var createCategoryName: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        textField.textColor = .ypBlackDay
        textField.layer.cornerRadius = 16
        textField.backgroundColor = .ypBackgroundDay
        textField.clearButtonMode = .whileEditing
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.keyboardType = .default
        textField.returnKeyType = .done
        textField.clipsToBounds = true
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var createCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.tintColor = .ypBlackDay
        button.layer.cornerRadius = 16
        button.backgroundColor = .ypBlackDay
        button.addTarget(self, action: #selector(didTapCreateCategoryButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGestureRecognizer()
        setupCreateCategoryView()
        setupCreateCategoryViewConstrains()
        updateCreateCategoryButton()
    }
    // MARK: - Actions
    @objc
    private func didTapCreateCategoryButton() {
        guard let newCategory = createCategoryName.text, !newCategory.isEmpty else {
            return
        }
        delegate?.addNewCategory(category: newCategory)
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func updateCreateCategoryButton() {
        if createCategoryName.text?.isEmpty == true {
            createCategoryButton.isEnabled = false
            createCategoryButton.backgroundColor = .ypGray
        } else {
            createCategoryButton.isEnabled = true
            createCategoryButton.backgroundColor = .ypBlackDay
        }
    }
    
    private func setupCreateCategoryView() {
        view.backgroundColor = .ypWhiteDay
        createCategoryName.delegate = self
        createCategoryName.addTarget(self,
                                     action: #selector(updateCreateCategoryButton),
                                     for: .editingChanged)
        view.addSubview(titleLabel)
        view.addSubview(createCategoryName)
        view.addSubview(createCategoryButton)
    }
    
    private func setupCreateCategoryViewConstrains() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            createCategoryName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            createCategoryName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createCategoryName.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            createCategoryName.heightAnchor.constraint(equalToConstant: 75),
            
            createCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

extension CreateCategoryViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String
    ) -> Bool {
        let currentText = (textField.text ?? "") as NSString
        currentText.replacingCharacters(in: range, with: string)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

