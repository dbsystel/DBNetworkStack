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
import DBNetworkStack

struct Train: Decodable, Equatable {
    let name: String
}

extension Train {
    static var validJSONData: Data! {
        return "{ \"name\": \"ICE\"}".data(using: .utf8)
    }
    
    static var invalidJSONData: Data! {
        return "{ name: \"ICE\"}".data(using: .utf8)
    }
    
    static var JSONDataWithInvalidKey: Data! {
        return "{ \"namee\": \"ICE\"}".data(using: .utf8)
    }
    
    static var validJSONArrayData: Data! {
        return "[{ \"name\": \"ICE\"}, { \"name\": \"IC\"}, { \"name\": \"TGV\"}]".data(using: .utf8)
    }
}
