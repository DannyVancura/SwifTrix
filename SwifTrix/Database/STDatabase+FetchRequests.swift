//
//  STDatabase+FetchRequests.swift
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


/****
IMPORTANT NOTICE: Only available in iOS. Not available in Mac OS X, due to missing NSFetchedResultsController in OS X Core Data.
*****/

import Foundation
import CoreData

// NSFetchedResultsController is not available on OS X
#if !(os(OSX))
    public extension NSFetchedResultsController {
        /**
         Returns a fetch request controller initialized using the given arguments.
         
         - parameter fetchRequest: The fetch request used to get the objects.
         - parameter database: The SwifTrix database on which fetchRequest is executed. The resulting fetched results controller will operate on the main context, so that it can be used on user interface elements, which require changes to be performed on the main thread.
         - parameter sectionNameKeyPath: A key path on result objects that returns the section name.
         - parameter name: The name of the cache file the receiver should use.
         - returns: The receiver initialized with the specified fetch request, database, key path, and cache name.
         */
        public convenience init(fetchRequest: NSFetchRequest, database: STDatabase, sectionNameKeyPath: String?, cacheName: String?) {
            self.init(fetchRequest: fetchRequest, managedObjectContext: database.mainContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)
        }
    }
#endif

public extension STDatabase {
    /**
     This function fetches all objects with a certain type and returns it as an optional array.
     - returns: An array of registered objects in the database. You have to specify the type implicitly by calling this method similarly to:
     
     let array: [MyObject]? = database.fetchObjectsWithType("MyObject")
     */
    func fetchObjectsWithType<ObjectType where ObjectType : NSManagedObject>(entityName: String) -> [ObjectType]? {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        do {
            if let result = try self.mainContext.executeFetchRequest(fetchRequest) as? [ObjectType]{
                return result
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        return nil
    }
}