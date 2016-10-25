//
//  MulitpartFormDataRepresentingMock.swift
//  DBNetworkStack
//
//  Created by Lukas Schmidt on 04.10.16.
//  Copyright © 2016 DBSystel. All rights reserved.
//

import Foundation
@testable import DBNetworkStack

class MulitpartFormDataRepresentingMock: MultipartFormDataRepresenting {
    var contentType: String = "multipart/form-data"
    var contentLength: UInt64 = 128
    var boundary: String = ""
    
    func appendBodyPart(data data: NSData, name: String) {
        
    }
    
    func appendBodyPart(data data: NSData, name: String, mimeType: String) {
        
    }
    
    func appendBodyPart(fileURL fileURL: NSURL, name: String, fileName: String, mimeType: String) {
        
    }
    
    func appendBodyPart(fileURL fileURL: NSURL, name: String) {
        
    }
    
    func appendBodyPart(data data: NSData, name: String, fileName: String, mimeType: String) {
    }
    
    func appendBodyPart(stream stream: NSInputStream, length: UInt64, headers: [String : String]) {
        
    }
    
    func appendBodyPart(stream stream: NSInputStream, length: UInt64, name: String, fileName: String, mimeType: String) {
        
    }
    
    func encode() throws -> NSData {
        return NSData()
    }
    
    func writeEncodedDataToDisk(fileURL: NSURL) throws {
        
    }
}
