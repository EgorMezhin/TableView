//
//  ViewController.swift
//  TableView
//
//  Created by Egor Mezhin on 12.07.2023.
//

import UIKit

class ViewController: UIViewController {
    lazy var cellData = (Constants.zero...Constants.arrayMaxValue).map { String($0) }
    
    private struct Constants {
        static let buttonTitle = "Shuffle"
        static let title = "Task 4"
        static let cellIdentider = "TableViewCell"
        
        static let zero = 0
        static let verticalIndent: CGFloat = 10
        static let cornerRadius: CGFloat = 10
        static let arrayMaxValue = 30
    }
    
    private lazy var selectedCells = [String]()
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.register(UITableViewCell.self,
                      forCellReuseIdentifier: Constants.cellIdentider)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Constants.cornerRadius
        view.isScrollEnabled = true
        return view
    }()
    
    private lazy var dataSource = UITableViewDiffableDataSource<Int, String>(tableView: tableView) { tableView, indexPath, itemIdentifier in
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentider,
                                                 for: indexPath)
        if self.selectedCells.contains(itemIdentifier) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        cell.textLabel?.text = itemIdentifier
        return cell
    }
    
    private lazy var dataSourceSnapshot: NSDiffableDataSourceSnapshot<Int, String> = {
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([Constants.zero])
        snapshot.appendItems(cellData)
        return snapshot
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        setupview()
    }
}

//MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        guard let selectedItem = dataSource.itemIdentifier(for: indexPath) else { return }
        
        if selectedCells.contains(selectedItem) {
            selectedCells = selectedCells.filter { $0 != selectedItem }
            cell.accessoryType = .none
        } else {
            selectedCells.append(selectedItem)
            cell.accessoryType = .checkmark
            dataSourceSnapshot.deleteItems([selectedItem])
            dataSourceSnapshot.insertItems([selectedItem], beforeItem: dataSourceSnapshot.itemIdentifiers.first ?? "")
            dataSource.apply(dataSourceSnapshot, animatingDifferences: true)
        }
        cell.isSelected = false
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellData.count
    }
}

//MARK: - Private methods
extension ViewController {
    func setupview() {
        view.backgroundColor = .cyan
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = dataSource
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                           constant: Constants.verticalIndent),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        dataSource.apply(dataSourceSnapshot, animatingDifferences: false)
    }
    
    @objc
    private func shuffleTapped() {
        cellData.shuffle()
        dataSourceSnapshot.deleteAllItems()
        dataSourceSnapshot.appendSections([Constants.zero])
        dataSourceSnapshot.appendItems(cellData)
        dataSource.apply(dataSourceSnapshot, animatingDifferences: true)
    }
    
    private func configureNavigationBar() {
        let rightBarButtonItem = UIBarButtonItem(title: Constants.buttonTitle,
                                                 style: .plain, target: self,
                                                 action: #selector(shuffleTapped))
        self.navigationItem.title = Constants.title
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
}
