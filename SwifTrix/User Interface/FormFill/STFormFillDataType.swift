//
//  STFormFillDataType.swift
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
 STFormFillDataTypes provide some information about common data types in forms. These data types provide requirements to text that the user enters while filling a form.
 
 You can provide your own data types by using .UnformattedText (which does not provide any requirements on its own) as a data type and provide additional requirements.
 */
public enum STFormFillDataType {
    /**
     Data of type unformatted text, i.e. text that does not conform to any specific syntax rules like for example E-Mails do.
     */
    case UnformattedText
    
    /**
     Data of type E-Mail, i.e. something formatted like john@smith.me
     */
    case EMail
    
    /**
     Data of type date (with day, month and year, without time)
     */
    case Date
    
    /**
     Data of type time (a date without a specific day, month and year, only time)
     */
    case Time
    
    /**
     An array of value checks that can be applied to a string and check if this string is in the correct format for the data type in question. If not, it provides an error text that can be shown to the user to describe what is wrong with the provided string value.
     */
    var requirements: [(valueCheck: String -> Bool, errorText: String)?] {
        get {
            switch self {
            case .UnformattedText:
                return []
            case .Time:
                let timeFormatter = NSDateFormatter()
                timeFormatter.locale = NSLocale.autoupdatingCurrentLocale()
                timeFormatter.dateStyle = .NoStyle
                timeFormatter.timeStyle = .ShortStyle
                return [({timeFormatter.dateFromString($0) != nil}, NSLocalizedString("The entered value is not a valid time.", comment: "Error text displayed to a user inside an STFormFillCell when he or she was supposed to enter a time."))]
            case .EMail:
                let emailRegEx = "^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$"
                let eMailCheck: String -> Bool = { return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluateWithObject($0) }
                return [(eMailCheck, NSLocalizedString("This is not a valid E-Mail address", comment: "Error text displayed to a user inside an STFormFillCell when he or she was supposed to enter a valid E-Mail address"))]
            case .Date:
                let dateFormatter = NSDateFormatter()
                dateFormatter.locale = NSLocale.autoupdatingCurrentLocale()
                dateFormatter.dateStyle = .ShortStyle
                dateFormatter.timeStyle = .NoStyle
                return [({dateFormatter.dateFromString($0) != nil}, NSLocalizedString("The entered value is not a valid date.", comment: "Error text displayed to a user inside an STFormFillCell when he or she was supposed to enter a date."))]
            }
        }
    }
}