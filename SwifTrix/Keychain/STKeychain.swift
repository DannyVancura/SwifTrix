//
//  STKeychain.swift
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

/**
 STKeychain offers higher-level access to parts of Apple's Security Framework. While the Security Framework operates on attributes, STKeychain tries to translate these into proper Objects - STKeychainItems.
*/
public class STKeychain: NSObject {
    /**
     Adds attributes to the keychain.
     
     - parameter attributes: the attributes to add to the keychain
     - throws: an instance of STKeychainError in case of an error
    */
    class func secureAdd(attributes: NSDictionary) throws {
        if let error = STKeychainError.fromOSStatus(SecItemAdd(attributes, nil)) {
            throw error
        }
    }
    
    /**
     Deletes objects from the keychain that match the given query.
     
     - parameter query: the query for the items you want to delete
     - throws: an instance of STKeychainError in case of an error
    */
    class func secureDelete(query: NSDictionary) throws {
        if let error = STKeychainError.fromOSStatus(SecItemDelete(query)) {
            throw error
        }
    }
    
    /**
     Updates objects for the given query with the provided attributes.
     
     - parameter attributes: the new updates for the objects you find with your query
     - parameter query: the query for the items you want to update
     - throws: an instance of STKeychainError in case of an error
    */
    class func secureUpdate(attributes: NSDictionary, query: NSDictionary) throws {
        if let error = STKeychainError.fromOSStatus(SecItemUpdate(query, attributes)) {
            throw error
        }
    }
    
    /**
     Searches the keychain for the given query
     
     - parameter query: the attributes, which are used to find the data you are looking for
     - returns: data of the request - for a single item, this is expected to be a NSDictionary, whereas for multiple results, it is a NSArray (depending on kSecMatchLimit in the search query)
     - throws: an instance of STKeychainError if any error occurred
     */
    class func secureFind<ResultType>(query: NSDictionary) throws -> ResultType? {
        var data: ResultType?
        try withUnsafeMutablePointer(&data, {
            if let error = STKeychainError.fromOSStatus(SecItemCopyMatching(query, UnsafeMutablePointer($0))) {
                throw error
            }
        })
        
        return data
    }
}