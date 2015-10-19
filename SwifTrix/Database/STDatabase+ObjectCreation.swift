//
//  STDatabase+ObjectCreation.swift
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
import CoreData

public extension STDatabase {
    /**
     Creates and returns an object with a given name and inserts it into the database. The return value is implicitly cast to the desired object type, if possible.
     - parameter name: The entity name of the desired object in the database
     
     Example:
     
     `let obj: MyManagedObject = STDatabase.SharedDatabase!.createObjectNamed("MyManagedObject")`
     */
    public func createObjectNamed<ObjectType where ObjectType : NSManagedObject>(name: String) -> ObjectType? {
        var asyncObject: NSManagedObject?
        self.asyncContext.performBlockAndWait({
            asyncObject = NSEntityDescription.insertNewObjectForEntityForName(name, inManagedObjectContext: self.asyncContext) as? ObjectType
        })
        if let asyncObject = asyncObject {
            return self.mainContext.objectWithID(asyncObject.objectID) as? ObjectType
        }
        return nil
    }
    
    /**
     Deletes an object from the database
     - parameter object: The managed object you want to delete
     */
    public func deleteObject(object : NSManagedObject) {
        if object.managedObjectContext === self.mainContext{
            self.mainContext.deleteObject(object)
        } else {
            self.asyncContext.performBlock({
                self.asyncContext.deleteObject(object)
            })
        }
    }
}