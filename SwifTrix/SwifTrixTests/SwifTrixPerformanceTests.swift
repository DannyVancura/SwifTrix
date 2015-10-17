//
//  SwifTrixPerformanceTests.swift
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
import SwifTrix
import CoreData

class SwifTrixPerformanceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        STDatabase.createSharedDatabase("TestDataModel", inBundle: NSBundle(forClass: SwifTrixPerformanceTests.self))
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        do {
            let userDirectory = try NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true).URLByAppendingPathComponent("Main.sqlite")
            try NSFileManager.defaultManager().removeItemAtURL(userDirectory)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    // Test performance of a large set of objects on the main context
    func testSaveLargeDatasetSynchronously() {
        guard let owner: Bookworm = STDatabase.SharedDatabase!.createObjectNamed("Bookworm") else {
            XCTFail()
            return
        }
        owner.name = "TestOwner"
        for _ in 0..<100 {
            if let book: Book = STDatabase.SharedDatabase!.createObjectNamed("Book") {
                book.owner = owner
                book.title = "TestTitle"
                for _ in 0..<1000 {
                    if let page: Page = STDatabase.SharedDatabase!.createObjectNamed("Page"){
                        page.book = book
                        page.text = "TestText"
                    }
                }
            }
        }
        self.measureBlock {
            STDatabase.SharedDatabase!.save()
        }
    }
    
    // Test performance of a large set of objects on the asynchronous context
    func testSaveLargeDatasetAsynchronously() {
        STDatabase.SharedDatabase!.asyncContext.performBlockAndWait({
            guard let owner: Bookworm = NSEntityDescription.insertNewObjectForEntityForName("Bookworm", inManagedObjectContext: STDatabase.SharedDatabase!.asyncContext) as? Bookworm else {
                XCTFail()
                return
            }
            owner.name = "TestOwner"
            for _ in 0..<100 {
                if let book: Book = NSEntityDescription.insertNewObjectForEntityForName("Book", inManagedObjectContext: STDatabase.SharedDatabase!.asyncContext) as? Book {
                    book.owner = owner
                    book.title = "TestTitle"
                    for _ in 0..<1000 {
                        if let page: Page = NSEntityDescription.insertNewObjectForEntityForName("Page", inManagedObjectContext: STDatabase.SharedDatabase!.asyncContext) as? Page{
                            page.book = book
                            page.text = "TestText"
                        }
                    }
                }
            }
        })
        self.measureBlock {
            STDatabase.SharedDatabase!.save()
        }
    }
    
    // Test performance of saving a small set of objects
    func testSaveSmallDataset() {
        guard let owner: Bookworm = STDatabase.SharedDatabase!.createObjectNamed("Bookworm") else {
            XCTFail()
            return
        }
        owner.name = "TestOwner"
        for _ in 0..<10 {
            if let book: Book = STDatabase.SharedDatabase!.createObjectNamed("Book") {
                book.owner = owner
                book.title = "TestTitle"
                for _ in 0..<10 {
                    if let page: Page = STDatabase.SharedDatabase!.createObjectNamed("Page"){
                        page.book = book
                        page.text = "TestText"
                    }
                }
            }
        }
        self.measureBlock {
            STDatabase.SharedDatabase!.save()
        }
    }
}
