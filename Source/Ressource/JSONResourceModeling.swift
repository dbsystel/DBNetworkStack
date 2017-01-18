//
//  JSONResourceModeling.swift
//
//  Copyright (C) 2016 DB Systel GmbH.
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
//  Created by Lukas Schmidt on 27.07.16.
//

import Foundation
/**
 `JSONResourceModeling` discribes resource which can be parsed from JSON into Model Type.
 
 It speciefies a JSON Container from which the model is parsed and a `parse` function to transform the container into the given Model.
 */
public protocol JSONResourceModeling: ResourceModeling {
    /** 
     The JSON container format represented as an foundation object
     e.g. {} becomes Dictionary<String, AnyObject>, [] becomes Array<Dictionary<String, AnyObject>>
     */
    associatedtype Container
    
    /**
     Parses a JSON container (Dictionary/Array) to a speciefied generic Model
     
     - parameter jsonPayload: the json payload as container (Dictionary/Array)
     
     - returns: The Model
     
     - Throws: If parsing fails
     */
    func parse(_ jsonPayload: Container) throws -> Model
}

extension JSONResourceModeling {
    
    /**
     Parses JSON to a speciefied generic Model
     
     - parameter data: the json payload to parse
     
     - returns: The Model
     
     - Throws: If parsing fails
     */
    func parseFunction(_ data: Data) throws -> Model {
        let container: Container = try parseContainer(data)
        
        return try parse(container)
    }
    
    /**
     Parses JSON to speciefied generic Container
     
     - parameter data: the json payload to parse
     
     - returns: The container
     
     - Throws: If parsing fails
     */
    fileprivate func parseContainer<Container>(_ data: Data) throws -> Container {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        guard let container = jsonObject as? Container else {
            let userInfo =  ["error": "Expected container of type: \(Container.self), but got \(type(of: (jsonObject)))"]
            throw NSError(domain: "Parsing Error", code: 0, userInfo: userInfo)
        }
        
        return container
    }
}
