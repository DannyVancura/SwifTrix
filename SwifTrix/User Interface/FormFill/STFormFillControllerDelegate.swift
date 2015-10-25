//
//  STFormFillControllerDelegate.swift
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
 View controllers that present an STFormFillController should conform to this protocol to receive the user's save- or cancel-actions in the form fill controller that you present.
 */
@objc
public protocol STFormFillControllerDelegate {
    /**
     Delegate method that is called once the user tapped on the save button.
     
     - parameter controller: The form fill controller that was presented to the user and whose save button was tapped
     - parameter savedItems: The dictionary that contains the saved values.
     */
    func formFillController(controller: STFormFillController, didSave savedItems: [STFormField]?)
    
    /**
     Delegate method that is called once the user tapped on the cancel button.
     
     - parameter controller: The form fill controller that was presented to the user and whose cancel button was tapped
     */
    func formFillControllerDidCancel(controller: STFormFillController)
    
    /**
     Optional delegate method that can be implemented to return a custom table view cell. The provided NIB must contain a subclass of STFormFillCell.
     
     You can provide different types of cells for different form fields.
     
     - note: Implementing this method will only have an effect if you also implement formFillController(_, shouldUseReuseIdentifierForFormField:)
     
     - parameter controller: The Controller that is about to present a table view cell on its table view for the given form field.
     - parameter formField: The form field for which a NIB should be provided.
     
     - returns: A NIB that contains the customized STFormFillCell subclass
     */
    optional func formFillController(controller: STFormFillController, shouldUseNibForFormField formField: STFormField) -> UINib
    
    /**
     Optional delegate method that can be implemented to return the reuse identifier for a custom table view cell. The provided NIB must contain a subclass of STFormFillCell.
     
     You can provide different types of cells for different form fields.
     
     - note: Implementing this method will only have an effect if you also implement formFillController(_, shouldUseNibForFormField:)
     
     - parameter controller: The Controller that is about to present a table view cell on its table view for the given form field.
     - parameter formField: The form field for which a reuse identifier should be provided.
     
     - returns: The reuse identifier for a table view cell.
     */
    optional func formFillController(controller: STFormFillController, shouldUseReuseIdentifierForFormField formField: STFormField) -> String
}