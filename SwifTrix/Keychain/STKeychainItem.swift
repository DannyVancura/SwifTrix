//
//  STKeychainItem.swift
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
 A keychain item represents a set of attributes in the keychain. This set of attributes can for example describe a certificate or password. To update or remove items in the keychain, search queries are used with a given set of attributes, which are saved in this object's searchAttributes.
 
 To search for an STKeychainItem, you create one and set all the values that you already know - such as account or server for example - and then you perform the search operation with STKeychain.searchKeychainItem(...). This will return key-value pairs that are stored in the keychain for the search perimeters that you set.
*/
public class STKeychainItem: NSObject {
    /**
     The object's attributes are attributes as defined in the
     [Security Framework reference](xcdoc://?url=developer.apple.com/library/prerelease/ios/documentation/Security/Reference/keychainservices/index.html#//apple_ref/doc/constant_group/Item_Class_Value_Constants)
     that describe the keychain item.
     */
    public var attributes: Dictionary<String,AnyObject>!
    
    /**
     The object's search attributes are attributes that let you search for the given item. These items can be a combination of both
     [Search Attribute Keys](xcdoc://?url=developer.apple.com/library/prerelease/ios/documentation/Security/Reference/keychainservices/index.html#//apple_ref/doc/constant_group/Search_Attribute_Keys)
     and
     [Item attributes](xcdoc://?url=developer.apple.com/library/prerelease/ios/documentation/Security/Reference/keychainservices/index.html#//apple_ref/doc/uid/TP30000898-CH4g-SW5)
     */
    public var searchAttributes: Dictionary<String,AnyObject>!
    
    public override init() {
        self.attributes = [:]
        self.searchAttributes = [:]
        
        super.init()
    }
    
    /**
     The data for this object. The corresponding value is of type CFDataRef.  For keys and password items, the data is secret (encrypted) and may require the user to enter a password for access.
     */
    public var data: NSData? {
        get { return self.attributeForKey(kSecValueData) }
        set { self.setAttribute(newValue, forKey: kSecValueData) }
    }
    
    /**
     Returns the attribute for a certain key in the desired class type.
     
     - parameter key: The key of the attribute in the keychain item's attributes
     - returns: The value for the searched key in the desired type
     */
    func attributeForKey<AttributeType>(key: CFStringRef) -> AttributeType? {
        return self.attributes[key as String] as? AttributeType
    }
    
    /**
     Sets the specified attribute value for a given key
     
     - parameter attribute: The attribute value that you want to save
     - parameter key: The key for which the attribute should be saved
    */
    func setAttribute(attribute: AnyObject?, forKey key: CFStringRef) {
        if let attribute = attribute {
            self.attributes.updateValue(attribute, forKey: key as String)
        }
    }
    
    /**
     Sets the specified search attribute value for a given key. If the attribute is nil, this pair is removed from the search attributes.
     
     - parameter attribute: The attribute value that you want to save
     - parameter key: The key for which the attribute should be saved
     */
    func setSearchAttribute(attribute: AnyObject?, forKey key: CFStringRef) {
        if let attribute = attribute {
            self.searchAttributes.updateValue(attribute, forKey: key as String)
        } else {
            self.searchAttributes.removeValueForKey(key as String)
        }
    }
}