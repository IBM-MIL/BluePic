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
    let containerName = "olivieri-container"
    
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
    
    func testAuthenticate() {
        let testName = "testAuthenticate"
        authenticate(testName, onSuccess: {
            print("\(testName) succeeded.")
            self.xctExpectation?.fulfill()
        })
        self.waitForExpectationsWithTimeout(20.0, handler:nil)
    }
    
    func testCreateContainer() {
        let testName = "testCreateContainer"
        authenticate(testName, onSuccess: {
            self.objectStorageClient.createContainer(self.containerName, onSuccess: {
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
    
    func testUploadImage() {
        let testName = "testUploadImage"
        authenticate(testName, onSuccess: {
            let imageName = "the-image.jpeg"
            let image = UIImage(named : "hatch-logo")
            self.objectStorageClient.uploadImage(self.containerName, imageName: imageName, image: image!, onSuccess: {
                print("\(testName) succeeded.")
                self.xctExpectation?.fulfill()
                }, onFailure: { (error) in
                    print("\(testName) failed!")
                    print("error: \(error)")
                    XCTFail(error)
                    self.xctExpectation?.fulfill()
            })
        })
        self.waitForExpectationsWithTimeout(50.0, handler:nil)    }
    
    /**
     * Convenience method for authenticating.
     */
    func authenticate(testName: String, onSuccess: () -> Void) {
        objectStorageClient.authenticate({() in
            onSuccess()
            }, onFailure: {(error) in
                print("\(testName) failed!")
                print("error: \(error)")
                XCTFail(error)
                self.xctExpectation?.fulfill()
        })
    }
    
}
