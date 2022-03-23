
import UIKit

class ToDoDetailsViewController: UIViewController {
    
    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var taskDetailsTextView: UITextView!
    @IBOutlet weak var taskCompletionButton: UIButton!
    @IBOutlet weak var taskCompletionDate: UILabel!
    
    var toDoItem: Task!
    var toDoIndex: Int!
    weak var delegate: ToDoListDelegate?
    
    //MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskTitleLabel.text = toDoItem.name
        taskDetailsTextView.text = toDoItem.details
        if toDoItem.isComplete {
            disableButton()
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM, yyyy hh:mm"
        let taskDate = formatter.string(from: toDoItem.completionDate as Date)
        taskCompletionDate.text = taskDate
    }
    
    //MARK: Actions
    
    private func disableButton() {
        taskCompletionButton.backgroundColor = UIColor.gray
        taskCompletionButton.isEnabled = false
    }
    
    @IBAction func taskDidComplete(_ sender: Any) {
        
        guard let realm = LocalDatabaseManager.realm else {
            return
        }
        
        do {
            try realm.write {
                toDoItem.isComplete = true
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        
        delegate?.update()
        disableButton()
    }
    
}
