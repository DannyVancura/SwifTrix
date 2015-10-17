//
//  STKeychainInternetPassword.swift
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

public class STKeychainInternetPassword: STKeychainItem {
    public override init() {
        super.init()
        
        // Set class key
        self.attributes.updateValue(kSecClassInternetPassword, forKey: kSecClass as String)
        self.searchAttributes.updateValue(kSecClassInternetPassword, forKey: kSecClass as String)
    }
    
    /**
     A property that declares the accessibility of this item, as described in [Accessibility Constants](xcdoc://?url=developer.apple.com/library/prerelease/ios/documentation/Security/Reference/keychainservices/index.html#//apple_ref/doc/constant_group/Keychain_Item_Accessibility_Constants)
     */
    public var accessible: String? {
        get { return self.attributeForKey(kSecAttrAccessible) }
        set { self.setAttribute(newValue, forKey: kSecAttrComment) }
    }
    
    /**
     A property that describes the access group of the keychain item.
     */
    public var accessGroup: String? {
        get { return self.attributeForKey(kSecAttrAccessGroup) }
        set { self.setAttribute(newValue, forKey: kSecAttrAccessGroup) }
    }
    
    /**
     A string, containing the user-editable comment for this item
     */
    public var comment: String? {
        get { return self.attributeForKey(kSecAttrComment) }
        set { self.setAttribute(newValue, forKey: kSecAttrComment) }
    }
    
    /**
     The date the keychain item was created
     */
    public var creationDate: NSDate? {
        get { return self.attributeForKey(kSecAttrCreationDate) }
    }
    
    /**
     The date the keychain item was last modified
     */
    public var modificationDate: NSDate? {
        get { return self.attributeForKey(kSecAttrModificationDate)}
    }
    
    /**
     Specifies a user-visible string describing this kind of item (for example, "Disk image password")
     */
    public var itemDescription: String? {
        get { return self.attributeForKey(kSecAttrDescription) }
        set { self.setAttribute(newValue, forKey: kSecAttrDescription) }
    }
    
    /**
     The corresponding value is of type CFNumberRef and represents the item's creator. This number is the unsigned integer representation of a four-character code (for example, 'aCrt').
     */
    public var creator: UInt? {
        get { return self.attributeForKey(kSecAttrCreator)}
        set { self.setAttribute(newValue, forKey: kSecAttrCreator) }
    }
    
    /**
     The corresponding value is of type CFNumberRef and represents the item's type. This number is the unsigned integer representation of a four-character code (for example, 'aTyp').
     */
    public var type: UInt? {
        get { return self.attributeForKey(kSecAttrType) }
        set { self.setAttribute(newValue, forKey: kSecAttrType) }
    }
    
    /**
     The user-visible label for this item.
     
     - if set, this is part of the search attributes
     */
    public var label: String? {
        get { return self.attributeForKey(kSecAttrLabel) }
        set {
            self.setAttribute(newValue, forKey: kSecAttrLabel)
            self.setSearchAttribute(newValue, forKey: kSecAttrLabel as String)
        }
    }
    
    /**
     True if the item is invisible (that is, should not be displayed).
     */
    public var isInvisible: Bool? {
        get { return self.attributeForKey(kSecAttrIsInvisible) }
        set { self.setAttribute(newValue, forKey: kSecAttrIsInvisible) }
    }
    
    /**
     Indicates whether there is a valid password associated with this keychain item. This is useful if your application doesn't want a password for some particular service to be stored in the keychain, but prefers that it always be entered by the user.
     */
    public var isNegative: Bool? {
        get { return self.attributeForKey(kSecAttrIsNegative) }
        set { self.setAttribute(newValue, forKey: kSecAttrIsNegative) }
    }
    
    /**
     Account name for this password
     
     - if set, this is part of the search attributes
     */
    public var account: String? {
        get { return self.attributeForKey(kSecAttrAccount) }
        set {
            self.setAttribute(newValue, forKey: kSecAttrAccount)
            self.setSearchAttribute(newValue, forKey: kSecAttrAccount as String)
        }
    }
    
    /**
     Represents the internet security domain
    */
    public var securityDomain: String? {
        get { return self.attributeForKey(kSecAttrSecurityDomain) }
        set { self.setAttribute(newValue, forKey: kSecAttrSecurityDomain) }
    }
    
    /**
     Contains the server's domain name or IP address
     
     - if set, this is part of the search attributes
    */
    public var server: String? {
        get { return self.attributeForKey(kSecAttrServer) }
        set {
            self.setAttribute(newValue, forKey: kSecAttrServer)
            self.setSearchAttribute(newValue, forKey: kSecAttrServer as String)
        }
    }
    
    /**
     Denotes the protocol for this item. See: [Protocol Values](xcdoc://?url=developer.apple.com/library/prerelease/ios/documentation/Security/Reference/keychainservices/index.html#//apple_ref/doc/constant_group/Protocol_Values)
    */
    public var internetProtocol: UInt? {
        get { return self.attributeForKey(kSecAttrProtocol) }
        set {
            self.setAttribute(newValue, forKey: kSecAttrProtocol)
            self.setSearchAttribute(newValue, forKey: kSecAttrProtocol as String)
        }
    }
    
    /**
     Denotes the authentication scheme for this item. See: [Authentication Type Values](xcdoc://?url=developer.apple.com/library/prerelease/ios/documentation/Security/Reference/keychainservices/index.html#//apple_ref/doc/constant_group/Authentication_Type_Values)
     
     - if set, this is part of the search attributes
    */
    public var authenticationType: UInt? {
        get { return self.attributeForKey(kSecAttrAuthenticationType) }
        set { self.setAttribute(newValue, forKey: kSecAttrAuthenticationType) }
    }
    
    /**
     Represents an Internet port number.
     
     - if set, this is part of the search attributes
    */
    public var port: UInt? {
        get { return self.attributeForKey(kSecAttrPort) }
        set {
            self.setAttribute(newValue, forKey: kSecAttrPort)
            self.setSearchAttribute(newValue, forKey: kSecAttrPort as String)
        }
    }
    
    /**
     Represents a path, typically the path component of the URL.
     
     - if set, this is part of the search attributes
    */
    public var path: String? {
        get { return self.attributeForKey(kSecAttrPath) }
        set {
            self.setAttribute(newValue, forKey: kSecAttrPath)
            self.setSearchAttribute(newValue, forKey: kSecAttrPath as String)
        }
    }
}