//
//  ViewController.swift
//  Todoey
//
//  Created by Antony on 2/3/18.
//  Copyright © 2018 Antony. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    var todoItems : Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory : Category? {
        didSet {
            loadItems()

        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

        searchBar.delegate = self
        
        tableView.separatorStyle = .none
     }
    
    override func viewWillAppear(_ animated: Bool) {
    
        title = selectedCategory?.name
        
        
        guard let colorHex = selectedCategory?.bgColor else {fatalError()}
        updateNavBar(withHexCode: colorHex)

        
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "1D9BF6")
    }
    
    //MARK: - Nac Bar Setup Methods
    
    func updateNavBar(withHexCode colorHexCode: String) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist.")}
        guard let navBarColor = HexColor(colorHexCode) else { fatalError() }
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
        searchBar.barTintColor =  navBarColor


    }
    
    
    //MARK - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        // Percentage reduced to half so it wont reach too dark 1.0
        let colorPercentage = CGFloat(indexPath.row) / (CGFloat((todoItems?.count)! * 2))
        //print(colorPercentage)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            //Ternary operator ==>
            // value = condition ? valueIfTrue : valueIfFalse
            cell.accessoryType = item.done ? .checkmark : .none
            cell.backgroundColor = HexColor((selectedCategory?.bgColor)!)?.darken(byPercentage: colorPercentage)
            cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        } else {
            cell.textLabel?.text = "No Items Added"
            cell.backgroundColor = HexColor("2ecc71")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    
    //MARK - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemArray[indexPath.row])
        
        
        if let item = todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    item.done = !item.done
                }
            } catch {
                print ("Error saving done status \(error)")
            }
        }

        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen when user clicks the Add Item button
            

            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        newItem.bgColor = ComplementaryFlatColorOf(HexColor(currentCategory.bgColor)!).hexValue()
                        //newItem.bgColor = UIColor(gradientStyle:UIGradientStyle.topToBottom , withFrame: self.view.bounds, andColors: [HexColor(currentCategory.bgColor)!, UIColor.blue]).hexValue()
                        print(currentCategory.bgColor)
                        print(self.view.bounds)
                        print(newItem.bgColor)
                        currentCategory.items.append(newItem)
                        self.realm.add(newItem)
                    }
                } catch {
                    print ("Error saving todoItems \(error)")
                }

            }
         
            self.tableView.reloadData()

        }
        alert.addTextField { (alertTextField) in
            
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
            
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }

    //MARK - Data Manipulation Methods
    
    
    func loadItems() {
        

        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
    
        tableView.reloadData()
        
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if self.selectedCategory != nil {
            if let itemForDeletion = todoItems?[indexPath.row] {
                do {
                    try self.realm.write {
                        self.realm.delete(itemForDeletion)
                    }
                } catch {
                    print ("Error deleting todoItem, \(error)")
                }
            }
        }

   
    }
}


//MARK: - Search bar methods
extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        fetchData()
        DispatchQueue.main.async {
            self.searchBar.resignFirstResponder()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        fetchData()

    }
    
    func fetchData() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        if searchBar.text!.count != 0 {
            todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        }
        tableView.reloadData()
        
        
//        if searchBar.text!.count == 0 {
//            loadItems()
//        } else {
//            todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
//            todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
//            self.tableView.reloadData()
//        }

    }

}
