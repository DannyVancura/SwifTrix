//
//  SecondViewController.swift
//  FormFillingDatabaseExample
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

import UIKit
import SwifTrix
import CoreData

let reuseIdentifier = "reuseIdentifier"

class SecondViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    private var fetchedResultsController: NSFetchedResultsController?
    @IBOutlet weak var tableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create fetched results controller
        let fetchRequest = NSFetchRequest(entityName: "FormFilling")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, database: STDatabase.SharedDatabase!, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchedResultsController?.delegate = self
        do {
            try self.fetchedResultsController?.performFetch()
        } catch {
            print(error)
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tableViewCell = UITableViewCell(style: .Subtitle, reuseIdentifier: reuseIdentifier)
        guard let formFilling: FormFilling = self.fetchedResultsController?.objectAtIndexPath(indexPath) as? FormFilling else {
            return tableViewCell
        }
        tableViewCell.textLabel?.text = formFilling.name
        if let date = formFilling.date {
            tableViewCell.detailTextLabel?.text = "\(formFilling.eMail ?? "nil") | \(NSDateFormatter().stringFromDate(date) ?? "nil") | \(formFilling.gender ?? "nil")"
        } else {
            tableViewCell.detailTextLabel?.text = "\(formFilling.eMail ?? "nil") | \(formFilling.gender ?? "nil")"
        }
        
        return tableViewCell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects else {
            return 0
        }
        
        return fetchedObjects.count
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // Commit deleting by deleting fetched object from database
        switch editingStyle {
        case .Delete:
            if let obj = self.fetchedResultsController?.objectAtIndexPath(indexPath) as? NSManagedObject {
                STDatabase.SharedDatabase!.deleteObject(obj)
            }
        default:
            break
        }
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView?.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView?.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            self.tableView?.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            self.tableView?.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Move:
            self.tableView?.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
        case .Update:
            self.tableView?.reloadRowsAtIndexPaths([indexPath!, newIndexPath!], withRowAnimation: .Fade)
        }
    }
}

