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

import XCTest
import Foundation
@testable import DBNetworkStack

class ModifyRequestNetworkServiceTest: XCTestCase {
    
    let url: URL! = URL(string: "bahn.de")
    var networkServiceMock: NetworkServiceMock!
    
    override func setUp() {
        super.setUp()
        networkServiceMock = NetworkServiceMock()
    }
    
    func testRequest_withModifedRequest() {
        //Given
        let modification: Array<(URLRequestConvertible) -> URLRequestConvertible> = [ { request in
            return request.appending(queryParameters: ["key": "1"])
            } ]
        let networkService: NetworkService = ModifyRequestNetworkService(networkService: networkServiceMock, requestModifications: modification)
        let request = URLRequest(path: "/trains", baseURL: url)
        let resource = Resource<Int>(request: request, parse: { _ in return 1 })
        
        //When
        networkService.request(resource, onCompletion: { _ in }, onError: { _ in })
        
        //Then
        XCTAssert(networkServiceMock.lastRequest?.asURLRequest().url?.absoluteString.contains("key=1") ?? false)
    }
    
    func testAddHTTPHeaderToRequest() {
        //Given
        let request = URLRequest(url: url)
        let header = ["header": "head"]
        
        //When
        let newRequest = request.added(HTTPHeaderFields: header).asURLRequest()
        
        //Then
        XCTAssertEqual(newRequest.allHTTPHeaderFields?["header"], "head")
    }
    
    func testAddDuplicatedQueryToRequest() {
        //Given
        let url: URL! = URL(string: "bahn.de?test=test&bool=true")
        let request = URLRequest(url: url)
        
        let parameters = ["test": "test2"]
        
        //When
        let newRequest = request.appending(queryParameters: parameters)
        
        //Then
        let newURL: URL! = newRequest.asURLRequest().url
        let query = URLComponents(url: newURL, resolvingAgainstBaseURL: true)?.queryItems
        XCTAssertEqual(query?.count, 2)
        XCTAssert(query?.contains(where: { $0.name == "test" && $0.value == "test2" }) ?? false)
        XCTAssert(query?.contains(where: { $0.name == "bool" && $0.value == "true" }) ?? false)
    }
    
    func testReplaceAllQueryItemsFromRequest() {
        //Given
        let url: URL! = URL(string: "bahn.de?test=test&bool=true")
        let request = URLRequest(url: url)
        
        let parameters = ["test5": "test2"]
        
        //When
        let newRequest = request.replacingAllQueryItems(with: parameters)
        
        //Then
        let newURL: URL! = newRequest.asURLRequest().url
        let query = URLComponents(url: newURL, resolvingAgainstBaseURL: true)?.queryItems
        XCTAssertEqual(query?.count, 1)
        XCTAssert(query?.contains(where: { $0.name == "test5" && $0.value == "test2" }) ?? false)
    }
}
