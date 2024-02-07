//
//  Created by Lukas Schmidt on 27.01.22.
//

import Foundation


/**
 Mocks a `NetworkService`.
 You can configure expected results or errors to have a fully functional mock.

 **Example**:
 ```swift
 //Given
 let networkServiceMock = NetworkServiceMock()
 let resource: Resource<String> = //

 //When
 networkService.request(
    resource,
    onCompletion: { string in /*...*/ },
    onError: { error in /*...*/ }
 )
 networkService.returnSuccess(with: "Sucess")

 //Then
 //Test your expectations

 ```

 It is possible to start multiple requests at a time.
 All requests and responses (or errors) are processed
 in order they have been called. So, everything is serial.

 **Example**:
 ```swift
 //Given
 let networkServiceMock = NetworkServiceMock()
 let resource: Resource<String> = //

 //When
 networkService.request(
    resource,
    onCompletion: { string in /* Success */ },
    onError: { error in /*...*/ }
 )
 networkService.request(
    resource,
    onCompletion: { string in /*...*/ },
    onError: { error in /*. cancel error .*/ }
 )

 networkService.returnSuccess(with: "Sucess")
 networkService.returnError(with: .cancelled)

 //Then
 //Test your expectations

 ```

 - seealso: `NetworkService`
 */
public final class NetworkServiceMock: NetworkService, @unchecked Sendable  {

    /// Count of all started requests
    public var requestCount: Int {
        return lastRequests.count
    }

    /// Last executed request
    public var lastRequest: URLRequest? {
        return lastRequests.last
    }

    /// All executed requests.
    public private(set) var lastRequests: [URLRequest] = []

    private var responses: [Result<(Data, HTTPURLResponse), NetworkError>]
    private let encoder: JSONEncoder

    /// Creates an instace of `NetworkServiceMock`
    public init(
        responses: [Result<(Data, HTTPURLResponse), NetworkError>] = [],
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.encoder = encoder
        self.responses = responses
    }

    /// Creates an instace of `NetworkServiceMock`
    public init<each T: Encodable>(
        _ responses: repeat Result<(each T, HTTPURLResponse), NetworkError>,
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.encoder = encoder
        var encodedResponses: [Result<(Data, HTTPURLResponse), NetworkError>] = []
        repeat (each responses).decode(&encodedResponses, encoder: encoder)
        self.responses = encodedResponses
    }

    /// Creates an instace of `NetworkServiceMock`
    public init<each T: Encodable>(
        _ responses: repeat Result<each T, NetworkError>,
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.encoder = encoder
        var encodedResponses: [Result<(Data, HTTPURLResponse), NetworkError>] = []
        repeat (each responses).decode(&encodedResponses, encoder: encoder)
        self.responses = encodedResponses
    }

    /**
     Fetches a resource asynchronously from remote location. Execution of the requests starts immediately.
     Execution happens on no specific queue. It dependes on the network access which queue is used.
     Once execution is finished either the completion block or the error block gets called.
     You decide on which queue these blocks get executed.

     **Example**:
     ```swift
     let networkService: NetworkService = //
     let resource: Resource<String> = //

     networkService.request(queue: .main, resource: resource, onCompletionWithResponse: { htmlText, response in
     print(htmlText, response)
     }, onError: { error in
     // Handle errors
     })
     ```

     - parameter queue: The `DispatchQueue` to execute the completion and error block on.
     - parameter resource: The resource you want to fetch.
     - parameter onCompletionWithResponse: Callback which gets called when fetching and transforming into model succeeds.
     - parameter onError: Callback which gets called when fetching or transforming fails.

     */
    @MainActor
    public func requestResultWithResponse<Success>(for resource: Resource<Success, NetworkError>) async -> Result<(Success, HTTPURLResponse), NetworkError> {
        lastRequests.append(resource.request)
        if !responses.isEmpty {
            let scheduled = responses.removeFirst()
            switch scheduled {
            case .success((let data, let httpURLResponse)):
                do {
                    let result = try resource.parse(data)
                    return .success((result, httpURLResponse))
                } catch {
                    fatalError("Not able to parse data. Error: \(error)")
                }
            case .failure(let error):
                return .failure(error)
            }
        } else {
            return .failure(.serverError(response: nil, data: nil))
        }
    }

    public func schedule<T: Encodable>(result: Result<(T, HTTPURLResponse), NetworkError>) {
        let scheduled: Result<(Data, HTTPURLResponse), NetworkError>
        switch result {
        case .failure(let error):
            scheduled = .failure(error)
        case .success((let object, let httpUrlResponse)):
            guard let data = try? encoder.encode(object) else {
                fatalError("Not able to encode object")
            }
            scheduled = .success((data, httpUrlResponse))
        }
        responses.append(scheduled)
    }

    public func schedule(success: Void) {
        schedule(result: .success(("", HTTPURLResponse())))
    }

    public func schedule(success: (Void, HTTPURLResponse)) {
        schedule(result: .success(("", success.1)))
    }

    public func schedule<T: Encodable>(success: T) {
        schedule(result: .success((success, HTTPURLResponse())))
    }

    public func schedule<T: Encodable>(success: (T, HTTPURLResponse)) {
        schedule(result: .success(success))
    }

    public func schedule(failure: NetworkError) {
        responses.append(.failure(failure))
    }
}

fileprivate extension Result {

    func decode<T: Encodable>(
        _ array: inout [Result<(Data, HTTPURLResponse), NetworkError>],
        encoder: JSONEncoder
    ) where Success == (T, HTTPURLResponse), Failure == NetworkError {
        array.append(self.map({ (try! encoder.encode($0.0), $0.1) }))
    }

}

fileprivate extension Result where Success: Encodable, Failure == NetworkError {

    func decode(
        _ array: inout [Result<(Data, HTTPURLResponse), NetworkError>],
        encoder: JSONEncoder
    ) {
        let defaultResponse: HTTPURLResponse! = HTTPURLResponse(
            url: URL(staticString: "bahn.de"),
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )
        array.append(self.map({ (try! encoder.encode($0), defaultResponse) }))
    }

}



