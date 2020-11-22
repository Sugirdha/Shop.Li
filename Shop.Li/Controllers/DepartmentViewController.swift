//
//  DepartmentViewController.swift
//  shoply
//
//  Created by Sugirdha on 15/11/20.
//

import Foundation
import UIKit
import CoreData

class DepartmentViewController: UITableViewController {

    var departments: [Department] = []
    var managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        title = "Your Shop.Li"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        load()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add Aisle", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) {
            [unowned self](action) in
            
            guard let textField = alert.textFields?.first, let newAisle = textField.text else {
                return
            }
            
            let newDepartment = Department(context: managedContext)
            newDepartment.aisle = newAisle
            departments.append(newDepartment)
            save()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Add an aisle"
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        
//        alert.view.backgroundColor = UIColor(named: K.brandHighlight)
//        alert.view.tintColor = UIColor.black
        
    
        present(alert, animated: true)
    }
    
    func load() {
        let fetchRequest = NSFetchRequest<Department>(entityName: "Department")
        do {
            departments = try managedContext.fetch(fetchRequest)
        } catch {
            print("Error fetching context \(error)")
        }
        tableView.reloadData()
    }
    
    func save() {
        do {
            try managedContext.save()
        } catch {
            print("Error saving context \(error)")
        }
        tableView.reloadData()
    }
    
}


extension DepartmentViewController {
    
    //MARK: - TableView Datasource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return departments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DepartmentCell", for: indexPath)
        cell.textLabel?.text = departments[indexPath.row].aisle
        
        let backgroundView  = UIView()
        backgroundView.backgroundColor = UIColor(named: K.brandHighlight)
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    
    //MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let cell = tableView.cellForRow(at: indexPath) {
//            cell.contentView.backgroundColor = UIColor(named: K.brandHighlight)
//        }
        performSegue(withIdentifier: "goToProducts", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ProductViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedDepartment = departments[indexPath.row]
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            managedContext.delete(departments[indexPath.row])
            departments.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            save()
        }
    }
    
}
