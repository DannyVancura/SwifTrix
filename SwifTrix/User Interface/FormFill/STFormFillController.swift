//
//  STFormFillController.swift
//  SwifTrix
//
// The MIT License (MIT)
//
// Copyright © 2015 Daniel Vancura
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#if os(OSX)
    import Cocoa
#else
    import UIKit
#endif

/**
 An STFormFillController can be used to fill a set of information (like for example: name, E-Mail, address, birth date, ...).
 
 By specifying the desired data type (`STFormFillDataType`), keys (e.g. "userEmail"), requirements (i.e. required or optional arguments - for example, the address in the above example might be optional, while the name could be required) and user-visible labels (e.g. "Your E-Mail") you create a form that can be presented to the user.
 
 Based on the requirements (format correct, requirements fulfilled), the user will receive the option to save the data with a button whose label you provide as (e.g.) `formFillController.doneLabel = "Next"`.
 
 ----
 **Using in Storyboard**
 
 When using in a storyboard, you can provide your own table view, save and cancel buttons and call actions on your own. Further, you can remove the view from a `STFormViewController` and it will load a default view from Nib.
 */
public class STFormFillController: UIViewController, UITableViewDataSource, UITableViewDelegate, STFormFieldDelegate {
    // MARK: -
    // MARK: Public variables
    @IBOutlet public private(set) weak var tableView: UITableView?
    
    /**
     The cancel button that calls the form fill controller delegate's cancel operation. The delegate is responsible of dismissing this view controller.
     */
    @IBOutlet public weak var cancelButton: UIBarButtonItem?
    
    /**
     The save button that calls the form fill controller delegate's save operation. The delegate is responsible of dismissing this view controller. This button should remain inactive, as long as the user did not enter all required values.
     */
    @IBOutlet public weak var saveButton: UIBarButtonItem?
    
    public var delegate: STFormFillControllerDelegate?
    public var formFields: [STFormField]? {
        didSet {
            for formField: STFormField in self.formFields ?? [] {
                formField.delegate = self
                self.formField(formField, valueDidChange: formField.value)
            }
            self.tableView?.reloadData()
        }
    }
    
    // MARK: Framework-only variables
    
    
    // MARK: Private variables
    private let formFillCellReuseIdentifier: String = "SwifTrix.ReuseIdentifier.STFormFillCell"
    private var cellsForFormFields: [STFormField:STFormFillCell] = [:]
    
    // MARK: - View setup
    public override func viewDidLoad() {
        if #available(OSX 10.10, *) {
            super.viewDidLoad()
        } else {
            
        }
        self.saveButton?.enabled = false
        self.setupTableView()
        self.setupKeyboardResponder()
        self.tableView?.reloadData()
    }
    
    public override func loadView() {
        // If a custom view was loaded that provides a table view then use this. Otherwise load the default view from the framework
        if self.tableView != nil {
            super.loadView()
            return
        }
        
        // Load view from the NIB that resides in the framework
        if let formFillView: UIView = UINib(nibName: "STFormFillController", bundle: NSBundle(forClass: STFormFillController.self)).instantiateWithOwner(self, options: nil).first as? UIView {
            self.view = formFillView
            return
        } else {
            super.loadView()
        }
    }
    
    private func setupKeyboardResponder() {
        #if !(os(OSX))
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidShow:"), name: UIKeyboardDidShowNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        #endif
    }
    
    /**
     Sets up the table view.
     */
    private func setupTableView() {
        guard let tableView = tableView else {
            return
        }
        
        tableView.registerNib(UINib(nibName: "STFormFillCell", bundle: NSBundle(forClass: STFormFillController.self)), forCellReuseIdentifier: formFillCellReuseIdentifier)
        
        #if !(os(OSX))
            tableView.rowHeight = UITableViewAutomaticDimension
            
            if #available(iOS 9.0, *) {
                if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.TV {
                    tableView.estimatedRowHeight = 132
                } else {
                    tableView.estimatedRowHeight = 78
                }
            } else {
                tableView.estimatedRowHeight = 78
            }
        #endif
    }
    
    // MARK: - Table View management
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let formFields = formFields else {
            return 0
        }
        
        return formFields.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let formField = self.formFields?[indexPath.row] else {
            return UITableViewCell()
        }
        
        guard let tableViewCell: STFormFillCell = tableView.dequeueReusableCellWithIdentifier(formFillCellReuseIdentifier) as? STFormFillCell else {
            print("Warning: Could not load tableViewCell from NIB.")
            return UITableViewCell()
        }
        
        // Set the form field (which will then automatically set label, text, ...)
        tableViewCell.formField = formField
        
        self.cellsForFormFields.updateValue(tableViewCell, forKey: formField)
        return tableViewCell
    }
    
    func formField(formField: STFormField, valueDidChange value: String?) {
        // Force update for table view cell:
        self.cellsForFormFields[formField]?.formField = formField
        
        // Check if all form fields contain valid values and enable save button if all required fields are valid
        for field in (self.formFields ?? []) {
            if field.isRequired && !field.isValueValid() {
                self.saveButton?.enabled = false
                return
                // Form field is optional, not empty and invalid
            } else if !field.isRequired && !(field.value?.isEmpty ?? true) && !field.isValueValid() {
                self.saveButton?.enabled = false
                return
            }
        }
        self.saveButton?.enabled = true
    }
    
    // MARK: - Button actions
    /**
    A function that is called on when the user taps the save button. This function then calls the delegate's save operation but does not dismiss this view controller on its own.
    */
    @IBAction func saveAction(sender: UIBarButtonItem) {
        if let delegate = delegate {
            delegate.formFillController(self, didSave: self.formFields)
        }
    }
    
    /**
     A function that is called on when the user taps the cancel button. This function then calls the delegate's cancel operation but does not dismiss this view controller on its own.
     */
    @IBAction func cancelAction(sender: UIBarButtonItem) {
        if let delegate = delegate {
            delegate.formFillControllerDidCancel(self)
        }
    }
    
    // MARK: - Keyboard management
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        STFormFillCell.activeField?.resignFirstResponder()
        STFormFillCell.activeField = nil
    }
    
    #if !(os(OSX))
    /**
     Function that will be called once the keybard will show. Scrolls the table view to the selected text field.
     */
    func keyboardDidShow(notification: NSNotification) {
        let info = notification.userInfo
        guard let kbSize = (info?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size, activeField = STFormFillCell.activeField else {
            return
        }
        
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
        self.tableView?.contentInset = contentInsets;
        self.tableView?.scrollIndicatorInsets = contentInsets;
        
        // If active text field is hidden by keyboard, scroll it so it's visible
        // Your app might not need or want this behavior.
        var aRect = self.view.frame;
        aRect.size.height -= kbSize.height;
        if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
            self.tableView?.scrollRectToVisible(activeField.frame, animated:true)
        }
    }
    
    /**
     Function that will be called once the keyboard will disappear.
     */
    func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsetsZero;
        self.tableView?.contentInset = contentInsets;
        self.tableView?.scrollIndicatorInsets = contentInsets;
    }
    #endif
    
    // MARK: - Other
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
