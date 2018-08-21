//
//  Copyright (C) 2017 DB Systel GmbH.
//	DB Systel GmbH; Jürgen-Ponto-Platz 1; D-60329 Frankfurt am Main; Germany; http://www.dbsystel.de/
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

/// Mock implementation for `NetworkTask`.
public class NetworkTaskMock: NetworkTask {
    
    /// Mock state of the network task
    public enum State {
        case canceled, resumed, suspended
    }
    
    /// Creates an `NetworkTaskMock` instance
    public init() {}
    
    /// State of the network taks. Can be used to assert.
    public private(set) var state: State?
    
    /// Cancel the request. Sets state to cancled.
    public func cancel() {
        state = .canceled
    }
    
    /// Resumes the request. Sets state to resumed.
    public func resume() {
        state = .resumed
    }
    
    /// Suspends the request. Sets state to suspended.
    public func suspend() {
        state = .suspended
    }
    
    /// Mock progress with constant value `0`
    @available(*, deprecated, message: "Progress is no longer supported and will be removed in version 2.0")
    public var progress: Progress {
        return Progress(totalUnitCount: 0)
    }
}
