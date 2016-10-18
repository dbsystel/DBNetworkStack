//
//  MulitpartFormDataRepresentingMock.swift
//  DBNetworkStack
//
//  Created by Lukas Schmidt on 04.10.16.
//  Copyright © 2016 DBSystel. All rights reserved.
//

import Foundation
import DBNetworkStack

open class MulitpartFormDataRepresentingMock: MultipartFormDataRepresenting {
    open var contentType: String = "multipart/form-data"
    open var contentLength: UInt64 = 128
    open var boundary: String = ""
    
    open func appendBodyPart(data: Data, name: String) {
        
    }
    
    open func appendBodyPart(data: Data, name: String, mimeType: String) {
        
    }
    
    open func appendBodyPart(fileURL: URL, name: String, fileName: String, mimeType: String) {
        
    }
    
    open func appendBodyPart(fileURL: URL, name: String) {
        
    }
    
    open func appendBodyPart(data: Data, name: String, fileName: String, mimeType: String) {
    }
    
    open func appendBodyPart(stream: InputStream, length: UInt64, headers: [String : String]) {
        
    }
    
    open func appendBodyPart(stream: InputStream, length: UInt64, name: String, fileName: String, mimeType: String) {
        
    }
    
    open func encode() throws -> Data {
        return Data()
    }
    
    open func writeEncodedDataToDisk(_ fileURL: URL) throws {
        
    }
}
