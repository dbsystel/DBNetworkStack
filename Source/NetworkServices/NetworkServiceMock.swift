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
public final actor NetworkServiceMock: NetworkService {

    public enum Error: Swift.Error, CustomDebugStringConvertible {
        case missingRequest
        case typeMismatch

        public var debugDescription: String {
            switch self {
            case .missingRequest:
                return "Could not return because no request"
            case .typeMismatch:
                return "Return type does not match requested type"
            }
        }
    }

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

    private var scheduledResponses: [Result<(Data, HTTPURLResponse), NetworkError>]

    private let encoder: JSONEncoder

    /// Creates an instace of `NetworkServiceMock`
    public init(
        scheduledResponses: [Result<(Data, HTTPURLResponse), NetworkError>] = [],
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.encoder = encoder
        self.scheduledResponses = scheduledResponses
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
    public func requestResultWithResponse<Success>(for resource: Resource<Success>) async -> Result<(Success, HTTPURLResponse), NetworkError> {
        lastRequests.append(resource.request)
        if !scheduledResponses.isEmpty {
            let scheduled = scheduledResponses.removeFirst()
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
            print(String(data: data, encoding: .utf8))
            scheduled = .success((data, httpUrlResponse))
        }
        scheduledResponses.append(scheduled)
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
        scheduledResponses.append(.failure(failure))
    }
}
