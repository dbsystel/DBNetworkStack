//
//  JSONRessourceModeling.swift
//  DBNetworkStack
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
//  Created by Lukas Schmidt on 27.07.16.
//

import Foundation
/**
 `JSONRessourceModeling` discribes ressource which can be parsed from JSON into Model Type.
 
 It speciefies a JSON Container from which the model is parsed and a `parse` function to transform the container into the given Model.
 */
public protocol JSONRessourceModeling: RessourceModeling {
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
    func parse(jsonPayload: Container) throws -> Model
}

extension JSONRessourceModeling {
    
    /**
     Parses JSON to a speciefied generic Model
     
     - parameter data: the json payload to parse
     
     - returns: The Model
     
     - Throws: If parsing fails
     */
    func parseFunction(data: NSData) throws -> Model {
        let container: Container = try parseContainer(data)
        
        return try parse(container)
    }
    
    /**
     Parses JSON to speciefied generic Container
     
     - parameter data: the json payload to parse
     
     - returns: The container
     
     - Throws: If parsing fails
     */
    private func parseContainer<Container>(data: NSData) throws -> Container {
        guard let container = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? Container else {
            throw NSError(domain: "Invalid JSON Container Type", code: 0, userInfo: nil)
        }
        
        return container
    }
}
