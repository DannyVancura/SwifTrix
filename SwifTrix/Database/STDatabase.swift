//
//  STDatabase.swift
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

private var _SharedDatabase: STDatabase?

/**
 An STDatabase is the central access point to an underlying Core Data database. It serves as a wrapper for two internal contexts (one private, asynchronous context and one synchronous context on the main queue) and provides common functionality to create the entire Core Data stack. You can maintain multiple STDatabase objects and/or you can create a singleton database (STDatabase.SharedDatabase) by calling
 
        STDatabase.createSharedDatabase(...)
 
*/
public class STDatabase: NSObject {
    // MARK: -
    // MARK: Private variables:
    private let model: NSManagedObjectModel!
    private let storeCoordinator: NSPersistentStoreCoordinator!
    
    // MARK: public variables:
    
    /**
    The internal asynchronous managed object context. Can be used for actions that are not visible for the user immediately, such as server synchronization.
    */
    public let asyncContext: NSManagedObjectContext!
    /**
     The internal synchronous managed object context. Should be used for actions that affect the user interface. Fetched Results Controllers should operate on this context, since the User Interface is supposed to be modified from the main thread only.
    */
    public let mainContext: NSManagedObjectContext!
    
    // MARK: -
    // MARK: Init methods
    
    /**
    Creates a new database with the given managed object model.
    
    - parameter managedObjectModel: the managed object model that you want to use in this database
    - parameter storeName: an optional argument that provides the file name for the persistent store. Defaults to "Main".<br/> **You have to provide this argument if you are handling multiple databases in different stores!**
    */
    public init?(managedObjectModel: NSManagedObjectModel, persistentStoreName storeName: String = "Main") {
        self.model = managedObjectModel
        self.asyncContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        self.mainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        self.storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.model)
        
        self.asyncContext.persistentStoreCoordinator = self.storeCoordinator
        self.mainContext.parentContext = self.asyncContext
        
        // Create persistent store in user directory under storeName
        do {
            let userDirectory = try NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true).URLByAppendingPathComponent("\(storeName).sqlite")
            try self.storeCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: userDirectory, options: nil)
        } catch let error as NSError {
            print("Error while creating a Core Data persistent store on disk.")
            print(error.localizedDescription)
            super.init()
            return nil
        }
        
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("contextDidSave:"), name: NSManagedObjectContextDidSaveNotification, object: self.asyncContext)
    }
    
    /**
     Creates a new database with the name of a given managed object model. The name does not have to include the implicit .momd extension of maanged object model files. Optionally, you can provide a bundle in which the managed object model file can be found. If no such argument is provided, it defaults to NSBundle.mainBundle() which is the default bundle of your application.
     
     - parameter managedObjectModelName: the name of the managed object model file
     - parameter bundle: an optional argument that indicates in which bundle the managed object model file can be found
     */
    public convenience init?(var managedObjectModelName: String, inBundle bundle: NSBundle = NSBundle.mainBundle()) {
        // Append momd suffix for finding the managed object model file
        if managedObjectModelName.hasSuffix(".momd") {
            managedObjectModelName = NSString(string: managedObjectModelName).stringByDeletingPathExtension
        }
        
        // Check for existing model and create URL to this file, finally check if the model has properly been created from this URL
        guard let
            modelPath = bundle.pathForResource(managedObjectModelName, ofType: "momd")?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()),
            modelURL = NSURL(string: modelPath),
            model = NSManagedObjectModel(contentsOfURL: modelURL) else {
                print("Warning: database was not created due to invalid file path.")
                return nil
        }
        
        self.init(managedObjectModel: model)
    }
    
    // MARK: -
    // MARK: Managing shared database
    
    /**
    Creates a shared database that you can access throughout your application. Only one such database can exist at a time, so multiple calls of this method just override the previously created shared database. You call this method with a managed object model that you have created yourself.
    
    - parameter managedObjectModel: the managed object model you want to use
    */
    public class func createSharedDatabase(managedObjectModel: NSManagedObjectModel) {
        _SharedDatabase = STDatabase(managedObjectModel: managedObjectModel)
    }
    
    /**
     Creates a shared database that you can access throughout your application. Only one such database can exist at a time, so multiple calls of this method just override the previously created shared database. You call this method with a managed object model name, which is the name of a managed object model file in your application and optionally you can provide a bundle in which this file can be found. If no bundle is provided, it defaults to NSBundle.mainBundle, which is the default bundle of your application.
     
     - parameter managedObjectModelName: the name of the managed object model file
     - parameter bundle: an optional argument that indicates in which bundle the managed object model file can be found
     */
    public class func createSharedDatabase(managedObjectModelName: String, inBundle bundle: NSBundle = NSBundle.mainBundle()) {
        _SharedDatabase = STDatabase(managedObjectModelName: managedObjectModelName, inBundle: bundle)
    }
    
    /**
     Returns a shared database object that has previously been initialized with STDatabase.createSharedDatabase(...)
     */
    public class var SharedDatabase: STDatabase? {
        get {
            return _SharedDatabase
        }
    }
    
    // MARK: -
    // MARK: Synchronizing contexts:
    /**
    Receives a ContextDidSaveNotification and merges the main context with the changes. This function is expected to be called by notifications of asyncContext, which handles the internal data representation asynchronously.
    
    - parameter notification: context did save notification, sent by asyncContext
    */
    func contextDidSave(notification: NSNotification) {
        self.mainContext.mergeChangesFromContextDidSaveNotification(notification)
        do {
            try self.mainContext.save()
        } catch let error as NSError {
            print("Error while saving main context")
            print(error.localizedDescription)
        }
    }
}
