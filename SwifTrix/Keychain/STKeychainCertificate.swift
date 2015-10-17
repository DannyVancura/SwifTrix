//
//  STKeychainCertificate.swift
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

public class STKeychainCertificate: STKeychainItem {
    public override init() {
        super.init()
        
        // Set class key
        self.attributes.updateValue(kSecClassCertificate, forKey: kSecClass as String)
        self.searchAttributes.updateValue(kSecClassCertificate, forKey: kSecClass as String)
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
     Denotes the certificate type (see the CSSM_CERT_TYPE enumeration in cssmtype.h)
    */
    public var certificateType: UInt? {
        get { return self.attributeForKey(kSecAttrCertificateType) }
        set { self.setAttribute(newValue, forKey: kSecAttrCertificateType) }
    }
    
    /**
     Denotes the certificate encoding (see the CSSM_CERT_ENCODING enumeration in cssmtype.h).
    */
    public var certificateEncoding: UInt? {
        get { return self.attributeForKey(kSecAttrCertificateEncoding) }
        set { self.setAttribute(newValue, forKey: kSecAttrCertificateEncoding) }
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
     The corresponding value is of type CFDataRef and contains the X.500 subject name of a certificate. Items of class kSecClassCertificate have this attribute. Read only.
    */
    public var subject: NSData? {
        get { return self.attributeForKey(kSecAttrSubject) }
    }
    
    /**
     The corresponding value is of type CFDataRef and contains the X.500 issuer name of a certificate. Items of class kSecClassCertificate have this attribute. Read only.
    */
    public var issuer: NSData? {
        get { return self.attributeForKey(kSecAttrIssuer) }
    }
    
    /**
     The corresponding value is of type CFDataRef and contains the serial number data of a certificate. Items of class kSecClassCertificate have this attribute. Read only.
    */
    public var serialNumber: NSData? {
        get { return self.attributeForKey(kSecAttrSerialNumber) }
    }
    
    /**
     The corresponding value is of type CFDataRef and contains the subject key ID of a certificate. Items of class kSecClassCertificate have this attribute. Read only.
    */
    public var subjectKeyID: NSData? {
        get { return self.attributeForKey(kSecAttrSubjectKeyID) }
    }
    
    /**
     The corresponding value is of type CFDataRef and contains the hash of a certificate's public key. Items of class kSecClassCertificate have this attribute. Read only.
    */
    public var publicKeyHash: NSData? {
        get { return self.attributeForKey(kSecAttrPublicKeyHash) }
    }
}