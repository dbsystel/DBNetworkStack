//
//  Copyright (C) 2017 DB Systel GmbH.
//  DB Systel GmbH; Jürgen-Ponto-Platz 1; D-60329 Frankfurt am Main; Germany; http://www.dbsystel.de/
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
import XCTest
@testable import DBNetworkStack

class RetryTaskTest: XCTestCase {
    
    let mockError: NetworkError = .unknownError
    
    func testDontHoldReference_withoutCreatingErrorClosure() {
        //Given
        var task: RetryNetworkTask<Int>? = RetryNetworkTask(maxmimumNumberOfRetries: 1, idleTimeInterval: 1,
                                                            shouldRetry: { _ in return true}, onSuccess: { _, _  in }, onError: { _ in }, retryAction: { _, _ in
            return NetworkTaskMock()
        }, dispatchRetry: { _, _ in
        })
        
        //When
        weak var weakTask = task
        task = nil
        
        //Then
        XCTAssertNil(weakTask)
    }
    
    func testDontHoldReference_Sucess() {
        //Given
        var successValue: Int?
        var task: RetryNetworkTask<Int>? = RetryNetworkTask(maxmimumNumberOfRetries: 1, idleTimeInterval: 1,
                                                            shouldRetry: { _ in return true}, onSuccess: { (value: Int, _) in
            successValue = value
        }, onError: { _ in
        }, retryAction: {sucess, _ in
            sucess(0, .defaultMock)
            return NetworkTaskMock()
        }, dispatchRetry: { _, block in
            block()
        })
        
        //When
        weak var weakTask = task
        var onError = task?.createOnError()
        task = nil
        XCTAssertNotNil(weakTask)
        onError?(mockError)
        onError = nil
        
        //Then
        XCTAssertNil(weakTask)
        XCTAssertEqual(successValue, 0)
    }
    
    func testDontHoldReference_CreatingErrorClosure() {
        //Given
        var numerOfRertrys = 0
        var task: RetryNetworkTask<Int>? = RetryNetworkTask(maxmimumNumberOfRetries: 3, idleTimeInterval: 0.3,
                                                            shouldRetry: { _ in return true}, onSuccess: { (_: Int, _) in
        }, onError: { _ in
        }, retryAction: {success, error in
            numerOfRertrys += 1
            if numerOfRertrys == 3 {
                success(0, .defaultMock)
            } else {
               error(self.mockError)
            }
            
            return NetworkTaskMock()
        }, dispatchRetry: { _, block in
            block()
        })
        
        //When
        weak var weakTask = task
        var onError = task?.createOnError()
        task = nil
        XCTAssertNotNil(weakTask)
        
        onError?(mockError)
        onError = nil
        
        //Then
        XCTAssertNil(weakTask)
        XCTAssertEqual(numerOfRertrys, 3)
    }
    
    func testDontHoldReference_CancleTask() {
        var numerOfRertrys = 0
        var task: RetryNetworkTask<Int>? = RetryNetworkTask(maxmimumNumberOfRetries: 3, idleTimeInterval: 0.3,
                                                            shouldRetry: { _ in return true}, onSuccess: { (_: Int, _) in
        }, onError: { _ in
        }, retryAction: { onSucess, onError in
            numerOfRertrys += 1
            if numerOfRertrys == 3 {
                onSucess(0, .defaultMock)
            } else {
                onError(self.mockError)
            }
            
            return NetworkTaskMock()
        }, dispatchRetry: { _, block in
            block()
        })
        weak var weakTask = task
        
        var onError = task?.createOnError()
        task?.cancel()
        task = nil
        XCTAssertNotNil(weakTask)
        
        onError?(mockError)
        onError = nil
        
        XCTAssertNil(weakTask)
        XCTAssertEqual(numerOfRertrys, 0)
    }
    
    func testShouldNotRetry() {
        var capturedError: NetworkError?
        var task: RetryNetworkTask<Int>? = RetryNetworkTask(maxmimumNumberOfRetries: 3, idleTimeInterval: 0.3,
                                                            shouldRetry: { _ in return false}, onSuccess: { _, _  in
            
        }, onError: { error in
            capturedError = error
        }, retryAction: { _, _ in
            XCTFail("Expects not to retry")
            return NetworkTaskMock()
        }, dispatchRetry: { _, block in
            block()
        })
        weak var weakTask = task
        
        var onError = task?.createOnError()
        task = nil
        XCTAssertNotNil(weakTask)
        
        onError?(mockError)
        onError = nil
        
        XCTAssertNil(weakTask)
        XCTAssertNotNil(capturedError)
    }
    
    func testShouldNotWhenMaximumNumberOfRetrys() {
        var retryCount = 0
        let task: RetryNetworkTask<Int> = RetryNetworkTask(maxmimumNumberOfRetries: 3, idleTimeInterval: 0.3,
                                                            shouldRetry: { _ in return true }, onSuccess: { _, _  in
                                                                
        }, onError: { _ in
            
        }, retryAction: { _, _ in
            retryCount += 1
            return NetworkTaskMock()
        }, dispatchRetry: { _, block in
            block()
        })
        
        let onError = task.createOnError()
        
        onError(.unknownError)
        onError(.unknownError)
        onError(.unknownError)
        onError(.unknownError)
        
        XCTAssertEqual(retryCount, 3)
    }
    
    func testResume() {
        //Given
        let taskMock = NetworkTaskMock()
        let task: RetryNetworkTask<Int>? = RetryNetworkTask(maxmimumNumberOfRetries: 3, idleTimeInterval: 0.3,
                                                            shouldRetry: { _ in return false}, onSuccess: { _, _  in
                                                                
        }, onError: { _ in
        }, retryAction: { _, _ in
            XCTFail("Expects not to retry")
            return NetworkTaskMock()
        }, dispatchRetry: { _, block in
            block()
        })
        task?.originalTask = taskMock
        
        //When
        task?.resume()
        
        //Then
        XCTAssert(taskMock.state == .resumed)
    }
    
    func testSuspend() {
        //Given
        let taskMock = NetworkTaskMock()
        let task: RetryNetworkTask<Int>? = RetryNetworkTask(maxmimumNumberOfRetries: 3, idleTimeInterval: 0.3,
                                                            shouldRetry: { _ in return false}, onSuccess: { _, _  in
                                                                
        }, onError: { _ in
        }, retryAction: { _, _ in
            XCTFail("Expects not to retry")
            return NetworkTaskMock()
        }, dispatchRetry: { _, block in
            block()
        })
        task?.originalTask = taskMock
        
        //When
        task?.suspend()
        
        //Then
        XCTAssert(taskMock.state == .suspended)
    }
    
    func testProgress() {
        //Given
        let taskMock = NetworkTaskMock()
        let task: RetryNetworkTask<Int>? = RetryNetworkTask(maxmimumNumberOfRetries: 3, idleTimeInterval: 0.3,
                                                            shouldRetry: { _ in return false}, onSuccess: { _, _  in
                                                                
        }, onError: { _ in
        }, retryAction: { _, _ in
            XCTFail("Expects not to retry")
            return NetworkTaskMock()
        }, dispatchRetry: { _, block in
            block()
        })
        task?.originalTask = taskMock
        
        //When
        task?.suspend()
        
        //Then
        taskMock.progress
    }
}
