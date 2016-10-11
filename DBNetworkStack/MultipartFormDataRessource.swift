//
//  MultipartFormDataRessource.swift
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
//  Created by Christian Himmelsbach on 27.09.16.
//
//
//  DBNetworkStack
//

import Foundation

public struct MultipartFormDataRessource<Model>: MultipartFormDataRessourceModelling {
    public var request: NetworkRequestRepresening
    public var parse: (data: NSData) throws -> Model
    public var encodingMemoryThreshold: UInt64
    public var encodeInMultipartFormData: MultipartFormDataRepresenting -> Void
    
    public init(request: NetworkRequestRepresening, parse: (data: NSData) throws -> Model,
                encodingMemoryThreshold: UInt64, encodeInMultipartFormData: MultipartFormDataRepresenting -> Void) {
        self.request = request
        self.parse = parse
        self.encodingMemoryThreshold = encodingMemoryThreshold
        self.encodeInMultipartFormData = encodeInMultipartFormData
    }
}
