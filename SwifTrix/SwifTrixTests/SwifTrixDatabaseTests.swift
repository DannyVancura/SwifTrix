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
            let userDirectory = try NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
            
            let databaseURL = userDirectory.URLByAppendingPathComponent("Main.sqlite")
            try NSFileManager.defaultManager().removeItemAtURL(databaseURL)
            
            // Delete the sqlite's Shared Memory file and Write-Ahead Log file as well
            guard let databasePath = databaseURL.path else {
                return
            }
            
            for additionalFile in [
                NSURL(fileURLWithPath: databasePath.stringByAppendingString("-shm")),
                NSURL(fileURLWithPath: databasePath.stringByAppendingString("-wal"))] {
                    print(additionalFile)
                    try NSFileManager.defaultManager().removeItemAtURL(additionalFile)
            }
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
                
                guard let allBooks: [Book] = STDatabase.SharedDatabase?.fetchObjectsWithType("Book") where allBooks.count == 1 else {
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
    
    private var completionCounter = 0
    private var expectation: XCTestExpectation?
    
    /**
     A function that is called twice by `testAsynchronousChanges` - once from the main queue, once from a separate queue. It checks, whether it has been called twice (so both queues finished adding books to the database) and then runs the tests, assuming that all books have been added.
     */
    private func asyncChangesCompletionBlock(expectedNumberOfBooks: Int) {
        completionCounter += 1
        
        if completionCounter == 2 {
            guard let books: [Book] = STDatabase.SharedDatabase!.fetchObjectsWithType("Book") else {
                XCTFail("Database contains no books")
                return
            }
            
            XCTAssertEqual(books.count, expectedNumberOfBooks)
            
            for book: Book in books {
                guard let title = book.title, pages = book.pages else {
                    XCTAssertNotNil(book.title, "Book contains no title")
                    XCTAssertNotNil(book.pages, "Book contains no pages")
                    continue
                }
                if title.containsString("async") {
                    let expectedNumberOfPages = NSString(string: NSString(string: title).substringFromIndex(5)).integerValue
                    XCTAssertEqual(expectedNumberOfPages, pages.count)
                } else if title.containsString("sync") {
                    let expectedNumberOfPages = NSString(string: NSString(string: title).substringFromIndex(4)).integerValue
                    XCTAssertEqual(expectedNumberOfPages, pages.count)
                }
            }
            
            // Fulfill the expectation that both queues did finish
            self.expectation?.fulfill()
        }
    }
    
    /**
     Tests the case where objects are added to the main context and the asynchronous background context simultaneously and checks if the inserted objects are saved correctly.
     */
    func testAsynchronousChanges() {
        // Number of asynchronously added books
        let nAsyncBooks = 100
        
        // Number of synchronously added books
        let nSyncBooks = 100
        
        self.expectation = self.expectationWithDescription("Expect both queues to finish adding books")
        
        // Asynchronous changes
        NSOperationQueue().addOperationWithBlock({
            for i in 0..<nAsyncBooks {
                STDatabase.SharedDatabase!.asyncContext.performBlock({
                    // Create a book asynchronously
                    guard let book = NSEntityDescription.insertNewObjectForEntityForName("Book", inManagedObjectContext: STDatabase.SharedDatabase!.asyncContext) as? Book else {
                        XCTFail("Failure while creating a book asynchronously")
                        return
                    }
                    
                    book.title = "async\(i)"
                    // Add i pages, so that the name of the book tells the number of pages it contains
                    for _ in 0..<i {
                        guard let page = NSEntityDescription.insertNewObjectForEntityForName("Page", inManagedObjectContext: STDatabase.SharedDatabase!.asyncContext) as? Page else {
                            XCTFail("Failure while creating a page asynchronously")
                            return
                        }
                        
                        page.book = book
                    }
                })
            }
            do {
                try STDatabase.SharedDatabase!.asyncContext.save()
                self.asyncChangesCompletionBlock(nAsyncBooks + nSyncBooks)
            } catch {
                XCTFail("Unexpected error while saving asynchronous context.")
            }
        })
        
        // Synchronous changes
        NSOperationQueue.mainQueue().addOperationWithBlock({
            for i in 0..<nSyncBooks {
                guard let book: Book = STDatabase.SharedDatabase?.createObjectNamed("Book") else {
                    XCTFail("Failure while creating a book synchronously")
                    return
                }
                
                book.title = "sync\(i)"
                // Add i pages, so that the name of the book tells the number of pages it contains
                for _ in 0..<i {
                    guard let page: Page = STDatabase.SharedDatabase!.createObjectNamed("Page") else {
                        XCTFail("Failure while creating a page synchronously")
                        return
                    }
                    
                    page.book = book
                }
            }
            
            STDatabase.SharedDatabase!.save()
            self.asyncChangesCompletionBlock(nAsyncBooks + nSyncBooks)
        })
        
        self.waitForExpectationsWithTimeout(30, handler: {print($0)})
    }
}
