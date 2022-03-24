
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
        
        handleTaskDetailsBoxSettings()
        
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
    
    //MARK: Methods
    private func disableButton() {
        taskCompletionButton.isHidden = true
    }
    
}

extension ToDoDetailsViewController {
    private func handleTaskDetailsBoxSettings() {
        taskDetailsTextView.layer.borderColor = UIColor.detailsColor.cgColor
        taskDetailsTextView.layer.borderWidth = CGFloat(1)
        taskDetailsTextView.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 5, right: 5)
    }
}
