//
//  STFormFieldDelegate.swift
//  SwifTrix
//
//  Created by Daniel Vancura on 10/21/15.
//  Copyright © 2015 Daniel Vancura. All rights reserved.
//

import Foundation

/**
 An `STFormFieldDelegate` is notified by an `STFormField` when its values changed.
 */
protocol STFormFieldDelegate {
    /**
     Function that is called when the form field's value changed.
     
     - parameter formField: The form field whose value changed
     - parameter value: The new value entered for the form field by the user
     */
    func formField(formField: STFormField, valueDidChange value: String?)
}