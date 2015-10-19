//
//  SwifTrixJSONParserTests.swift
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
@testable import SwifTrix

class SwifTrixJSONParserTests: XCTestCase {
    var jsonParser: STJSONParser!
    
    override func setUp() {
        super.setUp()
        
        self.jsonParser = STJSONParser()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSimpleJSONParsing() {
        do {
            let simpleJSONObject = ["aString":"Success"]
            
            self.jsonParser.registerFactoryMethod({return $0 as? String}, forKey: "aString")
            
            let result = try self.jsonParser.parse(dictionary: simpleJSONObject)
            XCTAssertEqual(result[0] as? String, "Success")
        } catch {
            XCTFail("Unexpected error")
        }
    }
    
    func testMultipleJSONParsing() {
        do {
            // Create two "JSON-like object sets"
            let multipleJSONObjects = ["one":1, "two":2, "three":"Three"]
            let singleJSONObject = ["Four":4]
            
            // Register parsers for numbers and strings that transform the saved data in some way
            self.jsonParser.registerFactoryMethod({return ($0 as! Int) + 1}, forKey: "one")
            self.jsonParser.registerFactoryMethod({return ($0 as! Int) + 2}, forKey: "two")
            self.jsonParser.registerFactoryMethod({return ($0 as! String).stringByAppendingString("3")}, forKey: "three")
            self.jsonParser.registerFactoryMethod({return ($0 as! Int) + 3}, forKey: "Four")
            
            // Parse the results for each set
            let multipleResults = try self.jsonParser.parse(dictionary: multipleJSONObjects)
            let singleResult = try self.jsonParser.parse(dictionary: singleJSONObject)
            
            // Keys of a dictionary are traversed in alphabetical order, so three comes before two and the order is swapped in the results
            let expectedMultipleResults: [AnyObject] = [2, "Three3", 4]
            let expectedSingleResult: [AnyObject] = [7]
            
            // Compare the results on their own and the combined results stored in the jsonParser's parsedObjects
            XCTAssertTrue(multipleResults.elementsEqual(expectedMultipleResults, isEquivalent: {($0 as? NSObject) == ($1 as? NSObject)}), "Elements not equal: \(multipleResults) vs. \(expectedMultipleResults)")
            XCTAssertTrue(singleResult.elementsEqual(expectedSingleResult, isEquivalent: {($0 as? NSObject) == ($1 as? NSObject)}))
            XCTAssertTrue(self.jsonParser.parsedObjects.elementsEqual(expectedMultipleResults+expectedSingleResult, isEquivalent: {($0 as? NSObject) == ($1 as? NSObject)}))
        } catch {
            XCTFail("Unexpected error")
        }
    }
    
}
