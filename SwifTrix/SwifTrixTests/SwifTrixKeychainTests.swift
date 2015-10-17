//
//  SwifTrixKeychainTests.swift
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

import XCTest
import Security
@testable import SwifTrix

class SwifTrixTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    /**
     Tests saving and loading of a keychain item with an STKeychainInternetPassword as example
     */
    func testKeychainItemCreation() {
        do {
            // Prepare the test object
            let internetPassword = STKeychainInternetPassword()
            internetPassword.label = "internetPassword"
            internetPassword.server = "www.example.de"
            internetPassword.data = NSString(string: "password").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            internetPassword.path = "path/to/something/"
            internetPassword.itemDescription = "A password for www.example.de"
            internetPassword.account = "test@example.com"
            
            // Save the test object and ignore the "Item already exists" error that might occur during successive tests
            do {
                try STKeychain.addKeychainItem(internetPassword)
            } catch STKeychainError.ItemAlreadyExists {
                
            }
            
            // Search the saved item with the test object's searchAttributes (in this case: label, server, path, account)
            let dict = try STKeychain.searchKeychainItem(internetPassword)
            
            // Array of the keys whose values should be equal in the saved and loaded objects
            let expectedEqualPairs = [kSecAttrLabel as String, kSecAttrServer as String, kSecValueData as String, kSecAttrPath as String, kSecAttrDescription as String, kSecAttrAccount as String]
            var equalItems = 0
            for key in expectedEqualPairs {
                XCTAssertFalse(dict!.keys.filter({$0 == key}).isEmpty, "Expected key \(key) in the result's key list")
                guard let obj1 = dict?[key], obj2 = internetPassword.attributes[key] else {
                    continue
                }
                
                // If objects are comparable (NSObjects are), count the number of equal items
                if let obj1 = obj1 as? NSObject, obj2 = obj2 as? NSObject {
                    equalItems += 1
                    XCTAssertEqual(obj1, obj2)
                }
            }
            
            // Check if all checked attributes were equal, i.e. if the number of equal items == the number of expected equal pairs
            XCTAssertEqual(equalItems, expectedEqualPairs.count)
        } catch {
            print(error)
            XCTFail("Unexpected error during test")
        }
    }
    
    func testKeychainItemDeletion() {
        // Prepare the test object
        let genericPassword = STKeychainGenericPassword()
        genericPassword.label = "genericPassword"
        genericPassword.data = NSString(string: "password").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        genericPassword.itemDescription = "A generic password"
        genericPassword.account = "testuser"
        genericPassword.generic = NSString(string: "genericData").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        do {
            // Add the keychain item to the keychain
            try STKeychain.addKeychainItem(genericPassword)
            
            // Ensure that it is properly saved
            guard let _ = try STKeychain.searchKeychainItem(genericPassword) else {
                XCTFail("Expected a keychain item to be added to the keychain")
                return
            }
            
            // delete it from the keychain
            try STKeychain.deleteKeychainItem(genericPassword)
            
            // Ensure that it is properly deleted
            do {
                if let _ = try STKeychain.searchKeychainItem(genericPassword) {
                    XCTFail("Expected the keychain item to be deleted from the keychain")
                    return
                }
            } catch STKeychainError.ItemNotFound {
                // This error is considered a success - we wanted it to be deleted
            }
        } catch {
            switch error {
            default:
                XCTFail("Unexpected error: \(error)")
            }
        }
        
    }
}
