
import UIKit
import RealmSwift

protocol ToDoListDelegate: AnyObject {
    func update()
}

class ToDoListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var toDoItems: Results<Task>? {
        get {
            guard let realm = LocalDatabaseManager.realm else {
                return nil
            }
            return realm.objects(Task.self)
        }
    }
    
    //MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tableView.setEditing(false, animated: false)
    }
    
    //MARK: Custom Methods
    
    private func setupView() {
        title = "Minhas Anotações"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped))
        
        NotificationCenter.default.addObserver(self, selector: #selector(addNewTask(_ :)), name: NSNotification.Name.init(rawValue: "com.todolistapp.addtask"), object: nil)
    }
    
    //MARK: Actions
    
    @objc private func addNewTask(_ notification: NSNotification) {
        tableView.reloadData()
    }
    
    @objc private func addTapped() {
        performSegue(withIdentifier: "AddTaskSegue", sender: nil)
        
    }
    
    @objc private func editTapped() {
        
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        if tableView.isEditing == true {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editTapped))
        }
        else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped))
        }
        
    }
    
    //MARK: TableView Methods
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
            guard let realm = LocalDatabaseManager.realm else { return }
            
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

//MARK: Protocol

extension ToDoListViewController: ToDoListDelegate {
    func update() {
        tableView.reloadData()
    }
}
