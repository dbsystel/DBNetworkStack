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
    
    
    func appendBodyPart(data data: Data, name: String) {
        
    }
    
    func appendBodyPart(data data: Data, name: String, mimeType: String) {
        
    }
    
    func appendBodyPart(fileURL fileURL: URL, name: String, fileName: String, mimeType: String) {
        
    }
    
    func appendBodyPart(fileURL fileURL: URL, name: String) {
        
    }
    
    func appendBodyPart(data data: Data, name: String, fileName: String, mimeType: String) {
    }
    
    func appendBodyPart(stream stream: InputStream, length: UInt64, headers: [String : String]) {
        
    }
    
    func appendBodyPart(stream stream: InputStream, length: UInt64, name: String, fileName: String, mimeType: String) {
        
    }
    
    func encode() throws -> Data {
        return Data()
    }
    
    func writeEncodedDataToDisk(_ fileURL: URL) throws {
        
    }
}
