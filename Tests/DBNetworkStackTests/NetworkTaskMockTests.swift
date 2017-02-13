//
//  NetworkTaskMockTests.swift
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
//  Created by Lukas Schmidt on 07.02.17.
//

import XCTest
import DBNetworkStack

class NetworkTaskMockTests: XCTestCase {
    
    func testCancled() {
        //Given
        let task = NetworkTaskMock()
        
        //When
        task.cancel()
        
        //Then
        XCTAssertEqual(task.state, .canceled)
    }
    
    func testResumed() {
        //Given
        let task = NetworkTaskMock()
        
        //When
        task.resume()
        
        //Then
        XCTAssertEqual(task.state, .resumed)
    }
    
    func testSuspended() {
        //Given
        let task = NetworkTaskMock()
        
        //When
        task.suspend()
        
        //Then
        XCTAssertEqual(task.state, .suspended)
    }
}
