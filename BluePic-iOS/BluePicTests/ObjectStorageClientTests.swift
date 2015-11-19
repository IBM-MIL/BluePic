//
//  ObjectStorageClientTests.swift
//  BluePic
//
//  Created by Ricardo Olivieri on 11/17/15.
//  Copyright © 2015 MIL. All rights reserved.
//

import XCTest
@testable import BluePic

class ObjectStorageClientTests: XCTestCase {
    
    var objectStorageClient: ObjectStorageClient!
    var xctExpectation:XCTestExpectation?
    
    override func setUp() {
        super.setUp()
        
        // Set up connection properties for Object Storage service on Bluemix
        let password = "***REMOVED***"
        let userId = "***REMOVED***"
        let projectId = "***REMOVED***"
        let authURL = "***REMOVED***"
        let publicURL = "***REMOVED***"
        
        // Init variables for test execution
        objectStorageClient = ObjectStorageClient(userId: userId, password: password, projectId: projectId, authURL: authURL, publicURL: publicURL)
        xctExpectation = self.expectationWithDescription("Asynchronous request about to occur...")
    }
    
    override func tearDown() {
        super.tearDown()
        objectStorageClient = nil
        xctExpectation = nil
    }
    
    func testGetAuthToken() {
        let testName = "testGetAuthToken"
        getAuthToken(testName, onSuccess: {token in
            print("\(testName) succeeded.")
            self.xctExpectation?.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(20.0, handler:nil)
    }
    
    func testCreateContainer() {
        let testName = "testCreateContainer"
        getAuthToken(testName, onSuccess: {token in
            let containerName = "androidContainer"
            self.objectStorageClient.createContainer(containerName, token: token, onSuccess: {
                print("\(testName) succeeded.")
                self.xctExpectation?.fulfill()
                }, onFailure: { (error) in
                    print("\(testName) failed!")
                    print("error: \(error)")
                    XCTFail(error)
                    self.xctExpectation?.fulfill()
            })
        })
        
        self.waitForExpectationsWithTimeout(50.0, handler:nil)
        
    }
    
    /**
     * Convenience method for getting auth token.
     */
    func getAuthToken(testName: String, onSuccess: (token: String) -> Void) {
        objectStorageClient.getAuthToken({(token) in
            print("token: \(token)")
            XCTAssertNotNil(token)
            onSuccess(token: token)
            }, onFailure: {(error) in
                print("\(testName) failed!")
                print("error: \(error)")
                XCTFail(error)
                self.xctExpectation?.fulfill()
        })
    }
    
}
