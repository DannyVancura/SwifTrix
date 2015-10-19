//
//  STJSONPackage.swift
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
 A JSON package contains information for a JSON object, obtained from or sent to a server.
 */
public class STJSONPackage: NSObject {
    var attributes: Dictionary<String,AnyObject>
    
    /**
     Initializes a JSON package with values for the respective keys, such as `values = ["John"]`, `keys = ["firstName"]`
     
     - parameter values: An array with the values for an object
     - parameter keys: An array with the corresponding keys for 'values'
     */
    public init(withValues values: [AnyObject], forKeys keys: [String]) {
        self.attributes = NSDictionary(objects: values, forKeys: keys) as! [String:AnyObject]
        super.init()
    }
    
    /**
     Initializes a JSON package with values for the respective keys in a dictionary, such as `["firstName":"John"]`
     
     - parameter valuesForKeys: A dictionary with the object's information
     */
    public init(valuesForKeys: [String:AnyObject]) {
        self.attributes = valuesForKeys
        super.init()
    }
    
    /**
     Initializes a JSON package with data from a HTTP response, i.e. data that can be parsed as a NSDictionary.
     
     - parameter data: Data that can be parsed as a JSON object, for example data that was sent from a server as response for a GET request
     */
    public convenience init(data: NSData) throws {
        // Check if data can be parsed to a JSON object
        if !NSJSONSerialization.isValidJSONObject(data) {
            throw STJSONError.JSONObjectParsingNotPossible
        }
        
        do {
            // Parse data as Dictionary with Strings as keys and any JSON-compliant object (Strings, Numbers, Arrays, ...)
            guard let jsonObject: Dictionary<String,AnyObject> = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? Dictionary<String,AnyObject> else {
                throw STJSONError.JSONObjectParsingError
            }
            
            // Initialize self with the parsed values
            self.init(valuesForKeys: jsonObject)
            
        } catch STJSONError.JSONObjectParsingNotPossible {
            // isValidJSONObject returned false
            print("Data can not be parsed to a valid JSON object.")
            throw STJSONError.JSONObjectParsingNotPossible
            
        } catch STJSONError.JSONObjectParsingError {
            // parsing JSON object to a <String,AnyObject> Dictionary failed
            print("Data represents a valid JSON object but error during parsing.")
            throw STJSONError.JSONObjectParsingError
        }
    }
}