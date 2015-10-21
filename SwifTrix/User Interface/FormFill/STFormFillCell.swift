//
//  STFormFillCell.swift
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
 An STFormFillCell represents a cell inside an STFormFillController and contains an STFormField. If any text is entered in the cell's text field, it will check for compliance to provided requirements for the text and display a warning if necessary.
 */
class STFormFillCell: UITableViewCell, UITextFieldDelegate {
    /**
     Used to display, which information the user is supposed to enter
     */
    @IBOutlet weak var label: UILabel? {
        didSet{
            label?.text = formField?.label
        }
    }
    
    /**
     Used by the user to change the form field item's value
     */
    @IBOutlet weak var textField: UITextField? {
        didSet{
            self.textField?.delegate = self
            if let value = formField?.value {
                self.textField?.text = value
                self.checkRequirements()
            }
            if let formField = formField {
                if formField.isRequired {
                    self.textField?.placeholder = NSLocalizedString("Required", comment: "Displayed as placeholder in a STFormFillCell's text field if the value is required to proceed.")
                } else {
                    self.textField?.placeholder = NSLocalizedString("Optional", comment: "Displayed as placeholder in a STFormFillCell's text field if the value is not required to proceed.")
                }
            }
        }
    }
    /**
     Used to display a warning, if invalid text was entered
     */
    @IBOutlet weak var warningLabel: UILabel?
    
    /**
     The form field associated with this cell item. Setting this value also changes the text inside label and form field (if a value was already provided in the `formField`'s value property).
     */
    var formField: STFormField? {
        didSet {
            self.label?.text = formField?.label
            if let formField = formField {
                if formField.isRequired {
                    self.textField?.placeholder = NSLocalizedString("Required", comment: "Displayed as placeholder in a STFormFillCell's text field if the value is required to proceed.")
                } else {
                    self.textField?.placeholder = NSLocalizedString("Optional", comment: "Displayed as placeholder in a STFormFillCell's text field if the value is not required to proceed.")
                }
            }
            self.textField?.text = formField?.value
            self.checkRequirements()
        }
    }
    
    /**
     If the form field's value is invalid, this function checks all requirements for the provided form field and displays a warning if necessary
     */
    private func checkRequirements() {
        self.warningLabel?.hidden = true
        guard let formField = formField, value = formField.value else {
            return
        }
        
        // If form field is valid or empty and optional, do nothing
        if formField.isValueValid() || (formField.value?.isEmpty ?? true) && !formField.isRequired {
            return
        }
        
        // Otherwise, go through all requirements and check which one does not fit
        for check in formField.allRequirements {
            guard let check = check else {
                continue
            }
            
            // If a check failed, display the error message in the (visible) warning label
            if !check.valueCheck(value) {
                self.warningLabel?.text = check.errorText
                self.warningLabel?.hidden = false
                return
            }
        }
    }
    
    // MARK: - Keyboard management
    
    /**
    Current active text field for which the keyboard is shown
    */
    static var activeField: UITextField?
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        STFormFillCell.activeField?.resignFirstResponder()
        STFormFillCell.activeField = nil
    }
    
    // MARK: - Text field delegate methods
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        STFormFillCell.activeField = textField
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if STFormFillCell.activeField == textField {
            STFormFillCell.activeField?.resignFirstResponder()
        }
        
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text ?? ""
        let fullString = NSString(string: text).stringByReplacingCharactersInRange(range, withString: string)
        
        self.formField?.value = fullString
        self.checkRequirements()
        
        return true
    }
}