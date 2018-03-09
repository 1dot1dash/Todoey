//
//  ViewController.swift
//  Todoey
//
//  Created by Antony on 2/3/18.
//  Copyright © 2018 Antony. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    var itemArray = [Item]()
    
    var selectedCategory : Category? {
        didSet {
            let request : NSFetchRequest<Item> = Item.fetchRequest()
            let predicate = NSPredicate(format: "parentCategory.name MATCHES %@", (selectedCategory?.name)!)
            request.predicate = predicate

            loadItems(with: request )
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    override func viewDidLoad() {
        super.viewDidLoad()
      
    print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

        searchBar.delegate = self
        
    }

    //MARK - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel!.text = item.title
        
        //Ternary operator ==>
        // value = condition ? valueIfTrue : valueIfFalse
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    
    //MARK - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemArray[indexPath.row])
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        self.saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen when user clicks the Add Item button
            
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            
            self.itemArray.append(newItem)
            
            self.saveItems()

        }
        alert.addTextField { (alertTextField) in
            
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
            
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }

    //MARK - Data Manipulation Methods
    
    func saveItems() {
       
        do {
            try context.save()
        } catch {
              print ("Error saving context \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()) {

        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("error fetching data from context \(error)")
        }
        
        tableView.reloadData()
        
    }
   
}


//MARK: - Search bar methods
extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        fetchData()
        
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        fetchData()
        
    }
    
    func fetchData() {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        if searchBar.text!.count != 0 {
            request.predicate = NSPredicate(format: "parentCategory.name MATCHES %@ AND title CONTAINS[cd] %@", (selectedCategory?.name)!,searchBar.text!)
        } else {
            request.predicate = NSPredicate(format: "parentCategory.name MATCHES %@", (selectedCategory?.name)!)
                
        }
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadItems(with: request)

    }

}
