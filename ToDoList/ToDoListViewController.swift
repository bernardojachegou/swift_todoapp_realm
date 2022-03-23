
import UIKit
import RealmSwift

protocol ToDoListDelegate: AnyObject {
    
    func update()
}

class ToDoListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    //    var toDoItems: [ToDoItemModel] = [ToDoItemModel]()
    
    var toDoItems: Results<Task>? {
        get {
            guard let realm = LocalDatabaseManager.realm else {
                return nil
            }
            
            return realm.objects(Task.self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        
        title = "Minhas Anotações"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped))
        
        //        let testItem = ToDoItemModel(name: "MICHEL Item", details: "test details", completionDate: Date())
        //        self.toDoItems.append(testItem)
        //
        //        let testItem2 = ToDoItemModel(name: "Test Item 2", details: "test details 2", completionDate: Date())
        //        self.toDoItems.append(testItem2)
        
        NotificationCenter.default.addObserver(self, selector: #selector(addNewTask(_ :)), name: NSNotification.Name.init(rawValue: "com.todolistapp.addtask"), object: nil)
    }
    
    @objc private func addNewTask(_ notification: NSNotification) {
        
        //        var toDoItem: ToDoItemModel!
        //
        //        if let task = notification.object as? ToDoItemModel {
        //            toDoItem = task
        //        }
        //        else {
        //            return
        //        }
        //
        //        toDoItems.append(toDoItem)
        //        toDoItems.sort(by: {$0.completionDate > $1.completionDate})
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tableView.setEditing(false, animated: false)
    }
    
    @objc func addTapped() {
        performSegue(withIdentifier: "AddTaskSegue", sender: nil)
        
    }
    
    @objc func editTapped() {
        
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        if tableView.isEditing == true {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editTapped))
        }
        else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped))
        }
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
            //            self.toDoItems.remove(at: indexPath.row)
            
            guard let realm = LocalDatabaseManager.realm else {
                return
            }
            
            do {
                try realm.write {
                    realm.delete(self.toDoItems![indexPath.row])
                }
            } catch let error as NSError {
                print(error.localizedDescription)
                return
            }
            
            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
        
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedItem = toDoItems![indexPath.row]
        
        let toDoTuple = (selectedItem, indexPath.row)
        
        performSegue(withIdentifier: "TaskDetailsSegue", sender: toDoTuple)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let toDoItem = toDoItems![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItem")!
        
        cell.textLabel?.text = toDoItem.name
        cell.detailTextLabel?.text = toDoItem.isComplete ? "Finalizado" : "A Fazer"
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TaskDetailsSegue" {
            guard let destinationVC = segue.destination as? ToDoDetailsViewController else { return }
            guard let toDoItem = sender as? (Task, Int) else { return }
            
            destinationVC.delegate = self
            destinationVC.toDoItem = toDoItem.0
            destinationVC.toDoIndex = toDoItem.1
            
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init(rawValue: "com.todolistapp.addtask"), object: nil)
    }
    
}

extension ToDoListViewController: ToDoListDelegate {
    
    func update() {
        
        //        toDoItems[index] = task
        tableView.reloadData()
    }
}
