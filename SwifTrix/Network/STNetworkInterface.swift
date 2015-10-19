//
//  STNetworkInterface.swift
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

private(set) var defaultNetworkInterface: STNetworkInterface?
private(set) var backgroundNetworkInterface: STNetworkInterface?
private(set) var ephemeralNetworkInterface: STNetworkInterface?

/**
 A network interface serves as the interface not to a specific server, but to a specific URL session. Over an URL session, you can request or send data, either in a background task that continues after you close the app or in the foreground.
 */
public class STNetworkInterface: NSObject {
    // MARK: -
    // MARK: Public variables
    public private(set) var URLSession: NSURLSession?
    public private(set) var URLSessionQueue: NSOperationQueue?
    
    // MARK: -
    // MARK: Initialization
    public override init() {
        super.init()
    }
    
    // MARK: -
    // MARK: Session configurations
    /**
    Starts a default URL Session with the network interface as delegate
    */
    private func startDefaultURLSession() {
        let sessionConfiguration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        self.URLSession = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
    }
    
    /**
     Starts a background URL Session with the network interface as delegate
     
     - parameter backgroundSessionIdentifier: Unique identifier for the background session
     */
    @available(OSX 10.10, *)
    private func startBackgroundURLSession(backgroundSessionIdentifier: String) {
        if backgroundSessionIdentifier.isEmpty {
            print("Unable to start a background URL session with an empty session identifier.")
            return
        }
        let sessionConfiguration: NSURLSessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(backgroundSessionIdentifier)
        
        self.URLSession = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
    }
    
    /**
     Starts an ephemeral URL session with the network interface as delegate
     */
    private func startEphemeralURLSession() {
        let sessionConfiguration: NSURLSessionConfiguration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        
        self.URLSession = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue:nil)
    }
    
    // MARK: -
    // MARK: Public singleton network interfaces
    
    /**
    Returns a singleton default network interface.
    */
    public var DefaultNetworkInterface: STNetworkInterface {
        if defaultNetworkInterface == nil {
            defaultNetworkInterface = STNetworkInterface()
            defaultNetworkInterface?.startDefaultURLSession()
        }
        return defaultNetworkInterface!
    }
    
    /**
     Returns a singleton background network interface.
     
     Allows HTTP and HTTPS uploads or downloads to be performed in the background.
     */
    public var BackgroundNetworkInterface: STNetworkInterface {
        if backgroundNetworkInterface == nil {
            backgroundNetworkInterface = STNetworkInterface()
            backgroundNetworkInterface?.startBackgroundURLSession("SwifTrix.BackgroundSession")
        }
        return backgroundNetworkInterface!
    }
    
    /**
     Returns a singleton ephemeral network interface.
     
     Operates on a configuration that uses no persistent storage for caches, cookies, or credentials.
     */
    public var EphemeralNetworkInterface: STNetworkInterface {
        if ephemeralNetworkInterface == nil {
            ephemeralNetworkInterface = STNetworkInterface()
            ephemeralNetworkInterface?.startEphemeralURLSession()
        }
        return ephemeralNetworkInterface!
    }
}