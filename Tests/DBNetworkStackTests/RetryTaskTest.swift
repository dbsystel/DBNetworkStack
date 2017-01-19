//
//  RetryTaskTest.swift
//  BFACore
//
//	Legal Notice! DB Systel GmbH proprietary License!
//
//	Copyright (C) 2015 DB Systel GmbH
//	DB Systel GmbH; Jürgen-Ponto-Platz 1; D-60329 Frankfurt am Main; Germany; http://www.dbsystel.de/

//	This code is protected by copyright law and is the exclusive property of
//	DB Systel GmbH; Jürgen-Ponto-Platz 1; D-60329 Frankfurt am Main; Germany; http://www.dbsystel.de/

//	Consent to use ("licence") shall be granted solely on the basis of a
//	written licence agreement signed by the customer and DB Systel GmbH. Any
//	other use, in particular copying, redistribution, publication or
//	modification of this code without written permission of DB Systel GmbH is
//	expressly prohibited.

//	In the event of any permitted copying, redistribution or publication of
//	this code, no changes in or deletion of author attribution, trademark
//	legend or copyright notice shall be made.
//
//  Created by Lukas Schmidt on 30.11.16.
//

import Foundation
import XCTest
@testable import DBNetworkStack

class RetryTaskTest: XCTestCase {
    
    let mockError: DBNetworkStackError = .unknownError
    
    func testDontHoldReference_withoutCreatingErrorClosure() {
        //Given
        var task: RetryNetworkTask<Int>? = RetryNetworkTask(maxmimumNumberOfRetries: 1, idleTimeInterval: 1,
            shouldRetry: { _ in return true}, onSuccess: { _ in }, onError: { _ in }, retryAction: { _, _ in
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
                                                            shouldRetry: { err in return true}, onSuccess: { (t: Int) in
            successValue = t
        }, onError: { err in
        }, retryAction: {sucess, _ in
            sucess(0)
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
                                                            shouldRetry: { _ in return true}, onSuccess: { (_: Int) in
        }, onError: { _ in
        }, retryAction: {success, error in
            numerOfRertrys += 1
            if numerOfRertrys == 3 {
                success(0)
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
                                                            shouldRetry: { _ in return true}, onSuccess: { (_: Int) in
        }, onError: { _ in
        }, retryAction: {a, b in
            numerOfRertrys += 1
            if numerOfRertrys == 3 {
                a(0)
            } else {
                b(self.mockError)
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
        var error: DBNetworkStackError?
        var task: RetryNetworkTask<Int>? = RetryNetworkTask(maxmimumNumberOfRetries: 3, idleTimeInterval: 0.3,
                                                            shouldRetry: { err in return false}, onSuccess: { _ in
            
        }, onError: { err in
            error = err
        }, retryAction: { _, _ in
            XCTFail()
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
        XCTAssertNotNil(error)
    }
}
