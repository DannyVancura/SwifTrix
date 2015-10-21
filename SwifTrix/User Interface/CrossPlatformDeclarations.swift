//
//  CrossPlatformDeclarations.swift
//  SwifTrix
//
//  Created by Daniel Vancura on 10/20/15.
//  Copyright © 2015 Daniel Vancura. All rights reserved.
//

#if os(OSX)
    import Cocoa
    
    public typealias UIViewController = NSViewController
    public typealias UIView = NSView
    public typealias UITableViewDataSource = NSTableViewDataSource
    public typealias UITableViewDelegate = NSTableViewDelegate
    public typealias UITableView = NSTableView
    public typealias UITableViewCell = NSTableRowView
    public typealias UITextFieldDelegate = NSTextFieldDelegate
    public typealias UIBarButtonItem = NSButton
    public typealias UILabel = NSTextField
    public typealias UINib = NSNib
    public typealias UITextField = NSTextField
    public typealias UIResponder = NSResponder
    public typealias UIEvent = NSEvent
    public typealias UITouch = NSTouch
#endif

// Extensions for OS X to look like iOS:
#if os(OSX)
    // MARK: - User interface extensions
    extension UILabel {
        var text: String? {
            set { if let newValue = newValue { self.stringValue = newValue } }
            get { return self.stringValue }
        }
    }
    
    extension UITableView {
        func registerNib(nib : UINib?, forCellReuseIdentifier identifier: String) {
            self.registerNib(nib, forIdentifier: identifier)
        }
        
        func dequeueReusableCellWithIdentifier(identifier: String) -> UITableViewCell? {
            return self.makeViewWithIdentifier(identifier, owner: self) as? UITableViewCell
        }
    }
    
    extension UIViewController {
        public func didReceiveMemoryWarning() {}
    }
    
    extension UITextField {
        var placeholder: String? {
            get {
                if #available(OSX 10.10, *) {
                    return self.placeholderString
                } else {
                    return nil
                }
            }
            set {
                if #available(OSX 10.10, *) {
                    self.placeholderString = newValue
                } else {
                    // Nothing
                }
            }
        }
    }
    
    // MARK: - Other object extensions
    
    extension NSIndexPath {
        public var row: Int {
            get {
                return self.indexAtPosition(0)
            }
        }
    }
    
    extension UIResponder {
        func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
            guard let event = event else {
                return
            }
            self.touchesBeganWithEvent(event)
        }
    }
    
    extension UINib {
        convenience init(nibName: String, bundle: NSBundle) {
            self.init(nibNamed: nibName, bundle: bundle)!
        }
        
        func instantiateWithOwner(ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]?) -> [AnyObject] {
            var resultArray: NSArray?
            if self.instantiateWithOwner(ownerOrNil,
                topLevelObjects: &resultArray) {
                    return (resultArray ?? []) as Array<AnyObject>
            }
            
            return []
        }
    }
#endif
