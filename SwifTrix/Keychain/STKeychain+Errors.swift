//
//  STKeychain+Errors.swift
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

public enum STKeychainError: ErrorType {
    case NoError
    case FunctionNotImplemented
    case InvalidParameters
    case MemoryAllocationFailure
    case NoTrustResultsAvailable
    case AuthenticationFailed
    case ItemAlreadyExists
    case ItemNotFound
    case InteractionWithSecServerNotAllowed
    case UnableToDecodeProvidedData
    case UnknownError
    
    static func fromOSStatus(status: OSStatus) -> STKeychainError? {
        switch status {
        case 0:
            return nil
        case -4:
            return .FunctionNotImplemented
        case -50:
            return .InvalidParameters
        case -108:
            return .MemoryAllocationFailure
        case -25291:
            return .NoTrustResultsAvailable
        case -25293:
            return .AuthenticationFailed
        case -25299:
            return .ItemAlreadyExists
        case -25300:
            return .ItemNotFound
        case -25308:
            return .InteractionWithSecServerNotAllowed
        case -26275:
            return .UnableToDecodeProvidedData
        default:
            return .UnknownError
        }
    }
}