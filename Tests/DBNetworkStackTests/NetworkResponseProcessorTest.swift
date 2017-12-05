//
//  Copyright (C) 2016 DB Systel GmbH.
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

import XCTest
@testable import DBNetworkStack

class NetworkResponseProcessingTests: XCTestCase {
    
    var processor: NetworkResponseProcessor!
    
    override func setUp() {
        super.setUp()
        processor = NetworkResponseProcessor()
    }
    
    func testCancelError() {
        // Given
        let resource = Resource(request: URLRequest.defaultMock, parse: { _ in return 0 })
        let cancelledError = URLError(_nsError: NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled, userInfo: nil))
        
        // When
        var result: Int? = nil
        do {
            result = try processor.process(response: nil, resource: resource, data: nil, error: cancelledError)
        } catch let error as NetworkError {
            // Then
            switch error {
            case .cancelled: // Excpected
                break
            default:
                XCTFail("Expected cancelled error (got \(error)")
            }
        } catch let error {
            XCTFail("Expected NetworkError (got \(type(of:error)))")
        }
        
        XCTAssertNil(result, "Expected processing to fail")
    }
    
    struct UnknownError: Error {}
    
    func testParseThrowsUnknownError() {
        // Given
        let resource = Resource(request: URLRequest.defaultMock, parse: { _  -> Int in
            throw NetworkError.unknownError })
        let data: Data! = "Data".data(using: .utf8)
        
        // When
        do {
            _ = try processor.process(response: .defaultMock, resource: resource, data: data, error: nil)
        } catch let error as NetworkError {
            // Then
            switch error {
            case .serializationError(let error, let recievedData): // Excpected
                switch error as? NetworkError {
                case .unknownError?:
                    XCTAssert(true)
                default:
                    XCTFail("Expects unknownError")
                }
                
                XCTAssertEqual(recievedData, data)
                break
            default:
                XCTFail("Expected cancelled error (got \(error)")
            }
        } catch let error {
            XCTFail("Expected NetworkError (got \(type(of:error)))")
        }
    }
    
    func testParseSucessFullWithNilResponse() {
        //Given
        let resource = Resource(request: URLRequest.defaultMock, parse: { _ in return 0 })
        
        //When
        do {
            _ = try processor.process(response: nil, resource: resource, data: Data(), error: nil)
        } catch let error as NetworkError {
            // Then
            switch error {
            case .unknownError: // Excpected
                break
            default:
                XCTFail("Expected cancelled error (got \(error)")
            }
        } catch let error {
            XCTFail("Expected NetworkError (got \(type(of:error)))")
        }
        
    }
}
