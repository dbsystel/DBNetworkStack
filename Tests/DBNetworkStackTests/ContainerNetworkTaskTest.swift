//
//  Created by Christian Himmelsbach on 23.07.18.
//

import XCTest
import DBNetworkStack

class ContainerNetworkTaskTest: XCTestCase {
    
    func testGIVEN_AuthenticatorNetworkTask_WHEN_ResumeTask_THEN_UnderlyingTaskShouldBeResumed() {
        //Given
        let taskMock = NetworkTaskMock()
        let task = ContainerNetworkTask()
        task.underlyingTask = taskMock
        
        //When
        task.resume()
        
        //Then
        XCTAssert(taskMock.state == .resumed)
    }
    
    func testGIVEN_AuthenticatorNetworkTask_WHEN_SuspendTask_THEN_UnderlyingTaskShouldBeSuspened() {
        //Given
        let taskMock = NetworkTaskMock()
        let task = ContainerNetworkTask()
        task.underlyingTask = taskMock
        
        //When
        task.suspend()
        
        //Then
        XCTAssert(taskMock.state == .suspended)
    }
    
    func testGIVEN_AuthenticatorNetworkTask_WHEN_CancelTask_THEN_UnderlyingTaskShouldBeCanceled() {
        // Given
        let taskMock = NetworkTaskMock()
        let task = ContainerNetworkTask()
        task.underlyingTask = taskMock
        
        // When
        task.cancel()
        
        // Then
        XCTAssert(taskMock.state == .canceled)
    }
    
    func testGIVEN_AuthenticatorNetworkTask_WHEN_getProgress_THEN_UnderlyingTaskShouldBeCanceled() {
        // Given
        let taskMock = NetworkTaskMock()
        let task = ContainerNetworkTask()
        task.underlyingTask = taskMock
        
        // When/Then
        _ = taskMock.progress
    }
}
