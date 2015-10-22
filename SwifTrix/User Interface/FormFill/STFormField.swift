//
//  STForm.swift
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

import Foundation

/**
 An STFormField represents the data for a cell inside the STFormFillController. It contains the label that will be presented to the user and should describe shortly what the user is supposed to enter (e.g. "Your E-Mail", "First name", ...). Further it specifies, whether or not the value is required to be entered to proceed, what data type is expected (E-Mail format, Date, ...) and optionally, you can provide additional requirements that check, whether the input provided by the user is valid. In the case that you want to provide your own view (for example to select a certain value from a UITableView), you can also pass a custom function to the form field that will be called once the user taps on the text field. In this case, the displayed text field will not be editable via keyboard.
 */
public class STFormField: NSObject {
    public var label: String
    public var isRequired: Bool
    public var dataType: STFormFillDataType
    public var additionalRequirements: [(valueCheck: String -> Bool, errorText: String)?]
    public var customFormFieldAction: ((inout STFormField) -> ())?
    public var value: String? {
        didSet {
            self.delegate?.formField(self, valueDidChange: self.value)
        }
    }
    var delegate: STFormFieldDelegate?
    
    /**
     All requirements - those predefined by using a certain data type and also the additional requirements
     */
    var allRequirements: [(valueCheck: String -> Bool, errorText: String)?] {
        get {
            var all = dataType.requirements
            all.appendContentsOf(additionalRequirements)
            return all
        }
    }
    
    /**
     Returns whether the form fields value fulfills all requirements
     */
    public func isValueValid() -> Bool {
        guard let value = self.value else {
            return false
        }
        for requirement in self.allRequirements {
            if let requirement = requirement {
                if !requirement.valueCheck(value) {
                    return false
                }
            }
        }
        return true
    }
    
    /**
     Creates a form field with the specified values.
     
     - parameter label: User-visible label that shortly (i.e. in one or two short words) describes what the user is supposed to enter
     - parameter isRequired: Specifies whether this field has to be filled to proceed or whether it is optional
     - parameter dataType: A data type for the input data
     - parameter additionalFormatters: One or more formatters that verify the input. If the text entered by the user is invalid for one of these formatters, the corresponding `errorText` is displayed as a warning.
     - parameter customFormFieldAction: If you provide this argument, the form field's text field will not be selected on user interaction but `customFormFieldAction` will be called with the form field you create. You can provide this method to present a new view (for example with a date picker) and set the value of the form field in this view.
     */
    public convenience init(label: String, isRequired:Bool, dataType: STFormFillDataType, additionalRequirements: [(valueCheck: String -> Bool, errorText: String)?], customFormFieldAction: ((inout STFormField) -> ())) {
        self.init(label: label, isRequired: isRequired, dataType: dataType, additionalRequirements: additionalRequirements)
        self.customFormFieldAction = customFormFieldAction
    }
    
    /**
     Creates a form field with the specified values.
     
     - parameter label: User-visible label that shortly (i.e. in one or two short words) describes what the user is supposed to enter
     - parameter isRequired: Specifies whether this field has to be filled to proceed or whether it is optional
     - parameter dataType: A data type for the input data
     - parameter additionalFormatters: One or more formatters that verify the input. If the text entered by the user is invalid for one of these formatters, the corresponding `errorText` is displayed as a warning.
     */
    public init(label: String, isRequired:Bool, dataType: STFormFillDataType, additionalRequirements: [(valueCheck: String -> Bool, errorText: String)?]) {
        self.label = label
        self.isRequired = isRequired
        self.dataType = dataType
        self.additionalRequirements = additionalRequirements
    }
    
    /**
     Creates a form field with the specified values.
     
     - parameter label: User-visible label that shortly (i.e. in one or two short words) describes what the user is supposed to enter
     - parameter isRequired: Specifies whether this field has to be filled to proceed or whether it is optional
     - parameter dataType: A data type for the input data
     */
    public convenience init(label: String, isRequired:Bool, dataType: STFormFillDataType) {
        self.init(label: label, isRequired: isRequired, dataType: dataType, additionalRequirements: [])
    }
}