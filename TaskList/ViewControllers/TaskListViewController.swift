//
//  TaskListViewController.swift
//  TaskList
//
//  Created by Alexey Efimov on 17.11.2022.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    private let storageManager = StorageManager.shared
    
    private let cellID = "task"
    private var taskList: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        taskList = storageManager.fetchData()
    }
    
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = UIColor(named: "MilkBlue")
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addNewTask() {
        showAlert(withTitle: "New Task", andMessage: "What do you want to do?")
    }
    
    private func showAlert(withTitle title: String, andMessage message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] _ in
            if tableView.indexPathForSelectedRow == nil {
                guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
                save(task)
            } else {
                guard let index = self.tableView.indexPathForSelectedRow else { return }
                let task = taskList[index.row]
                guard let newTitile = alert.textFields?.first?.text else { return }
                guard task.title != newTitile, !newTitile.description.isEmpty else { return }
                task.title = newTitile
                storageManager.saveContext()
                tableView.reloadData()
                tableView.deselectRow(at: index, animated: true)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { [unowned self] _ in
            guard let index = self.tableView.indexPathForSelectedRow else { return }
            tableView.deselectRow(at: index, animated: true)
        }
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "New Task"
        }
        present(alert, animated: true)
    }
    
    private func save(_ task: String) {
        storageManager.save(taskList: &taskList, taskName: task)
        tableView.reloadData()
    }
    
}

// MARK: - UITableView Data Source
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deliteAction = UIContextualAction(style: .destructive, title: "Удалить") { (_ , _, completionHandler) in
            self.storageManager.delete(taskList: &self.taskList, index: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }
        let swipe = UISwipeActionsConfiguration(actions: [deliteAction])
        return swipe
    }
}
