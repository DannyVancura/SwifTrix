//
//  FirstViewController.swift
//  FormFillingDatabaseExample
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

import UIKit
import SwifTrix

class FirstViewController: UIViewController, STFormFillControllerDelegate {

    private var formFillController: STFormFillController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.formFillController?.formFields = self.createEmptyFormFields()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedFormFillController" {
            // Get reference to the form fill controller in the container ver
            guard let formFillController = segue.destinationViewController as? STFormFillController else {
                return
            }
            
            self.formFillController = formFillController
            self.formFillController?.delegate = self
        }
    }
    
    // MARK: - Sample implementation of some table view cells
    
    /**
     Creates a set of four form fields
     */
    private func createEmptyFormFields() -> [STFormField] {
        // Create an ordered array of form fields
        var formFields: [STFormField] = []
        
        formFields.append(STFormField(label: "Name", isRequired: true, dataType: .UnformattedText))
        formFields.append(STFormField(label: "E-Mail", isRequired: true, dataType: .EMail))
        
        // A form field with a very simple "value selection" prototype
        formFields.append(STFormField(label: "Birth date", isRequired: false, dataType: .Date, additionalRequirements: [], customFormFieldAction: {
            (inout formField: STFormField) -> Void in formField.value="1/2/34"
        }))
        
        // A form field with custom additional requirements for unformatted text
        formFields.append(STFormField(label: "Gender", isRequired: false, dataType: .UnformattedText, additionalRequirements: [({ return $0 == "Male" || $0 == "Female"
            }, "You were supposed to enter 'Male' or 'Female'")]))
        
        return formFields
    }
    
    // MARK: - Implementation for the save- and cancel- button actions
    
    func formFillController(controller: STFormFillController, didSave savedItems: [STFormField]?) {
        // Save the entries in a new object in the database
        if let formFilling: FormFilling = STDatabase.SharedDatabase!.createObjectNamed("FormFilling") {
            formFilling.name = savedItems?[0].value
            formFilling.eMail = savedItems?[1].value
            if let dateString = savedItems?[2].value {
                formFilling.date = NSDateFormatter().dateFromString(dateString)
            }
            formFilling.gender = savedItems?[3].value
            STDatabase.SharedDatabase!.save()
        }
        
        // Clear the form fields by overwriting them with new ones
        self.formFillController?.formFields = self.createEmptyFormFields()
    }
    
    func formFillControllerDidCancel(controller: STFormFillController) {
        // Clear the form fields by overwriting them with new ones
        self.formFillController?.formFields = self.createEmptyFormFields()
    }
    
    // MARK: - Implementation to load your own table view cell style
    
    func formFillController(controller: STFormFillController, shouldUseNibForFormField formField: STFormField) -> UINib {
        return UINib(nibName: "CustomFormFillCell", bundle: nil)
    }
    
    func formFillController(controller: STFormFillController, shouldUseReuseIdentifierForFormField formField: STFormField) -> String {
        return "example.cell.reuseID"
    }
}

