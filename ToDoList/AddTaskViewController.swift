
import UIKit

class AddTaskViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var taskNameTextField: UITextField!
    @IBOutlet weak var taskDetailsTextView: UITextView!
    @IBOutlet weak var taskCompletionDatePicker: UIDatePicker!
    @IBOutlet weak var scrollView: UIScrollView!
    lazy private var touchView = buildTouchView()
    
    let toolBarDone = UIToolbar.init()
    var activeTextField: UITextField?
    var activeTextView: UITextView?
    
    //MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleNavigationBarSettings()
        handleTaskDetailsBoxSettings()
        handleToolBarSettings()
        handleDelegates()
    }
    
    private func handleDelegates() {
        taskNameTextField.delegate = self
        taskDetailsTextView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deregisterForKeyboardNotification()
    }
    
    //MARK: Actions
    
    @objc private func cancelButtonDidTouch() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func doneButtonTapped() {
        view.endEditing(true)
    }
    
    @IBAction private func addTaskDidTouch(_ sender: Any) {
        guard let taskName = taskNameTextField.text, !taskName.isEmpty else {
            reportError(title: "Ivalid Task Name", message: "Task name is required")
            return
        }
        
        guard let taskDetails = taskDetailsTextView.text, !taskDetails.isEmpty else {
            reportError(title: "Invalid Task Details", message: "Task details are required")
            return
        }
        
        let completionDate: Date = taskCompletionDatePicker.date
        if completionDate < Date() {
            reportError(title: "Invalid Date", message: "Date must be in the future")
            return
        }
        
        guard let realm = LocalDatabaseManager.realm else {
            reportError(title: "Error", message: "Uma nova tarefa não pode ser criada.")
            return
        }
        
        let nextTaskId = (realm.objects(Task.self).max(ofProperty: "id") as Int? ?? 0) + 1
        let newTask = Task()
        
        newTask.id = nextTaskId
        newTask.name = taskName
        newTask.details = taskDetails
        newTask.completionDate = completionDate as NSDate
        newTask.isComplete = false
        
        do {
            try realm.write {
                realm.add(newTask)
            }
        }
        catch let error as NSError {
            print(error.localizedDescription)
            reportError(title: "Error", message: "Uma nova tarefa não pode ser criada.")
            return
        }
        
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "com.todolistapp.addtask"), object: nil)
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Methods
    
    private func reportError(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
}

//MARK: Keyboard Settings

extension AddTaskViewController {
    private func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWasShown(notification:)),
                                               name: UIWindow.keyboardDidShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWasHidden(notification:)),
                                               name: UIWindow.keyboardWillHideNotification,
                                               object: nil)
    }
    
    private func deregisterForKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWasShown(notification: NSNotification) {
        view.addSubview(touchView)
        
        let info: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0.0,
                                                       left: 0.0,
                                                       bottom: (keyboardSize!.height + toolBarDone.frame.size.height + 10.0),
                                                       right: 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect: CGRect = UIScreen.main.bounds
        aRect.size.height -= keyboardSize!.height
        
        if activeTextField != nil {
            if aRect.contains(activeTextField!.frame.origin) {
                self.scrollView.scrollRectToVisible(activeTextField!.frame, animated: true)
            }
        } else if activeTextView != nil {
            let textViewPoint: CGPoint = CGPoint(x: activeTextView!.frame.origin.x,
                                                 y: activeTextView!.frame.size.height + activeTextView!.frame.size.height)
            
            if aRect.contains(textViewPoint) {
                self.scrollView.scrollRectToVisible(activeTextView!.frame, animated: true)
            }
        }
    }
    
    @objc private func keyboardWasHidden(notification: NSNotification) {
        touchView.removeFromSuperview()
        
        let contentInsets: UIEdgeInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

//MARK: UI Factory

extension AddTaskViewController {
    private func handleNavigationBarSettings() {
        let navigationItem = UINavigationItem(title: "Adicionar tarefa")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelButtonDidTouch))
        navigationBar.items = [navigationItem]
    }
    
    private func handleTaskDetailsBoxSettings() {
        taskDetailsTextView.layer.borderColor = UIColor.gray.cgColor
        taskDetailsTextView.layer.borderWidth = CGFloat(1)
        taskDetailsTextView.layer.cornerRadius = CGFloat(3)
    }
    
    private func handleToolBarSettings() {
        toolBarDone.sizeToFit()
        toolBarDone.barTintColor = UIColor.red
        toolBarDone.isTranslucent = false
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace,
                                        target: self,
                                        action: nil)
        
        let barButtonDone = UIBarButtonItem(title: "Concluir",
                                            style: .plain,
                                            target: self,
                                            action: #selector(doneButtonTapped))
        
        barButtonDone.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17),
                                              NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        
        toolBarDone.items = [flexSpace, barButtonDone, flexSpace]
        taskNameTextField.inputAccessoryView = toolBarDone
        taskDetailsTextView.inputAccessoryView = toolBarDone
    }
    
    private func buildTouchView() -> UIView {
        let touchViewTapped = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        let _touchView = UIView()
        view.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0)
        _touchView.addGestureRecognizer(touchViewTapped)
        _touchView.isUserInteractionEnabled = true
        _touchView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        return _touchView
    }
}

extension AddTaskViewController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeTextView = textView
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        activeTextView = nil
    }
}
