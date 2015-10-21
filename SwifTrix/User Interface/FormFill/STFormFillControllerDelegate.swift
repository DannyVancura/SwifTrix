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

import Foundation

/**
 View controllers that present an STFormFillController should conform to this protocol to receive the user's save- or cancel-actions in the form fill controller that you present.
 */
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
}