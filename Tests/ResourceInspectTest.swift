//
//  Copyright (C) DB Systel GmbH.
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
import DBNetworkStack

final class ResourceInspectTest: XCTestCase {
    func testInspect() {
        //Given
        let data = Data()
        let capturedParsingData = Container<Data?>(nil)
        let capturedInspectedData = Container<Data?>(nil)

        let resource = Resource<Int, NetworkError>(request: URLRequest.defaultMock, parse: { data in
            capturedParsingData.setValue(data)
            return 1
        })
        
        //When
        let inspectedResource = resource.inspectData({ data in
            capturedInspectedData.setValue(data)
        })
        let result = try? inspectedResource.parse(data)

        //Then
        XCTAssertNotNil(result)
        XCTAssertEqual(capturedParsingData.getValue(), capturedInspectedData.getValue())
        XCTAssertEqual(data, capturedInspectedData.getValue())
        XCTAssertEqual(capturedParsingData.getValue(), data)
    }
}

private class Container<T> {
    private var value: T

    init(_ value: T) {
        self.value = value
    }

    /// caller should manage concurrent access to its own state
    func setValue(_ newValue: T) {
        value = newValue
    }

    /// caller should manage concurrent access to its own state
    func getValue() -> T {
        value
    }
}
