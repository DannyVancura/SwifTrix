//
//  STKeychain+Items.swift
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
import Security

public extension STKeychain {
    /**
     Adds the given keychain item's attributes to the keychain.
     
     - precondition: The keychain item is assumed to not already exist in the keychain. Otherwise, this call will throw an `STKeychainError.ItemAlreadyExists` error.
     - parameter keychainItem: The keychain item whose attributes will be added to the keychain
     - throws: An instance of STKeychainError if any error occurred
     */
    public class func addKeychainItem(keychainItem: STKeychainItem) throws {
        try STKeychain.secureAdd(keychainItem.attributes)
    }
    
    /**
     Deletes the keychain item that is found by using the item's search attributes from the keychain.
     
     - precondition: The keychain item is assumed to exist in the keychain. Otherwise, this call will throw an `STKeychainError.ItemNotFound` error.
     
     - parameter keychainItem: The keychain item that you are trying to delete from the keychain
     - throws: An instance of STKeychainError if any error occurred
     */
    public class func deleteKeychainItem(keychainItem: STKeychainItem) throws {
        try STKeychain.secureDelete(keychainItem.searchAttributes)
    }
    
    /**
     Updates the keychain item that is found by the keychain item's search attributes with its current attributes.
     
     - precondition: The keychain item is assumed to exist in the keychain. Otherwise, this call will throw an `STKeychainError.ItemNotFound` error. Further, the updated keychain item should only contain the attributes that will be updated. Passing a keychain item with read-only properties (such as `kSecAttrCreationDate`) might fail, as the keychain will try to save these.
     
     - parameter keychainItem: The keychain item, whose search attributes are used to find itself in the database
     - parameter updatedKeychainItem: The keychain item, whose attributes are used to update the existing values in the keychain
     - throws: An instance of STKeychainError if any error occured
     */
    public class func updateKeychainItem(keychainItem: STKeychainItem, withNewValuesFrom updatedKeychainItem: STKeychainItem) throws {
        let keychainAttributes = keychainItem.searchAttributes
        
        // Remove the class from the attributes, since this is supposed to be set in an STKeychainItem, but can not be updated
        var updatedAttributes = updatedKeychainItem.attributes
        updatedAttributes.removeValueForKey(kSecClass as String)
        
        try STKeychain.secureUpdate(updatedAttributes, query: keychainAttributes)
    }
    
    /**
     Searches the keychain for the given keychain item's search attributes.
     
     - precondition: The keychain item is assumed to exist in the keychain. Otherwise, this call will throw an `STKeychainError.ItemNotFound` error.
     
     - parameter keychainItem: The keychain item, whose known search attributes are used to find the data you are looking for
     - returns: The attributes of the searched keychain item that are stored in the keychain or nil, if the item could not be found or its data parsed
     - throws: An instance of STKeychainError if any error occurred
     */
    public class func searchKeychainItem(keychainItem: STKeychainItem) throws -> Dictionary<String, AnyObject>? {
        var keychainAttributes = keychainItem.searchAttributes
        keychainAttributes.updateValue(kCFBooleanTrue, forKey: kSecReturnAttributes as String)
        keychainAttributes.updateValue(kCFBooleanTrue, forKey: kSecReturnData as String)
        keychainAttributes.updateValue(kSecMatchLimitOne, forKey: kSecMatchLimit as String)
        
        guard let
            data: NSDictionary = try STKeychain.secureFind(keychainAttributes),
            keyValuePairs = data as? Dictionary<String, AnyObject> else {
            return nil
        }
        
        return keyValuePairs
    }
}