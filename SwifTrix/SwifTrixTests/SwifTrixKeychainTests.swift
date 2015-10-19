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
     Creates a prefilled `STKeychainInternetPassword` for testing purposes.
     */
    private func createInternetPassword() -> STKeychainInternetPassword {
        let internetPassword = STKeychainInternetPassword()
        internetPassword.label = "internetPassword"
        internetPassword.server = "www.example.de"
        internetPassword.data = NSString(string: "password").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        internetPassword.path = "path/to/something/"
        internetPassword.itemDescription = "A password for www.example.de"
        internetPassword.account = "test@example.com"
        
        return internetPassword
    }
    
    /**
     If an item already exists in the keychain, this function deletes it (and all values that are stored with it) and creates it with the provided keychainItem (without the attributes that might have been set before)
     */
    private func addObjectToKeychain(keychainItem: STKeychainItem) throws {
        do {
            try STKeychain.deleteKeychainItem(keychainItem)
            try STKeychain.addKeychainItem(keychainItem)
        } catch STKeychainError.ItemNotFound {
            try STKeychain.addKeychainItem(keychainItem)
        }
    }
    
    /**
     Tests saving and loading of a keychain item with an STKeychainInternetPassword as example
     */
    func testKeychainItemCreation() {
        do {
            // Prepare the test object
            let internetPassword = self.createInternetPassword()
            
            try self.addObjectToKeychain(internetPassword)
            
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
    
    func testKeychainItemUpdate() {
        do {
            // Create an internet password and a password that contains only changes to this first internet password
            let internetPassword = self.createInternetPassword()
            let updatedInternetPassword = STKeychainInternetPassword()
            
            // Set the changes on the empty internet password
            updatedInternetPassword.data = NSString(string: "newPassword").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            updatedInternetPassword.port = 12345
            
            // Add the first internet password (without changes)
            try self.addObjectToKeychain(internetPassword)
            
            // Update this saved internet password (so that it contains the changes)
            try STKeychain.updateKeychainItem(internetPassword, withNewValuesFrom: updatedInternetPassword)
            
            // Fetch the saved values and check if they were updated correctly
            guard let updatedValues = try STKeychain.searchKeychainItem(updatedInternetPassword) else {
                XCTFail("Expected to find updated attributes for the updated internet password")
                return
            }
            
            XCTAssertTrue(updatedValues[kSecAttrPort as String] as? Int == 12345, "Expected the port to be updated to 12345, instead found \(updatedValues[kSecAttrPort as String])")
            guard let data = updatedValues[kSecValueData as String] as? NSData else {
                XCTFail("Expected the updated keychain item to contain data for the key kSecValueData")
                return
            }
            guard let str = String(data: data, encoding: NSUTF8StringEncoding) else {
                XCTFail("Expected the updated data to be parseable to a string")
                return
            }
            
            XCTAssertEqual(str, "newPassword")
        } catch {
            print(error)
            XCTFail("Unexpected error")
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
    
    /**
     Keychain operations are expected to throw errors under certain circumstances, such as deleting non-existing items, adding items twice or searching for non-existing items. This test checks, if the right errors are thrown in these cases.
     */
    func testForExpectedErrors() {
        let internetPassword = self.createInternetPassword()
        
        // Add it twice and check if it correctly throws an ItemAlreadyExists error
        do {
            try self.addObjectToKeychain(internetPassword)
            try STKeychain.addKeychainItem(internetPassword)
            XCTFail("Expected Error while adding an item twice")
        } catch STKeychainError.ItemAlreadyExists {
            // O.K.
        } catch {
            XCTFail("Unexpected error")
        }
        
        // Delete it twice and check if it correctly throws an ItemNotFound error the second time
        do {
            try STKeychain.deleteKeychainItem(internetPassword)
        } catch {
            XCTFail("Unexpected error while deleting")
        }
        do {
            try STKeychain.deleteKeychainItem(internetPassword)
            XCTFail("Expected Error while deleting non-existing item")
        } catch STKeychainError.ItemNotFound {
            // O.K.
        } catch {
            XCTFail("Unexpected error while deleting the second time")
        }
        
        // Search for a non-existing item
        do {
            try STKeychain.searchKeychainItem(internetPassword)
            XCTFail("Expected Error while searching for non-existing item")
        } catch STKeychainError.ItemNotFound {
            // O.K.
        } catch {
            XCTFail("Unexpected error while searching for a non-existing item")
        }
    }
}
