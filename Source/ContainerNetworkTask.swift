//
//  Copyright (C) 2018 DB Systel GmbH.
//    DB Systel GmbH; Jürgen-Ponto-Platz 1; D-60329 Frankfurt am Main; Germany; http://www.dbsystel.de/
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
//  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

import Foundation

/// A task which contains another task which can be updated in fligh.
/// Use this task to build machasnims which need to fetch requests during the orginal reuqets.
/// An oAuth Flow would be a good example for this.
public final class ContainerNetworkTask: NetworkTask {
    
    // MARK: - Init
    
    /// Creates an `ContainerNetworkTask` instance
    public init() { }
    
    // MARK: - Override
    
    // MARK: - Protocol NetworkTask
    
    /**
     Resumes a task.
     */
    public func resume() {
        underlyingTask?.resume()
    }
    
    /**
     Cancels the userlying task.
     */
    public func cancel() {
        isCanceled = true
        underlyingTask?.cancel()
    }
    
    /**
     Suspends a task.
     */
    public func suspend() {
        underlyingTask?.suspend()
    }
    
    /**
     Contains the current progress of a running task.
     */
    @available(iOS 11.0, OSX 10.13, watchOS 4.0, tvOS 11.0, *)
    public var progress: Progress {
        guard let task = underlyingTask else {
            fatalError("OrginalTask has to be set")
        }
        return task.progress
    }
    
    // MARK: - Public
    
    /// The underlying task
    public var underlyingTask: NetworkTask?
    
    // MARK: - Private
    
    /// Falg if the request is canceld. Can be used to stop
    /// cancle following request in the chain.
    public private(set) var isCanceled = false
}
