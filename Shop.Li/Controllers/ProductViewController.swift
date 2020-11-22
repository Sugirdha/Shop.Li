//
//  ViewController.swift
//  shoply
//
//  Created by Sugirdha on 11/11/20.
//

import UIKit
import CoreData

class ProductViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    var items: [Item] = []
    
    var selectedDepartment: Department? {
        didSet {
            load()
        }
    }
    
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        title = selectedDepartment?.aisle
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        load()
    }


    @IBAction func addItem(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "New Item", message: "Add a new item to buy" , preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] (action) in
            
            guard let textField = alert.textFields?.first, let itemToSave = textField.text else {
                return
            }
                        
            let item = Item(context: managedContext)
            
            item.title = itemToSave
            item.done = false
            item.parentDepartment = selectedDepartment
            items.append(item)

            save()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField { (textField) in
            textField.placeholder = "What do you need to buy?"
        }
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
//        alert.view.backgroundColor = UIColor(named: K.brandHighlight)
//        alert.view.tintColor = UIColor.black
        
        present(alert, animated: true)
    }
    
    func save() {
        do{
            try managedContext.save()
        } catch {
            print("Could not save. \(error)")
        }
        tableView.reloadData()
    }
    
    func load() {
        let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
        
        let predicate = NSPredicate(format: "parentDepartment.aisle MATCHES %@", selectedDepartment!.aisle!)
        
        fetchRequest.predicate = predicate
        
        do {
            items = try managedContext.fetch(fetchRequest)
        } catch {
            print("Couldn't fetch \(error)")
        }
    }
}

//MARK: - TableViewDataSource

extension ProductViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        let item = items[indexPath.row]
        
        cell.textLabel?.text = item.value(forKeyPath: "title") as? String

        cell.accessoryType = item.done ? .checkmark : .none
        
        let backgroundView  = UIView()
        backgroundView.backgroundColor = UIColor(named: K.brandHighlight)
        cell.selectedBackgroundView = backgroundView
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        item.done = !item.done
        save()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        
        if editingStyle == UITableViewCell.EditingStyle.delete {
            managedContext.delete(items[indexPath.row])
            
            tableView.beginUpdates()
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
          
            save()
        }

    }
    
}
