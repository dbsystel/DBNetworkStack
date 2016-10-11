//
//  MulitpartFormDataRepresentingMock.swift
//  DBNetworkStack
//
//  Created by Lukas Schmidt on 04.10.16.
//  Copyright © 2016 DBSystel. All rights reserved.
//

import Foundation
import DBNetworkStack

public class MulitpartFormDataRepresentingMock: MultipartFormDataRepresenting {
    public var contentType: String = "multipart/form-data"
    public var contentLength: UInt64 = 128
    public var boundary: String = ""
    
    public func appendBodyPart(data data: NSData, name: String) {
        
    }
    
    public func appendBodyPart(data data: NSData, name: String, mimeType: String) {
        
    }
    
    public func appendBodyPart(fileURL fileURL: NSURL, name: String, fileName: String, mimeType: String) {
        
    }
    
    public func appendBodyPart(fileURL fileURL: NSURL, name: String) {
        
    }
    
    public func appendBodyPart(data data: NSData, name: String, fileName: String, mimeType: String) {
    }
    
    public func appendBodyPart(stream stream: NSInputStream, length: UInt64, headers: [String : String]) {
        
    }
    
    public func appendBodyPart(stream stream: NSInputStream, length: UInt64, name: String, fileName: String, mimeType: String) {
        
    }
    
    public func encode() throws -> NSData {
        return NSData()
    }
    
    public func writeEncodedDataToDisk(fileURL: NSURL) throws {
        
    }
}
