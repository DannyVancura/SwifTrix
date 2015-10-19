//
//  STJSONParser.swift
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
 A function to parse some object from a JSON object.
 
 This is simply a function of type (jsonObject: AnyObject) throws -> AnyObject?
 */
public typealias STJSONParsingFunction = (AnyObject) throws -> (AnyObject?)

/**
 A JSON parser can use STJSONPackages or Dictionaries of kind [String:AnyObject] and parses any kind of objects from them.
 
 Example:
 ```
 let jsonDict: [String:AnyObject] = ["Branch":5]
 let jsonParser = STJSONParser()
 jsonParser.registerFactoryMethod({print($0); return $0}, forKey: "Branch")
 try jsonParser.parse(dictionary: jsonDict) // Prints "5" and returns [5]
 ```
 */
public class STJSONParser: NSObject {
    // MARK: -
    // MARK: Public variables
    public private(set) var parsedObjects: [AnyObject]
    
    // MARK: Private variables
    private var factoryMethods : [String:STJSONParsingFunction]
    
    // MARK: -
    // MARK: Initialization
    public override init() {
        self.parsedObjects = []
        self.factoryMethods = [:]
    }
    
    // MARK: -
    // MARK: Setup for parsing
    /**
    Registers a factory method for a certain key. If parse() encounters the specified key, the factory method is called with this branch to create an object that is stored in parsedObjects.
    
    Example:
    ```
    let jsonDict: [String:AnyObject] = ["Branch":5]
    let jsonParser = STJSONParser()
    jsonParser.registerFactoryMethod({print($0); return $0}, forKey: "Branch")
    try jsonParser.parse(dictionary: jsonDict) // Prints "5" and returns [5]
    ```
    
    - parameter factoryMethod: a factory method that takes the branch of a JSON object
    */
    public func registerFactoryMethod(factoryMethod: STJSONParsingFunction, forKey key: String) {
        self.factoryMethods.updateValue(factoryMethod, forKey: key)
    }
    
    /**
     Unregisters the factory method that is registered for the specified key.
     
     - parameter key: The key for the factory method that should be deleted
     */
    public func unregisterFactoryMethodForKey(key: String) {
        self.factoryMethods.removeValueForKey(key)
    }
    
    // MARK: -
    // MARK: Parsing
    
    /**
     Parses a dictionary and creates objects with the registered factory methods.
     
     Example:
     ```
     let jsonDict: [String:AnyObject] = ["Branch":5]
     let jsonParser = STJSONParser()
     jsonParser.registerFactoryMethod({print($0); return $0}, forKey: "Branch")
     try jsonParser.parse(dictionary: jsonDict) // Prints "5" and returns [5]
     ```
     
     - parameter dictionary: the dictionary that should be parsed for contained objects
     - returns: an array of all objects that were parsed during this call of parse(...).</br>**Important:** 
     This is not equal to *parsedObjects*, which contains the values that were parsed during all calls to *parse(...)*.
     - throws: any error that you throw in registered factory methods. Be aware that this cancels parsing right as soon as the error occurs
     */
    public func parse(dictionary dict: [String:AnyObject]) throws -> [AnyObject] {
        var parsed: [AnyObject] = []
        
        // Parse each key
        for key in dict.keys {
            guard let value = dict[key] else {
                continue
            }
            
            // If there is a parsing function that handles this key, call it
            if let parsingFunction: STJSONParsingFunction = self.factoryMethods[key] {
                if let parsedObject = try parsingFunction(value) {
                    parsed.append(parsedObject)
                }
            }
        }
        
        self.parsedObjects.appendContentsOf(parsed)
        
        return parsed
    }
    
    /**
     Parses a JSON package and creates objects with the registered factory methods.
     
     - parameter jsonPackage: the JSON package that should be parsed for contained objects
     */
    public func parse(jsonPackage jsonPackage: STJSONPackage) throws -> [AnyObject] {
        let attributes: [String:AnyObject] = jsonPackage.attributes
        
        return try self.parse(dictionary: attributes)
    }
}
