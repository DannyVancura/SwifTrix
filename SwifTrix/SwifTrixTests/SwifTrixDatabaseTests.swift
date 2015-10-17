//
//  SwifTrixDatabaseTests.swift
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
import CoreData
@testable import SwifTrix

class SwifTrixDatabaseTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        STDatabase.createSharedDatabase("TestDataModel", inBundle: NSBundle(forClass: SwifTrixTests.self))
    }
    
    override func tearDown() {
        super.tearDown()
        do {
            let userDirectory = try NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true).URLByAppendingPathComponent("Main.sqlite")
            try NSFileManager.defaultManager().removeItemAtURL(userDirectory)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    /**
     Tests the context consistency, i.e. modifying an object on both contexts and assuring that after a save operation, both changes have successfully been applied.
     */
    func testDatabaseContextConsistency() {
        // Create book on the main context
        if let book: Book = STDatabase.SharedDatabase!.createObjectNamed("Book") {
            book.pages = Set<Page>()
            
            // Create a page on the async, an another page on the main thread
            if let page1: Page = NSEntityDescription.insertNewObjectForEntityForName("Page", inManagedObjectContext: STDatabase.SharedDatabase!.asyncContext) as? Page,
                page2: Page = NSEntityDescription.insertNewObjectForEntityForName("Page", inManagedObjectContext: STDatabase.SharedDatabase!.mainContext) as? Page
            {
                // Add both pages to the book (once to the book reference on the main queue, once on the async queue)
                STDatabase.SharedDatabase!.asyncContext.performBlockAndWait({
                    page1.book = STDatabase.SharedDatabase!.asyncContext.objectWithID(book.objectID) as? Book
                })
                page2.book = book
                
                STDatabase.SharedDatabase!.save()
                
                guard let allBooks: [Book] = STDatabase.SharedDatabase?.fetchObjectsWithType("Book") else {
                    XCTFail("Expected one book to be saved")
                    return
                }
                
                XCTAssertEqual(allBooks[0].pages?.count, 2, "Expected the book to have 2 pages by now")
            } else {
                XCTFail("Unexpectedly got nil while creating pages")
            }
        } else {
            XCTFail("Unexpectedly got nil while creating a book")
        }
    }
    
    func testAsynchronousChanges() {
        // Asynchronous changes
        NSOperationQueue().addOperationWithBlock({
            
        })
    }
}
