//
//  MultipartFormDataRepresenting.swift
//
//  Copyright (c) 2014-2016 Alamofire Software Foundation (http://alamofire.org/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
import Foundation

/// Constructs `multipart/form-data` for uploads within an HTTP or HTTPS body. There are currently two ways to encode
/// multipart form data. The first way is to encode the data directly in memory. This is very efficient, but can lead
/// to memory issues if the dataset is too large. The second way is designed for larger datasets and will write all the
/// data to a single file on disk with all the proper boundary segmentation. The second approach MUST be used for
/// larger datasets such as video content, otherwise your app may run out of memory when trying to encode the dataset.
///
/// For more information on `multipart/form-data` in general, please refer to the RFC-2388 and RFC-2045 specs as well
/// and the w3 form documentation.
///
/// - https://www.ietf.org/rfc/rfc2388.txt
/// - https://www.ietf.org/rfc/rfc2045.txt
/// - https://www.w3.org/TR/html401/interact/forms.html#h-17.13
protocol MultipartFormDataRepresenting: class {
    
    // MARK: - Properties
    
    /// The `Content-Type` header value containing the boundary used to generate the `multipart/form-data`.
    var contentType: String { get }
    
    /// The content length of all body parts used to generate the `multipart/form-data` not including the boundaries.
    var contentLength: UInt64 { get }
    
    /// The boundary used to separate the body parts in the encoded form data.
    var boundary: String { get }
    
    // MARK: - Body Parts
    
    /**
     Creates a body part from the data and appends it to the multipart form data object.
     
     The body part data will be encoded using the following format:
     
     - `Content-Disposition: form-data; name=#{name}` (HTTP Header)
     - Encoded data
     - Multipart form boundary
     
     - parameter data: The data to encode into the multipart form data.
     - parameter name: The name to associate with the data in the `Content-Disposition` HTTP header.
     */
    func appendBodyPart(data: Data, name: String)
    
    /**
     Creates a body part from the data and appends it to the multipart form data object.
     
     The body part data will be encoded using the following format:
     
     - `Content-Disposition: form-data; name=#{name}` (HTTP Header)
     - `Content-Type: #{generated mimeType}` (HTTP Header)
     - Encoded data
     - Multipart form boundary
     
     - parameter data:     The data to encode into the multipart form data.
     - parameter name:     The name to associate with the data in the `Content-Disposition` HTTP header.
     - parameter mimeType: The MIME type to associate with the data content type in the `Content-Type` HTTP header.
     */
    func appendBodyPart(data: Data, name: String, mimeType: String)
    
    /**
     Creates a body part from the data and appends it to the multipart form data object.
     
     The body part data will be encoded using the following format:
     
     - `Content-Disposition: form-data; name=#{name}; filename=#{filename}` (HTTP Header)
     - `Content-Type: #{mimeType}` (HTTP Header)
     - Encoded file data
     - Multipart form boundary
     
     - parameter data:     The data to encode into the multipart form data.
     - parameter name:     The name to associate with the data in the `Content-Disposition` HTTP header.
     - parameter fileName: The filename to associate with the data in the `Content-Disposition` HTTP header.
     - parameter mimeType: The MIME type to associate with the data in the `Content-Type` HTTP header.
     */
    func appendBodyPart(data: Data, name: String, fileName: String, mimeType: String)
    
    /**
     Creates a body part from the file and appends it to the multipart form data object.
     
     The body part data will be encoded using the following format:
     
     - `Content-Disposition: form-data; name=#{name}; filename=#{generated filename}` (HTTP Header)
     - `Content-Type: #{generated mimeType}` (HTTP Header)
     - Encoded file data
     - Multipart form boundary
     
     The filename in the `Content-Disposition` HTTP header is generated from the last path component of the
     `fileURL`. The `Content-Type` HTTP header MIME type is generated by mapping the `fileURL` extension to the
     system associated MIME type.
     
     - parameter fileURL: The URL of the file whose content will be encoded into the multipart form data.
     - parameter name:    The name to associate with the file content in the `Content-Disposition` HTTP header.
     */
    func appendBodyPart(fileURL: URL, name: String)
    
    /**
     Creates a body part from the file and appends it to the multipart form data object.
     
     The body part data will be encoded using the following format:
     
     - Content-Disposition: form-data; name=#{name}; filename=#{filename} (HTTP Header)
     - Content-Type: #{mimeType} (HTTP Header)
     - Encoded file data
     - Multipart form boundary
     
     - parameter fileURL:  The URL of the file whose content will be encoded into the multipart form data.
     - parameter name:     The name to associate with the file content in the `Content-Disposition` HTTP header.
     - parameter fileName: The filename to associate with the file content in the `Content-Disposition` HTTP header.
     - parameter mimeType: The MIME type to associate with the file content in the `Content-Type` HTTP header.
     */
    func appendBodyPart(fileURL: URL, name: String, fileName: String, mimeType: String)
    
    /**
     Creates a body part from the stream and appends it to the multipart form data object.
     
     The body part data will be encoded using the following format:
     
     - `Content-Disposition: form-data; name=#{name}; filename=#{filename}` (HTTP Header)
     - `Content-Type: #{mimeType}` (HTTP Header)
     - Encoded stream data
     - Multipart form boundary
     
     - parameter stream:   The input stream to encode in the multipart form data.
     - parameter length:   The content length of the stream.
     - parameter name:     The name to associate with the stream content in the `Content-Disposition` HTTP header.
     - parameter fileName: The filename to associate with the stream content in the `Content-Disposition` HTTP header.
     - parameter mimeType: The MIME type to associate with the stream content in the `Content-Type` HTTP header.
     */
    func appendBodyPart(
        stream: InputStream,
               length: UInt64,
               name: String,
               fileName: String,
               mimeType: String)
    
    /**
     Creates a body part with the headers, stream and length and appends it to the multipart form data object.
     
     The body part data will be encoded using the following format:
     
     - HTTP headers
     - Encoded stream data
     - Multipart form boundary
     
     - parameter stream:  The input stream to encode in the multipart form data.
     - parameter length:  The content length of the stream.
     - parameter headers: The HTTP headers for the body part.
     */
    func appendBodyPart(stream: InputStream, length: UInt64, headers: [String: String])
    
    // MARK: - Data Encoding
    
    /**
     Encodes all the appended body parts into a single `NSData` object.
     
     It is important to note that this method will load all the appended body parts into memory all at the same
     time. This method should only be used when the encoded data will have a small memory footprint. For large data
     cases, please use the `writeEncodedDataToDisk(fileURL:completionHandler:)` method.
     
     - throws: An `NSError` if encoding encounters an error.
     
     - returns: The encoded `NSData` if encoding is successful.
     */
    func encode() throws -> Data
    
    /**
     Writes the appended body parts into the given file URL.
     
     This process is facilitated by reading and writing with input and output streams, respectively. Thus,
     this approach is very memory efficient and should be used for large body part data.
     
     - parameter fileURL: The file URL to write the multipart form data into.
     
     - throws: An `NSError` if encoding encounters an error.
     */
    func writeEncodedDataToDisk(_ fileURL: URL) throws
    
}
