//
//  NetworkResponseProcessingTests.swift
//  DBNetworkStack
//
//  Created by Christian Himmelsbach on 20.12.16.
//  Copyright © 2016 DBSystel. All rights reserved.
//

import XCTest
@testable import DBNetworkStack

fileprivate class NetworkResponseProcessor : NetworkResponseProcessing {}

class NetworkResponseProcessingTests: XCTestCase {
    
    var processor: NetworkResponseProcessing!
    
    override func setUp() {
        super.setUp()
        processor = NetworkResponseProcessor()
    }
    
    func testCancelError() {
        // Given
        let request = NetworkRequest(path: "", baseURLKey: "")
        let resource = Resource(request: request, parse: { _ in return 0 })
        let cancelledError = URLError(_nsError: NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled, userInfo: nil))
        
        // When
        var result: Int? = nil
        do {
            result = try processor.process(response: nil, resource: resource, data: nil, error: cancelledError)
        } catch let error as DBNetworkStackError {
            // Then
            switch error {
            case .cancelled: // Excpected
                break
            default:
                XCTFail("Expected cancelled error (got \(error)")
            }
        } catch let error {
            XCTFail("Expected DBNetworkStackError (got \(type(of:error)))")
        }
        
        XCTAssertNil(result, "Expected processing to fail")
    }
    
}
