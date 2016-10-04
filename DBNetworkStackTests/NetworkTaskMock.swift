//
//  NetworkTaskMock.swift
//  DBNetworkStack
//
//  Created by Christian Himmelsbach on 29.09.16.
//  Copyright © 2016 DBSystel. All rights reserved.
//

import Foundation
import DBNetworkStack

class NetworkTaskMock: NetworkTask {
    var isCanceld = false
    func cancel() {
        isCanceld = true
    }
    
    func resume() {
        
    }
    
    func suspend() {
        
    }
    
    var progress: NSProgress {
        return NSProgress()
    }
}
